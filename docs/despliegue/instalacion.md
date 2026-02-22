# Guía de Instalación

## Despliegue Rápido

```bash
# 1. Clonar repositorio
git clone https://github.com/TU-USUARIO/nokia-bng-lab.git
cd nokia-bng-lab

# 2. Verificar licencia Nokia
ls -la configs/license/SR_SIM_license.txt

# 3. Desplegar laboratorio
sudo containerlab deploy -t configs/lab.yml

# 4. Verificar estado
sudo containerlab inspect -t configs/lab.yml
```

## Paso a Paso

### 1. Preparar el Entorno

```bash
# Crear directorio de trabajo
mkdir -p ~/nokia-bng-lab
cd ~/nokia-bng-lab

# Clonar o copiar archivos de configuración
git clone https://github.com/TU-USUARIO/nokia-bng-lab.git .
```

### 2. Verificar Imágenes Docker

```bash
# Listar imágenes disponibles
docker images | grep -E "(sros|srlinux)"

# Salida esperada:
# vrnetlab/vr-sros       24.7.R1    abc123...   1.2GB
# ghcr.io/nokia/srlinux  24.7.2     def456...   2.1GB
```

### 3. Desplegar con Containerlab

```bash
# Modo interactivo (ver logs)
sudo containerlab deploy -t configs/lab.yml --log-level debug

# Modo background
sudo containerlab deploy -t configs/lab.yml -d
```

### 4. Verificar Despliegue

```bash
# Estado de contenedores
sudo containerlab inspect -t configs/lab.yml
```

Salida esperada:

```text
+---+----------------------+--------------+-------------------+------+---------+
| # |        Name          | Container ID |       Image       | Kind |  State  |
+---+----------------------+--------------+-------------------+------+---------+
| 1 | clab-bng-lab-bng1    | abc123...    | vrnetlab/vr-sros  | sros | running |
| 2 | clab-bng-lab-bng2    | def456...    | vrnetlab/vr-sros  | sros | running |
| 3 | clab-bng-lab-tx      | ghi789...    | nokia/srlinux     | srl  | running |
| 4 | clab-bng-lab-switch  | jkl012...    | vrnetlab/vr-sros  | sros | running |
| 5 | clab-bng-lab-olt     | mno345...    | vrnetlab/vr-sros  | sros | running |
| 6 | clab-bng-lab-ont1    | pqr678...    | network-multitool | linux| running |
| 7 | clab-bng-lab-ont2    | stu901...    | network-multitool | linux| running |
| 8 | clab-bng-lab-radius  | vwx234...    | network-multitool | linux| running |
| 9 | clab-bng-lab-gnmic   | yza567...    | gnmic             | linux| running |
|10 | clab-bng-lab-prom    | bcd890...    | prometheus        | linux| running |
|11 | clab-bng-lab-grafana | efg123...    | grafana           | linux| running |
+---+----------------------+--------------+-------------------+------+---------+
```

### 5. Esperar Inicialización

!!! warning "Tiempo de Boot"
    Los equipos Nokia SR-SIM pueden tardar **3-5 minutos** en inicializarse completamente. Espere hasta ver el prompt de login.

```bash
# Monitorear logs de BNG1
docker logs -f clab-bng-lab-bng1

# Buscar mensaje de boot completo
# "BOOT: ready for CLI login"
```

### 6. Acceso a Dispositivos

```bash
# SSH a BNG1
ssh admin@clab-bng-lab-bng1

# SSH usando IP de gestión
ssh admin@10.77.1.2

# Credenciales por defecto
# Usuario: admin
# Password: lab123
```

## Verificación Post-Instalación

### Stack de Telemetría

```bash
# Verificar gNMIc
curl -s http://10.77.1.12:9273/metrics | head -20

# Verificar Prometheus
curl -s http://10.77.1.13:9090/api/v1/targets | jq '.data.activeTargets[] | {instance, health}'

# Acceder a Grafana
# URL: http://10.77.1.14:3000
# Usuario: admin / Password: admin
```

### Conectividad RADIUS

```bash
# Desde el host
docker exec -it clab-bng-lab-radius radtest 00:d0:f6:01:01:01 testlab123 localhost 0 testing123
```

### Sesiones de Suscriptores

```bash
# Conectar a BNG1
ssh admin@10.77.1.2

# Ver suscriptores activos
show service active-subscribers

# Ver tabla DHCP
show router dhcp local-dhcp-server "dhcp4" leases
```

## Detener y Eliminar

### Detener Laboratorio

```bash
# Detener sin eliminar configuración
sudo containerlab destroy -t configs/lab.yml --keep-mgmt-net
```

### Eliminar Completamente

```bash
# Destruir laboratorio y limpiar
sudo containerlab destroy -t configs/lab.yml --cleanup
```

## Comandos Útiles

| Comando | Descripción |
|---------|-------------|
| `containerlab inspect -a` | Ver todos los labs activos |
| `containerlab save -t lab.yml` | Guardar configuración actual |
| `containerlab graph -t lab.yml` | Generar diagrama de topología |
| `docker logs CONTAINER` | Ver logs de un contenedor |
| `docker exec -it CONTAINER bash` | Acceder a shell |

## Troubleshooting

### Error: "Image not found"

```bash
# Verificar nombre exacto de imagen
docker images | grep sros

# Ajustar en lab.yml si es necesario
image: vrnetlab/vr-sros:24.7.R1
```

### Error: "Not enough memory"

```bash
# Verificar memoria disponible
free -h

# Reducir nodos si es necesario
# Comentar OLT o segundo BNG en lab.yml
```

### Error: "Port already in use"

```bash
# Identificar proceso usando puerto
sudo lsof -i :3000

# Detener proceso o cambiar puerto en lab.yml
```

### Equipos no responden

```bash
# Reiniciar nodo específico
docker restart clab-bng-lab-bng1

# Ver estado detallado
docker inspect clab-bng-lab-bng1 | jq '.[0].State'
```

## Scripts de Automatización

### deploy.sh

```bash
#!/bin/bash
set -e

echo "🚀 Desplegando Nokia BNG Lab..."

# Verificar requisitos
if ! command -v containerlab &> /dev/null; then
    echo "❌ Containerlab no instalado"
    exit 1
fi

# Desplegar
sudo containerlab deploy -t configs/lab.yml

# Esperar inicialización
echo "⏳ Esperando inicialización (3 minutos)..."
sleep 180

# Verificar
sudo containerlab inspect -t configs/lab.yml

echo "✅ Laboratorio desplegado exitosamente"
echo ""
echo "Accesos:"
echo "  - Grafana:    http://10.77.1.14:3000"
echo "  - Prometheus: http://10.77.1.13:9090"
echo "  - BNG1:       ssh admin@10.77.1.2"
echo "  - BNG2:       ssh admin@10.77.1.3"
```

### destroy.sh

```bash
#!/bin/bash
echo "🛑 Deteniendo Nokia BNG Lab..."
sudo containerlab destroy -t configs/lab.yml --cleanup
echo "✅ Laboratorio eliminado"
```
