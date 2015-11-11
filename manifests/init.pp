# == Class: cobbler
#
# === Parameters
#
# === Variables
#
# === Examples
#
# === Authors
#
# Anton Baranov <abaranov@linuxfoundation.org>
class cobbler (
  $distros                = {},
  $repos                  = {},
  $profiles               = {},
  $systems                = {},
  $cobbler_config         = {},
  $cobbler_modules_config = {},
  $ensure                 = $::cobbler::params::ensure,
  $package                = $::cobbler::params::package,
  $package_ensure         = $::cobbler::params::package_ensure,
  $service                = $::cobbler::params::service,
  $service_ensure         = $::cobbler::params::service_ensure,
  $service_enable         = $::cobbler::params::service_enable,
  $config_path            = $::cobbler::params::config_path,
  $config_file            = $::cobbler::params::config_file,
  $config_modules         = $::cobbler::params::config_modules,
  $default_cobbler_config = $::cobbler::params::default_cobbler_config,
  $default_modules_config = $::cobbler::params::default_modules_config,
  $cmd_cobbler           = $::cobbler::params::cmd_cobbler,
) inherits ::cobbler::params {

  # Validation
  validate_re($ensure, ['^present$','^absent$'])
  validate_re($service_ensure,['^stopped$', '^running$'])
  validate_re($package_ensure,[
    '^present$',
    '^installed$',
    '^absent$',
    '^purged$',
    '^held$',
    '^latest$',
    '*.*'
  ])
  validate_string(
    $service,
  )
  validate_absolute_path(
    $config_path,
    $config_file,
    $config_modules,
    $cmd_cobbler,
  )
  validate_hash(
    $default_cobbler_config,
    $cobbler_config,
    $cobbler_modules_config,
    $distros,
    $repos,
    $profiles,
    $systems,
  )

  if is_string($service_enable) {
    validate_re($service_enable, [
      '^manual$',
      '^mask$'
    ])
  } else {
    validate_bool($service_enable)
  }

  if is_array($package) {
    validate_array($package)
  } else {
    validate_string($package)
  }

  anchor{'before_cobbler':}
  anchor{'after_cobbler':}

  class{'cobbler::install':
    package        => $package,
    package_ensure => $package_ensure,
  }

  # Merging default cobbler config and cobbler config and pass to
  # cobbler::config class
  $_cobbler_config         = merge(
    $default_cobbler_config,
    $cobbler_config
  )
  $_cobbler_modules_config = merge(
    $default_modules_config,
    $cobbler_modules_config
  )

  class{'cobbler::config':
    ensure                 => $ensure,
    cobbler_config         => $_cobbler_config,
    cobbler_modules_config => $_cobbler_modules_config,
    distros                => $distros,
    config_path            => $config_path,
    config_file            => $config_file,
    config_modules         => $config_modules,
  }

  class{'cobbler::service':
    service        => $service,
    service_ensure => $service_ensure,
    service_enable => $service_enable,
  }


  Anchor['before_cobbler'] ->
  Class['cobbler::install'] ->
  Class['cobbler::config'] ~>
  Class['cobbler::service'] ->
  Anchor['after_cobbler']

  # Distros
  create_resources('cobbler_distro', $distros)
  create_resources('cobbler_profile', $profiles)
  create_resources('cobbler_system', $systems)
  create_resources('cobbler_repo', $repos)

  Cobbler_distro[keys($distros)] ->
  Cobbler_profile[keys($profiles)] ->
  Cobbler_system[keys($systems)]

  Cobbler_repo[keys($repos)] -> Cobbler_system[keys($systems)]
}
