# Topología de Red

## Visión General

Este laboratorio implementa una arquitectura de **red neutral** que permite la conexión de múltiples BNGs (Broadband Network Gateways) a una infraestructura de acceso compartida. El diseño sigue el modelo de redes de acceso neutras donde el operador de infraestructura provee conectividad de capa 2 a múltiples proveedores de servicios.

## Arquitectura Multi-BNG

La topología está diseñada con los siguientes principios:

!!! tip "Principios de Diseño"
    
    - **Escalabilidad**: Permite agregar más BNGs sin modificar la infraestructura de acceso
    - **Aislamiento**: Cada BNG opera de forma independiente con su propio dominio de broadcast
    - **Flexibilidad**: Soporte para diferentes tipos de servicio (residencial, empresarial)
    - **Resiliencia**: Posibilidad de redundancia entre BNGs

## Containerlab Topology

El laboratorio se define en el archivo `lab.yml` con la siguiente estructura:

```yaml
name: lab
prefix: ""

mgmt:
  network: lab
  ipv4-subnet: 10.77.1.0/24

topology:
  nodes:
    # =========================================================================
    # BNG ISP 1
    # =========================================================================
    bng1:
      kind: nokia_srsim
      image: localhost/nokia/srsim:25.10.R2
      mgmt-ipv4: 10.77.1.2
      license: configs/license/SR_SIM_license.txt
      type: sr-7
      components:
        - slot: A
        - slot: B
        - slot: 1
          type: iom5-e
          env:
            NOKIA_SROS_MDA_1: me6-100gb-qsfp28
            NOKIA_SROS_SFM: m-sfm6-7/12
        - slot: 2
          type: iom4-e-b
          env:
            NOKIA_SROS_MDA_1: isa2-bb
            NOKIA_SROS_SFM: m-sfm6-7/12
      startup-config: configs/sros/config-bng.txt
      ports:
        - 56661:22
        - 56662:57400
        - 56663:830
    # =========================================================================
    # BNG ISP 2
    # =========================================================================
    bng2:
      kind: nokia_srsim
      image: localhost/nokia/srsim:25.10.R2
      mgmt-ipv4: 10.77.1.3
      license: configs/license/SR_SIM_license.txt
      type: sr-7
      components:
        - slot: A
        - slot: B
        - slot: 1
          type: iom5-e
          env:
            NOKIA_SROS_MDA_1: me6-100gb-qsfp28
            NOKIA_SROS_SFM: m-sfm6-7/12
        - slot: 2
          type: iom4-e-b
          env:
            NOKIA_SROS_MDA_1: isa2-bb
            NOKIA_SROS_SFM: m-sfm6-7/12
      startup-config: configs/sros/config-bng-2.txt
      ports:
        - 56664:22
        - 56665:57400
        - 56666:830
    # =========================================================================
    # SWITCH 
    # =========================================================================
    switch:
      kind: nokia_srsim
      image: localhost/nokia/srsim:25.10.R2
      license: configs/license/SR_SIM_license.txt
      type: ixr-ec
      components:
        - slot: A
          type: cpm-ixr-ec
          env:
            NOKIA_SROS_MDA_1: m4-1g-tx+20-1g-sfp+6-10g-sfp+
      mgmt-ipv4: 10.77.1.4
      startup-config: configs/switch/switch.txt
      ports:
        - 56667:22
        - 56668:57400
        - 56669:830
    # =========================================================================
    # OLT
    # =========================================================================
    olt:
      kind: nokia_srsim
      image: localhost/nokia/srsim:25.10.R2
      license: configs/license/SR_SIM_license.txt
      type: ixr-ec
      components:
        - slot: A
          type: cpm-ixr-ec
          env:
            NOKIA_SROS_MDA_1: m4-1g-tx+20-1g-sfp+6-10g-sfp+
      mgmt-ipv4: 10.77.1.5
      startup-config: configs/olt/olt.txt
      ports:
        - 56678:22
        - 56671:57400
        - 56672:830

    # =========================================================================
    # ONT1
    # =========================================================================
    ont1:
      kind: linux
      group: leaf
      mgmt-ipv4: 10.77.1.6
      image: ont-ds:latest
      binds:
        - configs/ont/authorized_keys:/tmp/authorized_keys:ro
      env:
        VLAN_ID: "150"
        IFPHY: "eth1"
        IFLAN: "eth2"
        MAC_ADDRESS: "00:D0:F6:01:01:01"
        USER_PASSWORD: "test"
      ports:
        - 56673:22
        - 8081:8080

    # =========================================================================
    # ONT2 
    # =========================================================================
    ont2:
      kind: linux
      group: leaf
      mgmt-ipv4: 10.77.1.7
      image: ont-ds:latest
      binds:
        - configs/ont/authorized_keys:/tmp/authorized_keys:ro
      env:
        VLAN_ID: "150"
        IFPHY: "eth1"
        IFLAN: "eth2"
        MAC_ADDRESS: "00:D0:F6:01:01:02"
        USER_PASSWORD: "test"
      ports:
        - 56674:22
        - 8082:8080
    # =========================================================================
    # RADIUS
    # =========================================================================
    radius:
      kind: linux
      group: server
      mgmt-ipv4: 10.77.1.10
      image: ghcr.io/srl-labs/network-multitool
      binds:
        - configs/radius/interfaces.tmpl:/etc/network/interfaces
        - configs/radius/clients.tmpl.conf:/etc/raddb/clients.conf
        - configs/radius/radiusd.conf:/etc/raddb/radiusd.conf
        - configs/radius/authorize:/etc/raddb/mods-config/files/authorize
        - configs/radius/radius.sh:/client.sh
      exec:
        - bash /client.sh
        - bash -c "echo 'nameserver 10.77.1.10 ' | sudo tee /etc/resolv.conf"
      env:
        USER_PASSWORD: test
    # =========================================================================
    # GNMIC
    # =========================================================================        
    gnmic:
      kind: linux
      group: server
      mgmt-ipv4: 10.77.1.12
      image: ghcr.io/openconfig/gnmic:latest
      binds:
        - configs/gnmic/config.yml:/gnmic-config.yml:ro
        - /var/run/docker.sock:/var/run/docker.sock:ro
      cmd: --config /gnmic-config.yml --log subscribe
      env:
        GNMIC_PASSWORD: lab123
    # =========================================================================
    # PROMETHEUS
    # =========================================================================   
    prometheus:
      kind: linux
      group: server
      mgmt-ipv4: 10.77.1.13
      image: prom/prometheus
      binds:
        - configs/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      ports:
        - 9090:9090
      cmd: --config.file=/etc/prometheus/prometheus.yml
    # =========================================================================
    # GRAFANA
    # ========================================================================= 
    grafana:
      kind: linux
      group: server
      mgmt-ipv4: 10.77.1.14
      image: grafana/grafana:10.3.5
      binds:
        - configs/grafana/datasource.yml:/etc/grafana/provisioning/datasources/datasource.yaml:ro
        - configs/grafana/dashboards.yml:/etc/grafana/provisioning/dashboards/dashboards.yaml:ro
        - configs/grafana/dashboards:/var/lib/grafana/dashboards
      ports:
        - 3030:3000
      env:
        GF_INSTALL_PLUGINS: https://github.com/skyfrank/grafana-flowcharting/releases/download/v1.0.0e/agenty-flowcharting-panel-1.0.0e.231214594-SNAPSHOT.zip;agenty-flowcharting-panel
        GF_ORG_ROLE: "Editor"
        GF_ORG_NAME: "Main Org."
        GF_AUTH_ANONYMOUS_ENABLED: "true"
        GF_AUTH_ANONYMOUS: "true"
        GF_SECURITY_ADMIN_PASSWORD: admin
      cmd: "sh -c grafana cli admin reset-admin-password ${GF_SECURITY_ADMIN_PASSWORD} && /run.sh"
    # =========================================================================
    # IPERF
    # ========================================================================= 
    iperf:
      kind: linux
      mgmt-ipv4: 10.77.1.15
      image: ghcr.io/srl-labs/network-multitool
      ports:
        - 56675:22
      exec:
        - bash -lc "ip link set dev eth1 up || true"
        - bash -lc "ip link set dev eth2 up || true"
        - bash -lc "ip addr flush dev eth1 || true"
        - bash -lc "ip addr flush dev eth2 || true"
        - bash -lc "ip addr add 172.19.1.1/30 dev eth1"
        - bash -lc "ip addr add 172.20.1.1/30 dev eth2"
        - bash -lc "ip route del default"
        - bash -lc "ip route add default via 172.19.1.2"
    # =========================================================================
    # TX
    # =========================================================================
    tx:
      kind: nokia_srlinux
      image: ghcr.io/nokia/srlinux:25.10
      mgmt-ipv4: 10.77.1.16
      startup-config: configs/switch/srl.txt
      ports:
        - 56676:22
      binds:
        - configs/environment/srlinux.rc:/home/admin/.srlinuxrc:rw

    # =========================================================================
    # PC1 
    # =========================================================================
    pc1:
      kind: linux
      group: leaf
      mgmt-ipv4: 10.77.1.17
      image: ghcr.io/srl-labs/network-multitool
      ports:
        - 56677:22
      exec:
        - bash -lc "ip link set dev eth1 up || true"
        - bash -lc "sysctl -w net.ipv6.conf.all.forwarding=0 || true"
        - bash -lc "sysctl -w net.ipv6.conf.eth1.accept_ra=2 || true"
        - bash -lc "sysctl -w net.ipv6.conf.eth1.autoconf=1 || true"
    # =========================================================================
    # CONEXIONES
    # =========================================================================
  links:
    - endpoints: ["bng1:1/1/c1/1", "tx:ethernet-1/1"]
    - endpoints: ["bng2:1/1/c1/1", "tx:ethernet-1/2"]
    - endpoints: ["tx:ethernet-1/3", "switch:1/1/1"]
    - endpoints: ["switch:1/1/3", "olt:1/1/1"]
    - endpoints: ["olt:1/1/2", "ont1:eth1"]
    - endpoints: ["olt:1/1/3", "ont2:eth1"]
    - endpoints: ["bng1:1/1/c2/1", "iperf:eth1"]
    - endpoints: ["bng2:1/1/c2/1", "iperf:eth2"]
    - endpoints: ["ont1:eth2", "pc1:eth1"]

```

