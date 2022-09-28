# artix_pos.rb

version = nil
version_major = nil
revision = nil
test = {}

if File.exist? '/linuxcash/cash/bin/InfoClient'
    descr = %x[/linuxcash/cash/bin/InfoClient]
else
    descr = ''
end
  

# Получение иноформации через InfoServer
descr.split("\n").each do |descr_line|

    # Версия Артикс
    info_version = $1 if descr_line =~ /(version=.*)/
    if info_version != nil
        version = $1 and version_major = $2 if info_version =~ /^version=((\d+\.\d+)\.\d+)[\#-]/

        if version_major != nil
            case version_major
            when '4.3'
                revision = $1 if info_version =~ /^version=.*-(\d+)\#/
            else
                revision = $1 if info_version =~ /^version=.*\#rev(\d+)$/
            end
        end
    end

    # Данные о лицензии
    license = $1 if descr_line =~ /license&(.*)/
    if license != nil
        test['artix_license_type'] = $1 if license =~ /type=(.*?)(&|$)/
        test['artix_license_key'] = $1 if license =~ /key=(.*?)(&|$)/
        test['artix_license_exp_date_str'] = $1 if license =~ /exp_date_str=(.*?)(&|$)/
        test['artix_license_time_left'] = $1 if license =~ /time_left=(.*?)(&|$)/
    end

    # Сведения о подключенных ККМ
    kkm = $1 if descr_line =~ /(kkm.*)/
    if kkm != nil
        kkm_num = $1 if kkm =~ /kkm=(.*?)(&|$)/
        if kkm_num != nil
            if test['artix_kkms'] == nil
                test['artix_kkms'] = kkm_num
            else
                test['artix_kkms'] << ';'+kkm_num
            end

            test['artix_kkm_'+kkm_num+'_producer'] = $1 if kkm =~ /producer=(.*?)(&|$)/
            test['artix_kkm_'+kkm_num+'_model'] = $1 if kkm =~ /model=(.*?)(&|$)/
            test['artix_kkm_'+kkm_num+'_number'] = $1 if kkm =~ /number=(.*?)(&|$)/
            test['artix_kkm_'+kkm_num+'_fpcountleft'] = $1 if kkm =~ /fpcountleft=(.*?)(&|$)/
            if test['artix_kkm_'+kkm_num+'_producer'] == '1'
                test['artix_kkm_'+kkm_num+'_producer_name'] = "Shtrih-M"
            end
            if test['artix_kkm_'+kkm_num+'_producer'] == '2'
                test['artix_kkm_'+kkm_num+'_producer_name'] = "Service-Plus"
            end
            if test['artix_kkm_'+kkm_num+'_producer'] == '3'
                test['artix_kkm_'+kkm_num+'_producer_name'] = "2"
            end
            if test['artix_kkm_'+kkm_num+'_producer'] == '4'
                test['artix_kkm_'+kkm_num+'_producer_name'] = "3"
            end
            if test['artix_kkm_'+kkm_num+'_producer'] == '5'
                test['artix_kkm_'+kkm_num+'_producer_name'] = "TFP"
            end
        end
    end
end

# Получение версии Артикс из версии пакета, если нет данных от InfoServer
if version_major == nil
    package_version = %x[/usr/bin/dpkg --list | /bin/egrep '^ii.*artix[0-9]{2}(-(hasp|demo))? ' | /usr/bin/head -n 1]
    version = $1 and version_major = $2 and revision = $3 if package_version =~ /((\d+\.\d+)\.\d+)-(\d+)/
end

if version_major == nil
    package_version = %x[/usr/bin/dpkg --list | /bin/egrep '^ii.*artix[0-9]{2}(-(gui|sco))? ' | /usr/bin/head -n 1]
    version = $1 and version_major = $2 and revision = $3 if package_version =~ /((\d+\.\d+)\.\d+)-(\d+)/
end

if version != nil && version_major != nil && revision != nil
    test['artix_version'] = version
    test['artix_version_major'] = version_major
    if revision != nil
        test['artix_revision'] = revision
        test['artix_version_full'] = version + '-' + revision
    end
end

# Получение кода кассы и магазина из реестра
if version_major != nil
    reg_file = "/linuxcash/cash/data/cash.reg"

    case version_major
    when '4.3'
        if File.exist? reg_file and File.exist? '/linuxcash/cash/bin/cashre'
            cashcode = %x[/linuxcash/cash/bin/cashre --print /linuxcash/cash/data/cash.reg | /bin/grep cashcode ]
            test['artix_cashcode'] = $1 if cashcode =~ /^cashcode[ ]*=[ ]*(\d+)/
        end
        if File.exist? '/linuxcash/logs/current/terminal.log'
            shopcode = %x[/usr/bin/head -n 300 '/linuxcash/logs/current/terminal.log' | /bin/grep shopcode ]
            test['artix_shopcode'] = $1 if shopcode =~ /shopcode[ ]*=[ ]*(\d+)/
        end
    else
        begin
            require 'json'

            if File.exist? reg_file
                data = File.read(reg_file)
                registry = JSON.parse(data)
                if not registry.has_key? 'Error'
                    test['artix_shopcode'] = registry['shopCode']
                    test['artix_cashcode'] = registry['cashCode']
                end
            end
        rescue Exception => e
        end
    end
end

# Получение информации о файлах с дополнительными настроками
dirname = '/linuxcash/cash/conf/ncash.ini.d'
if File.directory?(dirname)
    Dir.chdir(dirname) do
        files = Dir.glob( ["hw_*.ini"] )
        if !files.empty?
            test['artix_hardware_conf_files'] = files * ','
        end
        files = Dir.glob( ["ext_*.ini"] )
        if !files.empty?
            test['artix_extend_conf_files'] = files * ','
        end
    end
end

test.each{ |name, fact|
    Facter.add(name) do
        setcode do
            fact
        end
    end
}
