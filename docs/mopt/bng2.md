# BNG2 - Nokia 7750 SR-7

## Información General

| Parámetro | Valor |
|-----------|-------|
| **Hostname** | BNG2 |
| **Modelo** | Nokia 7750 SR-7 (SRSIM) |
| **IP de Gestión** | 10.77.1.3 |
| **Puerto SSH** | 56664 |
| **Puerto gNMI** | 56665 → 57400 |
| **Puerto NETCONF** | 56666 → 830 |

!!! note "Configuración Idéntica"
    
    BNG2 tiene una configuración idéntica a BNG1, con las siguientes diferencias:
    
    - Hostname: "BNG2"
    - IP de gestión: 10.77.1.3
    - Router-ID: 10.77.1.3
    - Conexión al TX: ethernet-1/2 (en lugar de ethernet-1/1)

## Índice de Configuración

- [1. SYSTEM NAME](#1-system-name)
- [2. TIME](#2-time)
- [3. GRPC](#3-grpc)
- [4. NETCONF](#4-netconf)
- [5. SNMP](#5-snmp)
- [6. SSH](#6-ssh)
- [7. SYSTEM USERS PROFILES](#7-system-users-profiles)
- [8. SYSTEM USERS](#8-system-users)
- [9. LOGS](#9-logs)
- [10. CARDS](#10-cards)
- [11. ROUTER BASE](#11-router-base)
- [12. PORT](#12-port)
- [13. RADIUS](#13-radius)
- [14. QOS](#14-qos)
- [15. ESM](#15-esm)
- [16. NAT](#16-nat)
- [17. DHCP SERVERS](#17-dhcp-servers)
- [18. SUBSCRIBER INTERFACE](#18-subscriber-interface)
- [19. GROUP-INTERFACES](#19-group-interfaces)
- [20. VPLS](#20-vpls)

---

## 1. SYSTEM NAME

```text
/configure system
/configure system name "BNG2"
```

---

## 2. TIME

```text
/configure system time
/configure system time zone
/configure system time zone standard
/configure system time zone standard name est
```

---

## 3. GRPC

```text
/configure system grpc admin-state enable
/configure system grpc allow-unsecure-connection
/configure system grpc gnmi auto-config-save true
/configure system grpc rib-api admin-state enable
```

---

## 4. NETCONF

```text
/configure system management-interface netconf listen admin-state enable
/configure system management-interface configuration-save configuration-backups 5
/configure system management-interface configuration-save incremental-saves false
/configure system management-interface netconf auto-config-save true
```

---

## 5. SNMP

```text
/configure system management-interface snmp packet-size 9216
/configure system management-interface snmp streaming admin-state enable
/configure system security snmp community "public" access-permissions r
/configure system security snmp community "public" version v2c
```

---

## 6. SSH

```text
/configure system login-control ssh inbound-max-sessions 30
/configure system security ssh server-cipher-list-v2 cipher 190 name aes256-ctr
/configure system security ssh server-cipher-list-v2 cipher 192 name aes192-ctr
/configure system security ssh server-cipher-list-v2 cipher 194 name aes128-ctr
/configure system security ssh server-cipher-list-v2 cipher 200 name aes128-cbc
/configure system security ssh server-cipher-list-v2 cipher 205 name 3des-cbc
/configure system security ssh server-cipher-list-v2 cipher 225 name aes192-cbc
/configure system security ssh server-cipher-list-v2 cipher 230 name aes256-cbc
/configure system security ssh client-cipher-list-v2 cipher 190 name aes256-ctr
/configure system security ssh client-cipher-list-v2 cipher 192 name aes192-ctr
/configure system security ssh client-cipher-list-v2 cipher 194 name aes128-ctr
/configure system security ssh client-cipher-list-v2 cipher 200 name aes128-cbc
/configure system security ssh client-cipher-list-v2 cipher 205 name 3des-cbc
/configure system security ssh client-cipher-list-v2 cipher 225 name aes192-cbc
/configure system security ssh client-cipher-list-v2 cipher 230 name aes256-cbc
/configure system security ssh server-mac-list-v2 mac 200 name hmac-sha2-512
/configure system security ssh server-mac-list-v2 mac 210 name hmac-sha2-256
/configure system security ssh server-mac-list-v2 mac 215 name hmac-sha1
/configure system security ssh server-mac-list-v2 mac 220 name hmac-sha1-96
/configure system security ssh server-mac-list-v2 mac 225 name hmac-md5
/configure system security ssh server-mac-list-v2 mac 240 name hmac-md5-96
/configure system security ssh client-mac-list-v2 mac 200 name hmac-sha2-512
/configure system security ssh client-mac-list-v2 mac 210 name hmac-sha2-256
/configure system security ssh client-mac-list-v2 mac 215 name hmac-sha1
/configure system security ssh client-mac-list-v2 mac 220 name hmac-sha1-96
/configure system security ssh client-mac-list-v2 mac 225 name hmac-md5
/configure system security ssh client-mac-list-v2 mac 240 name hmac-md5-96
```

---

## 7. SYSTEM USERS PROFILES

```text
/configure system security aaa local-profiles profile "administrative" default-action permit-all
/configure system security aaa local-profiles profile "administrative" entry 10 match "configure system security"
/configure system security aaa local-profiles profile "administrative" entry 10 action permit
/configure system security aaa local-profiles profile "administrative" entry 20 match "show system security"
/configure system security aaa local-profiles profile "administrative" entry 20 action permit
/configure system security aaa local-profiles profile "administrative" entry 30 match "tools perform security"
/configure system security aaa local-profiles profile "administrative" entry 30 action permit
/configure system security aaa local-profiles profile "administrative" entry 40 match "tools dump security"
/configure system security aaa local-profiles profile "administrative" entry 40 action permit
/configure system security aaa local-profiles profile "administrative" entry 42 match "tools dump system security"
/configure system security aaa local-profiles profile "administrative" entry 42 action permit
/configure system security aaa local-profiles profile "administrative" entry 50 match "admin system security"
/configure system security aaa local-profiles profile "administrative" entry 50 action permit
/configure system security aaa local-profiles profile "administrative" entry 100 match "configure li"
/configure system security aaa local-profiles profile "administrative" entry 100 action deny
/configure system security aaa local-profiles profile "administrative" entry 110 match "show li"
/configure system security aaa local-profiles profile "administrative" entry 110 action deny
/configure system security aaa local-profiles profile "administrative" entry 111 match "clear li"
/configure system security aaa local-profiles profile "administrative" entry 111 action deny
/configure system security aaa local-profiles profile "administrative" entry 112 match "tools dump li"
/configure system security aaa local-profiles profile "administrative" entry 112 action deny

/configure system security aaa local-profiles profile "administrative" netconf base-op-authorization action true
/configure system security aaa local-profiles profile "administrative" netconf base-op-authorization cancel-commit true
/configure system security aaa local-profiles profile "administrative" netconf base-op-authorization close-session true
/configure system security aaa local-profiles profile "administrative" netconf base-op-authorization commit true
/configure system security aaa local-profiles profile "administrative" netconf base-op-authorization copy-config true
/configure system security aaa local-profiles profile "administrative" netconf base-op-authorization create-subscription true
/configure system security aaa local-profiles profile "administrative" netconf base-op-authorization delete-config true
/configure system security aaa local-profiles profile "administrative" netconf base-op-authorization discard-changes true
/configure system security aaa local-profiles profile "administrative" netconf base-op-authorization edit-config true
/configure system security aaa local-profiles profile "administrative" netconf base-op-authorization get true
/configure system security aaa local-profiles profile "administrative" netconf base-op-authorization get-config true
/configure system security aaa local-profiles profile "administrative" netconf base-op-authorization get-data true
/configure system security aaa local-profiles profile "administrative" netconf base-op-authorization get-schema true
/configure system security aaa local-profiles profile "administrative" netconf base-op-authorization kill-session true
/configure system security aaa local-profiles profile "administrative" netconf base-op-authorization lock true
/configure system security aaa local-profiles profile "administrative" netconf base-op-authorization validate true

/configure system security aaa local-profiles profile "default" entry 10 match "exec"
/configure system security aaa local-profiles profile "default" entry 10 action permit
/configure system security aaa local-profiles profile "default" entry 20 match "exit"
/configure system security aaa local-profiles profile "default" entry 20 action permit
/configure system security aaa local-profiles profile "default" entry 30 match "help"
/configure system security aaa local-profiles profile "default" entry 30 action permit
/configure system security aaa local-profiles profile "default" entry 40 match "logout"
/configure system security aaa local-profiles profile "default" entry 40 action permit
/configure system security aaa local-profiles profile "default" entry 50 match "password"
/configure system security aaa local-profiles profile "default" entry 50 action permit
/configure system security aaa local-profiles profile "default" entry 60 match "show config"
/configure system security aaa local-profiles profile "default" entry 60 action deny
/configure system security aaa local-profiles profile "default" entry 65 match "show li"
/configure system security aaa local-profiles profile "default" entry 65 action deny
/configure system security aaa local-profiles profile "default" entry 66 match "clear li"
/configure system security aaa local-profiles profile "default" entry 66 action deny
/configure system security aaa local-profiles profile "default" entry 67 match "tools dump li"
/configure system security aaa local-profiles profile "default" entry 67 action deny
/configure system security aaa local-profiles profile "default" entry 68 match "state li"
/configure system security aaa local-profiles profile "default" entry 68 action deny
/configure system security aaa local-profiles profile "default" entry 70 match "show"
/configure system security aaa local-profiles profile "default" entry 70 action permit
/configure system security aaa local-profiles profile "default" entry 75 match "state"
/configure system security aaa local-profiles profile "default" entry 75 action permit
/configure system security aaa local-profiles profile "default" entry 80 match "enable-admin"
/configure system security aaa local-profiles profile "default" entry 80 action permit
/configure system security aaa local-profiles profile "default" entry 90 match "enable"
/configure system security aaa local-profiles profile "default" entry 90 action permit
/configure system security aaa local-profiles profile "default" entry 100 match "configure li"
/configure system security aaa local-profiles profile "default" entry 100 action deny
```

---

## 8. SYSTEM USERS

```text
/configure system security user-params local-user user "admin" restricted-to-home false
/configure system security user-params local-user user "admin" access console true
/configure system security user-params local-user user "admin" access ftp true
/configure system security user-params local-user user "admin" access netconf true
/configure system security user-params local-user user "admin" access grpc true
/configure system security user-params local-user user "admin" password "lab123"
/configure system security user-params local-user user "admin" restricted-to-home false
/configure system security user-params local-user user "admin" access console true
/configure system security user-params local-user user "admin" console member ["administrative"] 
```

---

## 9. LOGS

```text
/configure log filter "1001" named-entry "10" description "Collect only events of major severity or higher"
/configure log filter "1001" named-entry "10" action forward
/configure log filter "1001" named-entry "10" match severity gte major
/configure log log-id "99" description "Default System Log"
/configure log log-id "99" source main true
/configure log log-id "99" destination memory max-entries 500
/configure log log-id "100" description "Default Serious Errors Log"
/configure log log-id "100" filter "1001"
/configure log log-id "100" source main true
/configure log log-id "100" destination memory max-entries 500
```

---

## 10. CARDS

```text
/configure card 1 card-type iom5-e
/configure card 1 mda 1 mda-type me6-100gb-qsfp28
/configure card 2 card-type iom4-e-b
/configure card 2 mda 1 mda-type isa2-bb
/configure sfm 1 sfm-type m-sfm6-7/12
```

---

## 11. ROUTER BASE

```text
/configure router "Base"
/configure router "Base" autonomous-system 65510
/configure router "Base" interface "system"
/configure router "Base" interface "system" ipv4
/configure router "Base" interface "system" ipv4 primary
/configure router "Base" interface "system" ipv4 primary address 1.1.1.1
/configure router "Base" interface "system" ipv4 primary prefix-length 32
```

---

## 12. PORT

### 12.1 PORT TO TX

```text
/configure port 1/1/c1 admin-state enable
/configure port 1/1/c1 connector breakout c1-100g
/configure port 1/1/c1/1 admin-state enable
/configure port 1/1/c1/1 ethernet mode hybrid
/configure port 1/1/c1/1 ethernet encap-type qinq
```

### 12.2 PORT TO IPERF

```text
/configure port 1/1/c2 admin-state enable
/configure port 1/1/c2 connector breakout c1-100g
/configure port 1/1/c2/1 admin-state enable
/configure port 1/1/c2/1 ethernet mode hybrid
```

---

## 13. RADIUS

### 13.1 ROUTER MANAGEMENT

```text
/configure router "management"
/configure router "management" radius
/configure router "management" radius server "radius"
/configure router "management" radius server "radius" address 10.77.1.10
/configure router "management" radius server "radius" secret testlab123
/configure router "management" radius server "radius" accept-coa true
```

### 13.2 RADIUS POLICY

```text
/configure aaa
/configure aaa radius server-policy "radius_policy"
/configure aaa radius server-policy "radius_policy" servers
/configure aaa radius server-policy "radius_policy" servers retry-count 5
/configure aaa radius server-policy "radius_policy" servers router-instance "management"
/configure aaa radius server-policy "radius_policy" servers source-address 10.77.1.3
/configure aaa radius server-policy "radius_policy" servers server 1
/configure aaa radius server-policy "radius_policy" servers server 1 server-name "radius"
/configure aaa radius server-policy "radius_policy" acct-on-off
```

### 13.3 RADIUS ACCOUNTING-POLICY

```text
/configure subscriber-mgmt radius-accounting-policy "accounting"
/configure subscriber-mgmt radius-accounting-policy "accounting" radius-server-policy "radius_policy"
/configure subscriber-mgmt radius-accounting-policy "accounting" session-id-format number
/configure subscriber-mgmt radius-accounting-policy "accounting" queue-instance-accounting
/configure subscriber-mgmt radius-accounting-policy "accounting" queue-instance-accounting admin-state disable
/configure subscriber-mgmt radius-accounting-policy "accounting" queue-instance-accounting interim-update false
/configure subscriber-mgmt radius-accounting-policy "accounting" session-accounting
/configure subscriber-mgmt radius-accounting-policy "accounting" session-accounting admin-state enable
/configure subscriber-mgmt radius-accounting-policy "accounting" session-accounting interim-update true
/configure subscriber-mgmt radius-accounting-policy "accounting" session-accounting host-update true
/configure subscriber-mgmt radius-accounting-policy "accounting" update-interval
/configure subscriber-mgmt radius-accounting-policy "accounting" update-interval interval 720
/configure subscriber-mgmt radius-accounting-policy "accounting" include-radius-attribute
/configure subscriber-mgmt radius-accounting-policy "accounting" include-radius-attribute acct-authentic true
/configure subscriber-mgmt radius-accounting-policy "accounting" include-radius-attribute acct-delay-time true
/configure subscriber-mgmt radius-accounting-policy "accounting" include-radius-attribute acct-triggered-reason true
/configure subscriber-mgmt radius-accounting-policy "accounting" include-radius-attribute called-station-id true
/configure subscriber-mgmt radius-accounting-policy "accounting" include-radius-attribute circuit-id true
/configure subscriber-mgmt radius-accounting-policy "accounting" include-radius-attribute delegated-ipv6-prefix true
/configure subscriber-mgmt radius-accounting-policy "accounting" include-radius-attribute framed-ip-address true
/configure subscriber-mgmt radius-accounting-policy "accounting" include-radius-attribute framed-ip-netmask true
/configure subscriber-mgmt radius-accounting-policy "accounting" include-radius-attribute framed-ipv6-prefix true
/configure subscriber-mgmt radius-accounting-policy "accounting" include-radius-attribute framed-ipv6-route true
/configure subscriber-mgmt radius-accounting-policy "accounting" include-radius-attribute framed-route true
/configure subscriber-mgmt radius-accounting-policy "accounting" include-radius-attribute ipv6-address true
/configure subscriber-mgmt radius-accounting-policy "accounting" include-radius-attribute mac-address true
/configure subscriber-mgmt radius-accounting-policy "accounting" include-radius-attribute nas-identifier true
/configure subscriber-mgmt radius-accounting-policy "accounting" include-radius-attribute nat-port-range true
/configure subscriber-mgmt radius-accounting-policy "accounting" include-radius-attribute remote-id true
/configure subscriber-mgmt radius-accounting-policy "accounting" include-radius-attribute sla-profile true
/configure subscriber-mgmt radius-accounting-policy "accounting" include-radius-attribute std-acct-attributes true
/configure subscriber-mgmt radius-accounting-policy "accounting" include-radius-attribute sub-profile true
/configure subscriber-mgmt radius-accounting-policy "accounting" include-radius-attribute subscriber-id true
/configure subscriber-mgmt radius-accounting-policy "accounting" include-radius-attribute tunnel-server-attrs true
/configure subscriber-mgmt radius-accounting-policy "accounting" include-radius-attribute user-name true
/configure subscriber-mgmt radius-accounting-policy "accounting" include-radius-attribute nas-port-id
/configure subscriber-mgmt radius-accounting-policy "accounting" include-radius-attribute nas-port-type
```

### 13.4 RADIUS AUTHENTICATION-POLICY

```text
/configure subscriber-mgmt radius-authentication-policy "autpolicy"
/configure subscriber-mgmt radius-authentication-policy "autpolicy" password testlab123
/configure subscriber-mgmt radius-authentication-policy "autpolicy" pppoe-access-method pap-chap
/configure subscriber-mgmt radius-authentication-policy "autpolicy" radius-server-policy "radius_policy"
/configure subscriber-mgmt radius-authentication-policy "autpolicy" re-authentication true
/configure subscriber-mgmt radius-authentication-policy "autpolicy" fallback
/configure subscriber-mgmt radius-authentication-policy "autpolicy" fallback action
/configure subscriber-mgmt radius-authentication-policy "autpolicy" fallback action user-db "clientes"
/configure subscriber-mgmt radius-authentication-policy "autpolicy" include-radius-attribute
/configure subscriber-mgmt radius-authentication-policy "autpolicy" include-radius-attribute access-loop-options true
/configure subscriber-mgmt radius-authentication-policy "autpolicy" include-radius-attribute called-station-id true
/configure subscriber-mgmt radius-authentication-policy "autpolicy" include-radius-attribute dhcp-options true
/configure subscriber-mgmt radius-authentication-policy "autpolicy" include-radius-attribute dhcp-vendor-class-id true
/configure subscriber-mgmt radius-authentication-policy "autpolicy" include-radius-attribute mac-address true
/configure subscriber-mgmt radius-authentication-policy "autpolicy" include-radius-attribute nas-identifier true
/configure subscriber-mgmt radius-authentication-policy "autpolicy" include-radius-attribute pppoe-service-name true
/configure subscriber-mgmt radius-authentication-policy "autpolicy" include-radius-attribute remote-id true
/configure subscriber-mgmt radius-authentication-policy "autpolicy" include-radius-attribute tunnel-server-attrs true
/configure subscriber-mgmt radius-authentication-policy "autpolicy" include-radius-attribute acct-session-id
/configure subscriber-mgmt radius-authentication-policy "autpolicy" include-radius-attribute acct-session-id type session
/configure subscriber-mgmt radius-authentication-policy "autpolicy" include-radius-attribute calling-station-id
/configure subscriber-mgmt radius-authentication-policy "autpolicy" include-radius-attribute calling-station-id type sap-string
/configure subscriber-mgmt radius-authentication-policy "autpolicy" include-radius-attribute nas-port-id
/configure subscriber-mgmt radius-authentication-policy "autpolicy" include-radius-attribute nas-port-type
```

### 13.5 AUTHENTICATION ORIGIN

```text
/configure subscriber-mgmt authentication-origin
/configure subscriber-mgmt authentication-origin overrides
/configure subscriber-mgmt authentication-origin overrides priority 3
/configure subscriber-mgmt authentication-origin overrides priority 3 source radius
```

---

## 14. QOS

### 14.1 QOS SAP-INGRESS

```text
/configure qos
/configure qos sap-ingress "10"
/configure qos sap-ingress "10" queue 1
/configure qos sap-ingress "10" queue 11
/configure qos sap-ingress "10" queue 11 multipoint true
/configure qos sap-ingress "10" fc "af"
/configure qos sap-ingress "10" fc "af" queue 1
/configure qos sap-ingress "10" fc "be"
/configure qos sap-ingress "10" fc "be" queue 1
/configure qos sap-ingress "10" fc "ef"
/configure qos sap-ingress "10" fc "ef" queue 1
/configure qos sap-ingress "10" fc "h1"
/configure qos sap-ingress "10" fc "h1" queue 1
/configure qos sap-ingress "10" fc "h2"
/configure qos sap-ingress "10" fc "h2" queue 1
/configure qos sap-ingress "10" fc "l1"
/configure qos sap-ingress "10" fc "l1" queue 1
/configure qos sap-ingress "10" fc "l2"
/configure qos sap-ingress "10" fc "l2" queue 1
/configure qos sap-ingress "10" fc "nc"
/configure qos sap-ingress "10" fc "nc" queue 1
```

### 14.2 QOS SAP-EGRESS

```text
/configure qos sap-egress "10"
/configure qos sap-egress "10" queue 1
/configure qos sap-egress "10" fc be
/configure qos sap-egress "10" fc be queue 1
/configure qos sap-egress "10" fc l2
/configure qos sap-egress "10" fc l2 queue 1
/configure qos sap-egress "10" fc af
/configure qos sap-egress "10" fc af queue 1
/configure qos sap-egress "10" fc l1
/configure qos sap-egress "10" fc l1 queue 1
/configure qos sap-egress "10" fc h2
/configure qos sap-egress "10" fc h2 queue 1
/configure qos sap-egress "10" fc ef
/configure qos sap-egress "10" fc ef queue 1
/configure qos sap-egress "10" fc h1
/configure qos sap-egress "10" fc h1 queue 1
/configure qos sap-egress "10" fc nc
/configure qos sap-egress "10" fc nc queue 1
```

---

## 15. ESM

### 15.1 IPOE POLICY

```text
/configure subscriber-mgmt
/configure subscriber-mgmt ipoe-session-policy "ipoe"
```

### 15.2 PPPOE POLICY

```text
/configure subscriber-mgmt ppp-policy "pppoe"
/configure subscriber-mgmt ppp-policy "pppoe" ppp-authentication pref-pap
/configure subscriber-mgmt ppp-policy "pppoe" ppp-initial-delay true
/configure subscriber-mgmt ppp-policy "pppoe" ppp-mtu 1500
/configure subscriber-mgmt ppp-policy "pppoe" reply-on-padt true
/configure subscriber-mgmt ppp-policy "pppoe" keepalive
/configure subscriber-mgmt ppp-policy "pppoe" keepalive interval 10
/configure subscriber-mgmt ppp-policy "pppoe" keepalive hold-up-multiplier 4
```

### 15.3 SUB-PROFILE

```text
/configure subscriber-mgmt sub-profile "subprofile"
/configure subscriber-mgmt sub-profile "subprofile" radius-accounting
/configure subscriber-mgmt sub-profile "subprofile" radius-accounting policy ["accounting"]
/configure subscriber-mgmt sub-profile "subprofile" radius-accounting session-optimized-stop true
```

### 15.4 SUB-IDENT POLICY

```text
/configure subscriber-mgmt sub-ident-policy "subident"
/configure subscriber-mgmt sub-ident-policy "subident" sla-profile-map
/configure subscriber-mgmt sub-ident-policy "subident" sla-profile-map use-direct-map-as-default true
/configure subscriber-mgmt sub-ident-policy "subident" sub-profile-map
/configure subscriber-mgmt sub-ident-policy "subident" sub-profile-map use-direct-map-as-default true
```

### 15.4 SLA PROFILE

```text
/configure subscriber-mgmt sla-profile "100M" egress qos sap-egress policy-name "10"
/configure subscriber-mgmt sla-profile "100M" egress qos sap-egress overrides queue 1 stat-mode v4-v6
/configure subscriber-mgmt sla-profile "100M" egress qos sap-egress overrides queue 1 rate pir 100000
/configure subscriber-mgmt sla-profile "100M" egress qos sap-egress overrides queue 1 rate cir 100000
/configure subscriber-mgmt sla-profile "100M" host-limits overall 10
/configure subscriber-mgmt sla-profile "100M" host-limits ipv4 dhcp 1
/configure subscriber-mgmt sla-profile "100M" host-limits ipv6 pd-ipoe-dhcp 1
/configure subscriber-mgmt sla-profile "100M" host-limits ipv6 wan-ipoe-dhcp 1
/configure subscriber-mgmt sla-profile "100M" ingress ip-filter "10"
/configure subscriber-mgmt sla-profile "100M" ingress qos sap-ingress policy-name "10"
/configure subscriber-mgmt sla-profile "100M" ingress qos sap-ingress overrides queue 1 stat-mode v4-v6
/configure subscriber-mgmt sla-profile "100M" ingress qos sap-ingress overrides queue 1 rate pir 100000
/configure subscriber-mgmt sla-profile "100M" ingress qos sap-ingress overrides queue 1 rate cir 100000
```

### 15.5 MSAP POLICY

```text
/configure subscriber-mgmt msap-policy "msap" sub-sla-mgmt subscriber-limit 131071
/configure subscriber-mgmt msap-policy "msap" sub-sla-mgmt sub-ident-policy "subident"
/configure subscriber-mgmt msap-policy "msap" sub-sla-mgmt defaults sla-profile "100M"
/configure subscriber-mgmt msap-policy "msap" sub-sla-mgmt defaults sub-profile "subprofile"
/configure subscriber-mgmt msap-policy "msap" sub-sla-mgmt defaults subscriber-id auto-id
/configure subscriber-mgmt msap-policy "msap" sub-sla-mgmt single-sub-parameters profiled-traffic-only true
/configure subscriber-mgmt msap-policy "msap" ies-vprn-only-sap-parameters anti-spoof next-hop-ip-and-mac-addr
/configure subscriber-mgmt msap-policy "msap" ies-vprn-only-sap-parameters ingress qos queuing-type service
```

### 15.6 LOCAL USER DATABASE

```text
/configure subscriber-mgmt local-user-db clientes
```

### 15.7 SHCV POLICY

```text
/configure subscriber-mgmt shcv-policy "host-connectivity-verify"
/configure subscriber-mgmt shcv-policy "host-connectivity-verify" trigger
/configure subscriber-mgmt shcv-policy "host-connectivity-verify" trigger inactivity
/configure subscriber-mgmt shcv-policy "host-connectivity-verify" trigger inactivity admin-state enable
/configure subscriber-mgmt shcv-policy "host-connectivity-verify" trigger inactivity timeout 60
```

---

## 16. NAT

### 16.1 ISA

```text
/configure isa
/configure isa nat-group 1
/configure isa nat-group 1 admin-state enable
/configure isa nat-group 1 redundancy
/configure isa nat-group 1 redundancy active-mda-limit 1
/configure isa nat-group 1 session-limits
/configure isa nat-group 1 session-limits watermarks
/configure isa nat-group 1 session-limits watermarks low 80
/configure isa nat-group 1 session-limits watermarks high 90
/configure isa nat-group 1 mda 2/1
```

### 16.2 NAT FILTER

```text
/configure filter ip-filter "10" default-action accept
/configure filter ip-filter "10" entry 1 match dst-ip address 100.90.0.0
/configure filter ip-filter "10" entry 1 match dst-ip mask 255.255.255.248
/configure filter ip-filter "10" entry 1 action accept
/configure filter ip-filter "10" entry 2 match src-ip address 100.90.0.0
/configure filter ip-filter "10" entry 2 match src-ip mask 255.255.255.248
/configure filter ip-filter "10" entry 2 action nat 
```

### 16.3 VPRN 9999 (NAT OUTSIDE)

```text
/configure service vprn "9999"
/configure service vprn "9999" admin-state enable
/configure service vprn "9999" customer "1"
/configure service vprn "9999" autonomous-system 65520
/configure service vprn "9999" nat
/configure service vprn "9999" nat outside
/configure service vprn "9999" nat outside pool "dtpool"
/configure service vprn "9999" nat outside pool "dtpool" admin-state enable
/configure service vprn "9999" nat outside pool "dtpool" type large-scale
/configure service vprn "9999" nat outside pool "dtpool" nat-group 1
/configure service vprn "9999" nat outside pool "dtpool" mode napt
/configure service vprn "9999" nat outside pool "dtpool" large-scale
/configure service vprn "9999" nat outside pool "dtpool" large-scale subscriber-limit 8
/configure service vprn "9999" nat outside pool "dtpool" large-scale deterministic
/configure service vprn "9999" nat outside pool "dtpool" large-scale deterministic port-reservation 64
/configure service vprn "9999" nat outside pool "dtpool" address-range 100.100.100.100 end 100.100.100.100
```

### 16.3 VPRN 9999 INTERFACE TO-IPERF

```text
/configure service vprn "9999" interface "to_iperf"
/configure service vprn "9999" interface "to_iperf" admin-state enable
/configure service vprn "9999" interface "to_iperf" ipv4 primary
/configure service vprn "9999" interface "to_iperf" ipv4 primary address 172.20.1.2
/configure service vprn "9999" interface "to_iperf" ipv4 primary prefix-length 30
/configure service vprn "9999" interface "to_iperf" sap 1/1/c2/1:0 admin-state enable
```

### 16.3 NAT POLICY

```text
/configure service
/configure service nat
/configure service nat nat-policy "natpol"
/configure service nat nat-policy "natpol" pool
/configure service nat nat-policy "natpol" pool router-instance "9999"
/configure service nat nat-policy "natpol" pool name "dtpool"
/configure service nat nat-policy "natpol" alg
/configure service nat nat-policy "natpol" alg pptp true
/configure service nat nat-policy "natpol" alg rtsp true
/configure service nat nat-policy "natpol" alg sip true
```

### 16.4 VPRN 9998 (NAT INSIDE)

```text
/configure service vprn "9998"
/configure service vprn "9998" admin-state enable
/configure service vprn "9998" customer "1"
/configure service vprn "9998" management
/configure service vprn "9998" management allow-ftp true
/configure service vprn "9998" management allow-ssh true
/configure service vprn "9998" management allow-netconf true
/configure service vprn "9998" management allow-grpc true

/configure service vprn "9998" nat
/configure service vprn "9998" nat inside
/configure service vprn "9998" nat inside large-scale
/configure service vprn "9998" nat inside large-scale nat44
/configure service vprn "9998" nat inside large-scale nat44 max-subscriber-limit 8
/configure service vprn "9998" nat inside large-scale nat44 deterministic
/configure service vprn "9998" nat inside large-scale nat44 deterministic prefix-map 100.90.0.0/29 nat-policy "natpol"
/configure service vprn "9998" nat inside large-scale nat44 deterministic prefix-map 100.90.0.0/29 nat-policy "natpol" admin-state enable
/configure service vprn "9998" nat inside large-scale nat44 deterministic prefix-map 100.90.0.0/29 nat-policy "natpol" map 100.90.0.0 to 100.90.0.7
/configure service vprn "9998" nat inside large-scale nat44 deterministic prefix-map 100.90.0.0/29 nat-policy "natpol" map 100.90.0.0 to 100.90.0.7 first-outside-address 100.100.100.100
```

---

## 17. DHCP SERVERS

### 17.1 DHCP IPv4

```text
/configure service vprn "9998" dhcp-server
/configure service vprn "9998" dhcp-server dhcpv4 "suscriptores"
/configure service vprn "9998" dhcp-server dhcpv4 "suscriptores" admin-state enable
/configure service vprn "9998" dhcp-server dhcpv4 "suscriptores" pool-selection
/configure service vprn "9998" dhcp-server dhcpv4 "suscriptores" pool-selection use-gi-address
/configure service vprn "9998" dhcp-server dhcpv4 "suscriptores" pool-selection use-pool-from-client
/configure service vprn "9998" dhcp-server dhcpv4 "suscriptores" pool "cgnat"
/configure service vprn "9998" dhcp-server dhcpv4 "suscriptores" pool "cgnat" minimum-free
/configure service vprn "9998" dhcp-server dhcpv4 "suscriptores" pool "cgnat" minimum-free percent 3
/configure service vprn "9998" dhcp-server dhcpv4 "suscriptores" pool "cgnat" options
/configure service vprn "9998" dhcp-server dhcpv4 "suscriptores" pool "cgnat" options option dns-server
/configure service vprn "9998" dhcp-server dhcpv4 "suscriptores" pool "cgnat" options option dns-server ipv4-address [8.8.8.8 8.8.4.4]
/configure service vprn "9998" dhcp-server dhcpv4 "suscriptores" pool "cgnat" options option lease-time
/configure service vprn "9998" dhcp-server dhcpv4 "suscriptores" pool "cgnat" options option lease-time duration 315446399
/configure service vprn "9998" dhcp-server dhcpv4 "suscriptores" pool "cgnat" subnet 100.90.0.0/29
/configure service vprn "9998" dhcp-server dhcpv4 "suscriptores" pool "cgnat" subnet 100.90.0.0/29 options
/configure service vprn "9998" dhcp-server dhcpv4 "suscriptores" pool "cgnat" subnet 100.90.0.0/29 options option default-router
/configure service vprn "9998" dhcp-server dhcpv4 "suscriptores" pool "cgnat" subnet 100.90.0.0/29 options option default-router ipv4-address [100.90.0.1]
/configure service vprn "9998" dhcp-server dhcpv4 "suscriptores" pool "cgnat" subnet 100.90.0.0/29 options option lease-time
/configure service vprn "9998" dhcp-server dhcpv4 "suscriptores" pool "cgnat" subnet 100.90.0.0/29 options option lease-time duration 315446399
/configure service vprn "9998" dhcp-server dhcpv4 "suscriptores" pool "cgnat" subnet 100.90.0.0/29 address-range 100.90.0.2 end 100.90.0.7
/configure service vprn "9998" dhcp-server dhcpv4 "suscriptores" pool "cgnat" subnet 100.90.0.0/29 exclude-addresses 100.90.0.1 end 100.90.0.1
```

### 17.2 DHCP IPv6

```text
/configure service vprn "9998" dhcp-server dhcpv6 "suscriptores_v6" admin-state enable
/configure service vprn "9998" dhcp-server dhcpv6 "suscriptores_v6" pool-selection use-pool-from-client
/configure service vprn "9998" dhcp-server dhcpv6 "suscriptores_v6" pool-selection use-link-address scope subnet


/configure service vprn "9998" dhcp-server dhcpv6 "suscriptores_v6" pool "IPv6" delegated-prefix minimum 56
/configure service vprn "9998" dhcp-server dhcpv6 "suscriptores_v6" pool "IPv6" delegated-prefix maximum 64
/configure service vprn "9998" dhcp-server dhcpv6 "suscriptores_v6" pool "IPv6" options option dns-server ipv6-address [2001:4860:4860::8888 2001:4860:4860::8844]


/configure service vprn "9998" dhcp-server dhcpv6 "suscriptores_v6" pool "IPv6" prefix 2001:db8:100::/56 preferred-lifetime 43200
/configure service vprn "9998" dhcp-server dhcpv6 "suscriptores_v6" pool "IPv6" prefix 2001:db8:100::/56 valid-lifetime 86400
/configure service vprn "9998" dhcp-server dhcpv6 "suscriptores_v6" pool "IPv6" prefix 2001:db8:100::/56 renew-time 21600
/configure service vprn "9998" dhcp-server dhcpv6 "suscriptores_v6" pool "IPv6" prefix 2001:db8:100::/56 rebind-time 36000
/configure service vprn "9998" dhcp-server dhcpv6 "suscriptores_v6" pool "IPv6" prefix 2001:db8:100::/56 prefix-type wan-host true
/configure service vprn "9998" dhcp-server dhcpv6 "suscriptores_v6" pool "IPv6" prefix 2001:db8:100::/56 prefix-type pd false


/configure service vprn "9998" dhcp-server dhcpv6 "suscriptores_v6" pool "IPv6" prefix 2001:db8:200::/48 preferred-lifetime 43200
/configure service vprn "9998" dhcp-server dhcpv6 "suscriptores_v6" pool "IPv6" prefix 2001:db8:200::/48 valid-lifetime 86400
/configure service vprn "9998" dhcp-server dhcpv6 "suscriptores_v6" pool "IPv6" prefix 2001:db8:200::/48 renew-time 21600
/configure service vprn "9998" dhcp-server dhcpv6 "suscriptores_v6" pool "IPv6" prefix 2001:db8:200::/48 rebind-time 36000
/configure service vprn "9998" dhcp-server dhcpv6 "suscriptores_v6" pool "IPv6" prefix 2001:db8:200::/48 prefix-type wan-host false
/configure service vprn "9998" dhcp-server dhcpv6 "suscriptores_v6" pool "IPv6" prefix 2001:db8:200::/48 prefix-type pd true
```

---

## 18. SUBSCRIBER INTERFACE

```text
/configure service vprn "9998" interface "loopback"
/configure service vprn "9998" interface "loopback" admin-state enable
/configure service vprn "9998" interface "loopback" loopback true
/configure service vprn "9998" interface "loopback" ipv4
/configure service vprn "9998" interface "loopback" ipv4 local-dhcp-server "suscriptores"
/configure service vprn "9998" interface "loopback" ipv4 primary
/configure service vprn "9998" interface "loopback" ipv4 primary address 9.9.9.9
/configure service vprn "9998" interface "loopback" ipv4 primary prefix-length 32
/configure service vprn "9998" interface "loopback" ipv6 local-dhcp-server "suscriptores_v6"
/configure service vprn "9998" interface "loopback" ipv6 address fd07:47::aaaa prefix-length 128
```

### 18.1 IPV4

```text
/configure service vprn "9998" subscriber-interface "services" ipv4
/configure service vprn "9998" subscriber-interface "services" ipv4 allow-unmatching-subnets true
/configure service vprn "9998" subscriber-interface "services" ipv4 default-dns [8.8.8.8 8.8.4.4]
/configure service vprn "9998" subscriber-interface "services" ipv4 address 100.90.0.1
/configure service vprn "9998" subscriber-interface "services" ipv4 address 100.90.0.1 prefix-length 29
/configure service vprn "9998" subscriber-interface "services" ipv4 dhcp
/configure service vprn "9998" subscriber-interface "services" ipv4 dhcp gi-address 100.90.0.1
```

### 18.1 IPV6

```text
/configure service vprn "9998" subscriber-interface "services" ipv6 allow-unmatching-prefixes true
/configure service vprn "9998" subscriber-interface "services" ipv6 delegated-prefix-length variable
/configure service vprn "9998" subscriber-interface "services" ipv6 prefix 2001:db8:100::/56 host-type wan
/configure service vprn "9998" subscriber-interface "services" ipv6 prefix 2001:db8:200::/48 host-type pd
/configure service vprn "9998" subscriber-interface "services" ipv6 link-local-address address fe80::7e20:64ff:fe84:8365
```

---

## 19. GROUP-INTERFACES
###19.1 HSI RESIDENTIAL

```text
/configure service vprn "9998" subscriber-interface "services" group-interface "gi"
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" admin-state enable
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" radius-auth-policy "autpolicy"
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ingress-stats true
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" oper-up-while-empty true
```

###19.1.1 HSI RESIDENTIAL IPV4

```text
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipv4
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipv4 urpf-check
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipv4 urpf-check mode strict-no-ecmp
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipv4 neighbor-discovery
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipv4 neighbor-discovery populate true
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipv4 dhcp
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipv4 dhcp admin-state enable
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipv4 dhcp server [9.9.9.9]
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipv4 dhcp trusted true
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipv4 dhcp gi-address 100.90.0.1
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipv4 dhcp proxy-server
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipv4 dhcp proxy-server admin-state enable
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipv4 dhcp proxy-server emulated-server 100.90.0.1
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipv4 dhcp lease-populate
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipv4 dhcp lease-populate max-leases 131071
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipv4 dhcp client-applications
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipv4 dhcp client-applications dhcp true
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipv4 dhcp client-applications ppp true
```

###19.1.1 HSI RESIDENTIAL IPV6

```text
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipv6 urpf-check mode strict-no-ecmp
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipv6 dhcp6 pd-managed-route
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipv6 dhcp6 relay admin-state enable

/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipv6 dhcp6 relay server ["fd07:47::aaaa"]

/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipv6 dhcp6 relay server ["fd07:47::aaaa"]
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipv6 dhcp6 relay client-applications dhcp true
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipv6 dhcp6 relay client-applications ppp true
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipv6 dhcp6 proxy-server admin-state enable
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipv6 router-advertisements admin-state enable
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipv6 router-advertisements options other-stateful-configuration true
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipv6 router-advertisements prefix-options autonomous false
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipv6 router-advertisements options managed-configuration true
```

###19.1.3 IPOE SESSION

```text
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipoe-session
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipoe-session admin-state enable
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipoe-session ipoe-session-policy "ipoe"
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipoe-session user-db "clientes"
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipoe-session session-limit 131071
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" ipoe-session sap-session-limit 131071
```

###19.1.4 PPPOE SESSION

```text
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" pppoe
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" pppoe admin-state enable
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" pppoe policy "pppoe"
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" pppoe session-limit 131071
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" pppoe sap-session-limit 131071
/configure service vprn "9998" subscriber-interface "services" group-interface "gi" pppoe user-db "clientes"
```

---

## 20. VPLS

### Capture-SAP

```text
/configure service vpls "capture-sap"
/configure service vpls "capture-sap" admin-state enable
/configure service vpls "capture-sap" service-id 2
/configure service vpls "capture-sap" customer "1"
/configure service vpls "capture-sap" capture-sap 1/1/c1/1:*.*
/configure service vpls "capture-sap" capture-sap 1/1/c1/1:*.* radius-auth-policy "autpolicy"
/configure service vpls "capture-sap" capture-sap 1/1/c1/1:*.* trigger-packet
/configure service vpls "capture-sap" capture-sap 1/1/c1/1:*.* trigger-packet dhcp true
/configure service vpls "capture-sap" capture-sap 1/1/c1/1:*.* trigger-packet dhcp6 true
/configure service vpls "capture-sap" capture-sap 1/1/c1/1:*.* trigger-packet pppoe true
/configure service vpls "capture-sap" capture-sap 1/1/c1/1:*.* msap-defaults
/configure service vpls "capture-sap" capture-sap 1/1/c1/1:*.* msap-defaults policy "msap"
/configure service vpls "capture-sap" capture-sap 1/1/c1/1:*.* msap-defaults service-name "9998"
/configure service vpls "capture-sap" capture-sap 1/1/c1/1:*.* msap-defaults group-interface "gi"
/configure service vpls "capture-sap" capture-sap 1/1/c1/1:*.* ipoe-session
/configure service vpls "capture-sap" capture-sap 1/1/c1/1:*.* ipoe-session admin-state enable
/configure service vpls "capture-sap" capture-sap 1/1/c1/1:*.* ipoe-session ipoe-session-policy "ipoe"
/configure service vpls "capture-sap" capture-sap 1/1/c1/1:*.* ipoe-session user-db "clientes"
/configure service vpls "capture-sap" capture-sap 1/1/c1/1:*.* pppoe
/configure service vpls "capture-sap" capture-sap 1/1/c1/1:*.* pppoe policy "pppoe"
/configure service vpls "capture-sap" capture-sap 1/1/c1/1:*.* pppoe user-db "clientes"
```

| Puerto SSH | 56661 | 56664 |
