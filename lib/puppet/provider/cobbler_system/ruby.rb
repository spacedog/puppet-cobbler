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
    # To add a system only name and profile is required
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

  def interfaces=(value)
    value.each do |interface,params|
      cmd_args = []
      cmd_args << "system edit --name=#{@resource[:name]} --interface=#{interface}".split(' ')
      params.each do |param,val|
        cmd_args << "--#{param.tr('_','-')}=#{val.tr('_','-')}"
      end
      cobbler(cmd_args)
    end
  end

end
