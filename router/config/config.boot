firewall {
    all-ping enable
    broadcast-ping disable
    ipv6-receive-redirects disable
    ipv6-src-route disable
    ip-src-route disable
    log-martians enable

    name VPN_INBOUND {
        default-action drop
        description "VPN subnet"
        rule 10 {
            action accept
            description "Allow established/related"
            log disable
            protocol all
            state {
                established enable
                invalid disable
                new disable
                related enable
            }
        }
        rule 20 {
            action drop
            description "Drop invalid state"
            log disable
            protocol all
            state {
                established disable
                invalid enable
                new disable
                related disable
            }
        }
        rule 30 {
            action accept
            description "Allow LAN access"
            destination {
                address 172.16.0.0/24
            }
            log disable
            protocol all
        }
    }
    name VSPHERE_OUT {
        default-action drop
        description "Access from the vSphere environment"
        enable-default-log
        rule 10 {
            action accept
            description "Allow established/related"
            log disable
            protocol all
            state {
                established enable
                invalid disable
                new disable
                related enable
            }
        }
        rule 20 {
            action drop
            description "Drop invalid state"
            log disable
            protocol all
            state {
                established disable
                invalid enable
                new disable
                related disable
            }
        }
        rule 30 {
            action accept
            description "Allow Local Access to the vSphere environment"
            destination {
                address 172.19.0.0/26
                port 22,80,443
            }
            log disable
            protocol tcp
            source {
                address 172.16.0.0/24
            }
        }
        rule 40 {
            action accept
            description "Allow VPN Access to the vSphere environment"
            destination {
                address 172.19.0.0/26
                port 22,80,443
            }
            log disable
            protocol tcp
            source {
                address 172.17.0.0/24
            }
        }
        rule 50 {
            action accept
            description "Allow Bootstrap access to the vSphere environment"
            destination {
                address 172.19.0.0/26
            }
            log disable
            protocol tcp
            source {
                address 172.20.0.0/26
            }
        }
        rule 60 {
            action accept
            description "Allow PCF infrastructure access to the vSphere environment"
            destination {
                address 172.19.0.0/26
            }
            log disable
            protocol tcp
            source {
                address 172.24.0.0/26
            }
        }
    }
    name VSPHERE_IN {
        default-action drop
        description "Access from the vSphere environment"
        enable-default-log
        rule 10 {
            action accept
            description "Allow established/related"
            log disable
            protocol all
            state {
                established enable
                invalid disable
                new disable
                related enable
            }
        }
        rule 20 {
            action drop
            description "Drop invalid state"
            log disable
            protocol all
            state {
                established disable
                invalid enable
                new disable
                related disable
            }
        }
        rule 30 {
            action accept
            description "Allow outbound web traffic"
            destination {
                port 80,443
            }
            log disable
            protocol tcp
        }
        rule 40 {
            action accept
            description "Allow outbound DNS traffic"
            destination {
                port 53
            }
            log disable
            protocol tcp_udp
        }
        rule 50 {
            action accept
            description "Allow outbound NTP traffic"
            destination {
                port 123
            }
            log disable
            protocol udp
        }
    }
    name BOOTSTRAP_IN {
        default-action drop
        description "Access to the Elastic Runtime routers"
        enable-default-log
        rule 10 {
            action accept
            description "Allow established/related"
            log disable
            protocol all
            state {
                established enable
                invalid disable
                new disable
                related enable
            }
        }
        rule 20 {
            action drop
            description "Drop invalid state"
            log disable
            protocol all
            state {
                established disable
                invalid enable
                new disable
                related disable
            }
        }
        rule 30 {
            action accept
            description "Allow outbound web traffiC"
            destination {
                port 80,443
            }
            log disable
            protocol tcp
        }
        rule 40 {
            action accept
            description "Allow outbound DNS traffic"
            destination {
                port 53
            }
            log disable
            protocol tcp_udp
        }
        rule 50 {
            action accept
            description "Allow outbound NTP traffic"
            destination {
                port 123
            }
            log disable
            protocol udp
        }
    }
    name BOOTSTRAP_OUT {
        default-action drop
        description "Access to the Elastic Runtime routers"
        enable-default-log
        rule 10 {
            action accept
            description "Allow established/related"
            log disable
            protocol all
            state {
                established enable
                invalid disable
                new disable
                related enable
            }
        }
        rule 20 {
            action drop
            description "Drop invalid state"
            log disable
            protocol all
            state {
                established disable
                invalid enable
                new disable
                related disable
            }
        }
        rule 30 {
            action accept
            description "Allow local access to bootstrap environment"
            destination {
                address 172.20.0.0/26
                port 22,443,6868,8443,8844,25555
            }
            log disable
            protocol tcp
            source {
                address 172.16.0.0/24
            }
        }
        rule 35 {
            action accept
            description "Allow VPN access to bootstrap environment"
            destination {
                address 172.20.0.0/26
                port 22,443,6868,8443,8844,25555
            }
            log disable
            protocol tcp
            source {
                address 172.17.0.0/24
            }
        }
    }
    name PCF_IN {
        default-action drop
        description "Allow Pivotal Cloud Foundry to access the internet and other components"
        enable-default-log
        rule 10 {
            action accept
            description "Allow established/related"
            log disable
            protocol all
            state {
                established enable
                invalid disable
                new disable
                related enable
            }
        }
        rule 20 {
            action drop
            description "Drop invalid state"
            log disable
            protocol all
            state {
                established disable
                invalid enable
                new disable
                related disable
            }
        }
        rule 30 {
            action accept
            description "Allow outbound web traffiC"
            destination {
                port 80,443
            }
            log disable
            protocol tcp
        }
        rule 40 {
            action accept
            description "Allow outbound DNS traffic"
            destination {
                port 53
            }
            log disable
            protocol tcp_udp
        }
        rule 50 {
            action accept
            description "Allow outbound NTP traffic"
            destination {
                port 123
            }
            log disable
            protocol udp
        }
    }
    name PCF_OUT {
        default-action drop
        description "Access ERT components to access the Internet and vSphere"
        enable-default-log
        rule 10 {
            action accept
            description "Allow established/related"
            log disable
            protocol all
            state {
                established enable
                invalid disable
                new disable
                related enable
            }
        }
        rule 20 {
            action drop
            description "Drop invalid state"
            log disable
            protocol all
            state {
                established disable
                invalid enable
                new disable
                related disable
            }
        }
        rule 30 {
            action accept
            description "Allow access to PCF web APIs and routers"
            destination {
                port 80,443
            }
            log disable
            protocol tcp
        }
        rule 40 {
            action accept
            description "Allow access to TCP routers"
            destination {
                port 1024-65535
            }
            log disable
            protocol tcp_udp
        }
        rule 50 {
            action accept
            description "Allow SSH access to applications"
            destination {
                port 22
            }
            log disable
            protocol udp
        }
    }
    name WAN_IN {
        default-action drop
        description "WAN to internal"
        rule 10 {
            action accept
            description "Allow established/related"
            state {
                established enable
                related enable
            }
        }
        rule 20 {
            action drop
            description "Drop invalid state"
            state {
                invalid enable
            }
        }
    }
    name WAN_LOCAL {
        default-action drop
        description "WAN to router"
        rule 10 {
            action accept
            description "Allow established/related"
            state {
                established enable
                related enable
            }
        }
        rule 20 {
            action drop
            description "Drop invalid state"
            state {
                invalid enable
            }
        }
        rule 30 {
            action accept
            description "Allow IKE for VPN Server"
            destination {
                port 500
            }
            log disable
            protocol udp
        }
        rule 40 {
            action accept
            description "Allow L2TP for VPN Server"
            destination {
                port 1701
            }
            log disable
            protocol udp
        }
        rule 50 {
            action accept
            description "Allow ESP for VPN Server"
            log disable
            protocol esp
        }
        rule 60 {
            action accept
            description "Allow NAT Traversal for VPN Server"
            destination {
                port 4500
            }
            log disable
            protocol udp
        }
    }
    receive-redirects disable
    send-redirects enable
    source-validation disable
    syn-cookies enable
}
interfaces {
    ethernet eth0 {
        address dhcp
        description Internet
        duplex auto
        firewall {
            in {
                name WAN_IN
            }
            local {
                name WAN_LOCAL
            }
        }
        speed auto
    }
    ethernet eth1 {
        address 172.19.0.1/26
        description "vSphere Management Network"
        duplex auto
        firewall {
            in {
                name VSPHERE_IN
            }
            out {
                name VSPHERE_OUT
            }
        }
        speed auto
    }
    ethernet eth2 {
        address 172.20.0.1/26
        description "Bootstrap Network"
        duplex auto
        firewall {
            in {
                name BOOTSTRAP_IN
            }
            out {
                name BOOTSTRAP_OUT
            }
        }
        speed auto
    }
    ethernet eth3 {
        address 172.24.0.1/13
        description "PCF Networks"
        duplex auto
        firewall {
            in {
                name PCF_IN
            }
            out {
                name PCF_OUT
            }
        }
        speed auto
    }
    ethernet eth4 {
        description Local
        duplex auto
        speed auto
    }
    loopback lo {
    }
    switch switch0 {
        address 172.18.0.1/24
        description Local
        firewall {

        }
        mtu 1500
        switch-port {
            interface eth4 {
            }
            vlan-aware disable
        }
    }
}
service {
    dhcp-server {
        disabled false
        hostfile-update disable
        shared-network-name LAN1 {
            authoritative enable
            subnet 172.16.0.0/24 {
                default-router 172.16.0.1
                dns-server 172.16.0.1
                lease 86400
                start 172.16.0.38 {
                    stop 172.16.0.243
                }
            }
        }
        shared-network-name LAN2 {
            authoritative enable
            subnet 172.18.0.0/24 {
                default-router 172.18.0.1
                dns-server 172.18.0.1
                lease 86400
                start 172.18.0.38 {
                    stop 172.18.0.243
                }
            }
        }
        use-dnsmasq disable
    }
    dns {
        forwarding {
            cache-size 150
            listen-on eth1
            listen-on switch0
            listen-on eth2
            listen-on eth3
        }
    }
    gui {
        http-port 80
        https-port 443
        older-ciphers enable
    }
    nat {
        rule 5010 {
            description "masquerade for WAN"
            outbound-interface eth0
            type masquerade
        }
    }
    ssh {
        port 22
        protocol-version v2
    }
}
system {
    host-name ubnt
    login {
        user ubnt {
            authentication {
                encrypted-password $6$Py7QMd9.9Osw$mmmSaJ1owmC1J757HELrIHspzI8.FrLDIHdhEOYFOGJ2T23lYHXj6442xbhWMfdc2vs6.w/1cx5C7Ve.XGI.F/
                public-keys crdant@natarajasana.local {
                    key AAAAB3NzaC1yc2EAAAADAQABAAACAQDYoucqC+eBcdKoKvKmu7NgIz7LQhWCdCZXAQFrjj+goO0iXecyO/MmM++PaN+wdNzZpZ2V0M333khXynFW8L+NHq2t2sI9R4n00np/y+t0PU7nDEqK6b3tbTzeTCIUnh+akwG9USjOzkTeXKxaZCgnni5cgrGiVb7cDGEhMconNZamdiGPhpHzpZAosATcydmRCKpvM0fGjhHX09RFG+ukva4v//6RVn5wQWYrYlKJrAnk7YUIWddhuRZqRwFbJh6aDUsDN0naevjn6gFfdEpkGZozx7w0eZ7KRAkk6aVVyRgiXDi/HykCefou7kJFqmwRxthNwPfoKQEDKeQtL1AGmUiFcAMU1eDT56U2cRd/Tpx300iEmoGsem93zRMRPJa3Uot3v8bQabHcM0UdSDD7/gOLOwtVFpflLVNmSoW0R9bH7h/3+zdNPbCp7yH9HLP1py5QMTfMCdCR5aXxkZCJlMIBdG+Lj6QGmZ9BuUrmP1XUzrw9x76jbIkxGyr0+sZAz+5Vj1Us4UroVaKDehZvwut03E4etZFud4D7PKtXPDHYbMyIm3PZKJGFQh7sRjcCQCBMRABkQj8+NqSVMs0g3AU/fJOenY0QvmP/8Fr7AiVnCfvSu1MROGogx4KOpEFSYNWR/jVuebjia/zP/OHcJyY3MAbvJAysMT1NciwdDQ==
                    type ssh-rsa
                }
            }
            level admin
        }
    }
    ntp {
        server 0.ubnt.pool.ntp.org {
        }
        server 1.ubnt.pool.ntp.org {
        }
        server 2.ubnt.pool.ntp.org {
        }
        server 3.ubnt.pool.ntp.org {
        }
    }
    syslog {
        global {
            facility all {
                level notice
            }
            facility protocols {
                level debug
            }
        }
    }
    time-zone UTC
}
vpn {
    ipsec {
        auto-firewall-nat-exclude enable
        ipsec-interfaces {
            interface eth0
        }
        nat-traversal enable
    }
    l2tp {
        remote-access {
            authentication {
                local-users {
                    username crdant {
                        password wireworm-checker-voodoo-unpack
                    }
                }
                mode local
            }
            client-ip-pool {
                start 172.17.0.38
                stop 172.17.0.50
            }
            dhcp-interface eth0
            dns-servers {
                server-1 8.8.8.8
                server-2 8.8.4.4
            }
            ipsec-settings {
                authentication {
                    mode pre-shared-secret
                    pre-shared-secret alone-diction-odyssey-backache
                }
                ike-lifetime 3600
            }
            mtu 1024
        }
    }
}


/* Warning: Do not remove the following line. */
/* === vyatta-config-version: "config-management@1:conntrack@1:cron@1:dhcp-relay@1:dhcp-server@4:firewall@5:ipsec@5:nat@3:qos@1:quagga@2:system@4:ubnt-pptp@1:ubnt-util@1:vrrp@1:webgui@1:webproxy@1:zone-policy@1" === */
/* Release version: v1.9.1.1.4977602.170427.0113 */
