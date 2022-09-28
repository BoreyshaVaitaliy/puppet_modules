#!/bin/bash

APTCOMMAND=/usr/bin/aptitude
AWK=/usr/bin/awk
CAT=/bin/cat
EGREP=/bin/egrep
ECHO=/bin/echo
GREP=/bin/grep
INFOCLIENT=/linuxcash/cash/bin/InfoClient
RM=/bin/rm
TOUCH=/usr/bin/touch
TR=/usr/bin/tr
TRUE=/bin/true
SLEEP=/bin/sleep

APTARG="-y -d -o DPkg::Options::=--force-confold"
CONFIGPATH=/linuxcash/cash/data/tmp/upgrade45to46
CONFIGFILE=/linuxcash/cash/conf/artix-upgrade.conf
DEFINEFILE=/linuxcash/cash/bin/artix-upgrade.def
DOWNLOAD_LIMIT=25
LOGFILE=/linuxcash/logs/current/artix-upgrade.log
IMMEDIATE=
OPTIONS=
PKG_LIST=/linuxcash/cash/conf/artix-packages.list
RUNSLEEP=240
SUDO=
NOTOFY_FILE=/linuxcash/cash/data/tmp/notification.json
PID_FILE=/var/run/artix-upgrade.pid

. $DEFINEFILE

UPGRADE_LIST=/tmp/artix-upgrade.list

if [ -f $CONFIGFILE ] ; then
    . $CONFIGFILE
fi

function tryupgrade() {
    setstatus UPGRADE_DOWNLOAD
    DONWLOAD_COMMAND=$1
    TARGETS=$2
    SUCCESS=1
    TIME=3
    CACHE_DIR=/var/cache/apt/archives

    log_info "Запрос [${DONWLOAD_COMMAND}]"
    for i in 1 2 3 4 5 ; do
        log_info "Попытка $i..."
        if $DONWLOAD_COMMAND ; then
            SUCCESS=0
            ITEMS=`python artix-upgrade.py $TARGETS`
            log_info "Проверяем наличие в кэше: [$ITEMS]"
            for ITEM in $ITEMS ; do
                PACKAGE=$(echo $ITEM | sed -e 's/:/%3a/')
                if ! ls $CACHE_DIR/$PACKAGE* >/dev/null 2>&1 ; then
                    log_info "Отсутствует пакет $PACKAGE"
                    SUCCESS=1
                    break
                fi
            done
        fi
        if [ "$SUCCESS" = "0" ] ; then
            log_info "Выполнено успешно!"
            break
        fi
        log_info "Ошибка, повторная попытка будет выполнена через ${TIME} мин."
        $SLEEP "${TIME}m"
    done
    return $SUCCESS
}

function atexit() {
    RESCODE=$?
    [ "$RESCODE" != "0" ] && setstatus EXECUTE_ERROR
    $GREP -q $$ $PID_FILE && $SUDO $RM -vf $PID_FILE $UPGRADE_LIST
    exit $RESCODE
}

trap atexit 0 1 2 5 15

TEMP=`/usr/bin/getopt -o il:r:st:v --long immediate,dl-limit:,result:,sudo,timeout:,verbose -- "$@"`
if [ $? != 0 ] ; then /bin/echo "Terminating..." >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"
while /bin/true ; do
    case "$1" in
        -i|--immediate) IMMEDIATE="yes" ; shift ;;
        -l|--dl-limit) DOWNLOAD_LIMIT=$2 ; shift 2 ;;
        -r|--result) RESULT=$2 ; shift 2 ;;
        -s|--sudo) SUDO="/usr/bin/sudo -E" ; shift ;;
        -t|--timeout) RUNSLEEP=$2 ; shift 2 ;;
        --) shift ; break ;;
        *) /bin/echo "Internal error!" ; exit 1 ;;
    esac
done

if pgrep aptitude >>/dev/null || ( test -e $PID_FILE && ps -p $(cat $PID_FILE) >>/dev/null ) ; then
    log_info "Обновление выполняется другим процессом"
    exit 0
fi
echo -n $$ >$PID_FILE

