#!/usr/bin/env rspec
require 'spec_helper'

require 'puppet/provider/dnsrr/fog'

provider_class = Puppet::Type.type(:dnsrr).provider(:fog)

describe provider_class, :if => Puppet.features.fog? do

  it "should have a parent of Puppet::Provider::Fog" do
    provider_class.should < Puppet::Provider::Fog
  end

  it "should have an instances method" do
    provider_class.should respond_to(:instances)
  end

  describe "when prefetching" do
    before do
      @resource = Puppet::Type.type(:dnsrr).new(:name => "www.planetpuppet.org", :ensure => :present, :type => :A, :value => "1.2.3.4", :zone => "planetpuppet.org")
      @resources = {"www.planetpuppet.org" => @resource}
      @zone = stub_everything 'zone'
      provider_class.stubs(:zone).returns(@zone)
    end

    describe "resources that do not exist" do
      it "should create a provider with :ensure => :absent" do
        provider = stub 'provider', :zone= => false
        record = stub 'record', :name => "puppetlabs.com", :value => "1.2.3.4", :type => :A
        @zone.expects(:records).returns([record])

        provider_class.expects(:new).with(nil, {:ensure => :absent}).returns provider
        @resource.stubs(:provider=).with(provider)
        provider_class.prefetch(@resources)
      end
    end

    describe "resources that exist" do
      it "should create a provider with the results of the find and ensure at present" do
        provider = stub 'provider', :zone= => false
        record = stub 'record', :name => "www.planetpuppet.org", :value => "1.2.3.4", :type => :A
        @zone.expects(:records).returns([record])

        provider_class.expects(:new).with(record, {:ensure => :present, :name => "www.planetpuppet.org", :value => "1.2.3.4", :type => :A}).returns provider

        @resource.stubs(:provider=).with(provider)
        provider_class.prefetch(@resources)
      end
    end
  end

  describe "when being initialized" do
    describe "with a hash" do
      it "should store a copy of the hash as its current properties" do
        instance = provider_class.new(:dnsrr, :one => :two)
        instance.properties.should == {:one => :two}
      end

      it "should store the given found fog zone" do
        instance = provider_class.new(:dnsrr, :one => :two)
        instance.record.should == :dnsrr
      end
    end
  end

  describe "when being flushed" do
    describe "and absent" do
      it "should remove it from fog" do
        record = stub 'fog_record', :name => "www.planetpuppet.org"
        instance = provider_class.new(record, :ensure => :absent)
        record.expects(:destroy)

        instance.flush
      end
    end

    describe "and present" do
      describe "but was absent" do
        it "should create a fog zone" do
          records = stub 'records'
          zone = stub_everything 'fog_zone', :records => records
          resource = stub 'resource', :[] => "www.planetpuppet.org"

          instance = provider_class.new(nil, {:ensure => :absent} )
          instance.resource = resource
          instance.zone = zone
          instance.value = "1.2.3.4"
          instance.type = :A
          instance.ensure = :present

          records.expects(:create).with({ :name => "www.planetpuppet.org", :type => :A, :value => "1.2.3.4" })
          instance.flush
        end
      end

      describe "but was present" do
        it "should modify the fog record" do
          class Fog::DNS::AWS::Record ; end
          record = stub 'fog_record', :name => "www.planetpuppet.org"
          resource = stub 'resource', :[] => "www.planetpuppet.org"
          instance = provider_class.new(record, :ensure => :present, :name => "www.planetpuppet.org", :type => :A, :value => "1.2.3.4")
          instance.resource = resource
          record.expects(:name=).with("www.planetpuppet.org")
          record.expects(:type=).with(:A)
          record.expects(:value=).with("1.2.3.4")
          record.expects(:save)
          instance.flush
        end
      end
    end
  end
end
