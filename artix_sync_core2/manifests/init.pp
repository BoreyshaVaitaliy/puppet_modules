#
# = Класс: artix_sync_core2
#
# Класс для конфигурирования агента кассового сервера Артикс версии 2.1.
#
#
# == Параметры
#
# [*enable*]
#   Параметр указывает необходимость использования агент кассового сервера.
#
#   Значение по молчанию: 'true'
#
# [*max_count_backup_files*]
#   Максимальное количество файлов бэкапов, которые хранятся на кассе.
#
#   Значение по умолчанию: 30
#
# [*actual_count_days_for_backup_files*]
#   Количество дней в течении которых хранятся файлы бэкапов.
#
#   Значение по умолчанию: 30
#
# [*queue_file_size*]
#   Настройки queue_file_size и queue_file_count задают размер и количество журналов для очередей.
#   Эти настройки ограничивают размер очереди: 65536 * queue_file_size * queue_file_count = queueSize (bytes)
#   Где queueSize - размер очереди в байтах. queue_file_size указывается в байтах.
#
#   Значение по умолчанию: 128
#
# [*queue_file_count*]
#   При указании количества файлов необходимо учитывать, что qpid для каждой очереди постоянно держит все файлы открытыми.
#
#   Значение по умолчанию: 16
#
# [*queue_max_size*]
#   Этим параметром ограничивается размер очереди. Размер указывается в байтах.
#
#   Значение по умолчанию: 104857600
#
# [*queue_max_count*]
#   Максимальное количество сообщений в очереди.
#
#   Значение по умолчанию: 3000
#
# [*use_queue_in_upload*]
#   Использвать очередь при загрузке справочников.
#
#   Значение по умолчанию: 'True'
#
# [*broker_connection_heartbeat*]
#   Как часто проверять доступность соединения до сервера во время подключения и забора сообщений из очереди КС.
#   Значение параметра указывается в секундах. Если соединение потеряно, то подключение закроется и заблокированное 
#   (обрабатываемое) сообщение освободится и станет доступно для повторного считывания из очереди КС. 
#   Если установлено значение 0, то доступность соединения проверяться не будет и подключение будет открыто, пока его
#   принудительно не закрыть.
#
#   Значение по умолчанию: 0
#
#
# == Примеры
#
# :include:../README.rdoc

class artix_sync_core2 (
    $enable                             = true,
    $max_count_backup_files             = 30,
    $actual_count_days_for_backup_files = 30,
    $queue_file_size                    = 128,
    $queue_file_count                   = 16,
    $queue_max_size                     = 104857600,
    $queue_max_count                    = 3000,
    $use_queue_in_upload                = 'True',
    $broker_connection_heartbeat        = 0 )
{
    require artix_sync_core2::basedir

    File {
        owner => 'root',
        group => 'root',
        mode  => '0644',
    }

    file { "cash.ini.default" :
        path    => '/linuxcash/cash/sync/properties/cash.ini',
        source  => 'puppet:///modules/artix_sync_core2/cash.ini.default',
        ensure  => present,
        replace => false,
        require => Package['package-sync-agent'],
    }

    if $::augeas_enable != 'true' {
        notify {"Augeas is disabled. sync-core2 will be installed but won't be configured": loglevel => warning,}
    }

    if $artix_sync_core2::enable and ($::augeas_enable == "true") {
        file { 'sync_core2.aug' :
            name    => "/usr/share/augeas/lenses/dist/sync_core2.aug",
            source  => "puppet:///modules/artix_sync_core2/sync_core2.aug",
        }

        augeas { "sync-core2.conf":
            context => "/files/linuxcash/cash/sync/properties/cash.ini",
            changes => [
                "set Properties/maxcountbackupfiles ${max_count_backup_files}",
                "set Properties/actualcountdaysforbackupfiles ${actual_count_days_for_backup_files}",
                "set Properties/queuefilesize ${queue_file_size}",
                "set Properties/queuefilecount ${queue_file_count}",
                "set Properties/queuemaxsize ${queue_max_size}",
                "set Properties/queuemaxcount ${queue_max_count}",
                "set Properties/usequeueinupload ${use_queue_in_upload}",
                "set Properties/brokerconnectionheartbeat ${broker_connection_heartbeat}",
            ],
            require => [ Package['package-sync-agent'], File['sync_core2.aug'], File['cash.ini.default'] ],
            notify  => Service['service-sync-agent'],
        }

    }
    else {
        file { '/usr/share/augeas/lenses/dist/sync_core2.aug' :
            ensure => absent,
        }
    }

    package { "package-sync-agent" :
        ensure      => $artix_sync_core2::enable ? { true => installed, default => purged, } ,
        name        => 'artix45-sync-core2.1',
        configfiles => keep,
        provider    => aptitude,
    }

    service { "service-sync-agent" :
        ensure    => $artix_sync_core2::enable ? { true => running, default => stopped, } ,
        name      => "sync-core2",
        enable    => $artix_sync_core2::enable,
        hasstatus => $artix_sync_core2::enable,
        require   => Package['package-sync-agent'],
    }


}
