# @summary Class manages cobbler installation and configuraiton
#
# @param cobbler_config
#   Hash of cobbler settings options. This hash is merged with the
#   default_cobbler_config hash from params class. All this options go to the
#   file defined with config_file parameter. There are no checks (yet?) done to
#   verify options passed with that hash
#
# @param cobbler_modules_config
#   Hash of cobbler modules configuration. This hash is
#   merged with the default_modules_config hash from params class.
#   Example:
#     cobbler_modules_config => {
#       section1            => {
#         option1 => value1,
#         option2 => [ value1, value2],
#       },
#       section2.subsection => {
#         option3 => value3,
#       }
#     }
#
# @param ensure
#   The state of puppet resources within the module.
#
# @param package
#   The package name or array of packages that provides cobbler.
#
# @param package_ensure
#   The state of the package.
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
# @param config_path
#   The absolute path where cobbler configuration files reside. This to prepend
#   to config_file and config_modules options to build full paths to setttings
#   and modules.conf files.
#
# @param config_file
#   The title of main cobbler configuration file. The full path to that file is
#   build by prepending config_file with config_path parameters
#
# @param config_modules
#   The title of cobbler modules configuration file. The full path to that file
#   is build by prepending config_modules with config_path parameters
#
# @param default_cobbler_config
#   Hash that contains default configuration options for cobbler. No checks are
#   performed to validate these configuration options. This is a left side hash
#   to be merged with cobbler_config hash to build config_file for cobbler
#
# @param default_modules_config
#   Hash that contains default configuration options for cobbler modules.
#   This is a left side hash  to be merged with cobbler_modules_config hash to
#   build config_modules file  for cobbler
#
# @author Anton Baranov <abaranov@linuxfoundation.org>
class cobbler (
  Hash $cobbler_config              = {},
  Hash $cobbler_modules_config      = {},
  Enum[
    'present',
    'absent'
  ] $ensure                         = $cobbler::params::ensure,
  Variant[
    Array[String],
    String
  ] $package                        = $cobbler::params::package,
  Enum[
    'present',
    'installed',
    'absent',
    'purged',
    'held',
    'latest'
  ] $package_ensure                 = $cobbler::params::package_ensure,
  String $service                   = $cobbler::params::service,
  Enum[
    'stopped',
    'running'
  ] $service_ensure                 = $cobbler::params::service_ensure,
  Variant[
    Boolean,
    Enum['manual','mask']
  ] $service_enable                 = $cobbler::params::service_enable,
  Stdlib::Absolutepath $config_path = $cobbler::params::config_path,
  String $config_file               = $cobbler::params::config_file,
  String $config_modules            = $cobbler::params::config_modules,
  Hash $default_cobbler_config      = $cobbler::params::default_cobbler_config,
  Hash $default_modules_config      = $cobbler::params::default_modules_config,
) inherits cobbler::params {
  class { 'cobbler::install':
    package        => $package,
    package_ensure => $package_ensure,
  }

  class { 'cobbler::config':
    ensure                 => $ensure,
    cobbler_config         => $default_cobbler_config + $cobbler_config,
    cobbler_modules_config => $default_modules_config + $cobbler_modules_config,
    config_path            => $config_path,
    config_file            => $config_file,
    config_modules         => $config_modules,
  }

  class { 'cobbler::service':
    service        => $service,
    service_ensure => $service_ensure,
    service_enable => $service_enable,
  }

  Class['cobbler::install']
  -> Class['cobbler::config']
  ~> Class['cobbler::service']
}
