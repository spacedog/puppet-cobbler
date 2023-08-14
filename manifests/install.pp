# @summary Installs packages required to deploy cobbler
#
# @param package
#   The package name or array of packages that provides cobbler.
#
# @param package_ensure
#   The state of the package.
#
# @author Anton Baranov <abaranov@linuxfoundation.org>
class cobbler::install (
  Variant[
    Array[String],
    String
  ] $package,
  Enum[
    'present$',
    'installed',
    'absent',
    'purged',
    'held',
    'latest'
  ] $package_ensure,
) {
  package { $package:
    ensure => $package_ensure,
  }
}
