#!/bin/bash
set -e

# Variables de configuración
REPO_URL="https://github.com/0xDimonet78/OpenClaw.git" # <--- CAMBIA ESTO POR TU URL DE FORK
INSTALL_DIR="/opt/OpenClaw"
APP_USER="openclaw"

echo "🚀 Instalación Personalizada de OpenClaw (con pnpm y seguridad)..."

# 1. Verificar que no se ejecute como root (seguridad)
if [ "$EUID" -eq 0 ]; then 
  echo "⚠️  Por seguridad, no ejecutar como root directamente."
  echo "   Usa: su - $APP_USER && ./install_custom.sh"
  exit 1
fi

# 2. Instalar dependencias del sistema
echo "📦 Actualizando sistema e instalando dependencias..."
sudo apt update
sudo apt install -y git ca-certificates curl build-essential wget

# 3. Instalar Node.js 22
echo "🟢 Instalando Node.js 22..."
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs

# 4. Instalar pnpm (Recomendado)
echo "🔗 Instalando pnpm globalmente..."
npm install -g pnpm

# 5. Crear usuario dedicado (si no existe)
if ! id "$APP_USER" &>/dev/null; then
  echo "👤 Creando usuario $APP_USER..."
  sudo useradd -m -s /bin/bash $APP_USER
  sudo usermod -aG sudo $APP_USER
fi

# 6. Cambiar al usuario y clonar
echo "🛠️ Clonando tu fork desde: $REPO_URL"
sudo mkdir -p $INSTALL_DIR
sudo chown $APP_USER:$APP_USER $INSTALL_DIR

# Cambiamos al usuario para clonar
su - $APP_USER -c "cd $INSTALL_DIR &&
