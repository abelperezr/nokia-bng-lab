# Grafana - Visualización de Métricas

## Descripción

**Grafana** es la plataforma de visualización que presenta las métricas de red en dashboards interactivos. El laboratorio incluye dashboards predefinidos para Nokia SROS y SR Linux.

## Acceso

| Parámetro | Valor |
|-----------|-------|
| URL | http://localhost:3030 |
| Usuario | admin |
| Password | admin |
| Puerto interno | 3000 |
| Puerto externo | 3030 |

## Configuración

### Datasource

```yaml
# configs/grafana/datasource.yml

apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    url: http://prometheus:9090
    uid: prometheus
    isDefault: true

  - name: Loki
    type: loki
    url: http://loki:3100
    uid: loki
```

### Provisioning de Dashboards

```yaml
# configs/grafana/dashboards.yml

apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    folderUid: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    options:
      path: /var/lib/grafana/dashboards
```

### Variables de Entorno

```yaml
# En lab.yml
grafana:
  env:
    GF_INSTALL_PLUGINS: https://github.com/skyfrank/grafana-flowcharting/releases/download/v1.0.0e/agenty-flowcharting-panel-1.0.0e.231214594-SNAPSHOT.zip;agenty-flowcharting-panel
    GF_ORG_ROLE: "Editor"
    GF_ORG_NAME: "Main Org."
    GF_AUTH_ANONYMOUS_ENABLED: "true"
    GF_AUTH_ANONYMOUS: "true"
    GF_SECURITY_ADMIN_PASSWORD: admin
```

## Dashboards Incluidos

### SROS Dashboard

Dashboard para monitorear dispositivos Nokia SROS (BNG1, BNG2, Switch, OLT):

**Paneles incluidos:**

- Estado de puertos
- Tráfico de entrada/salida por puerto
- Utilización de CPU
- Utilización de memoria
- Estado de servicios VPLS
- Estado de servicios VPRN
- Estadísticas BGP
- Temperatura de hardware

### SR Linux Dashboard

Dashboard para monitorear el TX (Nokia SR Linux):

**Paneles incluidos:**

- Estado de interfaces
- Tráfico por interfaz
- CPU y memoria
- Estado de network-instances
- Estadísticas de routing
- Estado de aplicaciones

## Creación de Paneles

### Panel de Tráfico de Puerto

```json
{
  "title": "Tráfico por Puerto",
  "type": "graph",
  "datasource": "Prometheus",
  "targets": [
    {
      "expr": "rate(port_statistics_in_octets{source=~\"$device\"}[1m]) * 8",
      "legendFormat": "{{port_id}} - In"
    },
    {
      "expr": "rate(port_statistics_out_octets{source=~\"$device\"}[1m]) * 8",
      "legendFormat": "{{port_id}} - Out"
    }
  ],
  "yaxes": [
    {
      "format": "bps",
      "label": "Bits/seg"
    }
  ]
}
```

### Panel de Estado de Puertos

```json
{
  "title": "Estado de Puertos",
  "type": "stat",
  "datasource": "Prometheus",
  "targets": [
    {
      "expr": "port_oper_state{source=~\"$device\"}",
      "legendFormat": "{{port_id}}"
    }
  ],
  "fieldConfig": {
    "defaults": {
      "mappings": [
        {"type": "value", "options": {"0": {"text": "DOWN", "color": "red"}}},
        {"type": "value", "options": {"1": {"text": "UP", "color": "green"}}}
      ]
    }
  }
}
```

### Panel de CPU

```json
{
  "title": "Utilización de CPU",
  "type": "gauge",
  "datasource": "Prometheus",
  "targets": [
    {
      "expr": "system_cpu_usage{source=~\"$device\"}",
      "legendFormat": "{{source}}"
    }
  ],
  "fieldConfig": {
    "defaults": {
      "max": 100,
      "thresholds": {
        "steps": [
          {"value": 0, "color": "green"},
          {"value": 70, "color": "yellow"},
          {"value": 90, "color": "red"}
        ]
      }
    }
  }
}
```

## Variables de Dashboard

Para crear dashboards dinámicos, usar variables:

```json
{
  "templating": {
    "list": [
      {
        "name": "device",
        "type": "query",
        "datasource": "Prometheus",
        "query": "label_values(port_oper_state, source)",
        "multi": true,
        "includeAll": true
      }
    ]
  }
}
```

## Consultas Útiles

### Top 5 puertos por tráfico

```promql
topk(5, rate(port_statistics_in_octets[5m]) * 8)
```

### Puertos con errores

```promql
rate(port_statistics_in_errors[5m]) > 0
```

### Dispositivos con alta CPU

```promql
system_cpu_usage > 80
```

### Servicios down

```promql
service_vpls_oper_state == 0 or service_vprn_oper_state == 0
```

## Alertas en Grafana

### Crear alerta de puerto down

1. Editar el panel de estado de puertos
2. Ir a la pestaña "Alert"
3. Configurar:
   - Condition: `WHEN last() OF query(A) IS BELOW 1`
   - Evaluate every: `1m`
   - For: `5m`
4. Configurar notificación (email, Slack, etc.)

## Acceso Anónimo

El laboratorio tiene habilitado el acceso anónimo para facilitar las pruebas:

```yaml
GF_AUTH_ANONYMOUS_ENABLED: "true"
GF_AUTH_ANONYMOUS: "true"
```

!!! warning "Producción"
    
    En entornos de producción, deshabilitar el acceso anónimo y configurar autenticación apropiada.

## Verificación

### Verificar Grafana

```bash
# Ver logs
docker logs grafana

# Verificar health
curl http://localhost:3030/api/health
```

### Verificar Datasource

```bash
curl -u admin:admin http://localhost:3030/api/datasources
```

### Verificar Dashboards

```bash
curl -u admin:admin http://localhost:3030/api/search
```
