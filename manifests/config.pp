# @summary Manages configuration files for cobbler
#
# @param ensure
#   The state of puppet resources within the module.
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
# @author Anton Baranov <abaranov@linuxfoundation.org>
class cobbler::config (
  Enum[
    'present',
    'absent'
  ] $ensure,
  Hash $cobbler_config,
  Hash $cobbler_modules_config,
  Stdlib::Absolutepath $config_path,
  String $config_file,
  String $config_modules,
) {
  $_dir_ensure = $ensure ? {
    'present' => directory,
    default   => absent,
  }
  $_file_ensure = $ensure ? {
    'present' => file,
    default   => absent,
  }

  file { $config_path:
    ensure => $_dir_ensure,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  file { "${config_path}/${config_file}":
    ensure  => $_file_ensure,
    content => $cobbler_config.to_yaml,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  cobbler::config::ini { 'modules.conf':
    ensure      => $ensure,
    config_file => "${config_path}/${config_modules}",
    options     => $cobbler_modules_config,
  }
}
