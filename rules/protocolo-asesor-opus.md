---
trigger: always_on
description: Protocolo de Asesoría Técnica Senior con Claude Opus (asesor CLI) para planes, atascos, auditorías pre-commit y cambios de enfoque.
---

# Protocolo de Asesoría Senior (Claude Opus)

Cuentas con un Asesor Técnico Senior (Claude Opus) accesible mediante el comando CLI:
`asesor "<tipo>" < /ruta/informe.md`

## 1. Principio Fundamental
- **El Asesor es de SOLO LECTURA:** Se ejecuta sin herramientas locales ni servidores MCP (`--tools "" --strict-mcp-config --mcp-config '{"mcpServers":{}}'`). Su rol es consultivo: analiza, detecta riesgos arquitectónicos, evalúa causas raíz y audita cambios.
- **Confidencialidad en informes:** Nunca incluyas contraseñas, tokens, claves API ni direccionamiento interno sensible en los informes enviados al asesor.
- **Tú eres el ejecutor y decisor:** Tú eres responsable de inspeccionar el entorno, diseñar la solución, aplicar los cambios y ejecutar las pruebas. Lo que el asesor devuelve es una opinión calificada, no una orden.

## 2. Puntos de Consulta Obligatoria
Debes invocar obligatoriamente al asesor en los siguientes 4 escenarios:

1. **ANTES de editar (tipo: `plan`):**
   - Si la tarea involucra modificar o crear **3 o más archivos**.
   - Si altera la **arquitectura del sistema** (módulos, esquemas de BD, protocolos de red, dependencias clave o flujos de despliegue).
   - Si toca entornos o ramas de producción.
   *Flujo:* Primero exploras y verificas el estado actual, luego redactas el plan y consultas al asesor, y solo tras procesar su consejo comienzas a editar.

2. **Segundo intento fallido (tipo: `atasco`):**
   - Si un test, compilación o comando falla por **SEGUNDA vez** consecutiva tras un intento de solución, **DETENTE**.
   - Queda estrictamente prohibido intentar un 3er parche a ciegas sin consultar al asesor con el diagnóstico del problema.

3. **Auditoría final pre-cierre o pre-commit (tipo: `auditoria`):**
   - Antes de dar por finalizada la tarea o solicitar aprobación para commit: guarda los cambios, genera el `git diff` completo y envíalo a Opus para que audite que el diff responde estrictamente al requerimiento original sin efectos secundarios ni código muerto.

4. **Cambio de rumbo o bloqueo técnico (tipo: `enfoque`):**
   - Si una hipótesis de trabajo queda descartada o te encuentras sin avance claro y necesitas evaluar alternativas técnicas.

*(Excepción: NO consultes al asesor en micro-cambios reactivos de 1 o 2 archivos conocidos, corrección de typos, consultas informativas de solo lectura o comandos cuyo resultado indique directamente el siguiente paso).*

## 3. Protocolo de Comunicación con el Asesor
El asesor **NO ve el historial de conversación ni los archivos del sistema en vivo**. Todo lo que sepa dependerá del informe que le pases por entrada estándar (`stdin`).

### Estructura obligatoria del informe Markdown:
Genera un archivo temporal (ej. en `scratch/informe_consulta.md`) con la siguiente estructura:
- **Pedido original:** Requerimiento literal del usuario.
- **Evidencia verificada:** Comandos ejecutados, archivos leídos, logs de error o puertos probados (hechos empíricos, no suposiciones).
- **Supuestos o hipótesis:** Qué asumes que aún no se ha comprobado.
- **Propuesta / Plan paso a paso:** Los pasos exactos que planeas ejecutar (para `plan` o `enfoque`) o el `git diff` (para `auditoria`).

### Invocación CLI:
```bash
asesor "plan" < scratch/informe_plan.md
asesor "atasco" < scratch/informe_atasco.md
asesor "auditoria" < scratch/informe_auditoria.md
asesor "enfoque" < scratch/informe_enfoque.md
```

## 4. Tratamiento Crítico de la Respuesta
- **No aceptes recomendaciones a ciegas:** Si una sugerencia del asesor contradice evidencia empírica ya comprobada en la terminal, no la apliques en silencio: descártala con fundamento técnico o realiza una repregunta contrastando los datos.
- **Puerta de seguridad (Gate de Usuario):** El visto bueno del asesor ("Adelante", "Aprobado") **NUNCA** sustituye la autorización explícita del usuario para acciones irreversibles (`git push`, despliegues en producción, borrados de carpetas o migraciones de datos).
