# puppet_augeas.rb

Facter.add('augeas_enable') do
    path = '/usr/share/augeas/lenses/dist'
    setcode do
        Puppet.features.augeas? && File.exists?(path) && File.directory?(path)
    end
end
