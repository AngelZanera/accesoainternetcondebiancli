# Documentación del Script de Configuración de Red

## Descripción
Script de bash que permite administrar las configuraciones de red en mi sistema Debian. Ofrece una serie de opciones que van desde listar interfaces de red, cambiar el estado de interfaz de red, conectarse y configurar direcciones ip ya sea de manera estática o dinámica.

## Requisitos
- Sistema operativo basado en Linux.
- Privilegios de superusuario (sudo) para realizar cambios en la configuración de red.
- `iw`, `dhclient` y `wpa_supplicant` deben estar instalados y disponibles.

## Uso
Ejecute el script con permisos de superusuario:
```bash
sudo ./script.sh
```

## Funcionalidades

### 1. Mostrar interfaces de red
Lista todas las interfaces de red disponibles en el sistema y su estado.

**Comando ejecutado:**
```bash
ip link show
```

### 2. Cambiar estado de una interfaz
Permite activar (`up`) o desactivar (`down`) una interfaz de red específica.

**Comando ejecutado:**
```bash
ip link set dev <interfaz> <estado>
```

### 3. Conectar a una red
- Si es una red inalámbrica, escanea las redes disponibles y solicita el SSID y contraseña, sin importar el tipo de cifrado de la red.
- Si es una red cableada, intenta obtener una dirección IP por DHCP.

**Comandos utilizados:**
```bash
iw dev <interfaz> scan
echo "network={
    ssid=\"<SSID>\"
    psk=\"<password>\"
}" > /etc/wpa_supplicant/wpa_supplicant.conf
wpa_supplicant -B -i <interfaz> -c /etc/wpa_supplicant/wpa_supplicant.conf
dhclient <interfaz>
```

### 4. Configurar red (estática o dinámica)
Permite asignar manualmente una dirección IP o configurarla para obtenerla dinámicamente.

- **Configuración estática:**
  - Modifica el archivo `/etc/network/interfaces`.
  - Asigna dirección IP, máscara de red y puerta de enlace.
- **Configuración dinámica:**
  - Habilita DHCP en la interfaz seleccionada.

**Comandos ejecutados:**
```bash
echo "auto <interfaz>
iface <interfaz> inet static
 address <ip>
 netmask <mascara>
 gateway <gateway>" > /etc/network/interfaces
echo "auto <interfaz>
iface <interfaz> inet dhcp" > /etc/network/interfaces
systemctl restart networking
```

### 5. Guardar configuración y hacerla permanente
Los cambios en la configuración de red se almacenan en `/etc/network/interfaces`, asegurando que persistan tras un reinicio.

### 6. Salir
Termina la ejecución del script.


