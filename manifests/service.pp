class cobbler::service (
  $service,
  $service_ensure,
  $service_enable,
){
  # Validation
  validate_string(
    $service,
  )
  validate_re($service_ensure,['^stopped$', '^running$'])

  if is_string($service_enable) {
    validate_re($service_enable, [
      '^manual$',
      '^mask$'
    ])
  } else {
    validate_bool($service_enable)
  }
  service {$cobbler::service:
    ensure => $cobbler::service_ensure,
    enable => $cobbler::service_enable,
  }
}
