# gNMIC - Colector de Telemetría

## Descripción

**gNMIC** es un cliente gNMI (gRPC Network Management Interface) de código abierto desarrollado por OpenConfig. En este laboratorio, gNMIC actúa como colector de telemetría, suscribiéndose a los dispositivos Nokia para recibir métricas en tiempo real.

## Configuración

### Archivo de Configuración Principal

```yaml
# configs/gnmic/config.yml

username: admin
password: admin
port: 57400
timeout: 10s
skip-verify: true
encoding: json_ietf
```

### Loader de Contenedores Docker

gNMIC utiliza un **loader de Docker** para descubrir automáticamente los dispositivos del laboratorio:

```yaml
loader:
  type: docker
  address: unix:///run/docker.sock
  filters:
    # Dispositivos SR Linux
    - containers:
        - label: clab-node-kind=nokia_srlinux
      network:
        label: containerlab
      port: "57400"
      config:
        username: admin
        password: lab123
        skip-verify: true
        encoding: proto
        subscriptions:
          - srl_platform
          - srl_apps
          - srl_if_stats
          - srl_if_lag_stats
          - srl_net_instance
          - srl_bgp_stats
          - srl_event_handler_stats
    
    # Dispositivos SROS (SRSIM)
    - containers:
        - label: clab-node-kind=nokia_srsim
      network:
        label: containerlab
      port: "57400"
      config:
        username: admin
        password: lab123
        insecure: true
        encoding: json
        subscriptions:
          - sros_ports_stats
          - sros_router_bgp
          - sros_router_interface
          - sros_router_isis
          - sros_router_route_table
          - sros_system
          - sros_service_stats
          - sros_temperature_stats
          - sros_fan_stats
          - sros_ludb
          - sros_vpls_sap_all
```

!!! info "Auto-Discovery"
    
    El loader de Docker descubre automáticamente todos los contenedores con las etiquetas `clab-node-kind=nokia_srlinux` o `clab-node-kind=nokia_srsim`, eliminando la necesidad de configurar cada dispositivo manualmente.

## Suscripciones

### Nokia SR Linux

```yaml
subscriptions:
  srl_platform:
    paths:
      - /platform/control[slot=*]/cpu[index=all]/total
      - /platform/control[slot=*]/memory
    mode: stream
    stream-mode: sample
    sample-interval: 5s

  srl_apps:
    paths:
      - /system/app-management/application[name=*]
    mode: stream
    stream-mode: sample
    sample-interval: 5s

  srl_if_stats:
    paths:
      - /interface[name=ethernet-1/*]/statistics
      - /interface[name=*]/subinterface[index=*]/statistics/
      - /interface[name=ethernet-1/*]/oper-state
      - /interface[name=ethernet-1/*]/traffic-rate
    mode: stream
    stream-mode: sample
    sample-interval: 5s

  srl_net_instance:
    paths:
      - /network-instance[name=*]/oper-state
      - /network-instance[name=*]/route-table/ipv4-unicast/statistics/
      - /network-instance[name=*]/route-table/ipv6-unicast/statistics/
    mode: stream
    stream-mode: sample
    sample-interval: 5s

  srl_bgp_stats:
    paths:
      - /network-instance[name=*]/protocols/bgp/statistics
      - /network-instance[name=*]/protocols/bgp/group[group-name=*]/statistics
    mode: stream
    stream-mode: sample
    sample-interval: 5s
```

### Nokia SROS

