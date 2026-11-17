import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const String _privacyPolicy = r'''POLÍTICA DE PRIVACIDAD DE CALENDARIO

Versión de trabajo para revisión antes de publicar. El responsable debe completar su identidad legal y domicilio antes de distribuir la aplicación.

1. RESPONSABLE Y CONTACTO
Aplicación: Calendario de turnos. Desarrollador/marca: AJATSoft. Contacto de privacidad: ajatsoft@gmail.com. Responsable legal: pendiente de completar con el nombre o razón social y domicilio del titular.

2. USO LOCAL SIN CUENTA
Calendario puede utilizarse sin crear una cuenta. En ese modo, turnos, cuadrantes, notas, recordatorios y preferencias se guardan en el almacenamiento local del dispositivo o navegador. Las notas personales no se envían a la función de calendarios compartidos. Las copias de seguridad exportadas se guardan en el destino que elija el usuario.

3. CUENTA Y CALENDARIOS COMPARTIDOS (OPCIONAL)
Si el usuario crea una cuenta y comparte un cuadrante, la aplicación utiliza Firebase Authentication y Cloud Firestore, servicios de Google. Se procesan el correo electrónico, un identificador interno de usuario, la pertenencia al grupo, el nombre del cuadrante compartido y sus turnos (fecha, título, descripción, hora de inicio, hora de fin y color). El código de invitación se almacena en forma de hash.

No se sincronizan las notas, alarmas personales, preferencias de apariencia ni otros cuadrantes que no se hayan seleccionado. La sincronización se inicia manualmente desde la pantalla correspondiente y solo debe considerarse activa cuando la configuración se haya completado correctamente.

4. PUBLICIDAD
La aplicación integra Google Mobile Ads. El proveedor puede procesar identificadores del dispositivo, información técnica y datos de interacción para prestar el servicio publicitario y, cuando corresponda y exista consentimiento válido, personalizar anuncios. Antes de distribuir en el Espacio Económico Europeo deben configurarse y probarse los avisos de consentimiento y las opciones publicitarias exigibles.

5. FINALIDADES Y BASES JURÍDICAS
- Guardar y mostrar datos locales: prestar las funciones solicitadas.
- Cuenta y sincronización opcional: ejecutar la función de cuenta y calendario compartido solicitada.
- Seguridad y prevención de abuso: interés legítimo y obligaciones aplicables.
- Publicidad: consentimiento cuando sea legalmente necesario y demás bases aplicables al servicio publicitario.

6. PROVEEDORES Y DESTINATARIOS
Los datos de cuenta y los cuadrantes compartidos se alojan mediante Firebase Authentication y Cloud Firestore de Google. La publicidad se presta mediante Google Mobile Ads. No se venden datos personales. Los datos compartidos solo son accesibles a miembros autorizados del grupo conforme a las reglas de seguridad del backend.

7. CONSERVACIÓN Y ELIMINACIÓN
- Datos locales: permanecen hasta que el usuario los borre, elimine los datos de la aplicación o desinstale la aplicación. Desinstalar puede eliminar datos locales no respaldados.
- Datos compartidos: permanecen mientras exista el grupo y sus registros. El propietario puede eliminar el grupo y un miembro puede salir.
- Cuenta: puede eliminarse desde la pantalla de sincronización. La eliminación puede requerir volver a autenticarse. No borra automáticamente los datos locales.
- Copias exportadas: el usuario debe borrar las copias guardadas fuera de la aplicación.

8. SEGURIDAD
Se aplican controles de acceso por usuario y pertenencia al grupo para los documentos compartidos. Ningún sistema conectado a Internet puede garantizar seguridad absoluta; el usuario debe proteger sus credenciales y códigos de invitación.

9. DERECHOS DE PROTECCIÓN DE DATOS
Cuando proceda, pueden solicitarse acceso, rectificación, supresión, limitación, oposición y portabilidad escribiendo a ajatsoft@gmail.com. También puede presentarse una reclamación ante la Agencia Española de Protección de Datos (AEPD).

10. MENORES
La aplicación no está diseñada para que menores creen cuentas o compartan datos sin la autorización y supervisión exigidas por la legislación aplicable.

11. ALMACENAMIENTO WEB Y COOKIES
La versión web utiliza almacenamiento del navegador para conservar datos locales y preferencias necesarias. Los proveedores externos de publicidad o autenticación pueden utilizar tecnologías propias sujetas a sus políticas.

12. MODIFICACIONES
Esta política podrá actualizarse si cambian las funciones, proveedores o requisitos legales. La versión vigente se publicará junto a la aplicación.

PENDIENTE ANTES DE PUBLICACIÓN: completar identidad legal y domicilio del responsable; revisar contratos y regiones de Firebase; configurar consentimiento publicitario para usuarios del EEE; validar el texto con asesoría especializada.
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        title: Text(
          'Política de privacidad',
          style: CustomTextStyle.appBarTitle(context: context),
        ),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SelectableText(
            _privacyPolicy,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(height: 1.5),
          ),
        ),
      ),
    );
  }
}
