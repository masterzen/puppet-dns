Puppet::Type.newtype(:dnsrr) do
  @doc = "Manage a DNS Resource Record"

  ensurable

  newparam(:name) do
    desc "RR name, this is usually a domain name, but for PTR resource record it will be an IP address"

    isnamevar
  end

  newproperty(:type) do
    defaultto(:A)
    newvalues(:A, :AAAA, :CNAME, :MX, :SRV, :TXT, :PTR)
  end

  newproperty(:value) do
    isrequired
    validate do |value|
      raise ArgumentError, "Empty values are not allowed" if value == ""
    end
  end

  validate do
    begin
      case self[:type]
      when :A, :AAAA
        IPAddr.new(self[:value])
      end
    rescue
      raise ArgumentError, "Invalid IP address #{self[:value]} for given type #{self[:type]}"
    end
  end

  newparam(:zone) do
    defaultto do
      raise ArgumentError, "No zone defined and name is not a FQDN" unless @resource[:name].include?(".")
      @resource[:name].gsub(/^[^.]+\./,'')
    end
  end

  autorequire(:dnszone) do
    [self[:zone]]
  end
end