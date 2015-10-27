define cobbler::import (
  $breed        = undef,
  $os_version   = undef,
  $path         = undef,
  $available_as = undef,
  $kickstart    = undef,
  $rsync_flags  = undef,
  $arch         = 'x86_64',
){
  include ::cobbler::params

  validate_re($arch, [
    '^i386$',
    '^x86_64$',
    '^ia64$',
    '^ppc$',
    '^ppc64$',
    '^s390$',
    '^arm$'
  ])

  validate_string(
    $path,
    $os_version,
    $path,
    $available_as,
    $kickstart,
    $rsync_flags,
  )
  # Required parameters
  if !$path {
    fail("'path' parameter is not defined")
  }

  $_args = join(
    join_keys_to_values({
      '--name'         => $title,
      '--breed'        => $breed,
      '--os_version'   => $os_version,
      '--path'         => $path,
      '--available-as' => $available_as,
      '--kickstart'    => $kickstart,
      '--rsync-flags'  => $rsync_flags,
      '--arch'         => $arch }.filter |$key,$arg| { $arg != undef }
      ,'='),
  ' ')

  # For some reason cobbler disto find command returns 0 even if distro 
  # not found. Use grep to get the right exit code
  exec {"import_${title}_from_${path}":
    command => "${::cobbler::params::cmd_cobbler} import ${_args}",
    unless  => "${::cobbler::params::cmd_cobbler} distro find \
      --name=${title}-${arch} | grep ${title}-${arch}",
  }
}
