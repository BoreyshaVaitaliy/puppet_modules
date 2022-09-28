class artix_upgrade (
    $version,
    $repo,
    $components        = 'artix main contrib puppet',
    $custom_enable     = false,
    $custom_repo       = '',
    $custom_components = '',
    $run_sleep         = 240,
    $dl_limit          = 25,
    $packages          = [],
    $server_name,
    $server_ip         = '',
    $bind_name         = false,
    $masterport        = 8140,
    $runinterval       = 7200,
    $splay             = true,
    $splaylimit        = 7200,
    $hostnamegen       = false,
    $hostname          = 'cash-%(shopcode)s-%(cashcode)s.local.domain.ru',
    $certname          = 'cash-%(shopcode)s-%(cashcode)s',
    $proxy_enable      = false,
    $http_proxy_host   = '',
    $http_proxy_port   = 3128

)
{
    stage { 'prepare' : 
    }

    stage { 'upgrade' :
    }

#    notify {"This is development environments"}
  
    Stage['prepare'] -> Stage['main'] -> Stage['upgrade']

    Class['artix_upgrade::aptsetup'] -> Class['artix_upgrade::puppet'] -> Class['artix_upgrade::upgrade']

    class { "artix_upgrade::aptsetup" :
        version           => $artix_upgrade::version,
        repo              => $artix_upgrade::repo,
        components        => $artix_upgrade::components,
        custom_enable     => $artix_upgrade::custom_enable,
        custom_repo       => $artix_upgrade::custom_repo,
        custom_components => $artix_upgrade::custom_components,
        stage             => prepare,
    }

    class { "artix_upgrade::puppet" :
        server_name       => $artix_upgrade::server_name,
        server_ip         => $artix_upgrade::server_ip,
        bind_name         => $artix_upgrade::bind_name,
        masterport        => $artix_upgrade::masterport,
        runinterval       => $artix_upgrade::runinterval,
        splay             => $artix_upgrade::splay,
        splaylimit        => $artix_upgrade::splaylimit,
        hostnamegen       => $artix_upgrade::hostnamegen,
        hostname          => $artix_upgrade::hostname,
        certname          => $artix_upgrade::certname,
        http_proxy_port   => $artix_upgrade::http_proxy_port,
        http_proxy_host   => $artix_upgrade::http_proxy_host,
        proxy_enable      => $artix_upgrade::proxy_enable,
        stage             => prepare,
    }

    class { "artix_upgrade::upgrade" :
        run_sleep         => $artix_upgrade::run_sleep,
        dl_limit          => $artix_upgrade::dl_limit,
        packages          => $artix_upgrade::packages,
        version           => $artix_upgrade::version,
        lock_install      => false,
        stage             => upgrade,
    }
}
