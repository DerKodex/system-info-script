#!/bin/bash

# Script de auditoría de sistema Linux
# Genera un reporte detallado del hardware y software

OUTPUT_FILE="system_report_$(hostname)_$(date +%Y%m%d).txt"

{
echo "=== INFORMACIÓN DEL SISTEMA ==="
echo "--------------------------------"
echo "Fecha: $(date)"
echo "Hostname: $(hostname)"
echo "Uptime: $(uptime -p)"
echo ""

echo "=== SISTEMA OPERATIVO ==="
echo "--------------------------------"
if [ -f /etc/os-release ]; then
    echo "Distribución:"
    cat /etc/os-release
elif [ -f /etc/redhat-release ]; then
    cat /etc/redhat-release
elif [ -f /etc/centos-release ]; then
    cat /etc/centos-release
else
    echo "No se pudo determinar la distribución"
fi
echo ""
echo "Kernel: $(uname -r)"
echo "Arquitectura: $(uname -m)"
echo ""

echo "=== CPU ==="
echo "--------------------------------"
echo "Modelo: $(grep "model name" /proc/cpuinfo | head -n 1 | cut -d ":" -f 2 | sed 's/^[ \t]*//')"
echo "Núcleos físicos: $(grep "physical id" /proc/cpuinfo | sort | uniq | wc -l)"
echo "Núcleos totales: $(grep -c "processor" /proc/cpuinfo)"
echo "Frecuencia: $(grep "MHz" /proc/cpuinfo | head -n 1 | cut -d ":" -f 2 | sed 's/^[ \t]*//') MHz"
echo ""

echo "=== MEMORIA RAM ==="
echo "--------------------------------"
free -h
echo ""
echo "Detalle:"
sudo dmidecode --type memory | grep -E "Size:|Type:|Speed:|Manufacturer:" | grep -v "Unknown" | uniq
echo ""

echo "=== ALMACENAMIENTO ==="
echo "--------------------------------"
echo "Discos disponibles:"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE,MODEL
echo ""
echo "Uso de disco:"
df -h
echo ""
echo "Particiones:"
sudo fdisk -l | grep "Disk /dev/"
echo ""

echo "=== GPU ==="
echo "--------------------------------"
if command -v nvidia-smi &> /dev/null; then
    echo "NVIDIA GPU:"
    nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader
elif lspci | grep -i "vga\|3d\|2d" > /dev/null; then
    echo "GPU detectada:"
    lspci | grep -i "vga\|3d\|2d"
else
    echo "No se detectó GPU dedicada"
fi
echo ""

echo "=== RED ==="
echo "--------------------------------"
echo "Interfaces de red:"
ip -br addr show
echo ""
echo "Puertos abiertos:"
sudo ss -tulnp | grep -E "LISTEN|UNCONN"
echo ""

echo "=== DOCKER ==="
echo "--------------------------------"
if command -v docker &> /dev/null; then
    echo "Versión de Docker: $(docker --version)"
    echo ""
    echo "Contenedores en ejecución:"
    docker ps
    echo ""
    echo "Imágenes disponibles:"
    docker images
else
    echo "Docker no está instalado"
fi
echo ""

echo "=== TEMPERATURAS ==="
echo "--------------------------------"
if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
    echo "Temperatura CPU: $(($(cat /sys/class/thermal/thermal_zone0/temp)/1000))°C"
else
    echo "No se pudo leer temperatura"
fi
echo ""

echo "=== INFORMACIÓN DE RASPBERRY PI (si aplica) ==="
echo "--------------------------------"
if [ -f /proc/device-tree/model ]; then
    echo "Modelo Raspberry Pi:"
    cat /proc/device-tree/model
    echo ""
    echo "Versión PCB:"
    cat /proc/device-tree/model | grep -o "Rev [0-9.]*"
    echo ""
    echo "Voltaje:"
    vcgencmd measure_volts core
    echo ""
    echo "Frecuencia CPU:"
    vcgencmd measure_clock arm
else
    echo "No es una Raspberry Pi"
fi
echo ""

echo "=== RESUMEN PARA TU INFRAESTRUCTURA ==="
echo "--------------------------------"
echo "Equipo: $(hostname)"
echo "IP: $(hostname -I | cut -d' ' -f1)"
echo "CPU: $(grep "model name" /proc/cpuinfo | head -n 1 | cut -d ":" -f 2 | sed 's/^[ \t]*//')"
echo "Núcleos: $(grep -c "processor" /proc/cpuinfo)"
echo "RAM: $(free -h | grep Mem | awk '{print $2}')"
echo "Almacenamiento: $(lsblk -o SIZE | grep -E "[0-9]+G" | head -n 1)"
if [ -f /proc/device-tree/model ]; then
    echo "Tipo: Raspberry Pi ($(cat /proc/device-tree/model | tr -d '\0'))"
else
    echo "Tipo: Computador convencional"
fi

} | tee "$OUTPUT_FILE"

echo ""
echo "Reporte generado en: $(pwd)/$OUTPUT_FILE"
