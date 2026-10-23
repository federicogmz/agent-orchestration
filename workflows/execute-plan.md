---
description: (Modo manual opcional) Ejecuta el último Plan de Implementación aprobado usando Gemini 3.8 Flash, escribiendo todo el código y ejecutando las validaciones hasta pasar sin desviarse del diseño.
---

# Workflow `/execute-plan` — Ejecución de Alta Velocidad (Gemini 3.8 Flash)

*(Nota: Este workflow es el complemento manual opcional de `/plan-argon` cuando el usuario desea ejecutar un `implementation_plan.md` previamente congelado).*

Sigue estos pasos sin desviarte del diseño congelado:

1. **Lectura del Plan Congelado:**
   - Lee el último artefacto `implementation_plan.md` en el directorio de artefactos de la conversación (`<appDataDir>/brain/<conversation-id>/implementation_plan.md`) o el plan aprobado en los turnos recientes.
   - Respeta estrictamente las firmas, contratos, nombres de archivos y restricciones definidos por el Arquitecto (Argon).

2. **Implementación Directa o en Enjambre:**
   - Si los cambios abarcan módulos independientes en paralelo (más de 2 archivos desacoplados), activa la skill `hybrid-swarm` para delegar en subagentes `implementer` con `Model: "flash"`.
   - Si los cambios son secuenciales, implementa el código completo directamente usando `write_file` y `edit_file` sin dejar placeholders ni `TODO`s incompletos.
   - Si el hook `PostToolUse` está activo, ejecutará automáticamente el formateador tras cada edición; no gastes turnos adicionales formateando manualmente.

3. **Verificación y Pruebas Automatizadas:**
   - Ejecuta los comandos de validación especificados en el plan (usando `<PROJECT_ROOT>/.venv/bin/python` para scripts de Python o `npm`/`npx` para módulos web).
   - Nunca ejecutes `--apply` contra bases de datos de producción sin autorización explícita del usuario y respaldo previo en `backups/`.
   - Si algún test o validación falla, corrígelo en máximo 2 iteraciones. Si persiste un bloqueo de diseño o arquitectura, detente y consulta al asesor (`asesor "atasco"`) o escala a **Gemini 4 Argon**.

4. **Reporte Conciso de Cierre:**
   - Entrega un resumen breve con enlaces clicables a los archivos creados/modificados y la salida de validación.
