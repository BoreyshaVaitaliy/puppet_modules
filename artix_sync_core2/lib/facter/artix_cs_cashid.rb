# artix_cs_cashid.rb

artix_cs_cashid = nil
cs_cashid = {}

artix_cs_cashid = %x[ /bin/grep ^cash.code /linuxcash/cash/sync/properties/cash.ini | /usr/bin/awk -F "=" {'print $2'} |sed 's/^[ \t]*//;s/[ \t]*$//'| tr -d '\n' ]
cs_cashid['artix_cs_cashid'] = artix_cs_cashid

cs_cashid.each{ |name, fact|
    Facter.add(name) do
        setcode do
            fact
        end
    end
}

