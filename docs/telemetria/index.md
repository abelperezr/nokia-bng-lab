# Stack de Telemetría

## Arquitectura de Monitoreo

El laboratorio implementa un stack de telemetría moderno basado en **gNMI (gRPC Network Management Interface)** para la recolección de métricas en tiempo real de todos los dispositivos Nokia.

```mermaid
graph LR
    subgraph Dispositivos Nokia
        BNG1[BNG1<br>7750 SR-7]
        BNG2[BNG2<br>7750 SR-7]
        TX[TX<br>SR Linux]
        SW[Switch<br>7250 IXR-ec]
        OLT[OLT<br>7250 IXR-ec]
    end
    
    subgraph Stack de Telemetría
        GNMIC[gNMIC<br>Collector]
        PROM[Prometheus<br>TSDB]
        GRAF[Grafana<br>Visualization]
    end
    
    BNG1 -->|gNMI:57400| GNMIC
    BNG2 -->|gNMI:57400| GNMIC
    TX -->|gNMI:57400| GNMIC
    SW -->|gNMI:57400| GNMIC
    OLT -->|gNMI:57400| GNMIC
    
    GNMIC -->|:9273/metrics| PROM
    PROM -->|:9090| GRAF
```

## Componentes

<div class="grid cards" markdown>

-   :material-database-export:{ .lg .middle } __gNMIC__

    ---
    
    Colector de telemetría gNMI que se suscribe a métricas de los dispositivos y las expone en formato Prometheus
    
    [:octicons-arrow-right-24: Configuración](gnmic.md)

-   :material-database:{ .lg .middle } __Prometheus__

    ---
    
    Base de datos de series temporales que almacena las métricas recolectadas por gNMIC
    
    [:octicons-arrow-right-24: Configuración](prometheus.md)

-   :material-chart-areaspline:{ .lg .middle } __Grafana__

    ---
    
    Plataforma de visualización con dashboards predefinidos para Nokia SROS y SR Linux
    
    [:octicons-arrow-right-24: Configuración](grafana.md)

</div>

## Métricas Recolectadas

### Nokia SROS (BNG, Switch, OLT)

| Categoría | Métricas |
|-----------|----------|
| **Puertos** | Estado operacional, estadísticas de tráfico, errores |
| **BGP** | Estadísticas de sesión, rutas por familia |
| **Interfaces** | Estadísticas IPv4/IPv6, contadores |
| **ISIS** | Estadísticas del protocolo |
| **Tabla de Rutas** | Contadores IPv4/IPv6 |
| **Sistema** | CPU, memoria, temperatura |
| **Servicios** | Estado operacional VPLS/VPRN |
| **Subscriber Mgmt** | Local User DB, sesiones |

### Nokia SR Linux (TX)

| Categoría | Métricas |
|-----------|----------|
| **Platform** | CPU, memoria |
| **Interfaces** | Estadísticas, estado operacional, traffic-rate |
| **Network Instance** | Estado, estadísticas de rutas |
| **BGP** | Estadísticas de grupo y globales |
| **LAG** | Estadísticas LACP |
| **Applications** | Estado de aplicaciones del sistema |

## Acceso a los Servicios

| Servicio | URL | Credenciales |
|----------|-----|--------------|
| Grafana | http://localhost:3030 | admin / admin |
| Prometheus | http://localhost:9090 | N/A |
| gNMIC Metrics | http://gnmic:9273/metrics | N/A |

## Flujo de Datos

```mermaid
sequenceDiagram
    participant Device as Nokia Device
    participant GNMIC as gNMIC
    participant PROM as Prometheus
    participant GRAF as Grafana
    
    Note over Device,GNMIC: 1. Suscripción gNMI
    GNMIC->>Device: Subscribe Request
    Device->>GNMIC: Subscribe Response (stream)
    
    loop Cada sample-interval
        Device->>GNMIC: Notification (métricas)
        GNMIC->>GNMIC: Procesar y transformar
    end
    
    Note over GNMIC,PROM: 2. Scrape Prometheus
    loop Cada 5s
        PROM->>GNMIC: GET /metrics
        GNMIC->>PROM: Métricas en formato Prometheus
        PROM->>PROM: Almacenar en TSDB
    end
    
    Note over PROM,GRAF: 3. Consultas PromQL
    GRAF->>PROM: PromQL Query
    PROM->>GRAF: Resultados
    GRAF->>GRAF: Renderizar Dashboard
```

## Configuración en lab.yml

```yaml
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
    GF_SECURITY_ADMIN_PASSWORD: admin
```

## Verificación del Stack

### Verificar gNMIC

```bash
# Ver logs de gNMIC
docker logs gnmic

# Verificar métricas expuestas
curl http://10.77.1.12:9273/metrics | head -50
```

### Verificar Prometheus

```bash
# Acceder a la UI
firefox http://localhost:9090

# Verificar targets
curl http://localhost:9090/api/v1/targets
```

### Verificar Grafana

```bash
# Acceder a la UI
firefox http://localhost:3030

# Login: admin / admin
```

## Troubleshooting

!!! warning "Problemas Comunes"
    
    **gNMIC no conecta a dispositivos**
    
    - Verificar que gRPC está habilitado en el dispositivo
    - Verificar credenciales (admin/lab123)
    - Verificar puerto 57400 accesible
    
    **Prometheus no tiene datos**
    
    - Verificar que gNMIC está exponiendo métricas
    - Revisar target status en Prometheus UI
    
    **Grafana sin datos**
    
    - Verificar datasource Prometheus está configurado
    - Verificar queries en los paneles
