# Contexto del proyecto

Este repositorio forma parte de una integración entre **Microsoft Dynamics 365 Business Central (BC)** y **PrestaShop**. Antes de proponer código o soluciones, ten en cuenta las siguientes restricciones técnicas.

## Stack y versiones

- **Business Central**: trabajo con varias versiones de BC (no asumir siempre la misma runtime). **Antes de proponer código AL, pregunta o confirma la versión/runtime del proyecto concreto**, ya que la disponibilidad de funciones (ej. `Codeunit "Temp Blob"`, `FieldRef.CreateOutStream`, namespaces del System Application) varía bastante entre versiones.
- **Lenguaje AL**: confirmar siempre la sintaxis compatible con la runtime del proyecto en el que se esté trabajando.
- **PrestaShop**: integración vía Webservice REST/XML (`/api/...`), con clientes en PHP (módulos propios) y C# (.NET Framework, uso de `RestSharp`).
- **C#**: .NET Framework (no .NET Core/5+). Evitar sugerir paquetes o sintaxis exclusivos de .NET moderno salvo que se indique lo contrario.
- **Infraestructura**: servidores Windows Server (IIS) y Linux/Ubuntu con Plesk, Apache, Cloudflare.

## Reglas específicas de AL

- Para leer/escribir campos Blob de forma genérica vía `RecordRef`/`FieldRef`, verificar primero si `FieldRef.CreateOutStream` está disponible en la versión del proyecto; si no lo está, usar el record tipado directamente (`Rec."Campo Blob".CreateOutStream(...)`) o `FieldRef.Value := texto` como alternativa compatible con versiones antiguas.
- Si se usa `Codeunit "Temp Blob"`, confirmar antes que esté accesible en la versión/runtime concreta; si no, usar `Record TempBlob` o el enfoque de `FieldRef.Value`.
- Siempre usar `Rec.` explícito al referenciar campos del record en page extensions y triggers (el acceso implícito a campos no está permitido en versiones recientes del compilador AL).
- Para enums personalizados, table relations y filtros SOAP, seguir el patrón ya existente en el proyecto (ej. enum `"PSC Tienda Online"`).
- Antes de proponer sintaxis con `SetFilter` que contenga espacios o caracteres especiales, verificar el escaping correcto para la versión del proyecto.

## Reglas específicas de PrestaShop

- La comunicación con BC se hace vía SOAP (no `SoapClient` de PHP en algunos módulos — cURL manual con OAuth 2.0) y vía Webservice REST/XML estándar de PrestaShop para otros casos.
- Recurso `specific_prices`: usar `reduction_type = 'amount'` para importes fijos y `'percentage'` para descuentos porcentuales. Las fechas deben ir en formato `YYYY-MM-DD HH:MM:SS`, distinto al formato `dd-MM-yyyy` que genera BC.
- Antes de proponer cambios en módulos personalizados (`facturacionnav`, `area_cliente_nav`, `cw_stocks`, `cw_customer_warehouses`), revisar que los hooks estén correctamente registrados en `ps_module_shop`.

## Estilo de código preferido

- Comentarios y nombres de variables en español cuando el código ya existente los usa así (mantener consistencia con el codebase).
- Preferir soluciones explícitas y verbosas frente a "magia" o abstracciones excesivas, dado que el mantenimiento es a largo plazo y por una sola persona/equipo pequeño.
- Al proponer una función, indicar siempre si depende de alguna característica que deba verificarse contra la versión/runtime concreta del proyecto.

## Cosas que NO hacer

- No asumir disponibilidad de namespaces o `using` de módulos del System Application sin confirmar que la dependencia existe en `app.json`.
- No sugerir `localStorage`/`sessionStorage` en código JS embebido en módulos PrestaShop si se trata de artifacts o contenido que deba persistir entre sesiones de servidor.
- No mezclar sintaxis de .NET moderno (C# 9+, `record`, top-level statements) en proyectos .NET Framework salvo que se confirme la versión exacta del proyecto.
