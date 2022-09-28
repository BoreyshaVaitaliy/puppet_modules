# artix_upgrade.rb

test = {}
files = {}
files['artix_upgrade_status_code'] = '/linuxcash/cash/data/upgrade-system/status.code'
files['artix_upgrade_status_text'] = '/linuxcash/cash/data/upgrade-system/status.text'

files.each{ |key, fileName|
    if File.exist? fileName
        data = File.read(fileName)
        test[key] = data.split("\n")[0]
    end
}

test.each{ |name, fact|
    Facter.add(name) do
        setcode do
            fact
        end
    end
}
