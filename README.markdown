# Puppet DNS module #

This is a set of two types and providers to manage hosted DNS systems.
This is done with the help of the ruby library Fog, so it can manage AWS Route 53, Zerigo 
and other DNS hosters.

# Usage #

```
dnszone {
    "planetpuppet.org":
        ensure => present,
        email => "brice@daysofwonder.com",
        yaml_fog_file => "./fog.yaml"
}

dnsrr {
    "www.planetpuppet.org":
        type => "A",
        value => "2.4.6.9",
        ensure => present
}
```

The fog.yaml file contains the fog provider and credentials as in this Route 53
examples:

fog.yaml:
```yaml
---
  provider: aws
  aws_access_key_id: ...
  aws_secret_access_key: ...
```

Refer to the Fog manual to use a different DNS provider: http://fog.io/1.0.0/dns/
