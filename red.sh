#!/bin/bash

function mostrar_interfaces() {
    echo "Interfaces de red disponibles:"
    ip link show
}

function cambiar_estado_interfaz() {
    read -p "Ingrese la interfaz (ej: eth0, wlan0): " interfaz
    read -p "Ingrese el estado (up o down): " estado
    ip link set dev "$interfaz" "$estado"
    echo "Estado de la interfaz $interfaz cambiado a $estado."
}

function conectar_red() {
    read -p "¿Es una red inalámbrica? (s/n): " es_inalambrica

    if [ "$es_inalambrica" == "s" ]; then
        echo "Escaneando redes disponibles..."
        read -p "Ingrese el nombre de la interfaz inalámbrica (ej: wlan0): " interfaz
        iw dev "$interfaz" scan | grep SSID

        read -p "Ingrese el SSID de la red: " ssid
        read -p "Ingrese la contraseña de la red (o déjelo vacío si no tiene): " password

        if [ -n "$password" ]; then
            echo "network={
    ssid=\"$ssid\"
    psk=\"$password\"
}" > /etc/wpa_supplicant/wpa_supplicant.conf

            wpa_supplicant -B -i "$interfaz" -c /etc/wpa_supplicant/wpa_supplicant.conf
        else
            iw dev "$interfaz" connect "$ssid"
        fi
        dhclient "$interfaz"
    else
        echo "Conectando a red cableada..."
        dhclient eth0
    fi
}


function configurar_red() {
    read -p "Ingrese la interfaz (ej: eth0, wlan0): " interfaz
    read -p "¿Configuración estática o dinámica? (estatica/dinamica): " tipo_config

    if [ "$tipo_config" == "estatica" ]; then
        read -p "Ingrese la dirección IP: " ip
        read -p "Ingrese la máscara de red: " mascara
        read -p "Ingrese la puerta de enlace: " gateway

        echo "Configurando $interfaz como estática..."
        echo "auto $interfaz
iface $interfaz inet static
    address $ip
    netmask $mascara
    gateway $gateway" > /etc/network/interfaces
    else
        echo "auto $interfaz
iface $interfaz inet dhcp" > /etc/network/interfaces
    fi

    systemctl restart networking
    echo "Configuración guardada y aplicada."
}


while true; do
    echo "======================================"
    echo "      Script de Configuración Red     "
    echo "======================================"
    echo "1. Mostrar interfaces de red"
    echo "2. Cambiar estado de una interfaz"
    echo "3. Conectar a una red"
    echo "4. Configurar red (estática o dinámica)"
    echo "5. Salir"
    echo "======================================"
    read -p "Seleccione una opción: " opcion

    case $opcion in
        1) mostrar_interfaces ;;
        2) cambiar_estado_interfaz ;;
        3) conectar_red ;;
        4) configurar_red ;;
        5) echo "Saliendo..."; exit ;;
        *) echo "Opción inválida. Intente nuevamente." ;;
    esac
done
