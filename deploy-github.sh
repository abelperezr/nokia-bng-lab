#!/bin/bash

# ============================================================================
# Script de Despliegue Inicial para GitHub - Nokia BNG Lab
# ============================================================================


set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_step() {
    echo -e "${BLUE}[*]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_info() {
    echo -e "${CYAN}[i]${NC} $1"
}

# Banner
clear
echo -e "${BLUE}"
cat << 'EOF'
╔════════════════════════════════════════════════════════════════════════════╗
║                                                                            ║
║    ███╗   ██╗ ██████╗ ██╗  ██╗██╗ █████╗     ██████╗ ███╗   ██╗ ██████╗    ║
║    ████╗  ██║██╔═══██╗██║ ██╔╝██║██╔══██╗    ██╔══██╗████╗  ██║██╔════╝    ║
║    ██╔██╗ ██║██║   ██║█████╔╝ ██║███████║    ██████╔╝██╔██╗ ██║██║  ███╗   ║
║    ██║╚██╗██║██║   ██║██╔═██╗ ██║██╔══██║    ██╔══██╗██║╚██╗██║██║   ██║   ║
║    ██║ ╚████║╚██████╔╝██║  ██╗██║██║  ██║    ██████╔╝██║ ╚████║╚██████╔╝   ║
║    ╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝    ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝    ║
║                                                                            ║
║              Script de Despliegue Inicial a GitHub                         ║
║                           ABEL PEREZ                                       ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Verificar que estamos en el directorio correcto
if [ ! -f "mkdocs.yml" ]; then
    print_error "No se encontró mkdocs.yml en el directorio actual"
    print_warning "Por favor, ejecuta este script desde la carpeta del laboratorio"
    echo "  cd containerlab && ./deploy-github.sh"
    exit 1
fi

if [ ! -f "lab.yml" ]; then
    print_error "No se encontró lab.yml - Este no parece ser el directorio del lab"
    exit 1
fi

print_success "Verificado: Directorio del laboratorio correcto"

# Verificar .gitignore
if [ -f ".gitignore" ]; then
    if grep -q "configs/license" .gitignore; then
        print_success "Verificado: .gitignore protege carpeta license"
    else
        print_warning "Agregando protección para carpeta license en .gitignore"
        echo -e "\n# Licencias - NUNCA SUBIR\nconfigs/license/\nlicense/\n*.lic" >> .gitignore
    fi
else
    print_error ".gitignore no encontrado - Creando uno básico"
    cat > .gitignore << 'GITIGNORE'
configs/license/
license/
SR_SIM_license.txt
*.lic
clab-*/
site/
__pycache__/
*.log
GITIGNORE
fi

# Verificar Git instalado
if ! command -v git &> /dev/null; then
    print_error "Git no está instalado"
    echo "  Instalar con: sudo apt install git"
    exit 1
fi

print_success "Git instalado: $(git --version)"

# Verificar que la carpeta license no existe o está vacía
if [ -d "configs/license" ]; then
    if [ "$(ls -A configs/license 2>/dev/null)" ]; then
        print_warning "La carpeta configs/license contiene archivos"
        print_info "Estos archivos NO serán subidos a GitHub (protegido por .gitignore)"
    fi
fi

# Verificar/Inicializar repositorio Git
if [ -d ".git" ]; then
    print_success "Repositorio Git existente detectado"
else
    print_step "Inicializando repositorio Git..."
    git init
    print_success "Repositorio Git inicializado"
fi

# Configuración del usuario Git (si no está configurado)
if [ -z "$(git config user.name)" ]; then
    echo ""
    print_step "Configuración de usuario Git"
    read -p "Tu nombre para Git: " GIT_NAME
    git config user.name "$GIT_NAME"
fi

if [ -z "$(git config user.email)" ]; then
    read -p "Tu email para Git: " GIT_EMAIL
    git config user.email "$GIT_EMAIL"
fi

print_success "Usuario Git: $(git config user.name) <$(git config user.email)>"

# Crear directorio de workflows para GitHub Actions
print_step "Configurando GitHub Actions para MkDocs..."
mkdir -p .github/workflows

cat > .github/workflows/docs.yml << 'WORKFLOW'
name: Deploy MkDocs to GitHub Pages

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.x'

      - name: Cache pip packages
        uses: actions/cache@v4
        with:
          path: ~/.cache/pip
          key: ${{ runner.os }}-pip-${{ hashFiles('requirements.txt') }}
          restore-keys: |
            ${{ runner.os }}-pip-

      - name: Install dependencies
        run: |
          pip install mkdocs-material
          pip install pymdown-extensions
          if [ -f requirements.txt ]; then pip install -r requirements.txt; fi

      - name: Build MkDocs
        run: mkdocs build --strict

      - name: Setup Pages
        uses: actions/configure-pages@v4

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: 'site'

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
WORKFLOW

print_success "GitHub Actions workflow creado"

# Solicitar información del repositorio
echo ""
print_step "Configuración del repositorio remoto"
echo ""

