
dnszone {
    "planetpuppet.org":
        ensure => present,
        email => "brice@planetpuppet.org",
        yaml_fog_file => "./fog.yaml"
    
}

dnsrr {
    "www.planetpuppet.org":
        type => "A",
        value => "2.4.6.9",
        ensure => present,
}
