#
#  class artix_reports
#
#  необходим для копирования reports
#  параметры:
#   reports_dir - директория от куда будет копироваться директория reports (По умолчанию default)
#
#  == Автор
#   Evgenii Kotov <kotove@rssib.ru>
#
class artix_reports (
    $basedir        = "/linuxcash/cash" )
{
    File {
        owner => root,
        group => root,
        mode  => '0755',
    }

    if $::root_dir == undefined {
        file { "${basedir}/reports" :
            ensure       => directory,
            path         => "${basedir}/reports",
            source       => "puppet:///files/client/reports/",
            sourceselect => all,
            recurse      => true,
            purge        => false,
            force        => true,
        }
    }
    if $::root_dir != undefined {
        file { "${basedir}/reports" :
            ensure       => directory,
            path         => "${basedir}/reports",
            source       => "puppet:///files/${root_dir}/reports/",
            sourceselect => all,
            recurse      => true,
            purge        => false,
            force        => true,
        }
    }

}
