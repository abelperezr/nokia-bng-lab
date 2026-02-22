# 🔷 Nokia BNG Lab - Red Neutral con Containerlab

<div align="center">


**Laboratorio de Red Neutral con Nokia BNG, Telemetría gNMI y RADIUS**

[![MkDocs](https://img.shields.io/badge/docs-MkDocs-blue?style=for-the-badge&logo=markdown)](https://abelperezr.github.io/nokia-bng-lab)
[![Containerlab](https://img.shields.io/badge/powered%20by-Containerlab-orange?style=for-the-badge)](https://containerlab.dev)
[![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)](LICENSE)

</div>

---

## 📖 Documentación

📚 **Documentación Completa:** [https://abelperezr.github.io/nokia-bng-lab](https://abelperezr.github.io/nokia-bng-lab)

  Cabe destacar que el Laboratorio fue pensado con servicios L2 debido a que en algunos casos el servicio de transporte (tx en este ejemplo) es arrendado, por tanto no aplique IS-IS, MPLS u otros.

---

## 📥 Descargar el Laboratorio

### Opción 1: Clonar con Git (Recomendado)

```bash
git clone https://github.com/abelperezr/nokia-bng-lab.git
cd nokia-bng-lab
```

### Opción 2: Descargar ZIP

1. Click en el botón verde **"Code"** arriba
2. Selecciona **"Download ZIP"**
3. Extrae el archivo descargado

### Opción 3: Descarga directa

```bash
# Descargar ZIP
curl -L https://github.com/abelperezr/nokia-bng-lab/archive/refs/heads/main.zip -o nokia-bng-lab.zip
unzip nokia-bng-lab.zip

# O usando wget
wget https://github.com/abelperezr/nokia-bng-lab/archive/refs/heads/main.zip
```

---

## 🏗️ Arquitectura del Laboratorio

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         RED NEUTRAL - BNG LAB                           │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│    ┌─────────┐         ┌─────────┐         ┌─────────┐                 │
│    │  BNG1   │◄───────►│   TX    │◄───────►│  BNG2   │                 │
│    │SR-7     │         │SR Linux │         │ SR-7    │                 │
│    └────┬────┘         └────┬────┘         └────┬────┘                 │
│         │                   │                   │                       │
│         │              ┌────┴────┐              │                       │
│         │              │ Switch  │              │                       │
│         │              │ IXR-ec  │              │                       │
│         │              └────┬────┘              │                       │
│         │                   │                   │                       │
│         │              ┌────┴────┐              │                       │
│    ┌────┴────┐         │   OLT   │         ┌────┴────┐                 │
│    │  iPerf  │         │ IXR-ec  │         │ RADIUS  │                 │
│    └─────────┘         └────┬────┘         └─────────┘                 │
│                             │                                           │
│                     ┌───────┴───────┐                                   │
│                     │               │                                   │
│                 ┌───┴───┐       ┌───┴───┐                              │
│                 │ ONT1  │       │ ONT2  │                              │
│                 └───┬───┘       └───────┘                              │
│                     │                                                   │
│                 ┌───┴───┐                                              │
│                 │  PC1  │                                              │
│                 └───────┘                                              │
│                                                                         │
├─────────────────────────────────────────────────────────────────────────┤
│  TELEMETRÍA: gNMIc → Prometheus → Grafana                              │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 🚀 Despliegue Rápido

### Prerrequisitos

- **Containerlab** v0.50+
- **Docker** v24+
- **Licencias Nokia SR-SIM e Imagen** (colocar en `configs/license/`)
- **Imagen ONT personalizada** (Se encuentra en mi github)

### Iniciar el Laboratorio

```bash
# 1. Agregar licencias Nokia
mkdir -p configs/license
cp /path/to/SR_SIM_license.txt configs/license/

# 2. Desplegar el laboratorio
sudo containerlab deploy -t lab.yml

# 3. Verificar despliegue
sudo containerlab inspect -t lab.yml
```

### Acceso a Servicios

| Servicio | URL/Puerto | Credenciales |
|----------|------------|--------------|
| **Grafana** | http://localhost:3030 | admin/admin |
| **Prometheus** | http://localhost:9090 | - |
| **BNG1 SSH** | localhost:56661 | admin/lab123 |
| **BNG2 SSH** | localhost:56664 | admin/lab123 |
| **Switch SSH** | localhost:56667 | admin/lab123 |
| **OLT SSH** | localhost:56678 | admin/lab123 |

### Detener el Laboratorio

```bash
sudo containerlab destroy -t lab.yml
```

---

## 📁 Estructura del Proyecto

```
nokia-bng-lab/
├── 📄 lab.yml                  # Topología principal Containerlab
├── 📄 mkdocs.yml               # Configuración documentación
├── 📄 requirements.txt         # Dependencias Python
├── 📁 configs/
│   ├── 📁 sros/               # Configuraciones Nokia SROS
│   ├── 📁 switch/             # Configuraciones switches
│   ├── 📁 olt/                # Configuración OLT
│   ├── 📁 radius/             # Servidor RADIUS
│   ├── 📁 grafana/            # Dashboards Grafana
│   ├── 📁 prometheus/         # Configuración Prometheus
│   ├── 📁 gnmic/              # Configuración gNMIc
│   └── 📁 license/            # ⚠️ Licencias (NO incluidas)
└── 📁 docs/                   # Documentación MkDocs
```

---

## 📊 Stack de Telemetría

El laboratorio incluye un stack completo de telemetría basado en:

- **gNMIc**: Collector de telemetría gNMI/gRPC
- **Prometheus**: Base de datos de series temporales
- **Grafana**: Visualización y dashboards

### Métricas Disponibles

- Uso de CPU/Memoria de equipos Nokia
- Estadísticas de interfaces
- Contadores de sesiones BNG
- Métricas RADIUS

---

## ⚠️ Importante: Licencias

Este repositorio **NO incluye** licencias Nokia SR-SIM. Necesitas:

1. Obtener licencias válidas de Nokia
2. Colocarlas en `configs/license/SR_SIM_license.txt`


---

## 🛠️ Scripts de Automatización

| Script | Descripción |
|--------|-------------|
| `./deploy-github.sh` | Primera subida a GitHub |
| `./push.sh "mensaje"` | Push rápido de cambios |

---

## 📝 Documentación Local

Para ver la documentación localmente:

```bash
# Instalar dependencias
pip install mkdocs-material pymdown-extensions

# Servir documentación
mkdocs serve

# Abrir en navegador: http://localhost:8000
```


---

## 👤 Autor

**Abel Pérez**  
Network Automation Engineer

---

<div align="center">

**[📖 Ver Documentación Completa](https://abelperezr.github.io/nokia-bng-lab)**

</div>
