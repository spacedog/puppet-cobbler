require 'pathname'

Puppet::Type.newtype(:cobbler_distro) do
  desc "Puppet type for cobbler distro object"

  ensurable

  # Parameters
  newparam(:name, :namevar => true) do
    desc "A string identifying the distribution"
    munge do |value|
      value.downcase
    end
    def insync?(is)
      is.downcase == should.downcase
    end
  end

  newparam(:path) do
    desc "Local path or rsync location"
    validate do |value|
      if value
        unless Pathname.new(value).absolute? || value =~ /^rsync:\/\/.*$/
          raise ArgumentError, "%s is not a valid directory or rsync location." % value
        end
      end
    end
  end
  autorequire(:file) do
    self[:path] if self[:path] and Pathname.new(self[:path]).absolute?
  end

  # Properties
  newproperty(:arch) do
    desc "Sets the architecture for the PXE bootloader"
    newvalues(:i386, :x86_64, :ia64, :ppc, :ppc64, :s390, :arm)
    defaultto(:x86_64)
  end

  newproperty(:owners, :array_matching => :all) do
    desc "List of users and groups as specified in /etc/cobbler/users.conf"
    defaultto(:admin)
  end

  newproperty(:kernel) do
    desc "An absolute filesystem path to a kernel image"
    validate do |value|
      unless Pathname.new(value).absolute?
        raise ArgumentError, "%s is not a valid path" % value
      end
    end
  end

  newproperty(:initrd) do
    desc "An absolute filesystem path to a initrd image"
    validate do |value|
      unless Pathname.new(value).absolute?
        raise ArgumentError, "%s is not a valid path" % value
      end
    end
  end

  newproperty(:comment) do
    desc "An optional comment to associate with this distro"
  end
end
