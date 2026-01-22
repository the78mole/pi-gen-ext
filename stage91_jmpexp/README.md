# Stage 91: Jumpstarter Exporter Image

Diese Stage erstellt ein vollständiges Jumpstarter Exporter Image für Hardware Testing und CI/CD Integration.

## Features

### 00-install-jumpstarter: Jumpstarter Installation
Installiert Jumpstarter mit allen verfügbaren Treibern und Tools.

**Installierte Packages:**
- `jumpstarter-cli` mit `jumpstarter-all` - Vollständige Jumpstarter-Installation
- `usbsdmux` - USB SD Multiplexer Unterstützung
- `sdwire` - SDWire Device Unterstützung

**Konfiguration:**
- Installation via `uv tool install` für isolierte Environments
- Erstellt `/etc/jumpstarter/exporters/` Verzeichnis
- Installiert Beispiel-Konfiguration `jmp-example-local.yaml`
- Gruppe `jumpstarter` für Konfigurationsverwaltung

**Optional via config:**
```bash
JMPEXP_EXTRA_PACKAGES="package1 package2"  # Zusätzliche uv-Packages
```

### 01-user-groups: Berechtigungen
Fügt den User zu relevanten System-Gruppen hinzu:
- `disk` - Zugriff auf Block-Devices (SD-Karten, USB-Devices)
- `jumpstarter` - Zugriff auf Jumpstarter-Konfiguration

### 02-screen-config: GNU Screen
Installiert angepasste Screen-Konfiguration mit:
- 256-Farben Unterstützung
- 30.000 Zeilen Scrollback
- Farbige Status-Leiste mit Tab-Anzeige
- Shift+PgUp/PgDn für Scrolling

### 03-install-scripts: Utility Scripts
Installiert Helper-Scripts nach `/usr/local/bin`:

#### `dut_console`
Verbindet zur seriellen DUT-Konsole.

```bash
dut_console
# Öffnet screen auf /dev/ttyUSB0 @ 115200 baud
```

#### `dut_console_split`
Erstellt Split-Screen mit serieller Konsole und Shell.

```bash
dut_console_split
# Links:  Serielle Konsole /dev/ttyUSB0
# Rechts: Interaktive Shell
# Wechsel: Ctrl-A dann Tab
```

#### `dut_power`
Steuert DUT-Power via GPIO Pin 5.

```bash
dut_power on   # DUT einschalten (Pin 5 low)
dut_power off  # DUT ausschalten (Pin 5 high)
```

## Verwendung

### Jumpstarter Exporter starten

```bash
# Exporter mit lokaler Konfiguration starten
jmp exporter run /etc/jumpstarter/exporters/jmp-example-local.yaml

# Mit custom Konfiguration
jmp exporter run ~/my-exporter-config.yaml
```

### Jumpstarter Konfiguration

Beispiel Exporter Config (`/etc/jumpstarter/exporters/jmp-example-local.yaml`):

```yaml
apiVersion: jumpstarter.dev/v1alpha1
kind: ExporterConfig
metadata:
  namespace: default
  name: example-local
export:
  storage:
    type: jumpstarter_driver_opendal.driver.MockStorageMux
  power:
    type: jumpstarter_driver_power.driver.MockPower
```

Für Production-Setup siehe [Jumpstarter Dokumentation](https://jumpstarter.dev).

### Screen Session Workflow

**Einfache Konsole:**
```bash
# Verbinden
dut_console

# Detachen: Ctrl-A dann D
# Wieder verbinden
screen -r
```

**Split Screen:**
```bash
# Split Session starten
dut_console_split

# Zwischen Panes wechseln: Ctrl-A dann Tab
# Pane schließen: Ctrl-A dann X
# Session beenden: Ctrl-A dann K (dann Y)
```

**Screen Shortcuts:**
- `Ctrl-A ?` - Hilfe anzeigen
- `Ctrl-A c` - Neues Fenster erstellen
- `Ctrl-A n` - Nächstes Fenster
- `Ctrl-A p` - Vorheriges Fenster
- `Ctrl-A "` - Fenster-Liste
- `Ctrl-A [` - Copy-Mode (für Scrolling)
- `Ctrl-A F` - Statusleiste ein/aus

### DUT Power Management

```bash
# DUT neustarten
dut_power off
sleep 2
dut_power on

# Power-Zyklus in Kombination mit Konsole
dut_power off && sleep 2 && dut_power on && dut_console_split
```

### Hardware Setup

**Typisches Setup:**
- GPIO Pin 5 → Power Control (Relais/MOSFET)
- USB Port → DUT für Storage/Debugging
- `/dev/ttyUSB0` → Serielle Konsole

**USB SD Mux:**
```bash
# SD-Karte zum Host switchen
usbsdmux /dev/sg0 host

# SD-Karte zum DUT switchen
usbsdmux /dev/sg0 dut

# Mit Jumpstarter automatisiert via Exporter Config
```

## Integration in CI/CD

```yaml
# Beispiel: GitLab CI mit Jumpstarter
test-on-hardware:
  tags:
    - jumpstarter
  script:
    - jmp client lease example-device
    - jmp client power on
    - jmp client storage mount disk.img
    - jmp client power on
    - dut_console_split  # Debug bei Bedarf
    - pytest tests/hardware/
    - jmp client power off
```

## Export

Diese Stage **wird als Image exportiert** (`EXPORT_IMAGE` ist gesetzt). Das resultierende Image kann direkt auf Raspberry Pi Hardware deployed werden.

## Weiterführende Dokumentation

- [Jumpstarter Documentation](https://jumpstarter.dev)
- [GNU Screen Manual](https://www.gnu.org/software/screen/manual/)
- [UV Documentation](https://github.com/astral-sh/uv)
