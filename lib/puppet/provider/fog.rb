class Puppet::Provider::Fog < Puppet::Provider

  # This is mostly for ralsh to list all the managed resources
  def self.instances
    # I fear we can't find any instances without having access to the fog credentials
  end

  # There are two types of providers:
  #  * basic ones, in which you implement property/parameter getters/setters and are supposed to actually fecth/persist
  #  to the managed resource at each call
  #  * prefetch/flush ones, in which you just implement flush and prefetch. Prefetch is called first and you're supposed
  #  to load up all the properties values. When puppet wants you to persist the result, it calls flush with the new values.

  # Ensurable calls
  def create
    @property_hash[:ensure] = :present
    self.class.resource_type.validproperties.each do |property|
      if val = resource.should(property)
        @property_hash[property] = val
      end
    end
  end

  def destroy
    @property_hash[:ensure] = :absent
  end

  def exists?
    @property_hash[:ensure] != :absent
  end

  def self.dns(options)
    ::Fog::DNS.new(fog_options(options))
  end

  def self.fog_options(options = nil)
    YAML.load(File.read(options)).inject({}){|h,(k,v)| h[k.to_sym] = v; h}
  end

  def properties
    @properties.dup
  end
end