```yaml
subscriptions:
  sros_ports_stats:
    paths:
      - /state/port/oper-state
      - /state/port/statistics/
      - /state/port/ethernet/statistics/
    stream-mode: sample
    sample-interval: 5s
  
  sros_router_bgp:
    paths:
      - /state/router/bgp/statistics/
      - /state/router/bgp/statistics/routes-per-family/
      - /state/router/bgp/neighbor/statistics/
    stream-mode: sample
    sample-interval: 5s
  
  sros_router_interface:
    paths:
      - /state/router/interface/ipv4/statistics/
      - /state/router/interface/ipv6/statistics/
      - /state/router/interface/statistics/
    stream-mode: sample
    sample-interval: 5s

  sros_system:
    paths:
      - /state/system/cpu[sample-period=1]
      - /state/system/memory-pools/
    stream-mode: sample
    sample-interval: 5s

  sros_service_stats:
    paths:
      - /state/service/vpls[service-name=*]/oper-state
      - /state/service/vprn[service-name=*]/oper-state
    mode: stream
    stream-mode: sample
    sample-interval: 5s

  sros_ludb:
    paths:
      - /state/subscriber-mgmt/local-user-db[name=*]
      - /state/subscriber-mgmt/local-user-db[name=*]/ipoe
    stream-mode: sample
    sample-interval: 5s

  sros_vpls_sap_all:
    paths:
      - /state/service/vpls[service-name=*]/sap[sap-id=*]
    stream-mode: sample
    sample-interval: 10s

  sros_temperature_stats:
    paths:
      - /state/card[slot-number=*]/hardware-data/temperature
      - /state/card[slot-number=*]/mda[mda-slot=*]/hardware-data/temperature
    stream-mode: sample
    sample-interval: 5s
```

## Output a Prometheus

gNMIC expone las métricas en formato Prometheus:

```yaml
outputs:
  prom:
    type: prometheus
    listen: :9273
    path: /metrics
    export-timestamps: true
    strings-as-labels: true
    debug: false
    event-processors:
      - trim-sros-prefixes
      - add-labels
      - trim-regex
      - group-by-interface
      - up-down-map
```

## Procesadores de Eventos

Los procesadores transforman las métricas antes de exportarlas:

```yaml
processors:
  # Elimina el prefijo /state de los nombres de métricas SROS
  trim-sros-prefixes:
    event-strings:
      value-names:
        - "^/state/.*"
      transforms:
        - trim-prefix:
            apply-on: "name"
            prefix: "/state"

  # Extrae etiquetas de los paths
  add-labels:
    event-extract-tags:
      value-names:
        - /router/route-table/unicast/(?P<family>[a-zA-Z0-9-_:]+)/statistics/(?P<protocol>[a-zA-Z0-9-_:]+)/([a-zA-Z0-9-_:]+)
        - /router/bgp/statistics/routes-per-family/(?P<family>[a-zA-Z0-9-_:]+)/([a-zA-Z0-9-_:]+)

  # Agrupa métricas por interfaz
  group-by-interface:
    event-group-by:
      tags:
        - interface_name

  # Convierte oper-state up/down a 1/0
  up-down-map:
    event-strings:
      value-names:
        - oper-state
      transforms:
        - replace:
            apply-on: "value"
            old: "up"
            new: "1"
        - replace:
            apply-on: "value"
            old: "down"
            new: "0"
```

## Verificación

### Ver logs de suscripción

```bash
docker logs gnmic -f
```

### Verificar métricas expuestas

```bash
# Desde el host
curl http://10.77.1.12:9273/metrics | head -100

# Métricas de puertos SROS
curl -s http://10.77.1.12:9273/metrics | grep port_statistics

# Métricas de CPU
curl -s http://10.77.1.12:9273/metrics | grep cpu

# Métricas de interfaces SR Linux
curl -s http://10.77.1.12:9273/metrics | grep interface_statistics
```

### Verificar conexiones gNMI

```bash
# Ver suscripciones activas
docker exec gnmic gnmic --config /gnmic-config.yml subscribe --path /
```

## Ejemplo de Métricas

```text
# HELP port_statistics_in_octets 
# TYPE port_statistics_in_octets gauge
port_statistics_in_octets{port_id="1/1/c1/1",source="bng1"} 1.234567e+09

# HELP port_oper_state 
# TYPE port_oper_state gauge
port_oper_state{port_id="1/1/c1/1",source="bng1"} 1

# HELP system_cpu_usage 
# TYPE system_cpu_usage gauge
system_cpu_usage{sample_period="1",source="bng1"} 15.5

# HELP interface_statistics_in_octets 
# TYPE interface_statistics_in_octets gauge
interface_statistics_in_octets{interface_name="ethernet-1/1",source="tx"} 5.6789e+08
```
