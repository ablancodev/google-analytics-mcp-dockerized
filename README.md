# Google Analytics MCP Server - Docker

Servidor MCP (Model Context Protocol) para Google Analytics dockerizado, basado en el [repositorio oficial](https://github.com/googleanalytics/google-analytics-mcp).

## Requisitos Previos

### 1. Habilitar APIs en Google Cloud

Necesitas habilitar las siguientes APIs en tu proyecto de Google Cloud:

- **Google Analytics Admin API**
- **Google Analytics Data API**

Puedes habilitarlas desde la [Google Cloud Console](https://console.cloud.google.com/apis/library).

### 2. Obtener Credenciales de Google Cloud

Existen tres opciones para autenticarte. Elige la que mejor se adapte a tu caso:

---

#### **Opción 1: Service Account (Recomendado para producción)**

1. Ve a [Google Cloud Console > IAM > Service Accounts](https://console.cloud.google.com/iam-admin/serviceaccounts)
2. Haz clic en "Create Service Account"
3. Dale un nombre descriptivo (ej: "analytics-mcp-server")
4. Asigna el rol "Viewer" o roles más específicos
5. Haz clic en "Create and Continue" > "Done"
6. Selecciona la service account creada
7. Ve a la pestaña "Keys" > "Add Key" > "Create new key"
8. Selecciona "JSON" y descarga el archivo
9. Guarda el archivo como `credentials.json` en el directorio del proyecto

**Importante:** Añade el email de la service account (ej: `nombre@proyecto.iam.gserviceaccount.com`) como usuario en Google Analytics con permisos de "Viewer" o superiores.

---

#### **Opción 2: OAuth Client (Para desarrollo local)**

1. Ve a [Google Cloud Console > APIs & Services > Credentials](https://console.cloud.google.com/apis/credentials)
2. Haz clic en "Create Credentials" > "OAuth client ID"
3. Selecciona "Desktop app" como tipo de aplicación
4. Descarga el archivo JSON del cliente OAuth
5. Instala gcloud CLI si no lo tienes: https://cloud.google.com/sdk/docs/install
6. Ejecuta el siguiente comando:

```bash
gcloud auth application-default login \
  --scopes https://www.googleapis.com/auth/analytics.readonly,https://www.googleapis.com/auth/cloud-platform \
  --client-id-file=tu-archivo-oauth-client.json
```

7. Se abrirá tu navegador para autenticarte con tu cuenta de Google
8. El comando generará un archivo de credenciales, cópialo a `credentials.json`

---

#### **Opción 3: Impersonar Service Account (Avanzado)**

Si tienes permisos para impersonar una service account existente:

```bash
gcloud auth application-default login \
  --impersonate-service-account=SERVICE_ACCOUNT_EMAIL@proyecto.iam.gserviceaccount.com
```

Copia el archivo de credenciales generado a `credentials.json`.

---

### 3. Dar permisos de Google Analytics

Asegúrate de que la cuenta (service account o usuario) tenga acceso a Google Analytics:

1. Ve a [Google Analytics](https://analytics.google.com/)
2. Admin > Property Access Management
3. Añade el email correspondiente
4. Asigna permisos de "Viewer" o superiores

## Instalación

### 1. Configurar variables de entorno

```bash
cp .env.example .env
```

Edita el archivo `.env` y configura:

```bash
GOOGLE_PROJECT_ID=tu-proyecto-id
CREDENTIALS_PATH=./credentials.json
```

### 2. Colocar el archivo de credenciales

Copia tu archivo de credenciales de Google Cloud:

```bash
cp /ruta/a/tus/credenciales.json ./credentials.json
```

## Uso

### Construir la imagen

```bash
docker-compose build
```

### Ejecutar el servidor

```bash
docker-compose up -d
```

### Ver logs

```bash
docker-compose logs -f
```

### Detener el servidor

```bash
docker-compose down
```

## Integración con Claude Code

Para usar este servidor MCP con Claude Code, añade la siguiente configuración a tu `~/.claude.json`:

```json
{
  "mcpServers": {
    "google-analytics": {
      "command": "docker",
      "args": [
        "exec",
        "-i",
        "google-analytics-mcp",
        "analytics-mcp"
      ]
    }
  }
}
```

**IMPORTANTE**: El contenedor debe estar corriendo (`docker-compose up -d`) antes de iniciar Claude Code.

Luego reinicia Claude Code y verifica que el servidor esté disponible con `/mcp`.

## Integración con Gemini

Si usas Gemini, configura en `~/.gemini/settings.json`:

```json
{
  "mcpServers": {
    "analytics-mcp": {
      "command": "docker",
      "args": [
        "exec",
        "-i",
        "google-analytics-mcp",
        "analytics-mcp"
      ],
      "env": {
        "GOOGLE_APPLICATION_CREDENTIALS": "/credentials/credentials.json",
        "GOOGLE_PROJECT_ID": "tu-proyecto-id"
      }
    }
  }
}
```

## Funcionalidades Disponibles

El servidor MCP proporciona herramientas para:

### Gestión de Cuentas y Propiedades
- Obtener resúmenes de cuentas
- Detalles de propiedades
- Enlaces de Google Ads

### Informes
- Consultar datos de Analytics con dimensiones y métricas personalizadas
- Soporta filtros, ordenamiento y agregaciones
- Acceso a métricas de tráfico, conversiones, eventos, etc.

### Monitoreo en Tiempo Real
- Acceder a datos en tiempo real
- Ver usuarios activos, eventos recientes, páginas visitadas

## Ejemplos de Uso en Claude Code

Una vez configurado, puedes hacer preguntas como:

```
"¿Cuántos usuarios tuve la semana pasada?"
"Muéstrame los eventos más populares del último mes"
"¿Qué páginas están visitando mis usuarios ahora mismo?"
"Dame un reporte de conversiones por fuente de tráfico"
```

## Solución de Problemas

### Error de autenticación

Si recibes errores de autenticación, verifica que:

1. Las credenciales estén en el lugar correcto (`./credentials.json`)
2. El proyecto de Google Cloud tenga las APIs habilitadas
3. La cuenta tenga permisos en Google Analytics (Admin > Property Access Management)
4. El scope sea correcto: `https://www.googleapis.com/auth/analytics.readonly`

### El contenedor no inicia

Verifica los logs:

```bash
docker-compose logs
```

Asegúrate de que:

1. El archivo `.env` esté configurado correctamente
2. El archivo `credentials.json` exista y sea válido
3. El formato del JSON sea correcto

### Claude Code no encuentra el servidor

Asegúrate de que:

1. El contenedor esté corriendo: `docker ps | grep google-analytics-mcp`
2. El archivo `~/.claude.json` esté correctamente configurado
3. Hayas reiniciado Claude Code después de añadir la configuración

Prueba ejecutar manualmente:

```bash
docker exec -i google-analytics-mcp analytics-mcp
```

### Permisos insuficientes

Si recibes errores tipo "Permission denied":

1. Ve a Google Analytics > Admin > Property Access Management
2. Verifica que el email de la service account o usuario esté en la lista
3. Asegúrate de que tenga al menos rol de "Viewer"
4. Espera unos minutos (los permisos pueden tardar en propagarse)

## Seguridad

- **NUNCA** subas el archivo `credentials.json` o `.env` a un repositorio público
- El `.gitignore` ya está configurado para ignorar estos archivos
- Rota las claves periódicamente desde Google Cloud Console
- Usa service accounts dedicadas para cada aplicación
- Mantén los permisos al mínimo necesario (principio de menor privilegio)

## Estructura del Proyecto

```
.
├── Dockerfile              # Imagen Docker con Python y analytics-mcp
├── docker-compose.yml      # Configuración para ejecutar el contenedor
├── .env.example           # Plantilla de variables de entorno
├── .env                   # Variables de entorno (no subir a git)
├── .gitignore            # Protege archivos sensibles
├── credentials.json      # Credenciales de Google Cloud (no subir a git)
└── README.md             # Esta documentación
```

## Recursos

- [Repositorio oficial del MCP](https://github.com/googleanalytics/google-analytics-mcp)
- [Google Analytics Admin API](https://developers.google.com/analytics/devguides/config/admin/v1)
- [Google Analytics Data API](https://developers.google.com/analytics/devguides/reporting/data/v1)
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [Documentación de Service Accounts](https://cloud.google.com/iam/docs/service-account-overview)
