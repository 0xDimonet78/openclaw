#!/bin/bash
set -e

# Configuración
REPO_URL="https://github.com/0xDimonet78/OpenClaw.git" # <--- CAMBIA ESTO POR TU URL DE FORK
INSTALL_DIR="/opt/OpenClaw"
APP_USER="openclaw"

echo "🚀 Instalación Corregida de OpenClaw (con pnpm)..."

# 1. Instalar dependencias del sistema (si no están)
echo "📦 Instalando dependencias del sistema..."
apt update
apt install -y git ca-certificates curl build-essential wget sudo

# 2. Instalar Node.js 22
echo "🟢 Instalando Node.js 22..."
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt install -y nodejs

# 3. Instalar pnpm
echo "🔗 Instalando pnpm..."
npm install -g pnpm

# 4. Crear usuario si no existe
if ! id "$APP_USER" &>/dev/null; then
  echo "👤 Creando usuario $APP_USER..."
  useradd -m -s /bin/bash $APP_USER
  usermod -aG sudo $APP_USER
fi

# 5. Preparar directorio
echo "📂 Preparando directorio en $INSTALL_DIR..."
mkdir -p $INSTALL_DIR
chown $APP_USER:$APP_USER $INSTALL_DIR

# 6. Clonar el repositorio (si no existe)
if [ ! -d "$INSTALL_DIR/.git" ]; then
  echo "🛠️ Clonando tu fork: $REPO_URL"
  su - $APP_USER -c "cd $INSTALL_DIR && git clone $REPO_URL ."
else
  echo "ℹ️ Repositorio ya existe. Actualizando..."
  su - $APP_USER -c "cd $INSTALL_DIR && git pull"
fi

# 7. Instalar dependencias y compilar
echo "⚙️ Instalando dependencias con pnpm y compilando..."
su - $APP_USER -c "cd $INSTALL_DIR && pnpm install && pnpm build && pnpm ui:build"

# 8. Enlazar CLI
echo "🔗 Enlazando CLI..."
su - $APP_USER -c "cd $INSTALL_DIR && pnpm link --global"

# 9. Onboarding (Interactivo)
echo "🔧 Ejecutando onboarding..."
echo "   (Introduce tu clave API cuando se solicite)"
su - $APP_USER -c "cd $INSTALL_DIR && openclaw onboard"

# 10. Instalar servicio
echo "🌐 Instalando servicio systemd..."
su - $APP_USER -c "cd $INSTALL_DIR && openclaw gateway install"
systemctl enable openclaw-gateway
systemctl start openclaw-gateway

echo "✅ ¡Instalación completada!"
echo "📊 Para acceder al Dashboard desde tu PC local:"
echo "   ssh -N -L 18789:127.0.0.1:18789 $APP_USER@75.119.145.5"
echo "   Luego abre: http://localhost:18789/"
EOF
chmod +x install_fixed.sh
