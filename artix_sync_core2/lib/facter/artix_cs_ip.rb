# artix_cs_ip.rb

artix_cs_ip = nil
cs_ip = {}

artix_cs_ip = %x[ /bin/grep ^dept.broker.ip /linuxcash/cash/sync/properties/cash.ini | /usr/bin/awk -F "=" {'print $2'} |sed 's/^[ \t]*//;s/[ \t]*$//'| tr -d '\n' ]
cs_ip['artix_cs_ip'] = artix_cs_ip

cs_ip.each{ |name, fact|
    Facter.add(name) do
        setcode do
            fact
        end
    end
}

