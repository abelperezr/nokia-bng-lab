# Requisitos del Sistema

## Hardware Mínimo

| Recurso | Mínimo | Recomendado |
|---------|--------|-------------|
| **CPU** | 8 cores | 16+ cores |
| **RAM** | 32 GB | 64 GB |
| **Almacenamiento** | 100 GB SSD | 200 GB NVMe |
| **Red** | 1 Gbps | 10 Gbps |

!!! warning "Memoria RAM"
    Cada nodo Nokia SR-SIM requiere aproximadamente **8-12 GB de RAM**. Con 2 BNGs + OLT + Switch, se necesitan al menos 32 GB disponibles.

## Sistema Operativo

| Distribución | Versión | Estado |
|--------------|---------|--------|
| Ubuntu | 22.04 LTS | ✅ Soportado |
| Ubuntu | 24.04 LTS | ✅ Soportado |
| Debian | 12 | ✅ Soportado |
| RHEL/Rocky | 9.x | ⚠️ Requiere ajustes |

## Software Requerido

### Docker

```bash
# Instalar Docker
curl -fsSL https://get.docker.com | sh

# Agregar usuario al grupo docker
sudo usermod -aG docker $USER

# Verificar instalación
docker --version
# Docker version 24.0.x o superior
```

### Containerlab

```bash
# Instalar Containerlab
bash -c "$(curl -sL https://get.containerlab.dev)"

# Verificar instalación
containerlab version
# Containerlab v0.55.x o superior
```

### Imágenes Docker

#### Nokia SR-SIM (BNG, Switch, OLT)

```bash
# Descargar imagen SR-SIM
# Requiere acceso al portal de Nokia

# Cargar imagen localmente
docker load -i sros-sim-24.7.R1.img.tar.gz

# Verificar
docker images | grep vrnetlab/vr-sros
```

#### Nokia SR Linux (TX)

```bash
# Descargar desde ghcr.io
docker pull ghcr.io/nokia/srlinux:24.7.2

# Verificar
docker images | grep srlinux
```

#### Contenedores Auxiliares

```bash
# gNMIc - Telemetría
docker pull ghcr.io/openconfig/gnmic:latest

# Prometheus
docker pull prom/prometheus:latest

# Grafana
docker pull grafana/grafana:latest

# Network Multitool (RADIUS, ONTs)
docker pull ghcr.io/srl-labs/network-multitool
```

## Licencias Nokia

### Ubicación

```text
configs/license/SR_SIM_license.txt
```

### Verificar Licencia


!!! info "Obtener Licencia"
    Las licencias SR-SIM están disponibles para partners y clientes de Nokia a través del portal de soporte. Para evaluación, contacte a su representante de Nokia.




## Puertos de Red

| Puerto | Servicio | Descripción |
|--------|----------|-------------|
| 3000 | Grafana | Dashboard web |
| 9090 | Prometheus | Métricas |
| 9273 | gNMIc | Exportador Prometheus |
| 1812/UDP | RADIUS Auth | Autenticación |
| 1813/UDP | RADIUS Acct | Accounting |
| 22 | SSH | Acceso a dispositivos |
| 57400 | gNMI | Telemetría Nokia |
| 830 | NETCONF | Configuración |


## Estructura de Archivos

```text
nokia-bng-lab/
├── configs/
│   ├── lab.yml              # Definición del laboratorio
│   ├── license/
│   │   └── SR_SIM_license.txt
│   ├── sros/
│   │   ├── config-bng.txt   # Config BNG1
│   │   └── config-bng-2.txt # Config BNG2
│   ├── switch/
│   │   └── switch.txt
│   ├── olt/
│   │   └── olt.txt
│   ├── srlinux/
│   │   └── tx/
│   │       └── srl.txt
│   ├── radius/
│   │   ├── authorize
│   │   ├── clients.tmpl.conf
│   │   └── radiusd.conf
│   ├── gnmic/
│   │   └── config.yml
│   ├── prometheus/
│   │   └── prometheus.yml
│   └── grafana/
│       ├── datasource.yml
│       ├── dashboards.yml
│       └── dashboards/
│           ├── SROS-Dashboard.json
│           └── srlinux-telemetry-dashboard.json
├── Underlay.png
└── Overlay.png
```
