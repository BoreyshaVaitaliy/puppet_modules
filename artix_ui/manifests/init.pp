class artix_ui (
    $basedir = "/linuxcash/cash"
)
{
    File {
        owner => root,
        group => root,
        mode  => '0644',
    }
    if $::root_dir == undefined {
        file { "${basedir}/ui" :
            ensure       => directory,
            path         => "${basedir}/ui",
            source       => "puppet:///files/ui",
            sourceselect => all,
            recurse      => true,
            purge        => false,
            force        => true,
        }
    }
    if $::root_dir != undefined {
        file { "${basedir}/ui" :
            ensure       => directory,
            path         => "${basedir}/ui",
            source       => "puppet:///files/${root_dir}/ui",
            sourceselect => all,
            recurse      => true,
            purge        => false,
            force        => true,
        }
    }
}
