describe Puppet::Type.type(:cobbler_repo) do
  # Validating parameters
  context "when validating parameters" do
    [
      :name,
      :provider
    ].each do |param|
      it "should have a #{param} parameter" do
        expect(Puppet::Type.type(:cobbler_repo).attrtype(param)).to eq(:param)
      end
    end
  end
  # Valiadting properties
  context "when validating properties" do
    [
      :arch,
      :mirror,
      :rpmlist,
      :mirror_locally,
    ].each do |prop|
      it "should have a #{prop} property" do
        expect(Puppet::Type.type(:cobbler_repo).attrtype(prop)).to eq(:property)
      end
    end
  end

  context "when validating parameters values" do
    context "ensure" do
      it "should support :present"  do
        Puppet::Type.type(:cobbler_repo).new(
          :name => "testrepo1",
          :ensure => :present,
        )
      end
      it "should support :absent" do
        Puppet::Type.type(:cobbler_repo).new(
          :name => "testrepo1",
          :ensure => :absent,
        )
      end
    end
  end

  context "when validating properties values" do
    context "arch" do
      [:i386, :x86_64, :ia64, :ppc, :ppc64, :s390, :arm].each do |arch|
        it "should suport #{arch}" do
          Puppet::Type.type(:cobbler_repo).new(
            :name   => "testrepo1",
            :ensure => :present,
            :arch   => arch,
          )
        end
      end
    end
    context "rpmlist" do
      it "should support array as a value" do
        Puppet::Type.type(:cobbler_repo).new(
          :name    => "testrepo1",
          :ensure  => :present,
          :rpmlist => ['package1.rpm', 'package2.rpm'],
        )
      end
      it "should support string as a value" do
        Puppet::Type.type(:cobbler_repo).new(
          :name    => "testrepo1",
          :ensure  => :present,
          :rpmlist => 'package1.rpm'
        )
      end
      it "should default to []" do
        type = Puppet::Type.type(:cobbler_repo).new(
          :name   => "testrepo1",
          :ensure => :present,
        )
        expect(type.should(:rpmlist)).to eq([])
      end
    end
    context "mirror_locally" do
      it "should support :true" do
        Puppet::Type.type(:cobbler_repo).new(
          :name           => "testrepo1",
          :ensure         => :present,
          :mirror_locally => :true,
        )
      end
      it "should support :false" do
        Puppet::Type.type(:cobbler_repo).new(
          :name           => "testrepo1",
          :ensure         => :present,
          :mirror_locally => :false,
        )
      end
      it "raise error if any other value" do
        expect {
          Puppet::Type.type(:cobbler_repo).new(
            :name           => "testrepo1",
            :ensure         => :present,
            :mirror_locally => "some_other_value",
          )
        }.to raise_error(Puppet::ResourceError)
      end
    end
    context "mirror" do
      it "support absolute path" do
        Puppet::Type.type(:cobbler_repo).new(
          :name   => "testrepo1",
          :ensure => :present,
          :mirror => '/path/to/mirror',
        )
      end
      it "support rsync path" do
        Puppet::Type.type(:cobbler_repo).new(
          :name   => "testrepo1",
          :ensure => :present,
          :mirror => 'rsync://path/to/mirror',
        )
      end
      it "support http path" do
        Puppet::Type.type(:cobbler_repo).new(
          :name   => "testrepo1",
          :ensure => :present,
          :mirror => 'http://path/to/mirror',
        )
      end
      it "support https path" do
        Puppet::Type.type(:cobbler_repo).new(
          :name   => "testrepo1",
          :ensure => :present,
          :mirror => 'https://path/to/mirror',
        )
      end
      it "support ftp path" do
        Puppet::Type.type(:cobbler_repo).new(
          :name   => "testrepo1",
          :ensure => :present,
          :mirror => 'ftp://path/to/mirror',
        )
      end
      it "support rhn path" do
        Puppet::Type.type(:cobbler_repo).new(
          :name   => "testrepo1",
          :ensure => :present,
          :mirror => 'rhn://path/to/mirror',
        )
      end
      it "raise error if any other value" do
        expect {
          Puppet::Type.type(:cobbler_repo).new(
            :name   => "testrepo1",
            :ensure => :present,
            :mirror => 'any_other_value',
          )
        }.to raise_error(Puppet::ResourceError)
      end
      it "should default to nil" do
        type = Puppet::Type.type(:cobbler_repo).new(
          :name   => "testrepo1",
          :ensure => :present,
        )
        expect(type.should(:kernel)).nil?
      end
    end
  end
end
