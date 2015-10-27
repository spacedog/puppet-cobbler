class cobbler::install (
  $package,
  $package_ensure,
){
  # Validation
  validate_re($package_ensure,[
    '^present$',
    '^installed$',
    '^absent$',
    '^purged$',
    '^held$',
    '^latest$',
    '*.*'
  ])

  if is_array($package) {
    validate_array($package)
  } else {
    validate_string($package)
  }

  package { $package:
    ensure => $package_ensure,
  }
}
