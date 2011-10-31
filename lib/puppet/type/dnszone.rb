Puppet::Type.newtype(:dnszone) do
  @doc = "Manage a DNS zone"

  ensurable

  newparam(:name) do
    desc "Zone name, this must be a domain name"

    isnamevar
  end

  newparam(:email) do
    desc "E-mail admin of the zone"
  end

  newparam(:yaml_fog_file) do
    desc "Path to a yaml file containing the fog credentials and provider - ignore if the dnszone puppet provider is not fog"
    # check provider is fog?
  end

  autorequire(:file) do
    [@parameters[:yaml_fog_file]]
  end
end