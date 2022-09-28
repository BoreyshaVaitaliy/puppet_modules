#
#  class artix_exchangers
#
#  необходим для копирования настроек exchangers
#  параметры:
#   reports_dir - директория от куда будет копироваться директория reports (По умолчанию default)
#
#  == Автор
#   Evgenii Kotov <kotove@rssib.ru>
#
class artix_exchangers (
    $basedir        = "/linuxcash/cash" )
{
    File {
        owner => root,
        group => root,
        mode  => '0644',
    }

    if $::root_dir == undefined {
        file { "${basedir}/exchangesystems/exchangers/config/cash/conf.d" :
            ensure       => directory,
            path         => "${basedir}/exchangesystems/exchangers/config/cash/conf.d",
            source       => "puppet:///files/${root_dir}/exchangers/",
            sourceselect => all,
            recurse      => true,
            purge        => false,
            force        => true,
        }
    }
    if $::root_dir != undefined {
        file { "${basedir}/exchangesystems/exchangers/config/cash/conf.d" :
            ensure       => directory,
            path         => "${basedir}/exchangesystems/exchangers/config/cash/conf.d",
            source       => "puppet:///files/${root_dir}/exchangers/",
            sourceselect => all,
            recurse      => true,
            purge        => false,
            force        => true,
        }
    }

}
