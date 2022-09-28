#!/bin/bash

DELAY=3300
IMMEDIATE=
SUDO=
VERBOSE=

TEMP=`/usr/bin/getopt -o d:ir:sv --long delay:,immediate,result:,sudo,verbose -- "$@"`
if [ $? != 0 ] ; then /bin/echo "Terminating..." >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"
while /bin/true ; do
    case "$1" in
        -d|--delay) DELAY=$2 ; shift 2 ;;
        -i|--immediate) IMMEDIATE=YES ; shift ;;
        -s|--sudo) SUDO="/usr/bin/sudo -E" ; shift ;;
        -v|--verbose) VERBOSE="--no-daemonize -v" ; shift ;;
        --) shift ; break ;;
        *) /bin/echo "Internal error!" ; exit 1 ;;
    esac
done

# Random sleep time before run
if [ -z $IMMEDIATE ] ; then
    RANDOM=$(/bin/dd if=/dev/urandom count=1 2> /dev/null | /usr/bin/cksum | /usr/bin/cut -c"1-5")
    TIME=$(($RANDOM % $DELAY))
    echo "$(date) ***** SLEEP: ${TIME} seconds"
    /bin/sleep "${TIME}"
fi

if [ -x /usr/sbin/puppetd ] ; then
    echo "$(date) ***** START!"
    $SUDO /usr/sbin/puppetd --no-splay --onetime $VERBOSE
elif [ -x /usr/bin/puppet ] ; then
    echo "$(date) ***** START!"
    $SUDO /usr/bin/puppet agent --test --no-splay --onetime $VERBOSE
else
    echo "Не установлен клиент для сервера управления конфигурацией"
fi
