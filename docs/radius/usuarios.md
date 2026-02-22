# Base de Datos de Usuarios

## Archivo Authorize

El archivo `authorize` contiene la base de datos local de usuarios para FreeRADIUS. Cada entrada define un suscriptor con sus credenciales y atributos de servicio.

## Ubicación

```text
configs/radius/authorize
→ Montado en: /etc/raddb/mods-config/files/authorize
```

## Formato de Entrada

```text
# Formato general
MAC-ADDRESS    Cleartext-Password := "PASSWORD"
               Atributo1 = "Valor1",
               Atributo2 = "Valor2",
               AtributoN = "ValorN"
```

## Usuarios Configurados

### ONT-001 (BNG1)

```text
00:d0:f6:01:01:01   Cleartext-Password := "testlab123"
                    Framed-Pool = "cgnat",
                    Framed-IPv6-Pool = "IPv6",
                    Alc-Delegated-IPv6-Pool = "IPv6",
                    Alc-SLA-Prof-str = "100M",
                    Alc-Subsc-Prof-str = "subprofile",
                    Alc-Subsc-ID-Str = "ONT-001"
```

| Atributo | Valor | Descripción |
|----------|-------|-------------|
| **MAC** | 00:d0:f6:01:01:01 | Identificador único del equipo |
| **Framed-Pool** | cgnat | Pool IPv4 CGNAT (100.64.0.0/10) |
| **Framed-IPv6-Pool** | IPv6 | Pool IPv6 WAN |
| **Alc-Delegated-IPv6-Pool** | IPv6 | Pool para Prefix Delegation |
| **Alc-SLA-Prof-str** | 100M | Perfil de ancho de banda |
| **Alc-Subsc-Prof-str** | subprofile | Perfil de suscriptor |
| **Alc-Subsc-ID-Str** | ONT-001 | ID único del suscriptor |

### ONT-002 (BNG2)

```text
00:d0:f6:01:02:01   Cleartext-Password := "testlab123"
                    Framed-Pool = "cgnat",
                    Framed-IPv6-Pool = "IPv6",
                    Alc-Delegated-IPv6-Pool = "IPv6",
                    Alc-SLA-Prof-str = "100M",
                    Alc-Subsc-Prof-str = "subprofile",
                    Alc-Subsc-ID-Str = "ONT-002"
```

## Agregar Nuevos Usuarios

Para agregar un nuevo suscriptor, añada una entrada al archivo `authorize`:

```text
# Nuevo suscriptor - Plan 200Mbps
00:d0:f6:01:03:01   Cleartext-Password := "testlab123"
                    Framed-Pool = "cgnat",
                    Framed-IPv6-Pool = "IPv6",
                    Alc-Delegated-IPv6-Pool = "IPv6",
                    Alc-SLA-Prof-str = "200M",
                    Alc-Subsc-Prof-str = "subprofile",
                    Alc-Subsc-ID-Str = "ONT-003"
```

!!! tip "Buenas Prácticas"
    
    - Use la MAC del equipo como identificador (username)
    - Mantenga un esquema consistente para `Alc-Subsc-ID-Str`
    - El `Alc-SLA-Prof-str` debe coincidir con un perfil existente en el BNG
    - El `Framed-Pool` debe corresponder a un pool configurado en el BNG

## Perfiles de Servicio Disponibles

| Perfil SLA | Descripción | Down/Up |
|------------|-------------|---------|
| 100M | Plan residencial básico | 100/50 Mbps |
| 200M | Plan residencial estándar | 200/100 Mbps |
| 500M | Plan residencial premium | 500/250 Mbps |
| 1G | Plan empresarial | 1000/500 Mbps |

!!! warning "Importante"
    Los perfiles deben estar pre-configurados en el BNG antes de asignarlos a usuarios. Verifique la existencia del perfil con:
    
    ```text
    show qos sla-profile "NOMBRE-PERFIL"
    ```

## Recargar Usuarios

Después de modificar el archivo `authorize`, recargue FreeRADIUS:

```bash
# Método 1: Signal HUP
docker exec radius pkill -HUP radiusd

# Método 2: Reiniciar servicio
docker exec radius sh -c "pkill radiusd && /usr/sbin/radiusd -x"
```

## Verificación

### Test Local

```bash
# Desde el contenedor RADIUS
docker exec -it radius radtest 00:d0:f6:01:01:01 testlab123 localhost 0 testing123
```

### Ver Sesiones Activas en BNG

```text
A:BNG1# show service active-subscribers

===============================================================================
Active Subscribers
===============================================================================
Subscriber                    
    MAC Address             Service     
-------------------------------------------------------------------------------
ONT-001
    00:d0:f6:01:01:01      VPLS:capture-bng1
-------------------------------------------------------------------------------
No. of Active Subscribers: 1
===============================================================================
```
