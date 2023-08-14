# @summary Manages cobbler service
#
# @param service
#   Name of the service this modules is responsible to manage.
#
# @param service_ensure
#   The state of the serivce in the system
#
# @param service_enable
#   Whether a service should be enabled to start at boot
#
# @author Anton Baranov <abaranov@linuxfoundation.org>
class cobbler::service (
  String $service,
  Enum[
    'stopped',
    'running'
  ] $service_ensure,
  Variant[
    Boolean,
    Enum['manual','mask']
  ] $service_enable,
) {
  service { $service:
    ensure => $service_ensure,
    enable => $service_enable,
  }
}
