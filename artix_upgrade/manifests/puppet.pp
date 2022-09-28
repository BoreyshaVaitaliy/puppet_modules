class artix_upgrade::puppet (
    $server_name,
    $server_ip       = '',
    $bind_name       = false,
    $masterport      = 8140,
    $runinterval     = 7200,
    $splay           = true,
    $splaylimit      = 7200,
    $hostnamegen     = false,
    $hostname        = 'cash-%(shopcode)s-%(cashcode)s.local.domain.ru',
    $certname        = 'cash-%(shopcode)s-%(cashcode)s',
    $proxy_enable    = false,
    $http_proxy_host = '',
    $http_proxy_port = 3128

)
{
    if $::memorysize_mb > 250 {
        $run_as_service = true
    }
    else {
        $run_as_service = false
    }

    File {
        owner => root,
        group => root,
        mode  => '0644',
    }

    file { 'hostnamegen.conf' :
        name        => '/linuxcash/cash/conf/hostnamegen.conf',
        content     => template('artix_upgrade/hostnamegen.erb'),
    }

    exec { "generate_hostname" :
        path        => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games",
        command     => "/usr/bin/python /linuxcash/cash/tools/tools_avail/generate_hostname.py",
        require     => File["hostnamegen.conf"],
        subscribe   => File["hostnamegen.conf"],
        refreshonly => true,
        onlyif      => "test -f /linuxcash/cash/tools/tools_avail/generate_hostname.py",
    }

    if $bind_name == true {
        host { "${server_name}" :
            ip      => "${server_ip}",
        }
    }

    file { "puppet-start.sh" :
        name     => "/linuxcash/cash/bin/puppet-start.sh",
        source   => "puppet:///modules/artix_upgrade/puppet-start.sh",
        mode     => '0755',
    }


    file { '/linuxcash/cash/bin/puppet-start-after-boot.sh' :
        source  => "puppet:///modules/artix_upgrade/puppet-start-after-boot.sh",
#        ensure  => $puppet::run_as_service ? { true => absent, default => present, } ,
        mode    => '0755',
#        require => Package["puppet-agent"]
    }

    file { '/etc/cron.daily/puppet-start' :
        source  => "puppet:///modules/artix_upgrade/puppet-start",
#        ensure  => $puppet::run_as_service ? { true => absent, default => present, } ,
        mode    => '0755',
#        require => Package["puppet-agent"]
    }

    $is_os_1004 = $operatingsystemrelease == '10.04'
    $packages = $is_os_1004 ? {
        true    => [ 'libaugeas-ruby1.8', 'puppet', 'augeas-lenses' , 'anacron', 'facter' ],
        default => [ 'puppet', 'augeas-lenses' , 'anacron', 'facter' ]
    }

#    package { $packages :
#        ensure      => latest,
#        configfiles => keep,
#        provider    => aptitude,
#        require     => $package_requirements,
#    }

}
