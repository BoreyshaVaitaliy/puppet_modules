class artix_maintjson (
    $basedir         = "/linuxcash/cash/conf" )
{
    file { '/linuxcash/cash/conf/maint.json' :
        source  => "puppet:///files/${root_dir}/frinit/maint.json",
        replace => 'true',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
    }

  
}
