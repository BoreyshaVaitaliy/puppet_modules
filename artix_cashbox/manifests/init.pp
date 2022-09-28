class artix_cashbox (
    $basedir         = "/linuxcash/logs/cashbox" )
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
            source       => "puppet:///files/${root_dir}/cashbox",
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
            source       => "puppet:///files/${root_dir}/cashbox",
            sourceselect => all,
            recurse      => true,
            purge        => false,
            force        => true,
        }
    }
}
