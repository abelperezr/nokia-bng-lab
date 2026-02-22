#!/bin/bash

# ============================================================================
# Script de Push Rápido - Nokia BNG Lab
# ============================================================================
# Uso: ./push.sh "mensaje del commit"
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

# Banner compacto
echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}       ${CYAN}Nokia BNG Lab - Push de Cambios${NC}                       ${BLUE}║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Verificaciones básicas
if [ ! -f "mkdocs.yml" ] || [ ! -f "lab.yml" ]; then
    print_error "Este script debe ejecutarse desde el directorio del laboratorio"
    exit 1
fi

if [ ! -d ".git" ]; then
    print_error "No es un repositorio Git. Ejecuta primero: ./deploy-github.sh"
    exit 1
fi

# Verificar si hay cambios
if git diff --quiet && git diff --staged --quiet; then
    print_warning "No hay cambios pendientes para subir"
    echo ""
    echo "  Últimos commits:"
    git log --oneline -5
    echo ""
    exit 0
fi

# Mostrar resumen de cambios
print_step "Resumen de cambios:"
echo ""
echo -e "${CYAN}Archivos modificados:${NC}"
git status --short | head -20
CHANGES_COUNT=$(git status --short | wc -l)
if [ "$CHANGES_COUNT" -gt 20 ]; then
    echo "  ... y $(($CHANGES_COUNT - 20)) archivos más"
fi
echo ""

# Verificar que no se incluyan licencias
if git status --short | grep -E "license|\.lic"; then
    print_error "¡ALERTA! Se detectaron archivos de licencia"
    print_warning "Estos archivos NO deben subirse a GitHub"
    read -p "¿Continuar sin los archivos de licencia? (s/N): " CONTINUE
    if [[ ! "$CONTINUE" =~ ^[Ss]$ ]]; then
        exit 1
    fi
fi

# Obtener mensaje de commit
if [ -n "$1" ]; then
    COMMIT_MSG="$*"
else
    echo -e "${CYAN}Tipos de commit sugeridos:${NC}"
    echo "  feat:     Nueva funcionalidad"
    echo "  fix:      Corrección de bug"
    echo "  docs:     Cambios en documentación"
    echo "  config:   Cambios en configuración"
    echo "  refactor: Refactorización de código"
    echo ""
    read -p "Mensaje del commit: " COMMIT_MSG
    
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="update: $(date '+%Y-%m-%d %H:%M')"
    fi
fi

# Agregar archivos (excluyendo licencias)
print_step "Agregando archivos..."
git add .

# Remover licencias si se agregaron accidentalmente
git reset -- configs/license/ 2>/dev/null || true
git reset -- license/ 2>/dev/null || true
git reset -- '*.lic' 2>/dev/null || true

print_success "Archivos agregados"

# Crear commit
print_step "Creando commit..."
git commit -m "$COMMIT_MSG"
print_success "Commit creado: $COMMIT_MSG"

# Push
print_step "Subiendo a GitHub..."
git push origin main

echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}[✓] ¡Cambios subidos exitosamente!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
echo ""

# Obtener info del repositorio
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
if [ -n "$REMOTE_URL" ]; then
    GITHUB_USER=$(echo $REMOTE_URL | sed -E 's/.*github\.com[\/:]([^\/]+)\/.*/\1/')
    REPO_NAME=$(echo $REMOTE_URL | sed -E 's/.*\/([^\/]+)(\.git)?$/\1/' | sed 's/\.git$//')
    
    echo -e "  ${CYAN}📦 Repositorio:${NC}    https://github.com/${GITHUB_USER}/${REPO_NAME}"
    echo -e "  ${CYAN}📖 Documentación:${NC}  https://${GITHUB_USER}.github.io/${REPO_NAME}"
    echo -e "  ${CYAN}⚙️  Actions:${NC}        https://github.com/${GITHUB_USER}/${REPO_NAME}/actions"
fi
echo ""
