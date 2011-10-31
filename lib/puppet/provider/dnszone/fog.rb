require 'puppet/provider/fog'

Puppet::Type.type(:dnszone).provide :fog, :parent => Puppet::Provider::Fog do
  desc "Fog provider for DNS zones."

  confine :feature => :fog

  attr_accessor :dns

  # This creates a bunch of getters/setters for our properties/parameters
  # this is only for prefetch/flush providers
  mk_resource_methods

  # Prefetch/Flush providers
  def self.prefetch(resources)
    resources.each do |name, resource|
      Puppet.debug("prefetching for #{name}")
      dns = dns(resource[:yaml_fog_file])
      if found = dns.zones.all.find { |z| z.domain =~ /^#{Regexp.quote(name)}\.?$/ }
        result = { :ensure => :present }
        result[:email] = found.email if found.respond_to?(:email)
        result[:domain] = found.domain
        resource.provider = new(found, result)
      else
        Puppet.debug("found none #{name}")
        resource.provider = new(nil, :ensure => :absent)
      end
      resource.provider.dns = dns
    end
  end

  def flush
    Puppet.debug("flushing zone #{@property_hash[:domain]}")
    case @property_hash[:ensure]
    when :absent
      @zone.destroy if @zone
    when :present
      if @properties[:ensure] == :absent
        dns.zones.create(:domain => resource[:name], :email => @property_hash[:email])
      else
        @zone.domain = resource[:name]
        @zone.email = @property_hash[:email] if @zone.respond_to?(:email)
        @zone.save
      end
    end
    @property_hash.clear
  end

  def zone
    @zone
  end

  def initialize(zone, *args)
    @zone = zone
    super(*args)

    @properties = @property_hash.dup
  end
end