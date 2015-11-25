# == Class cobbler::config
#
# Manages configuration files for cobbler
#
# === Parameters
#
# [*ensure*]
#   The state of puppet resources within the module.
#
#   Type: String
#   Values: 'present', 'absent'
#   Default: 'present'
#
# [*cobbler_config*]
#   Hash of cobbler settings options. This hash is merged with the
#   default_cobbler_config hash from params class. All this options go to the
#   file defined with config_file parameter. There are no checks (yet?) done to
#   verify options passed with that hash
#
#   Type: Hash
#   Default: {}
#
# [*cobbler_modules_config*]
#   Hash of cobbler modules configuration. Puppetlabs-inifile module is used
#   to manage cobbler modules. This dictates how cobbler_modules_config must be
#   build (check puppetlabs-inifile documentation for details). This hash is
#   merged with the default_modules_config hash from params class.
#
#   Type: Hash
#   Default: {}
#
# [*config_path*]
#   The absolute path where cobbler configuration files reside. This to prepend
#   to config_file and config_modules options to build full paths to setttings
#   and modules.conf files.
#
#   Type: String
#   Default: /etc/cobbler
#
# [*config_file*]
#   The title of main cobbler configuration file. The full path to that file is
#   build by prepending config_file with config_path parameters
#
#   Type: String
#   Default: settings
#
# [*config_modules*]
#   The title of cobbler modules configuration file. The full path to that file
#   is build by prepending config_modules with config_path parameters
#
#   Type: String
#   Default: modules.conf
#
# === Authors
#
# Anton Baranov <abaranov@linuxfoundation.org>
class cobbler::config(
  $ensure,
  $cobbler_config,
  $cobbler_modules_config,
  $config_path,
  $config_file,
  $config_modules,
){
  # Validation
  validate_absolute_path(
    $config_path,
  )
  validate_hash(
    $cobbler_config,
    $cobbler_modules_config,
  )
  validate_re($ensure, ['^present$','^absent$'])

  validate_string(
    $config_file,
    $config_modules
  )


  File {
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  $_dir_ensure = $ensure ? {
    'present' => 'directory',
    default   => 'absent',
  }
  file {$config_path:
    ensure => $_dir_ensure,
  }
  # Just convert to yaml
  file {"${config_path}/${config_file}":
    ensure  => $ensure,
    content => inline_template('<%= @cobbler_config.to_yaml %>'),
  }

  $_modules_defaults = {'path' => "${config_path}/${config_modules}"}
  create_ini_settings($cobbler_modules_config, $_modules_defaults)

}
