class scripts (
    $basedir         = "/linuxcash/cash/bin" )
{
    file { '/linuxcash/cash/bin/pkill.sh' :
        source  => "puppet:///files/${root_dir}/bin/pkill.sh",
        replace => 'true',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
    }
    file { '/linuxcash/cash/bin/vb_puppet.sh' :
        source  => "puppet:///files/${root_dir}/bin/vb_puppet.sh",
        replace => 'true',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
    }

  
}