# cobbler [![Build Status](https://travis-ci.org/spacedog/puppet-cobbler.svg)](https://travis-ci.org/spacedog/puppet-cobbler)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [What cobbler affects](#what-cobbler-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with cobbler](#beginning-with-cobbler)
4. [Usage](#usage)
    * [Sample Hiera YAML configuration file](#sample-hiera-yaml-configuration-file)
5. [Reference](#reference)
5. [Limitations](#limitations)

## Overview

This module manages installation and configuration cobbler itself as well as
cobbler objects such as distros, profiles, systems and repos.

## Module Description

Module installs cobbler servers. Module performs cobbler configuration,
including main configuration file, and cobbler modules. Module provides  custom
types for cobbler objects:
  * cobbler_distro - cobbler distributions
  * cobbler_repo - cobbler repositories
  * cobbler_profile - cobbler profiles
  * cobbler_system - cobbler systems


## Setup

### What cobbler affects

+ Module installs (including dependencies):
  * cobbler
  * syslinux
  * syslinux-tftpboot

  This can be overwritten using *_package_* parameter of *_cobbler_* class
  
+ Modules manages files:
  * /etc/cobbler/settings
  * /etc/cobbler/modules.conf

+ Affected services:
  * cobblerd

### Setup Requirements

This module uses custom types and providers so pluginsync must be enabled.

### Beginning with cobbler

For a basic installation setup with a default configuration parameters it's just
enough to declare cobbler module inside the manifest
```puppet
class {'cobbler':}
```

## Usage

To pass any configuration parameters the *cobbler_config* parameter is used.
*cobbler_config* is merged with *default_cobbler_config* from _params.pp_ and
pushed to /etc/cobbler/settings file

*cobbler_config* must be a hash that contains cobbler configuration options:

```puppet
$cobbler_settings = {
    'server'        => '192.168.0.1',
    'next_server'   => '192.168.0.1',
    'pxe_just_once' => 1
}

class {'cobbler':
  cobbler_config => $cobbler_settings,
}
```

For cobbler mopdules configuration _cobbler_modules_config parameter is used.
As well as _cobbler_config_ modules configuration passed to the class is merged
with _default_modules_config_ from _params.pp_

```puppet
$modules_settings = {
  'dns'  => {'module' => 'manage_dnsmasq'},
}

class {'cobbler':
  cobbler_modules_config => $modules_settings,
}
```

Cobbler objects are managed using custom types. One of the ways to create
distributions, repositories, profiles and systems is to pass hash to
_create_resources_ function. For example:
+ Using hiera:

```yaml
cobbler::distros:
  centos7-x86_64:
    ensure: present
    comment: 'CentOS7 Distribution'
    arch: x86_64
    path: /mnt
    initrd: '/var/www/cobbler/ks_mirror/centos7-minimal-x86_64/images/pxeboot/initrd.img'
    kernel: '/var/www/cobbler/ks_mirror/centos7-minimal-x86_64/images/pxeboot/vmlinuz'
    owners:
      - admin

create_resources('cobbler_distro', hiera('cobbler::distros')
```

or

+ Using puppet hash

```puppet
$interfaces = {
  'eth0'       => {
    ip_address => '192.168.1.6',
    netmask    => '255.255.255.0',
    if_gateway => '192.168.1.1',
  },
  'eth1'       => {
    ip_address => '192.168.100.10',
    netmask    => '255.255.255.0',
    if_gateway => '192.168.100.1',
  },
  'eth2'       => {
    ip_address => '192.168.200.11',
    netmask    => '255.255.255.0',
    if_gateway => '192.168.200.1',
  }
}
$systems = {
  'testhost01' => {
    ensure     => 'present',
    profile    => 'cvo_mgmt_server',
    interfaces => $interfaces,
    hostname   => 'testhost01',
}

create_resources('cobbler_system', $systems)
```

### Sample Hiera YAML configuration file

The Hiera configuration file typically looks like the following:

```yaml
cobbler::settings:
  auth_token_expiration: 3600
  bind_master: '127.0.0.1'
  client_use_https: 0
  client_use_localhost: 0
  default_name_servers: '192.168.1.100'
  default_password_crypted: '$1$alongpas$dd8QvxAdUttv/EO43ZxMy0'
  http_port: 80
  next_server: '192.168.1.1'
  puppet_auto_setup: 1
  puppet_server: '192.168.1.1'
  puppet_version: 3
  pxe_just_once: 0
  restart_dhcp: 1
  restart_dns: 1
  server: '192.168.1.1'
  xmlrpc_port: 25151

cobbler::modules_settings:
  authentication:
    module: 'authn_configfile'
  authorization:
    module: 'authz_allowall'
  dhcp:
    module: 'manage_isc'
  dns:
    module: 'manage_bind'
  tftpd:
    module: 'manage_in_tftpd'

cobbler::distros:
  CentOS6:
    initrd: '/var/lib/cobbler/pxeboot/initrd.img'
    kernel: '/var/lib/cobbler/pxeboot/vmlinuz'
    ksmeta:
      tree: 'http://192.168.1.1/mirror.centos.org/6/os/x86_64/'
    name: 'CentOS6'

cobbler::repos:
  CentOS-6-Base:
    breed: 'yum'
    mirror: 'http://192.168.1.1/mirror.centos.org/6/os/x86_64/'
    mirror_locally: "false"
    name: 'CentOS-6-Base'
  CentOS-6-Extras:
    breed: 'yum'
    mirror: 'http://192.168.1.1/mirror.centos.org/6/extras/x86_64/'
    mirror_locally: "false"
    name: 'CentOS-6-Extras'
  CentOS-6-Updates:
    breed: 'yum'
    mirror: 'http://192.168.1.1/mirror.centos.org/6/updates/x86_64/'
    mirror_locally: "false"
    name: 'CentOS-6-Updates'
  Extra-Packages-for-Enterprise-Linux-6:
    breed: 'yum'
    mirror: 'http://192.168.1.1/dl.fedoraproject.org/pub/epel/6/x86_64'
    mirror_locally: "false"
    name: 'Extra-Packages-for-Enterprise-Linux-6'
  IUS-Community-Packages-for-Enterprise-Linux-6:
    breed: 'yum'
    mirror: 'http://192.168.1.1/ius/stable/Redhat/6/x86_64'
    mirror_locally: "false"
    name: 'IUS-Community-Packages-for-Enterprise-Linux-6'
  Puppet-Labs-Dependencies-El-6:
    breed: 'yum'
    mirror: 'http://192.168.1.1/yum.puppetlabs.com/el/6/dependencies/x86_64'
    mirror_locally: "false"
    name: 'Puppet-Labs-Dependencies-El-6'
  Puppet-Labs-Devel-El-6:
    breed: 'yum'
    mirror: 'http://192.168.1.1/yum.puppetlabs.com/el/6/devel/x86_64'
    mirror_locally: "false"
    name: 'Puppet-Labs-Devel-El-6'
  Puppet-Labs-Products-El-6:
    breed: 'yum'
    mirror: 'http://192.168.1.1/yum.puppetlabs.com/el/6/products/x86_64'
    mirror_locally: "false"
    name: 'Puppet-Labs-Products-El-6'
  RPMFusion-free-6:
    breed: 'yum'
    mirror: 'http://192.168.1.1/rpmfusion/free/el/updates/6/x86_64'
    mirror_locally: "false"
    name: 'RPMFusion-free-6'

cobbler::images: []

cobbler::profiles:
  server:
    dhcp_tag: 'default'
    distro: 'CentOS6'
    kickstart: '/var/lib/cobbler/kickstarts/sample.ks'
    kopts:
      ksdevice: 'link'
    ksmeta:
      puppet_server: '192.168.1.123'
      tree: 'http://192.168.1.1/mirror.centos.org/6/os/x86_64'
    name: 'server'
    name_servers:
    - '192.168.1.100'
    - '192.168.1.200'
    name_servers_search:
    - 'testdomain.com'
    repos:
    - 'CentOS-6-Base'
    - 'CentOS-6-Extras'
    - 'CentOS-6-Updates'
    - 'IUS-Community-Packages-for-Enterprise-Linux-6'
    - 'RPMFusion-free-6'
    - 'Puppet-Labs-Dependencies-El-6'
    - 'Puppet-Labs-Devel-El-6'
    - 'Puppet-Labs-Products-El-6'

cobbler::systems:
  server1.testdomain.com:
    gateway: '192.168.1.1'
    interfaces:
      eth0:
        interface: 'eth0'
        ip_address: '192.168.1.2'
        mac_address: '00:11:22:33:44:55'
        netmask: '255.255.255.0'
    name: 'server1.testdomain.com'
    profile: 'server'
  server2.testdomain.com:
    gateway: '192.168.1.1'
    interfaces:
      eth0:
        interface: 'eth0'
        ip_address: '192.168.1.3'
        mac_address: '11:22:33:44:55:66'
        netmask: '255.255.255.0'
        static_routes: '192.168.2.0/24:192.168.1.1,192.168.3.0/24:192.168.1.1'
    name: 'server2.testdomain.com'
    profile: 'server'
```

Then the Puppet code is calling those settings via Cobbler Puppet provider:

```puppet
$cobbler_settings         = hiera('cobbler::settings')
$cobbler_modules_settings = hiera('cobbler::modules_settings')
$cobbler_distros          = hiera('cobbler::distros')
$cobbler_repos            = hiera('cobbler::repos')
$cobbler_profiles         = hiera('cobbler::profiles')
$cobbler_systems          = hiera('cobbler::systems')

class { 'cobbler':
    cobbler_config         => $cobbler_settings,
    cobbler_modules_config => $cobbler_modules_settings,
}

create_resources('cobbler_distro', $cobbler_distros)

create_resources('cobbler_repo', $cobbler_repos)

create_resources('cobbler_profile', $cobbler_profiles)

create_resources('cobbler_system', $cobbler_systems)

```


## Reference

That module contains:
 + Custom types:
    * cobbler_distro
    * cobbler_repo
    * cobbler_profile
    * cobbler_system

## Limitations

+ osfamily => RedHat
+ if getenforce == Enforcing
  * setsebool -P httpd_can_network_connect_cobbler 1
  * setsebool -P httpd_serve_cobbler_files 1
  * semanage fcontext -a -t cobbler_var_lib_t "/var/lib/tftpboot/boot(/.*)?"
