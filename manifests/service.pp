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
  service {$service:
    ensure => $service_ensure,
    enable => $service_enable,
  }
}
