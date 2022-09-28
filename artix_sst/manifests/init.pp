#
#  class artix_sst
#
#  необходим для копирования reports
#  параметры:
#   reports_dir - директория от куда будет копироваться директория reports (По умолчанию default)
#
#  == Автор
#   Boreysha vitaliy <boreysha@tusson.by>
#
class artix_sst (
    $basedir        = "/opt/sst-sco/conf" )
{
    File {
        owner => root,
        group => root,
        mode  => '0644',
    }

    if $::root_dir == undefined {
        file { "${basedir}" :
            ensure       => directory,
            path         => "${basedir}",
            source       => "puppet:///files/${root_dir}/sst-sco/conf/",
            sourceselect => all,
            recurse      => true,
            purge        => false,
            force        => true,
        }
    }
    if $::root_dir != undefined {
        file { "${basedir}" :
            ensure       => directory,
            path         => "${basedir}",
            source       => "puppet:///files/${root_dir}/sst-sco/conf/",
            sourceselect => all,
            recurse      => true,
            purge        => false,
            force        => true,
        }
    }

}
