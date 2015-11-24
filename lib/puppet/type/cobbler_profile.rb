require 'pathname'

Puppet::Type.newtype(:cobbler_profile) do
  desc "Puppet type for cobbler profile object"

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

  newproperty(:kickstart) do
    desc "Path to kickstart template"
    validate do |value|
      if value
        unless Pathname.new(value).absolute? 
          raise ArgumentError, "%s is not a valid path" % value
        end
      end
    end
  end
  autorequire(:file) do
    self[:kickstart] if self[:kickstart] and Pathname.new(self[:kickstart]).absolute?
  end

  # Properties
  newproperty(:distro) do
    desc "Distribution (Parent distribution)"
    validate do |value|
      raise ArgumentError, "%s is not valid value for distro" % value  unless value
    end
  end
  autorequire(:cobbler_distro) do
    self[:distro] if self[:distro]
  end


  newproperty(:repos, :array_matching => :all) do
    desc "Repos to auto-assign to this profile"
  end
  autorequire(:cobbler_repo) do
    self[:repos] if self[:repos]
  end

  newproperty(:kopts, :array_matching => :all) do
    desc "Kernel Options"
  end

end
