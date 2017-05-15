firewall {
    all-ping enable
    broadcast-ping disable
    ipv6-receive-redirects disable
    ipv6-src-route disable
    ip-src-route disable
    log-martians enable
    name VPN {
        default-action drop
        description ""
        rule 1 {
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
        rule 2 {
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
        rule 3 {
            action accept
            description "Allow LAN access"
            destination {
                address 172.16.0.0/24
            }
            log disable
            protocol all
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
        rule 21 {
            action accept
            description "Allow IKE for VPN Server"
            destination {
                port 500
            }
            log disable
            protocol udp
        }
        rule 22 {
            action accept
            description "Allow L2TP for VPN Server"
            destination {
                port 1701
            }
            log disable
            protocol udp
        }
        rule 23 {
            action accept
            description "Allow ESP for VPN Server"
            log disable
            protocol esp
        }
        rule 24 {
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
        address 172.16.0.1/24
        description "Local 2"
        duplex auto
        speed auto
    }
    ethernet eth2 {
        description Local
        duplex auto
        speed auto
    }
    ethernet eth3 {
        description Local
        duplex auto
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
        mtu 1500
        switch-port {
            interface eth2 {
            }
            interface eth3 {
            }
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
                start 172.17.0.25
                stop 172.17.0.45
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
