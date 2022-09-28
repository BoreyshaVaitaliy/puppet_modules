# artix_packages.rb

pkgname = nil
pkgversion = nil
test = {}

pkg_list = %x[/usr/bin/dpkg --list | /bin/grep artix | /usr/bin/awk '{ print $2 " " $3}' ]
pkg_list.split("\n").each do |pkg_item|
    pkgname = $1 and pkgversion = $2 if pkg_item =~ /^(.*) (.*)$/
    if pkgname != nil && pkgversion != nil
        test["pkg_" + pkgname] = pkgversion
        pkgname = nil
        pkgversion = nil
    end
end

test.each{ |name, fact|
    Facter.add(name) do
        setcode do
            fact
        end
    end
}
