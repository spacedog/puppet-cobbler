class cobbler::config(
  $ensure,
  $cobbler_config,
  $config_path,
  $config_file,
  $config_modules,
){
  # Validation
  validate_absolute_path(
    $config_file,
    $config_path,
    $config_modules
  )
  validate_hash($cobbler_config)
  validate_re($ensure, ['^present$','^absent$'])

  File {
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  # Just convert to yaml
  file {$cobbler::config_file:
    ensure  => $ensure,
    content => inline_template('<%= @cobbler_config.to_yaml %>'),
  }

  #concat {$cobbler::config_modules:
  #  owner   => 'root',
  #  group   => 'root',
  #  mode    => '0644',
  #}

  #concat::fragment {"${cobbler::config_modules}_HEADER":
  #  target  => $cobbler::config_modules,
  #  content => template("${module_name}/modules.conf.header.erb"),
  #  order   => '01',
  #}

  #create_resources('cobbler::module', $cobbler::modules)


}
