class artix_plugins (
    $basedir         = "/linuxcash/cash/conf/plugins" )
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
            source       => "puppet:///files/plugins",
            sourceselect => all,
            recurse      => true,
            purge        => false,
            force        => true,
        }
    }
    if $::root_dir != undefined {
        file { "${basedir}/license" :
            ensure       => directory,
            path         => "${basedir}",
            source       => "puppet:///files/${root_dir}/plugins",
            sourceselect => all,
            recurse      => true,
            purge        => false,
            force        => true,
        }
    }
}
