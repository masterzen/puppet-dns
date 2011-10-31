#!/usr/bin/env rspec
require 'spec_helper'

describe Puppet::Type.type(:dnszone) do

  it "should have a 'name' parameter'" do
    Puppet::Type.type(:dnszone).new(:name => "planetpuppet.org")[:name].should == "planetpuppet.org"
  end

  it "should have a 'email' parameter'" do
    Puppet::Type.type(:dnszone).new(:name => "planetpuppet.org", :email => "hostmaster@puppetlabs.com")[:email].should == "hostmaster@puppetlabs.com"
  end

  it "should have an ensure property" do
    Puppet::Type.type(:dnszone).attrtype(:ensure).should == :property
  end

  it "should have a yaml_fog_file parameter" do
    Puppet::Type.type(:dnszone).new(:name => "planetpuppet.org", :yaml_fog_file => "fog.yaml")[:yaml_fog_file].should == "fog.yaml"
  end

  describe "when validating attribute values" do
    before do
      @provider = stub 'provider', :class => Puppet::Type.type(:dnszone).defaultprovider, :clear => nil
      Puppet::Type.type(:dnszone).defaultprovider.stubs(:new).returns(@provider)
    end

    it "should support :present as a value to :ensure" do
      Puppet::Type.type(:dnszone).new(:name => "planetpuppet.org", :ensure => :present)
    end

    it "should support :absent as a value to :ensure" do
      Puppet::Type.type(:dnszone).new(:name => "planetpuppet.org", :ensure => :absent)
    end
  end
end
