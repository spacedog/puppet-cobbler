require 'xmlrpc/client'
require 'fileutils'

Puppet::Type.type(:cobbler_distro).provide(:distro) do
  desc "Provides cobbler distro via cobbler_api"

  # Supports redhat only
  confine    :osfamily => :redhat
  defaultfor :osfamily => :redhat
  commands   :cobbler  => '/usr/bin/cobbler'

  mk_resource_methods
  # generates the following methods via Ruby metaprogramming
  # def version
  #   @property_hash[:version] || :absent
  # end

  # Resources discovery
  def self.instances
    distros = []
    cserver = XMLRPC::Client.new2('http://127.0.0.1/cobbler_api')
    xmlresult = cserver.call('get_distros')

    # get properties of current system to @property_hash
    xmlresult.each do |distro|
      distros << new(
        :name    => distro['name'],
        :ensure  => :present,
        :arch    => distro['arch'],
        :kernel  => distro['kernel'],
        :initrd  => distro['initrd'],
        :comment => distro['comment'],
        :owners  => distro['owners']
      )
    end
    distros
  end

  def self.prefetch(resources)
    instances.each do |distro|
      if resource = resources[distro.name]
        resource.provider = distro
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def add
    # Import if not exists
    if @property_hash[:ensure] != :present
      self.import
    end
    # set properties 
    self.arch       = @resource[:arch]    unless @resource[:arch].nil?    or self.arch    == @resource[:arch]
    self.comment    = @resource[:comment] unless @resource[:comment].nil? or self.comment == @resource[:comment]
  
    cobbler('sync')
    @property_hash[:ensure] = :present
  end

  def remove
    # remove cobbler distribution
    Puppet.warning("All child objects of #{@resource[:name]} distribution are deleted")
    
    cobbler(
      "distro", 
      "remove",
      "--recursive",
      "--name=#{@resource[:name]}"
    )
  end

  def import
    # import cobbler distribution
    cmd_arg = "--name=#{@resource[:name]} --arch=#{@resource[:arch]} --path=#{@resource[:path]}" 
    cobbler("import", cmd_arg.split(' '))
  end

  #Setters
  def kernel=(value)
    raise ArgumentError, '%s: not exists' % value unless File.exists? value
    cobbler("distro",
            "edit", 
            "--name=#{@resource[:name]}", 
            "--kernel=\"#{value}\""
            )
    @property_hash[:kernel] = (value)
  end

  def initrd=(value)
    raise ArgumentError, '%s: not exists' % value unless File.exists? value
    cobbler("distro",
            "edit", 
            "--name=#{@resource[:name]}", 
            "--initrd=\"#{value}\""
            )
    @property_hash[:initrd] = (value)
  end

  def comment=(value)
    cobbler(
      "distro", 
      "edit",
      "--name=#{@resource[:name]}",
      "--comment=#{value}"
    )
    @property_hash[:comment] = (value)
  end

  def owners=(value)
    cobbler(
      "distro", 
      "edit",
      "--name=#{@resource[:name]}",
      "--owners=#{value.join(' ')}"
    )
    @property_hash[:owners] = (value)
  end

  def arch=(value)
    cobbler(
      "distro", 
      "edit",
      "--name=#{@resource[:name]}",
      "--arch=#{value}"
    )
    @property_hash[:arch] = (value)
  end
end
