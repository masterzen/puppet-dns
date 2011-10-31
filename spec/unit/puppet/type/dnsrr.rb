#!/usr/bin/env rspec
require 'spec_helper'

describe Puppet::Type.type(:dnsrr) do

  it "should have a 'name' parameter'" do
    Puppet::Type.type(:dnsrr).new(:name => "www.planetpuppet.org")[:name].should == "www.planetpuppet.org"
  end

  it "should have an ensure property" do
    Puppet::Type.type(:dnsrr).attrtype(:ensure).should == :property
  end

  it "should have an type property" do
    Puppet::Type.type(:dnsrr).attrtype(:type).should == :property
  end

  it "should have a value property" do
    Puppet::Type.type(:dnsrr).attrtype(:value).should == :property
  end

  it "should autorequire the dnszone" do
    testzone = Puppet::Type.type(:dnszone).new(:name => "testzone")
    testrr = Puppet::Type.type(:dnsrr).new(:name => "testrr", :zone => "testzone")

    catalog = Puppet::Resource::Catalog.new :testing do |conf|
      [testrr, testzone].each { |resource| conf.add_resource resource }
    end

    rel = testrr.autorequire(catalog)[0]
    rel.source.ref.should == testzone.ref
    rel.target.ref.should == testrr.ref
  end

  describe "when validating attribute values" do
    before do
      @provider = stub 'provider', :class => Puppet::Type.type(:dnsrr).defaultprovider, :clear => nil
      Puppet::Type.type(:dnsrr).defaultprovider.stubs(:new).returns(@provider)
    end

    it "should support :present as a value to :ensure" do
      Puppet::Type.type(:dnsrr).new(:name => "www.planetpuppet.org", :ensure => :present)
    end

    it "should support :absent as a value to :ensure" do
      Puppet::Type.type(:dnsrr).new(:name => "www.planetpuppet.org", :ensure => :absent)
    end
  end
end
