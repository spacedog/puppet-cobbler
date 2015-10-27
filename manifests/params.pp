# == Class: cobbler::params
#
# Defines default values for variables inside whole cobbler class
#
# === Parameters
#
# None
#
# === Authors
#
# Anton Baranov <email:abaranov@linuxfoundation.org>
class cobbler::params {
  $ensure                 = 'present'
  $package                = [
                              'cobbler',
                              'syslinux',
                              'syslinux-tftpboot'
                            ]
  $package_ensure         = 'installed'
  $service                = 'cobblerd'
  $service_ensure         = 'running'
  $service_enable         = true
  $config_path            = '/etc/cobbler'
  $config_file            = "${config_path}/settings"
  $config_modules         = "${config_path}/modules.conf"
  $config_objects         = '/var/lib/cobbler/config'
  $cmd_cobbler            = '/usr/bin/cobbler'
  # Default config you have just after cobbler is installed
  # Just load yaml as cobbler use yaml format for $config_file
  $default_cobbler_config = parseyaml(
    file('cobbler/default_settings.yaml')
  )
  # Default configuration for cobbler modules
  $default_modules_config = {
    'authentication' => {'module' => 'authn_configfile'},
    'authorization'  => {'module' => 'authz_allowall'},
    'dns'            => {'module' => 'manage_bind'},
    'dhcp'           => {'module' => 'manage_isc'},
    'tftpd'          => {'module' => 'manage_in_tftpd'},
  }
}
