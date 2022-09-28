#
# = Класс: artix_sync_core2::basedir
#
# Этот класс создает базовые директории для агента кассового сервера
#
# == Переменные
#
# [*basedir*]
#   Параметр определяет базовую директорию, которая должна уже существовать.
#   В указанной директории будут созданны поддиректории для размещения
#   настроек.
#
#   Значение по молчанию: '/linuxcash/cash'
#
#
class artix_sync_core2::basedir (
    $basedir = "/linuxcash/cash" 
)
{
    file { [ "${basedir}/sync",
             "${basedir}/sync/properties", ] :
        ensure => directory,
        owner  => root,
        group  => root,
        mode   => 0777,
    }
}
