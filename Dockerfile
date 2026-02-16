FROM python:3.11-slim

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Instalar pipx
RUN python -m pip install --no-cache-dir pipx
RUN python -m pipx ensurepath

# Configurar variables de entorno para pipx
ENV PIPX_HOME=/opt/pipx
ENV PIPX_BIN_DIR=/usr/local/bin
ENV PATH="${PIPX_BIN_DIR}:${PATH}"

# Instalar analytics-mcp
RUN pipx install analytics-mcp

# Crear directorio para credenciales
RUN mkdir -p /credentials

# Configurar variables de entorno (se pueden sobrescribir)
ENV GOOGLE_APPLICATION_CREDENTIALS=/credentials/credentials.json
ENV GOOGLE_PROJECT_ID=""

# Directorio de trabajo
WORKDIR /app

# El servidor MCP se ejecuta con stdio
CMD ["analytics-mcp"]
