# Stage 90: Proxy, Python und APT Konfiguration

Diese Stage bereitet das System für Entwicklung und Testing vor, insbesondere für den Einsatz in Corporate-Umgebungen mit Artifactory-Proxies.

## Features

### 00-apt-config: APT Proxy Konfiguration
Konfiguriert APT zur Nutzung eines Artifactory Debian Mirrors anstelle der Standard-Repositories.

**Konfiguration via config:**
```bash
ARTIFACTORY_APT_URL="https://artifactory.example.com/artifactory/debian-remote"
ARTIFACTORY_APT_SECURITY_URL="https://artifactory.example.com/artifactory/debian-security-remote"
ARTIFACTORY_USER="username"
ARTIFACTORY_TOKEN="your-token"
```

- Falls `ARTIFACTORY_APT_URL` nicht gesetzt ist, wird dieser Schritt übersprungen
- Unterstützt Machine Auth über .netrc für sichere Authentifizierung
- Konfiguriert beide Standard- und Security-Repositories

### 01-install-uv: UV Package Manager
Installiert [uv](https://github.com/astral-sh/uv), einen extrem schnellen Python Package und Project Manager.

**Features:**
- Installation via offizielles Installer-Script
- System-weite Installation für alle User
- Automatische PATH-Konfiguration

### 02-python-config: Python Umgebung
Konfiguriert Python für die Nutzung mit uv und optionalem PyPI-Proxy.

**Konfiguration via config:**
```bash
PYPI_INDEX_URL="https://artifactory.example.com/artifactory/api/pypi/pypi-remote/simple"
ARTIFACTORY_USER="username"
ARTIFACTORY_TOKEN="your-token"
```

**Erstellt:**
- `~/.config/pip/pip.conf` - PIP Konfiguration mit Custom Index
- `~/.config/uv/uv.toml` - UV Konfiguration mit Custom Index
- Machine Auth via .netrc für sichere Authentifizierung

### 03-uart-config: UART Aktivierung
Aktiviert die serielle Schnittstelle (UART) für Konsolen-Zugriff.

**Konfiguration:**
- Fügt `enable_uart=1` in `/boot/firmware/config.txt` hinzu
- Ermöglicht serielle Kommunikation via GPIO 14/15 (UART0)

## Verwendung

### UV Package Manager Beispiele

```bash
# Python Package installieren
uv pip install requests

# Tool installieren (isolierte Umgebung)
uv tool install pytest

# Neues Python-Projekt erstellen
uv init my-project
cd my-project
uv venv
source .venv/bin/activate
uv pip install -r requirements.txt

# Script mit spezifischer Python-Version ausführen
uv run --python 3.11 script.py
```

### APT über Artifactory

Nach der Konfiguration nutzt APT automatisch den Artifactory Mirror:

```bash
# Updates wie gewohnt
sudo apt update
sudo apt upgrade

# Packages installieren
sudo apt install python3-dev
```

### UART Konsole

Nach Aktivierung ist die serielle Konsole verfügbar:

```bash
# Von anderem System verbinden
screen /dev/ttyUSB0 115200

# Oder mit minicom
minicom -D /dev/ttyUSB0 -b 115200
```

## Export

Diese Stage wird **nicht** als Image exportiert (`EXPORT_IMAGE` ist gesetzt). Sie dient als Vorbereitung für nachfolgende Stages.
