class artix_timezone (
    $set_timezone
)
{
    if $set_timezone != $timezone_name {
        exec { "aptitude_update_for_tzdata" :
            path    => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games",
            command => "/usr/bin/aptitude update",
#            unless  => "/bin/grep -q ${set_timezone} /etc/timezone",
        }
        package { "tzdata":
            ensure  => latest,
            require => Exec["aptitude_update_for_tzdata"],
        }
        exec {"test_timezone" :
            path        => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games",
            command     => "/bin/true",
            onlyif      => "/usr/bin/test -f /usr/share/zoneinfo/${set_timezone}",
            require     => Package["tzdata"],
            subscribe   => Package["tzdata"],
            refreshonly => true,
        }
        file { '/etc/timezone' :
            content => "${set_timezone}\n",
            require => Exec["test_timezone"],
        }
        exec { "installed_timezone" :
            path        => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games",
            command     => '/usr/sbin/dpkg-reconfigure -f noninteractive tzdata',
            require     => File["/etc/timezone"],
            subscribe   => File["/etc/timezone"],
            refreshonly => true,
        }
    }
}

