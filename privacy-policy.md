# Política de privacidad de Calendario

**Versión de trabajo para revisión antes de publicar.** Antes de distribuir la aplicación, el responsable debe completar su nombre o razón social y domicilio legal.

## 1. Responsable y contacto

- Aplicación: Calendario de turnos.
- Desarrollador/marca: AJATSoft.
- Contacto de privacidad: ajatsoft@gmail.com.
- Responsable legal: **pendiente de completar con la identidad y domicilio del titular de la aplicación**.

## 2. Uso local sin cuenta

Calendario puede utilizarse sin crear una cuenta. En ese modo, los turnos, cuadrantes, notas, recordatorios y preferencias se guardan en el almacenamiento local del dispositivo o navegador. La aplicación no envía las notas personales a la función de calendarios compartidos.

Las copias de seguridad que el usuario exporta se guardan en el destino que elija y quedan bajo su control.

## 3. Cuenta y calendarios compartidos (opcional)

Si el usuario decide crear una cuenta y compartir un cuadrante, la aplicación utiliza Firebase Authentication y Cloud Firestore, servicios de Google.

Se procesan:
- Correo electrónico y datos técnicos de la cuenta para autenticarla.
- Identificador interno de usuario y pertenencia al grupo compartido.
- Nombre del cuadrante compartido.
- Turnos del cuadrante: fecha, título, descripción, hora de inicio, hora de fin y color.
- Código de invitación en forma de hash; el código original se muestra al propietario para compartirlo.

**No se sincronizan las notas, alarmas personales, preferencias de apariencia ni otros cuadrantes que no se hayan seleccionado para compartir.** La sincronización se inicia desde la pantalla correspondiente; no se debe considerar activa hasta que el usuario la configure y complete correctamente.

## 4. Publicidad

La aplicación integra Google Mobile Ads. El proveedor puede procesar identificadores del dispositivo, información técnica y datos de interacción para prestar el servicio publicitario y, cuando corresponda y exista consentimiento válido, personalizar anuncios. Antes de distribuir en el Espacio Económico Europeo deben configurarse y probarse los avisos de consentimiento y las opciones de publicidad exigibles.

## 5. Finalidades y bases jurídicas

- Guardar y mostrar datos locales: prestación de las funciones solicitadas por el usuario.
- Cuenta y sincronización opcional: ejecución de la función de cuenta y calendario compartido solicitada.
- Seguridad y prevención de abuso: interés legítimo y obligaciones aplicables.
- Publicidad: consentimiento cuando sea legalmente necesario y las demás bases aplicables al servicio publicitario.

## 6. Proveedores y destinatarios

Los datos de cuenta y los cuadrantes compartidos se alojan mediante Firebase Authentication y Cloud Firestore de Google. La publicidad se presta mediante Google Mobile Ads. Estos proveedores procesan datos conforme a sus condiciones y documentación de privacidad.

No se venden datos personales. Los datos compartidos solo son accesibles a los miembros autorizados del grupo conforme a las reglas de seguridad del backend.

## 7. Conservación y eliminación

- Datos locales: permanecen en el dispositivo hasta que el usuario los borre, elimine los datos de la aplicación o desinstale la aplicación. Desinstalar puede eliminar los datos locales que no se hayan respaldado.
- Datos compartidos: permanecen mientras exista el grupo y sus registros. El propietario puede eliminar el grupo compartido; un miembro puede salir del grupo.
- Cuenta: se puede solicitar su eliminación desde la pantalla de sincronización. La eliminación puede requerir volver a autenticarse. La eliminación de la cuenta no borra automáticamente los datos locales del dispositivo.
- Copias exportadas: el usuario debe borrar las copias que haya guardado fuera de la aplicación.

## 8. Seguridad

Se aplican controles de acceso por usuario y pertenencia al grupo para los documentos de calendarios compartidos. Ningún sistema conectado a Internet puede garantizar seguridad absoluta; el usuario debe proteger sus credenciales y códigos de invitación.

## 9. Derechos de protección de datos

Las personas usuarias pueden solicitar acceso, rectificación, supresión, limitación, oposición y portabilidad cuando proceda, escribiendo a ajatsoft@gmail.com. También pueden presentar una reclamación ante la Agencia Española de Protección de Datos (AEPD).

## 10. Menores

La aplicación no está diseñada para que menores creen cuentas o compartan datos sin la autorización y supervisión que exija la legislación aplicable.

## 11. Almacenamiento web y cookies

La versión web utiliza almacenamiento del navegador para conservar los datos locales y preferencias necesarias para el funcionamiento. Los proveedores externos de publicidad o autenticación pueden utilizar tecnologías propias sujetas a sus políticas.

## 12. Cambios

Esta política podrá actualizarse si cambian las funciones, proveedores o requisitos legales. La versión vigente se publicará junto a la aplicación.

---

**Pendiente antes de publicación:** completar identidad legal y domicilio del responsable; revisar contratos y regiones de Firebase; configurar consentimiento de anuncios para usuarios del EEE; validar esta política con asesoría especializada.
