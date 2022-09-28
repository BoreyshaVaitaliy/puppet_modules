#
# = Класс: artix_upgrade
#
# Базовый класс для конфигурирования менеджера пакетов,
# чтобы получить доступ к репозиторию Артикс.
# Данный класс предназначен для добавления репозитория Артикс
# в список источников, маркировки его в качестве доверенного
# и обновления индексных файлов.
#
#
# == Параметры
#
# [*version*]
#   Версия дистрибутива Артикс, которая доступна в указанном
#   репозитории.
#
# [*repo*]
#   Размещение ресурса с дистрибутивами.
#   Основной ресурс: http://update.artix.su/repository
#
# [*components*]
#   Не обязательный! Список доступных компонент. Как правило
#   используются компоненты 'artix main contrib'. Указанный
#   список определен по умолчанию.
#
# [*custom_enable*]
#   Не обязательный! Признак использования дополнительного
#   ресурса. По умолчанию - дополнительный ресур не используется.
#
# [*custom_repo*]
#   Не обязательный! Размещение дополнительного ресурса с
#   дистрибутивами.
#
# [*custom_components*]
#   Не обязательный! Список доступных компонент для дополнительного
#   ресурса.
#
#
# == Примеры
#
# :include:../README.rdoc
#
# == Автор
#   Yurii Anisimov <ays@rssib.ru>
#
#
class artix_upgrade::aptsetup (
    $version,
    $repo,
    $components        = 'artix main contrib',
    $custom_enable     = false,
    $custom_repo       = '',
    $custom_components = ''
)
{
    File {
        owner => root,
        group => root,
        mode  => '0644',
    }

    file { "default-sources.list" :
        name    => "/etc/apt/sources.list",
        content => "",
    }

    file { "artix-sources.list" :
        name    => "/etc/apt/sources.list.d/artix.list",
        content => template("artix_upgrade/artix_list.erb"),
    }
    if versioncmp($version, '4.6.1-1') < 1 {
        file { "puppet-sources.list" :
            name    => "/etc/apt/sources.list.d/puppet.list",
            content => template("artix_upgrade/puppet_list.erb"),
        }
    }
    else {
        file { "puppet-sources.list" :
            ensure  => "absent",
            path    => "/etc/apt/sources.list.d/puppet.list",
        }
    }

    $flag_path = '/root/.puppet'
    $flag_name = '/root/.puppet/artix.list'

    exec { 'mark-as-changed' :
        command     => "mkdir -p $flag_path && touch $flag_name",
        cwd         => '/root',
        path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games',
        subscribe   => [ File[ 'default-sources.list' ], File[ 'artix-sources.list' ], File[ 'puppet-sources.list' ] ],
        refreshonly => true
    }

    file { "artix.gpg.key" :
        name   => "/etc/apt/artix.gpg.key",
        source => "puppet:///modules/artix_upgrade/artix.gpg.key",
    }

    exec { "mark-as-trusted" :
        command     => "/usr/bin/apt-key add /etc/apt/artix.gpg.key",
        require     => File["artix.gpg.key"],
        subscribe   => File["artix.gpg.key"],
        refreshonly => true,
    }

    exec { "aptitude-update":
        path        => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games",
        command     => "/usr/bin/aptitude update && rm -f $flag_name",
        require     => [ Exec[ 'mark-as-changed' ], Exec[ 'mark-as-trusted' ] ],
        onlyif      => "test -f $flag_name",
    }

}
