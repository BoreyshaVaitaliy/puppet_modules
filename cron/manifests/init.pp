class cron (
    $basedir         = "/etc/cron.d" )
{
    File {
        owner => root,
        group => root,
        mode  => '0644',
    }
    if $::root_dir == undefined {
        file { "${basedir}/license" :
            ensure       => directory,
            path         => "${basedir}",
            source       => "puppet:///files/cron",
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
            source       => "puppet:///files/${root_dir}/cron",
            sourceselect => all,
            recurse      => true,
            purge        => false,
            force        => true,
        }
    }
}
