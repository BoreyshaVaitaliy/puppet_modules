#
#  class artix_sst_i18n
#
#  необходим для копирования сообщений для КСО
#  параметры:
#   reports_dir - директория от куда будет копироваться директория reports (По умолчанию default)
#
#  == Автор
#   Boreysha vitaliy <boreysha@tusson.by>
#
class artix_sst_i18n (
    $basedir        = "/opt/sst-sco/i18n" )
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
            source       => "puppet:///files/${root_dir}/sst-sco/i18n/",
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
            source       => "puppet:///files/${root_dir}/sst-sco/i18n/",
            sourceselect => all,
            recurse      => true,
            purge        => false,
            force        => true,
        }
    }

}
