require 'pathname'
require 'ipaddr'

Puppet::Type.newtype(:cobbler_system) do
  desc "Puppet type for cobbler system object"

  ensurable

  # Parameters
  newparam(:name, :namevar => true) do
    desc "A string identifying the system"
    munge do |value|
      value.downcase
    end
    def insync?(is)
      is.downcase == should.downcase
    end
  end

  newproperty(:interfaces) do
    desc "Interfaces for the system"
    defaultto({})
    validate do |value|
      unless value.is_a? Hash
        raise ArgumentError, "interfaces parameter is not a hash"
      end
      # Validating interfaces parameters
      value.each do |interface, params|
        params.each do |param, val|
        case param
        when 'ip_address','if_gateway', 'netmask'
          unless IPAddr.new(val)
            raise ArgumentError, "%s is not a valid IP address" % val
          end
        when 'mac_address'
          unless /^[a-f0-9]{1,2}(:[a-f0-9]{1,2}){5}$/i.match(val) or val == :random
            raise ArgumentError, "%s is not a valid MAC address" % val
          end
        end
        end
      end
    end

    def insync?(is)
      should.each do |interface, params|
        # Return false if interface is not found on the server
        unless is.has_key? interface
          return false
        end
        # Check interface parameters
        params.each do |param, value|
          unless is[interface][param] == value
            return false
          end
        end
      end
      true
    end
  end

  newproperty(:profile) do
    desc "Parent profile"
    validate do |value|
      raise ArgumentError, "Profile must be specified"  if value.nil?
    end
  end
  autorequire(:cobbler_profile) do
    self[:profile]
  end

  newproperty(:server) do
    desc "Server Override"
  end

  newproperty(:hostname) do
    desc "System hostname"
  end

  validate do
    raise ArgumentError, "Profile is required for system object" unless self[:profile]
  end

end
