---
name: hybrid-swarm
description: >-
  Orquestación multi-agente bajo arquitectura híbrida 10/90 (Gemini 4 Argon + Gemini 3.8 Flash).
  Activar obligatoriamente cuando una tarea involucre tocar más de 2 archivos, explorar múltiples
  módulos o implementar un componente completo en paralelo.
---

# Hybrid Swarm Orchestration Skill (Arquitectura 10/90)

Utiliza esta skill siempre que una tarea requiera inspeccionar o modificar **más de 2 archivos**, cruzar múltiples fuentes de datos o construir un módulo completo.

---

## 1. Plantillas Estándar de Subagentes (`define_subagent`)

Antes de despachar tareas paralelas, define los subagentes especializados según la necesidad de la sesión:

### A. Subagente `explorer` (Solo Lectura — Mapeo de Contexto)
Úsalo para explorar código, buscar referencias, inspeccionar esquemas o analizar logs sin ensuciar la ventana principal de **Gemini 4 Argon**:

```json
{
  "Name": "explorer",
  "Description": "Subagente rápido de solo lectura para mapear contexto, firmas, esquemas SQL y referencias sin contaminar el contexto principal de Argon.",
  "EnableWriteTools": false,
  "EnableSubagentTools": false,
  "EnableMCPTools": false,
  "SystemPrompt": "Eres un Subagente Explorador de solo lectura (arquitectura 10/90). Tu objetivo es localizar archivos, extraer firmas exactas, esquemas SQL y relaciones de código en el menor número de pasos posible. Devuelve SIEMPRE un reporte compacto y estructurado: (1) Archivos hallados con rutas absolutas y líneas clave, (2) Firmas/contratos relevantes, (3) Riesgos o dependencias detectadas. Prohibido volcar archivos enteros en tu respuesta."
}
```

### B. Subagente `implementer` (Escritura Aislada en Paralelo)
Úsalo para implementar módulos independientes, scripts o tests en paralelo con aislamiento de workspace (`"Workspace": "branch"` o `"inherit"`):

```json
{
  "Name": "implementer",
  "Description": "Subagente ejecutor con herramientas de escritura y ejecución para implementar módulos y tests acotados.",
  "EnableWriteTools": true,
  "EnableSubagentTools": false,
  "EnableMCPTools": false,
  "SystemPrompt": "Eres un Subagente Implementador de alta velocidad (arquitectura 10/90). Recibes un contrato o especificación congelada por el Arquitecto Principal (Argon). Implementa exactamente los archivos asignados, ejecuta las pruebas o validaciones locales (usando <PROJECT_ROOT>/.venv/bin/python cuando aplique) y verifica que no existan errores de sintaxis. Nunca ejecutes mutaciones destructivas en bases de datos de producción sin autorización explícita. Devuelve un resumen conciso de los archivos modificados y el resultado de las pruebas."
}
```

---

## 2. Protocolo de Invocación (`invoke_subagent`)

### Paso 1: Despacho de Exploración (`explorer`)
Cuando necesites mapear más de 2 archivos:
```json
{
  "TypeName": "explorer",
  "Role": "Context & Schema Explorer",
  "Model": "flash",
  "Workspace": "inherit",
  "Prompt": "Inspecciona [RUTAS_O_MODULOS] y devuelve: 1) Firmas y estructuras de datos actuales, 2) Dependencias cruzadas, 3) Puntos exactos de inserción."
}
```

### Paso 2: Despacho Automático de Implementación (`implementer`)
Una vez que Argon congela el diseño (sin pedir al usuario que escriba `/execute-plan` ni que cambie el modelo manualmente), despacha la implementación directamente a `flash`:
- Usa `"Workspace": "inherit"` cuando quieras que el subagente escriba directamente sobre el workspace activo.
- Usa `"Workspace": "branch"` cuando ejecutes múltiples implementadores en paralelo sobre módulos aislados.
```json
{
  "TypeName": "implementer",
  "Role": "Module Implementer",
  "Model": "flash",
  "Workspace": "inherit",
  "Prompt": "Implementa el siguiente contrato congelado en [ARCHIVOS_OBJETIVO]:\n[CONTRATO_Y_TIPOS]\nEjecuta la validación con [COMANDO_TEST] y reporta el resumen final."
}
```

### Paso 3: Revisión e Integración por Argon
1. Recibe las notificaciones reactivas de los subagentes (no hagas polling en bucle).
2. Verifica que los cambios cumplan el contrato congelado y las invariantes del proyecto.
3. Consolida el resultado final para el usuario.
