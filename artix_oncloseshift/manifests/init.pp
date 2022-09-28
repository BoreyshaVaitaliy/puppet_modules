class artix_oncloseshift (
    $basedir         = "/linuxcash/cash/bin" )
{
    file { '/linuxcash/cash/bin/oncloseshift.sh' :
        source  => "puppet:///files/${root_dir}/onclose/oncloseshift.sh",
        replace => 'true',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
    }

  
}