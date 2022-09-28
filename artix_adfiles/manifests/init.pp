#
#  class artix_adfiles
#
#  необходим для копирования рекламы на КСО
#
class artix_adfiles (
    $basedir        = "/opt/sst-sco" )
{
    File {
        owner => root,
        group => root,
        mode  => '0644',
    }

    if $::root_dir == undefined {
        file { "${basedir}/adfiles" :
            ensure       => directory,
            path         => "${basedir}/adfiles",
            source       => "puppet:///files/${root_dir}/adfiles/",
            sourceselect => all,
            recurse      => true,
            purge        => true,
            force        => true,
        }
    }
    if $::root_dir != undefined {
        file { "${basedir}/adfiles" :
            ensure       => directory,
            path         => "${basedir}/adfiles",
            source       => "puppet:///files/${root_dir}/adfiles/",
            sourceselect => all,
            recurse      => true,
            purge        => true,
            force        => true,
        }
    }

}
