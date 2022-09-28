class artix_bcode (
    $basedir         = "/linuxcash/cash/conf" )
{
    file { '/linuxcash/cash/conf/bcode.ini' :
        source  => "puppet:///files/${root_dir}/bcode/bcode.ini",
        replace => 'true',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
    }
}

