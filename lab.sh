#!/bin/bash

# ============================================================================
# Script de Gestión del Laboratorio - Nokia BNG Lab
# ============================================================================
# Uso: ./lab.sh [comando]
# Comandos: deploy, destroy, status, logs, connect, backup
# ============================================================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_step() { echo -e "${BLUE}[*]${NC} $1"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }

# Verificar si se ejecuta como root
check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        print_warning "Este comando requiere privilegios de administrador"
        echo "Ejecutando con sudo..."
        exec sudo "$0" "$@"
    fi
}

# Banner
show_banner() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              Nokia BNG Lab - Gestión del Laboratorio         ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Mostrar ayuda
show_help() {
    echo ""
    echo "Uso: ./lab.sh [comando]"
    echo ""
    echo "Comandos disponibles:"
    echo ""
    echo "  ${CYAN}deploy${NC}      Despliega el laboratorio"
    echo "  ${CYAN}destroy${NC}     Destruye el laboratorio"
    echo "  ${CYAN}redeploy${NC}    Destruye y vuelve a desplegar"
    echo "  ${CYAN}status${NC}      Muestra el estado del laboratorio"
    echo "  ${CYAN}inspect${NC}     Inspección detallada del lab"
    echo "  ${CYAN}logs${NC}        Muestra logs de contenedores"
    echo "  ${CYAN}connect${NC}     Conectar a un nodo (interactivo)"
    echo "  ${CYAN}backup${NC}      Respaldar configuraciones"
    echo "  ${CYAN}graph${NC}       Genera grafo de topología"
    echo "  ${CYAN}services${NC}    Muestra URLs de servicios"
    echo ""
    echo "Ejemplos:"
    echo "  ./lab.sh deploy       # Iniciar el lab"
    echo "  ./lab.sh connect      # Menú para conectar a nodos"
    echo "  ./lab.sh status       # Ver estado"
    echo ""
}

# Verificar prerrequisitos
check_prerequisites() {
    print_step "Verificando prerrequisitos..."
    
    # Verificar containerlab
    if ! command -v containerlab &> /dev/null; then
        print_error "Containerlab no está instalado"
        echo "  Instalar: bash -c \"\$(curl -sL https://get.containerlab.dev)\""
        exit 1
    fi
    
    # Verificar Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker no está instalado"
        exit 1
    fi
    
    # Verificar licencias
    if [ ! -f "configs/license/SR_SIM_license.txt" ]; then
        print_warning "Licencia Nokia no encontrada en configs/license/"
        print_warning "Los nodos Nokia SROS no iniciarán sin licencia"
    fi
    
    print_success "Prerrequisitos verificados"
}

# Desplegar laboratorio
cmd_deploy() {
    show_banner
    check_prerequisites
    
    print_step "Desplegando laboratorio Nokia BNG..."
    echo ""
    
    containerlab deploy -t lab.yml
    
    echo ""
    print_success "¡Laboratorio desplegado exitosamente!"
    echo ""
    cmd_services
}

# Destruir laboratorio
cmd_destroy() {
    show_banner
    print_warning "Esto destruirá el laboratorio y todos los contenedores"
    read -p "¿Estás seguro? (s/N): " CONFIRM
    
    if [[ "$CONFIRM" =~ ^[Ss]$ ]]; then
        print_step "Destruyendo laboratorio..."
        containerlab destroy -t lab.yml --cleanup
        print_success "Laboratorio destruido"
    else
        print_warning "Operación cancelada"
    fi
}

# Redesplegar
cmd_redeploy() {
    show_banner
    print_step "Redesplegando laboratorio..."
    containerlab destroy -t lab.yml --cleanup 2>/dev/null || true
    sleep 2
    cmd_deploy
}

# Estado del laboratorio
cmd_status() {
    show_banner
    print_step "Estado del laboratorio:"
    echo ""
    containerlab inspect -t lab.yml 2>/dev/null || {
        print_warning "El laboratorio no está desplegado"
        exit 0
    }
}

# Inspección detallada
cmd_inspect() {
    show_banner
    containerlab inspect -t lab.yml --all
}

# Ver logs
cmd_logs() {
    show_banner
    
    echo "Selecciona un contenedor:"
    echo ""
    docker ps --filter "label=containerlab=lab" --format "table {{.Names}}\t{{.Status}}" | head -20
    echo ""
    read -p "Nombre del contenedor: " CONTAINER
    
    if [ -n "$CONTAINER" ]; then
        docker logs -f "$CONTAINER"
    fi
}

