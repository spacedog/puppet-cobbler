require 'xmlrpc/client'
require 'fileutils'

Puppet::Type.type(:cobbler_profile).provide(:ruby) do
  desc "Provides cobbler profile via cobbler_api"

  # Supports redhat only
  confine    :osfamily => :redhat
  defaultfor :osfamily => :redhat
  commands   :cobbler  => 'cobbler'

  mk_resource_methods
  # generates the following methods via Ruby metaprogramming
  # def version
  #   @property_hash[:version] || :absent
  # end

  # Resources discovery
  def self.instances
    profiles = []
    cserver = XMLRPC::Client.new2('http://127.0.0.1/cobbler_api')
    xmlresult = cserver.call('get_profiles')

    # get properties of current system to @property_hash
    xmlresult.each do |profile|
      profiles << new(
        :name      => profile["name"],
        :ensure    => :present,
        :distro    => profile["distro"],
        :kickstart => profile["kickstart"],
        :kopts     => profile["kopts"],
        :repos     => profile["repos"]
      )
    end
    profiles
  end

  def self.prefetch(resources)
    instances.each do |profile|
      if resource = resources[profile.name]
        resource.provider = profile
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    # To add a profile only name and distro is required
    cobbler( 
            [
              "profile",
              "add",
              "--name=" + @resource[:name],
              "--distro=" + @resource[:distro]
            ]
           )
    # set properties as they are not set by defaut
    properties = [
      "distro",
      "kickstart",
      "repos",
      "kopts"
    ]
    for property in properties
      unless self.send(property) == @resource.should(property) or @resource[property].nil?
        self.set_field(property, @resource.should(property))
      end
    end

    cobbler("sync")
    @property_hash[:ensure] = :present
  end

  def set_field(what, value)
    if value.is_a? Array
      value = "'#{value.join(' ')}'"
    end

    cobbler(
      [
        "profile",
        "edit",
        "--name=" + @resource[:name],
        "--#{what.tr('_','-')}=" + value
      ]
    )
    @property_hash[what] = value
  end

  def destroy
    # remove cobbler profile
    cobbler(
      [
        "profile", 
        "remove",
        "--name=#{@resource[:name]}"
      ]
    )
    @property_hash.clear
  end

  # Setters
  def kickstart=(value)
    raise ArgumentError, '%s: not exists' % value unless File.exists? value
    self.set_field("kickstart", value)
  end

  def distro=(value)
    self.set_field("distro", value)
  end

  def kopts=(value)
    self.set_field("kopts", value)
  end

  def repos=(value)
    self.set_field("repos", value)
  end

end
