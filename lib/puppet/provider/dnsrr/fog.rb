require 'puppet/provider/fog'

Puppet::Type.type(:dnsrr).provide :fog, :parent => Puppet::Provider::Fog do
  desc "Fog provider for DNS records."

  confine :feature => :fog

  attr_accessor :zone
  attr_reader :record

  # This creates a bunch of getters/setters for our properties/parameters
  # this is only for prefetch/flush providers
  mk_resource_methods

  # Prefetch/Flush providers
  def self.prefetch(resources)
    resources.each do |name, resource|
      Puppet.debug("Prefetching #{name} with #{resource} through #{resource[:zone][:name]}")
      zone = zone(resource)
      if found = zone.records.find { |z| z.name =~ /^#{Regexp.quote(name)}\.?$/ }
        resource.provider = new(found, { :ensure => :present, :name => found.name, :type => found.type,
                                         :value => found.value.is_a?(Array) ? found.value.first : found.value })
      else
        resource.provider = new(nil, :ensure => :absent)
      end
      resource.provider.zone = zone
    end
  end

  def flush
    if @property_hash[:ensure] == :absent
      @record.destroy if @record
    else
      if @record
        if changed?
          if @record.is_a?(::Fog::DNS::AWS::Record)
            # grr, Fog AWS doesn't support change, only separate destroy/create
            # which is not atomic :(
            @record.destroy
          end
          @record.name = resource[:name]
          @record.type = @property_hash[:type]
          @record.value = @property_hash[:value]
          @record.save
        end
      else
        zone.records.create(
          :name => resource[:name],
          :value => @property_hash[:value],
          :type => @property_hash[:type]
        )
      end
    end
    @property_hash.clear
  end

  def changed?
    @record.type != @property_hash[:type] or @record.value != @property_hash[:value]
  end

  def self.zone(resource)
    # let's find our dnszone resource in the catalog
    unless dnszone = resource.catalog.resource("Dnszone[#{resource[:zone]}]")
      raise "Can't find Dnszone[#{resource[:zone]}]"
    end
    dns(dnszone[:yaml_fog_file]).zones.find { |z| z.domain =~ /^#{Regexp.quote(dnszone[:name])}\.?$/ }
  end

  def initialize(record, *args)
    @record = record
    super(*args)

    @properties = @property_hash.dup
  end
end