## Enlaces de Red

La conectividad entre dispositivos se define en la sección `links`:

```yaml
links:
  # BNG1 <-> TX
  - endpoints: ["bng1:1/1/c1/1", "tx:ethernet-1/1"]
  
  # BNG2 <-> TX
  - endpoints: ["bng2:1/1/c1/1", "tx:ethernet-1/2"]
  
  # TX <-> Switch
  - endpoints: ["tx:ethernet-1/3", "switch:1/1/1"]
  
  # Switch <-> OLT
  - endpoints: ["switch:1/1/3", "olt:1/1/1"]
  
  # OLT <-> ONTs
  - endpoints: ["olt:1/1/2", "ont1:eth1"]
  - endpoints: ["olt:1/1/3", "ont2:eth1"]
  
  # BNGs <-> iPerf (Testing)
  - endpoints: ["bng1:1/1/c2/1", "iperf:eth1"]
  - endpoints: ["bng2:1/1/c2/1", "iperf:eth2"]
  
  # ONT1 <-> PC1 (LAN)
  - endpoints: ["ont1:eth2", "pc1:eth1"]
```

## Direccionamiento de Gestión

Todos los dispositivos están conectados a una red de gestión `10.77.1.0/24`:

| Dispositivo | IP de Gestión | Puerto SSH |
|-------------|---------------|------------|
| BNG1 | 10.77.1.2 | 56661 |
| BNG2 | 10.77.1.3 | 56664 |
| Switch | 10.77.1.4 | 56667 |
| OLT | 10.77.1.5 | 56678 |
| ONT1 | 10.77.1.6 | 56673 |
| ONT2 | 10.77.1.7 | 56674 |
| RADIUS | 10.77.1.10 | - |
| gNMIC | 10.77.1.12 | - |
| Prometheus | 10.77.1.13 | 9090 |
| Grafana | 10.77.1.14 | 3030 |
| iPerf | 10.77.1.15 | 56675 |
| TX | 10.77.1.16 | 56676 |
| PC1 | 10.77.1.17 | 56677 |

