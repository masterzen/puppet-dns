#!/usr/bin/env rspec
require 'spec_helper'

require 'puppet/provider/fog'

Puppet::Type.type(:dnszone).provide :test, :parent => Puppet::Provider::Fog do
  mk_resource_methods
  def self.prefetch(resources)
  end
  def flush
  end
  def properties
    @property_hash.dup
  end
end

provider_class = Puppet::Type.type(:dnszone).provider(:test)

describe provider_class do
  before do
    @resource = stub("resource", :name => "test")
    @provider = provider_class.new(@resource)
  end

  describe "when an instance" do
    before do
      @instance = provider_class.new(:dnszone)
    end

    it "should have a method for creating the instance" do
      @instance.should respond_to(:create)
    end

    it "should have a method for removing the instance" do
      @instance.should respond_to(:destroy)
    end

    it "should indicate when the instance already exists" do
      @instance = provider_class.new(:ensure => :present)
      @instance.exists?.should be_true
    end

    it "should indicate when the instance does not exist" do
      @instance = provider_class.new(:ensure => :absent)
      @instance.exists?.should be_false
    end

    describe "is being destroyed" do
      it "should set its :ensure value to :absent" do
        @instance.destroy
        @instance.properties[:ensure].should == :absent
      end
    end
  end

  describe "when creating the fog instance", :if => Puppet.features.fog? do
    it "should read the yaml fog file and create a fog attribute hash" do
      File.expects(:read).returns("---
  provider: aws
  aws_access_key_id: keyid
  aws_secret_access_key: accesskey")

      provider_class.fog_options("fog.yaml").should == { :provider => "aws", :aws_access_key_id => "keyid", :aws_secret_access_key => "accesskey" }
    end

    it "should initialize fog with parameters coming from the fog.yaml file" do
      File.expects(:read).returns("---
  provider: aws
  aws_access_key_id: keyid
  aws_secret_access_key: accesskey")

      ::Fog::DNS.expects(:new).with({ :provider => "aws", :aws_access_key_id => "keyid", :aws_secret_access_key => "accesskey" })
      provider_class.dns("fog.yaml")
    end
  end
end
