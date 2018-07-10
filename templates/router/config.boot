firewall {
    all-ping enable
    broadcast-ping disable
    group {
      address-group dns-servers {
          description "DNS Servers"
          address ${primary_dns_server}
          address ${secondary_dns_server}
      }
      address-group pcf-routers {
          description "PCF HTTP/S Routers"
          ${gorouter_address_group}
      }
      address-group pcf-tcp-routers {
          description "PCF TCP Routers"
          ${tcp_router_address_group}
      }
      address-group pcf-diego-brains {
          description "Diego Brains"
          ${brain_address_group}
      }
      network-group pcf-subnets {
          description "PCF Subnets"
          network "${infrastructure_cidr}"
          network "${deployment_cidr}"
          network "${services_cidr}"
          network "${dynamic_cidr}"
          network "${container_cidr}"
      }
      network-group pcf-director-subnets {
          description "PCF BOSH Director Networks"
          network ${bootstrap_cidr}
          network ${infrastructure_cidr}
      }
      port-group bosh-ports {
          description "BOSH Ports"
          ${bosh_port_group}
      }
      port-group gorouter-ports {
          description "PCF Router Ports"
          ${gorouter_port_group}
      }
      port-group tcp-router-ports {
          description "PCF TCP Routing Ports"
          ${tcp_router_port_group}
      }
    }
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
                address ${local_cidr}
            }
            log disable
            protocol all
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
            action accept
            description "Allow invalid HTTPS packets to the ESXi API to work around handshake timeouts"
            destination {
                address ${vsphere_ip}
                port 443
            }
            log disable
            protocol tcp
            state {
                established disable
                invalid enable
                new disable
                related disable
            }
        }
        rule 30 {
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
        rule 40 {
            action accept
            description "Allow Local Access to the vSphere environment"
            destination {
                address ${vmware_cidr}
                port 22,80,443,5480
            }
            log disable
            protocol tcp
            source {
                address ${local_cidr}
            }
        }
        rule 50 {
            action accept
            description "Allow VPN Access to the vSphere environment"
            destination {
                address ${vmware_cidr}
                port 22,80,443,5480
            }
            log disable
            protocol tcp
            source {
                address ${vpn_cidr}
            }
        }
        rule 60 {
            action accept
            description "Allow Bootstrap access to the vSphere environment"
            destination {
                address ${vmware_cidr}
            }
            log disable
            protocol tcp
            source {
                address ${bootstrap_cidr}
            }
        }
        rule 70 {
            action accept
            description "Allow PCF infrastructure access to the vSphere environment"
            destination {
                address ${vmware_cidr}
            }
            log disable
            protocol tcp
            source {
                address ${infrastructure_cidr}
            }
        }
        rule 80 {
          action accept
          description "Allow Kubernetes access to vCenter"
          destination {
            address ${vmware_cidr}
          }
          source {
            address ${container_cidr}
          }
          log disable
          protocol tcp
        }
        rule 90 {
            action accept
            description "Allow VPN access to remote console"
            destination {
                address ${vmware_cidr}
                port 902,9443
            }
            log disable
            protocol tcp
            source {
                address ${vpn_cidr}
            }
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
            action accept
            description "Allow invalid HTTPS packets to the ESXi API to work around handshake timeouts"
            destination {
                address ${vsphere_ip}
                port 443
            }
            log disable
            protocol tcp
            state {
                established disable
                invalid enable
                new disable
                related disable
            }
        }
        rule 30 {
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
        rule 40 {
            action accept
            description "Allow outbound web traffiC"
            destination {
                port 80,443
            }
            log disable
            protocol tcp
        }
        rule 50 {
            action accept
            description "Allow outbound DNS traffic"
            destination {
                group {
                    address-group dns-servers
                }
                port 53
            }
            log disable
            protocol tcp_udp
        }
        rule 60 {
            action accept
            description "Allow outbound NTP traffic"
            destination {
                port 123
            }
            log disable
            protocol udp
        }
        rule 70 {
            action accept
            description "Allow SSH traffic to GitHub"
            destination {
                address 192.30.252.0/22
                port 22
            }
            log disable
            protocol tcp
        }
        rule 80 {
            action accept
            description "All SSH traffic to GitHub"
            destination {
                address 185.199.108.0/22
                port 22
            }
            log disable
            protocol tcp
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
                address ${bootstrap_cidr}
                // use the port group we've defined
                group {
                  port-group bosh-ports
                }
            }
            log disable
            protocol tcp
            source {
                address ${local_cidr}
            }
        }
        rule 40 {
            action accept
            description "Allow VPN access to bootstrap environment"
            destination {
                address ${bootstrap_cidr}
                group {
                  port-group bosh-ports
                }
            }
            log disable
            protocol tcp
            source {
                address ${vpn_cidr}
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
            action accept
            description "Allow invalid packets over HTTPS"
            destination {
                address ${vsphere_ip}
                port 443
            }
            log disable
            protocol tcp
            state {
                established disable
                invalid enable
                new disable
                related disable
            }
        }
        rule 30 {
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
        rule 40 {
            action accept
            description "Allow PCF internal calls"
            destination {
                group {
                    network-group pcf-subnets
                }
            }
            log disable
            protocol tcp_udp
            source {
                group {
                    network-group pcf-subnets
                }
            }
        }
        rule 50 {
            action accept
            description "Allow PCF internal pings"
            destination {
                group {
                    network-group pcf-subnets
                }
            }
            log disable
            protocol icmp
            source {
                group {
                    network-group pcf-subnets
                }
            }
        }
        rule 60 {
            action accept
            description "Allow LBs access to PCF Routers"
            destination {
                group {
                    address-group pcf-routers
                }
                port 80,443,8080
            }
            log disable
            protocol tcp
            source {
                address ${balancer_internal_cidr}
            }
        }
        rule 65 {
            action accept
            description "Allow LBs access to PCF TCP Routers"
            destination {
                group {
                    address-group pcf-tcp-routers
                }
            }
            log disable
            protocol tcp
            source {
                address ${balancer_internal_cidr}
            }
        }
        rule 70 {
            action accept
            description "Allow outbound web traffic from PCF applications"
            destination {
                port 80,443
            }
            log disable
            protocol tcp
            source {
                address ${deployment_cidr}
            }
        }
        rule 80 {
            action accept
            description "Allow outbound DNS traffic"
            destination {
                group {
                    address-group dns-servers
                }
                port 53
            }
            log disable
            protocol tcp_udp
        }
        rule 90 {
            action accept
            description "Allow outbound NTP traffic"
            destination {
                port 123
            }
            log disable
            protocol udp
        }
        rule 100 {
            action accept
            description "Allow pings to reduce spurious Ops Manager errors/warnings"
            destination {
                group {
                    network-group pcf-subnets
                }
            }
            log disable
            protocol icmp
            source {
                group {
                    network-group pcf-director-subnets
                }
            }
        }
        rule 110 {
          action accept
          description "Allow Kubernetes access to vCenter"
          destination {
            address ${vmware_cidr}
          }
          source {
            address ${container_cidr}
          }
          log disable
          protocol tcp
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
            description "Allow PCF internal calls"
            destination {
                group {
                    network-group pcf-subnets
                }
            }
            log disable
            protocol tcp_udp
            source {
                group {
                    network-group pcf-subnets
                }
            }
        }
        rule 40 {
            action accept
            description "Allow PCF internal pings"
            destination {
                group {
                    network-group pcf-subnets
                }
            }
            log disable
            protocol icmp
            source {
                group {
                    network-group pcf-subnets
                }
            }
        }
        rule 45 {
            action accept
            description "Allow pings for BOSH to instantiate VMs"
            destination {
                group {
                    network-group pcf-subnets
                }
            }
            log disable
            protocol icmp
            source {
                group {
                    network-group pcf-director-subnets
                }
            }
        }
        rule 50 {
            action accept
            description "Allow access to PCF web APIs and routers"
            destination {
                group {
                    address-group pcf-routers
                    port-group gorouter-ports
                }
            }
            source {
              address ${balancer_external_cidr}
            }
            log disable
            protocol tcp
        }
        rule 60 {
            action accept
            description "Allow access to TCP routers"
            destination {
                group {
                    address-group pcf-tcp-routers
                    port-group tcp-router-ports
                }
            }
            source {
              address ${balancer_external_cidr}
            }
            log disable
            protocol tcp
        }
        rule 70 {
            action accept
            description "Allow SSH access to applications"
            destination {
                group {
                    address-group pcf-diego-brains
                }
                port 22
            }
            source {
              address ${balancer_external_cidr}
            }
            log disable
            protocol tcp
        }
        rule 80 {
            action accept
            description "Allow local access to configure the load balancer environment"
            destination {
                address ${balancer_external_cidr}
                port 4444
            }
            log disable
            protocol tcp
            source {
                address ${local_cidr}
            }
        }
        rule 85 {
            action accept
            description "Allow VPN Access to configure the load balancer environment"
            destination {
                address ${balancer_external_cidr}
                port 4444
            }
            log disable
            protocol tcp
            source {
                address ${vpn_cidr}
            }
        }
        rule 90 {
            action accept
            description "Allow access to the load balancers"
            destination {
                address ${balancer_external_cidr}
                port 443
            }
            log disable
            protocol tcp
        }
        rule 95 {
            action accept
            description "Allow access to Ops Manager and director"
            destination {
                address ${infrastructure_cidr}
                port 443
            }
            log disable
            protocol tcp
        }
        rule 100 {
            action accept
            description "Allow SSH access to applications"
            destination {
                port 2222
                group {
                  address-group pcf-diego-brains
                }
            }
            log disable
            protocol tcp
            source {
              address ${balancer_internal_cidr}
            }
        }
        rule 110 {
            action accept
            description "Enable SSH load balancing"
            destination {
                address 172.26.0.30
                port 2222
            }
            log disable
            protocol tcp
        }
        rule 120 {
            action accept
            description "Manage infrastructure over VPN via SSH"
            destination {
                address ${infrastructure_cidr}
                port 22
            }
            log disable
            protocol tcp
            source {
                address ${vpn_cidr}
            }
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
        address "${vmware_port_ip}"
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
        address ${bootstrap_port_ip}
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
        address ${infrastructure_port_ip}
        address ${deployment_port_ip}
        address ${balancer_external_port_ip}
        address ${balancer_internal_port_ip}
        address ${services_port_ip}
        address ${dynamic_port_ip}
        address ${container_port_ip}
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
        address ${management_port_ip}
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
            subnet ${local_cidr} {
                default-router "${router_ip}"
                dns-server "${router_ip}"
                lease 86400
                start ${local_dhcp_start_addr}  {
                    stop ${local_dhcp_end_addr}
                }
            }
        }
        shared-network-name LAN2 {
            authoritative enable
            subnet ${management_cidr} {
                default-router ${management_port_ip}
                dns-server ${management_port_ip}
                lease 86400
                start ${management_dhcp_start_addr}
                    stop ${management_dhcp_end_addr}
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
        user ${admin_user} {
            authentication {
                plaintext-password ${admin_password}
                public-keys ${admin_user}@${router_fqdn} {
                    key ${admin_key_type}
                    type ${admin_public_key}
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
                  ${vpn_users}
                }
                mode local
            }
            client-ip-pool {
                start ${vpn_start_address}
                stop ${vpn_end_address}
            }
            dhcp-interface eth0
            dns-servers {
                server-1 ${primary_dns_server}
                server-2 ${secondary_dns_server}
            }
            ipsec-settings {
                authentication {
                    mode pre-shared-secret
                    pre-shared-secret ${vpn_psk}
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