# Verificar si ya hay un remote configurado
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")

if [ -n "$REMOTE_URL" ]; then
    print_warning "Remote 'origin' ya configurado: $REMOTE_URL"
    read -p "¿Deseas cambiarlo? (s/N): " CHANGE_REMOTE
    if [[ "$CHANGE_REMOTE" =~ ^[Ss]$ ]]; then
        read -p "Usuario de GitHub: " GITHUB_USER
        read -p "Nombre del repositorio: " REPO_NAME
        git remote set-url origin "https://github.com/${GITHUB_USER}/${REPO_NAME}.git"
        print_success "Remote actualizado"
    else
        # Extraer usuario y repo del URL existente
        GITHUB_USER=$(echo $REMOTE_URL | sed -E 's/.*github\.com[\/:]([^\/]+)\/.*/\1/')
        REPO_NAME=$(echo $REMOTE_URL | sed -E 's/.*\/([^\/]+)(\.git)?$/\1/' | sed 's/\.git$//')
    fi
else
    read -p "Usuario de GitHub: " GITHUB_USER
    read -p "Nombre del repositorio (default: nokia-bng-lab): " REPO_NAME
    REPO_NAME=${REPO_NAME:-nokia-bng-lab}
    git remote add origin "https://github.com/${GITHUB_USER}/${REPO_NAME}.git"
    print_success "Remote 'origin' configurado"
fi

# Agregar archivos
print_step "Agregando archivos al staging..."
git add .

# Verificar que license no está en staging
if git diff --cached --name-only | grep -q "license"; then
    print_error "¡ALERTA! Archivos de licencia detectados en staging"
    print_step "Removiendo archivos de licencia..."
    git reset -- configs/license/ 2>/dev/null || true
    git reset -- license/ 2>/dev/null || true
fi

print_success "Archivos agregados (sin licencias)"

# Mostrar archivos que se van a subir
echo ""
print_info "Archivos a subir:"
git diff --cached --name-only | head -20
FILES_COUNT=$(git diff --cached --name-only | wc -l)
if [ "$FILES_COUNT" -gt 20 ]; then
    echo "  ... y $(($FILES_COUNT - 20)) archivos más"
fi
echo ""

# Crear commit
print_step "Creando commit..."
read -p "Mensaje del commit (default: 'Initial commit - Nokia BNG Lab'): " COMMIT_MSG
COMMIT_MSG=${COMMIT_MSG:-"Initial commit - Nokia BNG Lab"}
git commit -m "$COMMIT_MSG" 2>/dev/null || print_warning "Sin cambios para commitear"

# Verificar/crear rama main
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")
if [ "$CURRENT_BRANCH" != "main" ]; then
    print_step "Cambiando a rama 'main'..."
    git branch -M main
fi
print_success "Rama actual: main"

# Push a GitHub
echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
print_step "Subiendo a GitHub..."
echo ""
print_warning "Si es la primera vez, necesitarás autenticarte"
print_info "Puedes usar:"
print_info "  - Token personal (recomendado): Settings > Developer settings > Personal access tokens"
print_info "  - SSH key: ssh-keygen -t ed25519 && cat ~/.ssh/id_ed25519.pub"
echo ""

read -p "¿Continuar con el push? (S/n): " DO_PUSH
if [[ ! "$DO_PUSH" =~ ^[Nn]$ ]]; then
    git push -u origin main || {
        print_error "Error en push. Posibles soluciones:"
        echo "  1. Crea el repositorio en GitHub primero: https://github.com/new"
        echo "  2. Verifica tus credenciales"
        echo "  3. Si usas 2FA, necesitas un token personal"
        exit 1
    }
    print_success "¡Código subido exitosamente!"
fi

# Instrucciones finales
echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}¡DESPLIEGUE COMPLETADO!${NC}"
echo ""
echo -e "${YELLOW}📋 Pasos para activar GitHub Pages:${NC}"
echo ""
echo "  1. Ve a: https://github.com/${GITHUB_USER}/${REPO_NAME}/settings/pages"
echo ""
echo "  2. En 'Build and deployment':"
echo "     - Source: GitHub Actions"
echo ""
echo "  3. El workflow se ejecutará automáticamente en cada push"
echo ""
echo -e "${YELLOW}🔗 URLs importantes:${NC}"
echo ""
echo "  📦 Repositorio:    https://github.com/${GITHUB_USER}/${REPO_NAME}"
echo "  📖 Documentación:  https://${GITHUB_USER}.github.io/${REPO_NAME}"
echo "  ⚙️  Actions:        https://github.com/${GITHUB_USER}/${REPO_NAME}/actions"
echo ""
echo -e "${YELLOW}📥 Para descargar el laboratorio:${NC}"
echo ""
echo "  git clone https://github.com/${GITHUB_USER}/${REPO_NAME}.git"
echo "  # o descarga ZIP desde GitHub"
echo ""
echo -e "${CYAN}💡 Para futuros cambios, usa: ./push.sh${NC}"
echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════════════════════${NC}"
