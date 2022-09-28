# timezone_name.rb

timezone_name = nil
tname = {}

timezone_name = %x[ /bin/cat /etc/timezone | tr -d '\n' ]
tname['timezone_name'] = timezone_name

tname.each{ |name, fact|
    Facter.add(name) do
        setcode do
            fact
        end
    end
}


