# Prometheus - Base de Datos de Métricas

## Descripción

**Prometheus** es una base de datos de series temporales (TSDB) que almacena las métricas recolectadas por gNMIC. Proporciona un lenguaje de consultas (PromQL) para analizar y agregar métricas.

## Configuración

### Archivo de Configuración

```yaml
# configs/prometheus/prometheus.yml

global:
  scrape_interval: 5s

scrape_configs:
  - job_name: "gnmic"
    static_configs:
      - targets: ["gnmic:9273"]
```

!!! info "Scrape Interval"
    
    Prometheus hace scrape de las métricas de gNMIC cada 5 segundos, sincronizado con el sample-interval de las suscripciones gNMI.

## Acceso

| Parámetro | Valor |
|-----------|-------|
| URL | http://localhost:9090 |
| Puerto interno | 9090 |
| Puerto externo | 9090 |

## Interfaz Web

### Explorador de Métricas

1. Acceder a http://localhost:9090
2. En el campo de consulta, escribir el nombre de la métrica
3. Click en "Execute" para ver los resultados

### Targets

Para verificar que Prometheus está recolectando métricas de gNMIC:

1. Ir a Status → Targets
2. Verificar que el target `gnmic:9273` está en estado "UP"

## Consultas PromQL

### Métricas de Puertos

```promql
# Octetos de entrada por puerto
port_statistics_in_octets

# Octetos de salida por puerto del BNG1
port_statistics_out_octets{source="bng1"}

# Tasa de cambio de octetos (bytes/seg)
rate(port_statistics_in_octets[1m])

# Estado operacional de puertos
port_oper_state
```

### Métricas de Sistema

```promql
# Uso de CPU
system_cpu_usage

# Memoria utilizada
system_memory_pools_summary_current_total_in_use

# CPU por dispositivo
system_cpu_usage{source=~"bng.*"}
```

### Métricas de Servicios

```promql
# Estado de servicios VPLS
service_vpls_oper_state

# Estado de servicios VPRN
service_vprn_oper_state

# Servicios en estado down
service_vpls_oper_state == 0
```

### Métricas de Interfaces SR Linux

```promql
# Estadísticas de interfaces
interface_statistics_in_octets{source="tx"}

# Tasa de tráfico
interface_traffic_rate_in_bps{source="tx"}

# Estado operacional
interface_oper_state
```

### Métricas de Subscriber Management

```promql
# Estado de Local User DB
subscriber_mgmt_local_user_db_oper_state

# Sesiones IPoE
subscriber_mgmt_local_user_db_ipoe
```

## API de Prometheus

### Query instantáneo

```bash
curl 'http://localhost:9090/api/v1/query?query=port_oper_state'
```

### Query de rango

```bash
curl 'http://localhost:9090/api/v1/query_range?query=rate(port_statistics_in_octets[5m])&start=2024-01-01T00:00:00Z&end=2024-01-01T01:00:00Z&step=60s'
```

### Ver targets

```bash
curl 'http://localhost:9090/api/v1/targets'
```

### Ver métricas disponibles

```bash
curl 'http://localhost:9090/api/v1/label/__name__/values'
```

## Retención de Datos

Por defecto, Prometheus retiene los datos por 15 días. Para modificar esto:

```yaml
# En lab.yml, modificar el cmd de prometheus
prometheus:
  cmd: --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.retention.time=30d
```

## Verificación

### Verificar que Prometheus está funcionando

```bash
# Ver logs
docker logs prometheus

# Verificar health
curl http://localhost:9090/-/healthy

# Verificar que está listo
curl http://localhost:9090/-/ready
```

### Verificar métricas de gNMIC

```bash
# Consultar directamente
curl -s 'http://localhost:9090/api/v1/query?query=up{job="gnmic"}' | jq

# Respuesta esperada
{
  "status": "success",
  "data": {
    "resultType": "vector",
    "result": [
      {
        "metric": {
          "__name__": "up",
          "instance": "gnmic:9273",
          "job": "gnmic"
        },
        "value": [1234567890, "1"]
      }
    ]
  }
}
```

## Alertas (Opcional)

Prometheus puede configurarse con alertas para notificar problemas:

```yaml
# Ejemplo de regla de alerta
groups:
  - name: network_alerts
    rules:
      - alert: PortDown
        expr: port_oper_state == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Puerto {{ $labels.port_id }} en {{ $labels.source }} está down"
```