# Conectar a nodo
cmd_connect() {
    show_banner
    
    echo -e "${CYAN}Nodos disponibles:${NC}"
    echo ""
    echo "  1) bng1    - Nokia 7750 SR-7 (SSH: 56661)"
    echo "  2) bng2    - Nokia 7750 SR-7 (SSH: 56664)"
    echo "  3) switch  - Nokia 7250 IXR-ec (SSH: 56667)"
    echo "  4) olt     - Nokia 7250 IXR-ec (SSH: 56678)"
    echo "  5) tx      - Nokia SR Linux (SSH: 56676)"
    echo "  6) ont1    - Linux ONT (SSH: 56673)"
    echo "  7) ont2    - Linux ONT (SSH: 56674)"
    echo "  8) radius  - Servidor RADIUS"
    echo "  9) grafana - Grafana Dashboard"
    echo ""
    read -p "Selecciona nodo (1-9): " NODE
    
    case $NODE in
        1) docker exec -it clab-lab-bng1 sr_cli ;;
        2) docker exec -it clab-lab-bng2 sr_cli ;;
        3) docker exec -it clab-lab-switch sr_cli ;;
        4) docker exec -it clab-lab-olt sr_cli ;;
        5) docker exec -it clab-lab-tx sr_cli ;;
        6) docker exec -it clab-lab-ont1 bash ;;
        7) docker exec -it clab-lab-ont2 bash ;;
        8) docker exec -it clab-lab-radius bash ;;
        9) print_info "Grafana: http://localhost:3030 (admin/admin)" ;;
        *) print_error "Opción no válida" ;;
    esac
}

# Backup de configuraciones
cmd_backup() {
    show_banner
    BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    print_step "Respaldando configuraciones..."
    
    # Backup BNG1
    docker exec clab-lab-bng1 sr_cli "admin show configuration" > "$BACKUP_DIR/bng1_config.txt" 2>/dev/null || true
    
    # Backup BNG2
    docker exec clab-lab-bng2 sr_cli "admin show configuration" > "$BACKUP_DIR/bng2_config.txt" 2>/dev/null || true
    
    # Backup Switch
    docker exec clab-lab-switch sr_cli "admin show configuration" > "$BACKUP_DIR/switch_config.txt" 2>/dev/null || true
    
    # Backup OLT
    docker exec clab-lab-olt sr_cli "admin show configuration" > "$BACKUP_DIR/olt_config.txt" 2>/dev/null || true
    
    print_success "Backup guardado en: $BACKUP_DIR"
    ls -la "$BACKUP_DIR"
}

# Generar grafo
cmd_graph() {
    show_banner
    print_step "Generando grafo de topología..."
    containerlab graph -t lab.yml
    print_success "Grafo generado. Abre el archivo HTML en tu navegador."
}

# Mostrar servicios
cmd_services() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    SERVICIOS DISPONIBLES                     ║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  📊 Grafana:       ${GREEN}http://localhost:3030${NC}  (admin/admin)    ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  📈 Prometheus:    ${GREEN}http://localhost:9090${NC}                   ${CYAN}║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  🔷 BNG1 SSH:      ${GREEN}ssh admin@localhost -p 56661${NC}            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  🔷 BNG2 SSH:      ${GREEN}ssh admin@localhost -p 56664${NC}            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  🔷 Switch SSH:    ${GREEN}ssh admin@localhost -p 56667${NC}            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  🔷 OLT SSH:       ${GREEN}ssh admin@localhost -p 56678${NC}            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  🔷 TX SSH:        ${GREEN}ssh admin@localhost -p 56676${NC}            ${CYAN}║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  💻 ONT1 SSH:      ${GREEN}ssh root@localhost -p 56673${NC}             ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  💻 ONT2 SSH:      ${GREEN}ssh root@localhost -p 56674${NC}             ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Main
case "${1:-help}" in
    deploy)   check_sudo; cmd_deploy ;;
    destroy)  check_sudo; cmd_destroy ;;
    redeploy) check_sudo; cmd_redeploy ;;
    status)   cmd_status ;;
    inspect)  cmd_inspect ;;
    logs)     cmd_logs ;;
    connect)  cmd_connect ;;
    backup)   cmd_backup ;;
    graph)    cmd_graph ;;
    services) cmd_services ;;
    help|--help|-h) show_banner; show_help ;;
    *)
        print_error "Comando desconocido: $1"
        show_help
        exit 1
        ;;
esac
