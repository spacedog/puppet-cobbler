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
