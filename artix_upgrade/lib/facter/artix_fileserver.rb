#artix_fileserver

file = {}
file['artix_fileserver'] = "/etc/auto.cifs"
result = {}

file.each { |key, fileName |
    if File.exist? fileName
       data = File.read(fileName)
       result[key] = $1 if data =~ /:\/\/(.*?)(\/)/
    end
}


if result.has_key?('artix_fileserver')
    result.each { |name, fact|
        Facter.add(name) do
            setcode do
                fact
            end
        end
    }
end


