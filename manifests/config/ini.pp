# @summary Helps build ini configuration files for cobbler
#
# @param ensure
#   The state of puppet resources within the module.
#
# @param config_file
#   Absolute path to configuration file
#
# @param options
#   Hash of options to build config_file upon.
#
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
# @author Anton Baranov <abaranov@linuxfoundation.org>
define cobbler::config::ini (
  Enum[
    'present',
    'absent'
  ] $ensure,
  Stdlib::Absolutepath $config_file,
  Hash $options
) {
  $_file_ensure = $ensure ? {
    'present' => file,
    default   => absent,
  }

  file { $config_file:
    ensure  => $_file_ensure,
    content => template("${module_name}/ini.erb"),
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
  }
}
