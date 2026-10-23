---
description: (Modo manual opcional) Escanea el contexto con subagentes ligeros, diseña la arquitectura, congela interfaces/contratos y genera el Artefacto de Plan de Implementación sin escribir código de producción.
---

# Workflow `/plan-argon` — Diseño Arquitectónico y Congelamiento de Contratos (Regla 10/90)

*(Nota: En operación estándar la regla 10/90 se ejecuta de forma 100% automática. Utiliza este workflow únicamente si deseas forzar una pausa manual de revisión entre la fase de diseño en Argon y la ejecución en Flash).*

Sigue estrictamente este flujo cuando el usuario invoque `/plan-argon`:

1. **Exploración Delegada (Cero Ruido en Contexto Principal):**
   - No leas múltiples archivos extensos directamente desde Gemini 4 Argon.
   - Invoca un subagente de solo lectura (`invoke_subagent` con `TypeName: "research"` o el subagente `explorer` definido en la skill `hybrid-swarm`, usando `Model: "flash"`) para escanear los archivos relevantes del proyecto y devolver únicamente el mapa de dependencias, firmas actuales y restricciones.

2. **Diseño de Arquitectura y Contratos Exactos:**
   - Analiza el resumen devuelto por el subagente.
   - Define con precisión:
     - Archivos exactos a crear o modificar.
     - Firmas de funciones, clases, tipos (Python / TypeScript) o consultas/migraciones SQL.
     - Invariantes de seguridad (respaldos en `backups/`, banderas `--apply`, preservación de IDs primarios).
     - Comandos exactos de verificación y pruebas.

3. **Generación del Artefacto de Plan de Implementación:**
   - Crea el archivo `implementation_plan.md` en el directorio de artefactos de la conversación (`<appDataDir>/brain/<conversation-id>/implementation_plan.md`) con `ArtifactMetadata` (`UserFacing: true`, `RequestFeedback: true`).
   - **PROHIBIDO escribir código de producción** o modificar archivos del repositorio durante este workflow.

4. **Cierre y Handoff Determinista:**
   - Detén la ejecución inmediatamente después de publicar el artefacto y responde al usuario con:
     > *"Plan e interfaces congeladas. Puedes continuar directamente o cambiar a **Gemini 3.8 Flash** y escribir `/execute-plan` para implementar."*
