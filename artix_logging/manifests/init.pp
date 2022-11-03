#
#  class artix_logging
#

class artix_logging (
    $basedir        = "/linuxcash/cash" )
{
    File {
        owner => root,
        group => root,
        mode  => '0644',
    }

    if $::root_dir == undefined {
        file { "${basedir}/conf/Artix" :
            ensure       => directory,
            path         => "${basedir}/conf/Artix",
            source       => "puppet:///files/${root_dir}/logging/",
            sourceselect => all,
            recurse      => true,
            purge        => false,
            force        => true,
        }
    }
    if $::root_dir != undefined {
        file { "${basedir}/conf/Artix" :
            ensure       => directory,
            path         => "${basedir}/conf/Artix",
            source       => "puppet:///files/${root_dir}/logging/",
            sourceselect => all,
            recurse      => true,
            purge        => false,
            force        => true,
        }
    }

}
