#!/usr/bin/env rspec
require 'spec_helper'

require 'puppet/provider/dnszone/fog'

provider_class = Puppet::Type.type(:dnszone).provider(:fog)

describe provider_class, :if => Puppet.features.fog? do

  it "should have a parent of Puppet::Provider::Fog" do
    provider_class.should < Puppet::Provider::Fog
  end

  it "should have an instances method" do
    provider_class.should respond_to(:instances)
  end

  describe "when prefetching" do
    before do
      @resource = Puppet::Type.type(:dnszone).new(:name => "planetpuppet.org", :ensure => :present)
      @resources = {"planetpuppet.org" => @resource}
      @zones = stub 'zones'
      @fog = stub_everything 'fog', :zones => @zones
      provider_class.stubs(:dns).returns(@fog)
    end

    describe "resources that do not exist" do
      it "should create a provider with :ensure => :absent" do
        provider = stub 'provider', :dns => false
        zone = stub 'zone', :domain => "puppetlabs.com"
        @zones.expects(:all).returns([zone])

        provider_class.expects(:new).with(nil, {:ensure => :absent}).returns provider
        @resource.stubs(:provider=).with(provider)
        provider_class.prefetch(@resources)
      end
    end

    describe "resources that exist" do
      it "should create a provider with the results of the find and ensure at present" do
        provider = stub 'provider', :dns => false
        zone = stub 'zone', :domain => "planetpuppet.org"
        @zones.expects(:all).returns([zone])
        provider_class.expects(:new).with(zone, {:ensure => :present, :domain => 'planetpuppet.org'}).returns provider

        @resource.stubs(:provider=).with(provider)
        provider_class.prefetch(@resources)
      end
    end
  end

  describe "when being initialized" do
    describe "with a hash" do
      it "should store a copy of the hash as its current properties" do
        instance = provider_class.new(:dnszone, :one => :two)
        instance.properties.should == {:one => :two}
      end

      it "should store the given found fog zone" do
        instance = provider_class.new(:dnszone, :one => :two)
        instance.zone.should == :dnszone
      end
    end
  end

  describe "when being flushed" do
    describe "and absent" do
      it "should remove it from fog" do
        zone = stub 'fog_zone', :domain => "planetpuppet.org"
        instance = provider_class.new(zone, :ensure => :absent)
        zone.expects(:destroy)

        instance.flush
      end
    end

    describe "and present" do
      describe "but was absent" do
        it "should create a fog zone" do
          zones = stub 'zones'
          fog = stub_everything 'fog', :zones => zones
          resource = stub 'resource', :[] => "planetpuppet.org"

          instance = provider_class.new(nil, {:ensure => :absent} )
          instance.resource = resource
          instance.dns = fog
          instance.email = "host@planetpuppet.org"
          instance.ensure = :present

          zones.expects(:create).with({ :domain => "planetpuppet.org", :email => "host@planetpuppet.org" })
          instance.flush
        end
      end

      describe "but was present" do
        it "should modify the fog zone" do
          zone = stub 'fog_zone', :domain => "planetpuppet.org"
          resource = stub 'resource', :[] => "planetpuppet.org"
          instance = provider_class.new(zone, :ensure => :present, :domain => "planetpuppet.org")
          instance.resource = resource
          zone.expects(:domain=).with("planetpuppet.org")
          zone.expects(:save)
          instance.flush
        end
      end
    end
  end
end