if [ -e $PKG_DOWNLOAD ] ; then 
    [ -e $PKG_INSTALL_LOCK ] && setstatus UPGRADE_AVAILABLE_LOCK || setstatus UPGRADE_AVAILABLE
    exit 0
fi

# Random sleep time before run
if [ -z $IMMEDIATE ] ; then
    RANDOM=$(/bin/dd if=/dev/urandom count=1 2> /dev/null | /usr/bin/cksum | /usr/bin/cut -c"1-5")
    TIME=$(($RANDOM % $RUNSLEEP))

    log_info "Процесс загрузки обновлений отложен на ${TIME} мин."
#    setstatus UPGRADE_WAIT
    $SLEEP "${TIME}m"
fi

# Для aptitude устанавливаем английский язык.
export LANG=en_US.UTF-8

log_info "Запуск процесса загрузки обновлений"

$SUDO $APTCOMMAND autoclean
[ ! -z $DOWNLOAD_LIMIT ] && OPTIONS="-o Acquire::http::Dl-Limit=$DOWNLOAD_LIMIT"
UPGRADE_AVAILABLE=

if [ -d $CONFIGPATH ] ; then
    cd $CONFIGPATH && find . -depth | cpio -pvdmu /
    rm -rf $CONFIGPATH/*
fi
log_info "Обновление индексных файлов"
$SUDO $APTCOMMAND update || setstatus INDEX_ERROR EXIT

log_info "Установка новых пакетов..."
$SUDO $RM -f $PKG_INSTALL_LIST
# Создаем новый список пакетов -> artix-packages.instlist
$CAT $PKG_LIST | $EGREP -v '^[[:space:]]*#' | $AWK -F '#' '{print $1}' | $TR -d ' ' > $PKG_INSTALL_LIST
# Если есть список с версиями artix-packages.version
if [ -f $PKG_VERSION ] ; then
    PACKAGES_TEMP=`$CAT $PKG_INSTALL_LIST`
    $SUDO $RM -f $PKG_INSTALL_LIST
    for NAME in $PACKAGES_TEMP ; do
        $GREP "$NAME=" $PKG_VERSION >> $PKG_INSTALL_LIST
    done
fi
PACKAGES=`$CAT $PKG_INSTALL_LIST`
$SUDO $APTCOMMAND -y --simulate install $PACKAGES 2>&1 >$UPGRADE_LIST || setstatus DOWNLOAD_ERROR EXIT
if $GREP 'The following NEW packages will be installed' $UPGRADE_LIST >/dev/null || $GREP 'The following packages will be upgraded' $UPGRADE_LIST >/dev/null || $GREP 'Downgrade the following packages' $UPGRADE_LIST >/dev/null || $GREP 'The following packages will be DOWNGRADED' $UPGRADE_LIST >/dev/null ; then
    tryupgrade "$SUDO $VISUAL $APTCOMMAND $APTARG $OPTIONS install $PACKAGES" $UPGRADE_LIST && UPGRADE_AVAILABLE="YES" || $TRUE
    [ -z $UPGRADE_AVAILABLE ] && setstatus DOWNLOAD_ERROR EXIT
fi

$SUDO $RM -fv $PKG_INSTALL
if [ ! -z $UPGRADE_AVAILABLE ] ; then
    $TOUCH $PKG_DOWNLOAD
    if [ ! -e $PKG_INSTALL_LOCK ] ; then
        setstatus UPGRADE_AVAILABLE
        if [ -x /linuxcash/cash/bin/artix-gui ] || [ -x /linuxcash/cash/bin/artix-sco ] ; then
            echo '{"message":"Доступны обновления", "action": "restart"}' > $NOTOFY_FILE.tmp
            mv $NOTOFY_FILE.tmp $NOTOFY_FILE
        else
            [ -x $INFOCLIENT ] && $INFOCLIENT --encoding="UTF-8" --set-alert="Доступны обновления" || $TRUE
        fi
    else
        setstatus UPGRADE_AVAILABLE_LOCK
    fi
else
    setstatus UPGRADE_INSTALLED
fi