## Escalabilidad de la Red Neutral

### Agregar un Nuevo BNG

Para agregar un tercer BNG a la topología:

1. **Definir el nuevo nodo en lab.yml**:
```yaml
bng3:
  kind: nokia_srsim
  image: localhost/nokia/srsim:25.10.R2
  mgmt-ipv4: 10.77.1.18
  type: sr-7
  startup-config: configs/sros/config-bng-3.txt
```

2. **Agregar enlace al TX**:
```yaml
- endpoints: ["bng3:1/1/c1/1", "tx:ethernet-1/4"]
```

3. **Configurar nuevo MAC-VRF en TX**:
```bash
set /network-instance bng3 type mac-vrf
set /network-instance bng3 admin-state enable
set /network-instance bng3 interface ethernet-1/4.70
set /network-instance bng3 interface ethernet-1/3.70
```

4. **Agregar VPLS en Switch y OLT** para la nueva VLAN

5. **Registrar cliente en RADIUS**:
```
client bng3 {
    ipaddr = 10.77.1.18
    secret = testlab123
}
```

!!! success "Modelo de Red Neutral"
    
    Esta arquitectura permite que diferentes ISPs operen sus propios BNGs mientras comparten la infraestructura de acceso (OLT, Switch, TX). Cada ISP recibe tráfico de suscriptores aislado en su propia VLAN/VPLS.
