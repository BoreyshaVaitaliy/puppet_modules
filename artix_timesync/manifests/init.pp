class artix_timesync (
    $ntp_enable  = false,
    $ntp_servers = [],
    $smb_enable  = false,
    $smb_server  = $::artix_fileserver
)
{

    File {
        owner => root,
        group => root,
        mode  => 0644,
    }

    file { "ntpserver.conf" :
        name    => "/linuxcash/cash/conf/ntpserver.conf",
        ensure => $artix_timesync::ntp_enable ? { true => present, default => absent, } ,
        content => template("artix_timesync/ntpsync.erb"),
    }

    if $artix_timesync::smb_server == undef {
        notify { 'smb-server-not-found' :
            message => 'Не настроено подключение к SMB серверу',
        }
    }
    else {
        file { "smbtimeserver.conf" :
            name    => "/linuxcash/cash/conf/smbtimeserver.conf",
            ensure => $artix_timesync::smb_enable ? { true => present, default => absent, } ,
            content => template("artix_timesync/smbsync.erb"),
        }
    }

}
