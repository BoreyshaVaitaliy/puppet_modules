class artix_time (
    $basedir         = "/linuxcash/cash/conf" )
{
    file { '/linuxcash/cash/conf/ntpserver.conf' :
        source  => "puppet:///files/${root_dir}/time/ntpserver.conf",
        replace => 'true',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
    }

  
}
