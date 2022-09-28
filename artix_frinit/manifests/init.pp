class artix_frinit (
    $basedir         = "/linuxcash/cash/conf" )
{
    file { '/linuxcash/cash/conf/frinit.conf' :
        source  => "puppet:///files/${root_dir}/frinit/frinit.conf",
        replace => 'true',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
    }

  
}
