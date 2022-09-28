#
#  class artix_ncash.ini.d
#
#  необходим для копирования reports
#  параметры:
#   reports_dir - директория от куда будет копироваться директория reports (По умолчанию default)
#
#  == Автор
#   Evgenii Kotov <kotove@rssib.ru>
#
class artix_ncashinid (
    $basedir        = "/linuxcash/cash" )
{
    File {
        owner => root,
        group => root,
        mode  => '0644',
    }

    if $::root_dir == undefined {
        file { "${basedir}/conf/ncash.ini.d" :
            ensure       => directory,
            path         => "${basedir}/conf/ncash.ini.d",
            source       => "puppet:///files/${root_dir}/ncash.ini.d/",
            sourceselect => all,
            recurse      => true,
            purge        => false,
            force        => true,
        }
    }
    if $::root_dir != undefined {
        file { "${basedir}/conf/ncash.ini.d" :
            ensure       => directory,
            path         => "${basedir}/conf/ncash.ini.d",
            source       => "puppet:///files/${root_dir}/ncash.ini.d/",
            sourceselect => all,
            recurse      => true,
            purge        => false,
            force        => true,
        }
    }

}
