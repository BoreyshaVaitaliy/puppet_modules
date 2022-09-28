class artix_upgrade::upgrade (
    $run_sleep     = 240,
    $dl_limit      = 25,
    $packages      = [],
    $version       = '',
    $lock_install  = false )
{
    File {
        owner => root,
        group => root,
        mode  => '0644',
    }

    $is_new_package_available = versioncmp($version, '4.5.7-345') > 0
    $package_name = $is_new_package_available ? {true => "artix-upgrade-system2", default => "artix-upgrade-system" }

    package { "artix-upgrade" :
        ensure      => $artix_upgrade::upgrade::version,
        name        => $package_name,
        configfiles => "keep",
        provider    => "aptitude",
    }

    file { "artix-upgrade.conf" :
        name    => "/linuxcash/cash/conf/artix-upgrade.conf",
        content => template("artix_upgrade/config.erb"),
        require => [ Package["artix-upgrade"] ],
    }

    file { "artix-packages.list" :
        name    => "/linuxcash/cash/conf/artix-packages.list",
        content => template("artix_upgrade/packages.erb"),
        require => [ Package["artix-upgrade"] ],
    }

    file { "08_upgrade-system" :
        name    => "/linuxcash/cash/bin/startup/08_upgrade-system",
        content => file("artix_upgrade/08_upgrade-system"),
        require => [ Package["artix-upgrade"] ],
    }

    file { "artix-upgrade.def" :
        name    => "/linuxcash/cash/bin/artix-upgrade.def",
        content => file("artix_upgrade/artix-upgrade.def"),
        require => [ Package["artix-upgrade"] ],
    }

    file { "artix-upgrade.sh" :
        name    => "/linuxcash/cash/bin/artix-upgrade.sh",
        content => file("artix_upgrade/artix-upgrade.sh"),
        mode    => '0755',
        require => [ Package["artix-upgrade"] ],
    }

    file { "lock-install" :
        ensure  => $artix_upgrade::lock_install ? { true => present, default => absent, } ,
        name    => "/linuxcash/cash/data/upgrade-system/lock-install",
        content => "",
        require => [ Package["artix-upgrade"] ],
    }

    file { "/etc/cron.daily/artix-upgrade" :
        ensure  => absent,
        require => [ Package["artix-upgrade"] ],
    }

    exec { "remove-downloaded-flag" :
        command     => "/bin/rm -f /linuxcash/cash/data/upgrade-system/downloaded",
        subscribe   => [ File["artix-packages.list"] ],
        refreshonly => true
    }

    $install_flag_name = "/linuxcash/cash/data/upgrade-system/new-install"

    exec { "mark-for-install" :
        command     => "/usr/bin/touch $install_flag_name",
        require     => File["artix-packages.list"],
        subscribe   => [ File["artix-packages.list"] ],
        refreshonly => true
    }

    exec { "force-install" :
        command => "/usr/bin/setsid /linuxcash/cash/bin/artix-upgrade.sh -i >>/linuxcash/logs/current/artix-upgrade.log &",
        require => [ File['08_upgrade-system'], File['artix-upgrade.sh'], File['artix-upgrade.conf'], 
                     File['artix-upgrade.def'], Exec['mark-for-install'], Exec['remove-downloaded-flag'] ],
        onlyif  => "/usr/bin/test -e $install_flag_name"
    }

}
