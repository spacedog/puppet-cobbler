require 'pathname'
require 'ipaddr'

Puppet::Type.newtype(:cobbler_system) do
  desc "Puppet type for cobbler system object"

  ensurable

  # Parameters
  newparam(:name, :namevar => true) do
    desc "A string identifying the profile"
    munge do |value|
      value.downcase
    end
    def insync?(is)
      is.downcase == should.downcase
    end
  end

  newproperty(:mac_address) do
    desc "MAC Address"
    munge do |value|
      value.downcase
    end
    validate do |value|
      unless /^[a-f0-9]{1,2}(:[a-f0-9]{1,2}){5}$/i.match(value) or value == :random
        raise ArgumentError, "%s is not a valid MAC address" % value
      end
    end
  end

  newproperty(:ip_address) do
    desc "IP Address (Should be used with --interface)"
    validate do |value|
      unless IPAddr.new(value)
        raise ArgumentError, "%s is not a valid IP address" % value
      end
    end
  end

  newproperty(:gateway) do
    desc "Gateway"
    validate do |value|
      unless IPAddr.new(value)
        raise ArgumentError, "%s is not a valid IP address" % value
      end
    end
  end

  newproperty(:netmask) do
    desc "Subnet Mask (Should be used with --interface)"
    validate do |value|
      unless IPAddr.new(value)
        raise ArgumentError, "%s is not a valid IP address" % value
      end
    end
  end

  newproperty(:server) do
    desc "Server Override"
  end

  newproperty(:hostname) do
    desc "System hostname"
  end

  newproperty(:profile) do
    desc "Parent profile"
    validate do |value|
      raise ArgumentError, "Profile must be specified"  if value.nil?
    end
  end

  newparam(:interface) do
    desc "The interface to operate on"
  end

  newproperty(:static) do
    desc "Is this interface static? Should be used with --interface"
    defaultto(:true)
    newvalues(:true, :false)
  end

  validate do
    if self[:ip_address] or self[:netmask] or self[:gateway] or self[:mac_address]
      unless self[:interface] and self[:static] == :true
        raise ArgumentError, "ip_address, gateway, netmask should be used with interface"
      end
    end
  end
end

