#!/bin/bash
# Script de verificación de DHCPv6 con Prefix Delegation

echo "=============================================="
echo "Verificación de DHCPv6 con Prefix Delegation"
echo "=============================================="
echo ""

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_pass() {
    echo -e "${GREEN}[✓] $1${NC}"
}

check_fail() {
    echo -e "${RED}[✗] $1${NC}"
}

check_warn() {
    echo -e "${YELLOW}[!] $1${NC}"
}

# ============================================
# Verificar en ONT1
# ============================================
echo "--- Verificando ONT1 ---"

# Verificar odhcp6c
if docker exec ont1 pgrep -f odhcp6c > /dev/null 2>&1; then
    check_pass "odhcp6c está corriendo en ONT1"
else
    check_fail "odhcp6c NO está corriendo en ONT1"
    echo "   Ejecutar: docker exec ont1 /home/user/start-dhcp6-pd.sh eth1.150 eth2 &"
fi

# Verificar IPv4
ONT1_IPV4=$(docker exec ont1 ip -4 addr show eth1.150 2>/dev/null | grep "inet " | awk '{print $2}')
if [ -n "$ONT1_IPV4" ]; then
    check_pass "ONT1 tiene IPv4 WAN: $ONT1_IPV4"
else
    check_fail "ONT1 NO tiene IPv4 WAN"
fi

# Verificar IPv6 WAN
ONT1_IPV6_WAN=$(docker exec ont1 ip -6 addr show eth1.150 scope global 2>/dev/null | grep "inet6" | head -1 | awk '{print $2}')
if [ -n "$ONT1_IPV6_WAN" ]; then
    check_pass "ONT1 tiene IPv6 WAN: $ONT1_IPV6_WAN"
else
    check_fail "ONT1 NO tiene IPv6 WAN (IA_NA)"
fi

# Verificar IPv6 LAN (PD)
ONT1_IPV6_LAN=$(docker exec ont1 ip -6 addr show eth2 scope global 2>/dev/null | grep "inet6" | head -1 | awk '{print $2}')
if [ -n "$ONT1_IPV6_LAN" ]; then
    check_pass "ONT1 tiene IPv6 LAN (PD): $ONT1_IPV6_LAN"
else
    check_warn "ONT1 NO tiene IPv6 en LAN - verificar PD"
fi

# Verificar radvd
if docker exec ont1 pgrep radvd > /dev/null 2>&1; then
    check_pass "radvd está corriendo en ONT1"
else
    check_warn "radvd NO está corriendo en ONT1 - PC1 no recibirá prefijo"
fi

echo ""

# ============================================
# Verificar en ONT2
# ============================================
echo "--- Verificando ONT2 ---"

# Verificar odhcp6c
if docker exec ont2 pgrep -f odhcp6c > /dev/null 2>&1; then
    check_pass "odhcp6c está corriendo en ONT2"
else
    check_fail "odhcp6c NO está corriendo en ONT2"
fi

# Verificar IPv4
ONT2_IPV4=$(docker exec ont2 ip -4 addr show eth1.150 2>/dev/null | grep "inet " | awk '{print $2}')
if [ -n "$ONT2_IPV4" ]; then
    check_pass "ONT2 tiene IPv4 WAN: $ONT2_IPV4"
else
    check_fail "ONT2 NO tiene IPv4 WAN"
fi

# Verificar IPv6 WAN
ONT2_IPV6_WAN=$(docker exec ont2 ip -6 addr show eth1.150 scope global 2>/dev/null | grep "inet6" | head -1 | awk '{print $2}')
if [ -n "$ONT2_IPV6_WAN" ]; then
    check_pass "ONT2 tiene IPv6 WAN: $ONT2_IPV6_WAN"
else
    check_fail "ONT2 NO tiene IPv6 WAN (IA_NA)"
fi

echo ""

# ============================================
# Verificar en PC1
# ============================================
echo "--- Verificando PC1 ---"

PC1_IPV6=$(docker exec pc1 ip -6 addr show eth1 scope global 2>/dev/null | grep "inet6" | head -1 | awk '{print $2}')
if [ -n "$PC1_IPV6" ]; then
    check_pass "PC1 tiene IPv6 del prefijo delegado: $PC1_IPV6"
else
    check_warn "PC1 NO tiene IPv6 - ejecutar configuración:"
    echo "   docker exec pc1 sysctl -w net.ipv6.conf.eth1.accept_ra=2"
    echo "   docker exec pc1 ip link set eth1 up"
fi

echo ""

# ============================================
# Verificar logs
# ============================================
echo "--- Últimas líneas de log de odhcp6c en ONT1 ---"
docker exec ont1 tail -5 /var/log/odhcp6c.log 2>/dev/null || echo "(No hay log disponible)"

echo ""
echo "=============================================="
echo "Verificación completa"
echo ""
echo "Para más detalles, ejecutar en los BNGs:"
echo "  show service active-subscribers hierarchy"
echo "  show service id 9998 dhcp6 summary"
echo "  show service id 9998 dhcp6 lease-state"
echo "=============================================="
