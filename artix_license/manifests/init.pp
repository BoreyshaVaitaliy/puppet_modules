class artix_license (
    $basedir         = "/linuxcash/cash" )
{
    File {
        owner => root,
        group => root,
        mode  => '0644',
    }
    if $::root_dir == undefined {
        file { "${basedir}/license" :
            ensure       => directory,
            path         => "${basedir}/license",
            source       => "puppet:///files/license",
            sourceselect => all,
            recurse      => true,
            purge        => false,
            force        => true,
        }
    }
    if $::root_dir != undefined {
        file { "${basedir}/license" :
            ensure       => directory,
            path         => "${basedir}/license",
            source       => "puppet:///files/${root_dir}/license",
            sourceselect => all,
            recurse      => true,
            purge        => false,
            force        => true,
        }
    }
}
