#
#  class artix_autostart
#
#  необходим для копирования autostart
#  параметры:
#  autostart_dir - директория от куда будет копироваться директория reports (По умолчанию default)
#
#  == Автор
#   Evgenii Kotov <kotove@rssib.ru>
#
class artix_autostart (
    $basedir        = "/linuxcash/cash/conf" )
{
    File {
        owner => root,
        group => root,
        mode  => '0777',
    }

    if $::root_dir == undefined {
        file { "${basedir}/autostart" :
            ensure       => directory,
            path         => "${basedir}/autostart",
            source       => "puppet:///files/client/autostart/",
            sourceselect => all,
            recurse      => true,
            purge        => false,
            force        => true,
        }
    }
    if $::root_dir != undefined {
        file { "${basedir}/autostart" :
            ensure       => directory,
            path         => "${basedir}/autostart",
            source       => "puppet:///files/${root_dir}/autostart/",
            sourceselect => all,
            recurse      => true,
            purge        => false,
            force        => true,
        }
    }

}
