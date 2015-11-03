require 'xmlrpc/client'
require 'fileutils'

Puppet::Type.type(:cobbler_system).provide(:ruby) do
  desc "Provides cobbler system via cobbler_api"

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
    systems = []
    cserver = XMLRPC::Client.new2('http://127.0.0.1/cobbler_api')
    xmlresult = cserver.call('get_systems')

    # get properties of current system to @property_hash
    xmlresult.each do |system|
      systems << new(
        :name        => system["name"],
        :ensure      => :present,
        :profile     => system["profile"],
        :hostname    => system["hostname"],
        :interfaces  => system["interfaces"],
        :mac_address => system["mac-address"],
        :ip_address  => system["ip-address"],
        :netmask     => system["netmask"],
        :gateway     => system["gateway"],
        :server      => system["server"]
      )
    end
    systems
  end

  def self.prefetch(resources)
    instances.each do |system|
      if resource = resources[system.name]
        resource.provider = system
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
              "system",
              "add",
              "--name=" + @resource[:name],
              "--profile=" + @resource[:profile]
            ]
           )
    # set properties as they are not set by defaut
    properties = [
      :hostname,
      :server,
      :mac_address
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
      value = value.join(' ')
    end

    cobbler(
      [
        "system",
        "edit",
        "--name=" + @resource[:name],
        "--#{what.tr('_','-')}=" + value.to_s
      ]
    )
    @property_hash[what] = value
  end

  def set_field_with(with, what, value)
    if value.is_a? Array
      value = value.join(' ')
    end

    cobbler(
      [
        "system",
        "edit",
        "--name=" + @resource[:name],
        "--#{with}=" + @resource[with],
        "--#{what.tr('_','-')}=" + value.to_s
      ]
    )
    @property_hash[what] = value
  end

  def destroy
    # remove cobbler profile
    cobbler(
      [
        "system", 
        "remove",
        "--name=#{@resource[:name]}"
      ]
    )
    @property_hash.clear
  end
  
  # Getters
  def mac_address
    @property_hash[:interfaces][@resource[:interface]]["mac_address"] || :absent
  end

  def static
    @property_hash[:interfaces][@resource[:interface]]["static"].to_s || :absent
  end

  def ip_address
    @property_hash[:interfaces][@resource[:interface]]["ip_address"] || :absent
  end

  def netmask
    @property_hash[:interfaces][@resource[:interface]]["netmask"] || :absent
  end

  # Setters
  def hostname=(value)
    self.set_field("hostname", value)
  end

  def server=(value)
    self.set_field("server", value)
  end

  def profile=(value)
    self.set_field("profile", value)
  end

  def gateway=(value)
    self.set_field("gateway", value)
  end

  def mac_address=(value)
    self.set_field_with("interface","mac_address", value)
  end

  def static=(value)
    self.set_field_with("interface", "static", value)
  end

  def ip_address=(value)
    self.set_field_with("interface", "ip_address", value)
  end

  def netmask=(value)
    self.set_field_with("interface", "netmask", value)
  end

end
