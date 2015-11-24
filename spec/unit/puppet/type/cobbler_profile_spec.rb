describe Puppet::Type.type(:cobbler_profile) do
  # Validating parameters
  context "when validating parameters" do
    [
      :name,
      :provider
    ].each do |param|
      it "should have a #{param} parameter" do
        expect(Puppet::Type.type(:cobbler_profile).attrtype(param)).to eq(:param)
      end
    end
  end
  # Valiadting properties
  context "when validating properties" do
    [
      :distro,
      :kickstart,
      :kopts,
      :repos,
    ].each do |prop|
      it "should have a #{prop} property" do
        expect(Puppet::Type.type(:cobbler_profile).attrtype(prop)).to eq(:property)
      end
    end
  end

  context "when validating parameters values" do
    context "ensure" do
      it "should support :present"  do
        Puppet::Type.type(:cobbler_profile).new(
          :name   => "testrepo1",
          :ensure => :present,
          :distro => "testdistro1",
        )
      end
      it "should support :absent" do
        Puppet::Type.type(:cobbler_profile).new(
          :name => "testrepo1",
          :ensure => :absent,
          :distro => "testdistro1",
        )
      end
    end
  end

  context "when validating properties values" do
    context "distro" do
      it "raise error if not set" do
        expect {
          Puppet::Type.type(:cobbler_profile).new(
            :name           => "testrepo1",
            :ensure         => :present,
          )
        }.to raise_error(Puppet::ResourceError)
      end
    end
    context "repos" do
      it "should support array value" do
        Puppet::Type.type(:cobbler_profile).new(
          :name   => "testrepo1",
          :ensure => :present,
          :distro => 'testdistro1',
          :repos  => ['testrepo1','testrepo2'],
        )
      end
      it "should support string value" do
        Puppet::Type.type(:cobbler_profile).new(
          :name   => "testrepo1",
          :ensure => :present,
          :distro => 'testdistro1',
          :repos  => 'testrepo1',
        )
      end
      it "should default to []" do
          Puppet::Type.type(:cobbler_profile).new(
            :name   => "testrepo1",
            :ensure => :present,
            :distro => 'testdistro1',
          )
      end
    end
    context "kopts" do
      it "should support array value" do
        Puppet::Type.type(:cobbler_profile).new(
          :name   => "testrepo1",
          :ensure => :present,
          :distro => 'testdistro1',
          :kopts  => ['testkopt1','testkopts2'],
        )
      end
      it "should support string value" do
        Puppet::Type.type(:cobbler_profile).new(
          :name   => "testrepo1",
          :ensure => :present,
          :distro => 'testdistro1',
          :repos  => 'testkopt1',
        )
      end
      it "should default to []" do
          Puppet::Type.type(:cobbler_profile).new(
            :name   => "testrepo1",
            :ensure => :present,
            :distro => 'testdistro1',
          )
      end
    end
  end
end
