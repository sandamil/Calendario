import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const String _privacyPolicy = r'''POLÍTICA DE PRIVACIDAD

Bienvenido a «Calendario de turnos». Para permitirle utilizar los servicios y la información del servicio con tranquilidad, le explicamos la política de protección de la privacidad para proteger sus derechos e intereses. Por favor, lea lo siguiente.

1. ÁMBITO DE APLICACIÓN DE LA POLÍTICA DE PROTECCIÓN DE LA PRIVACIDAD

El contenido de esta política incluye la forma en que el servicio maneja la información de identificación personal recopilada cuando utiliza sus servicios. Esta política no se aplica a otros sitios web vinculados ni a las personas que no están encargadas ni participan en la gestión de este servicio.

2. RECOPILACIÓN, PROCESAMIENTO Y USO DE DATOS PERSONALES

• Cuando visite este servicio o utilice sus funciones, dependiendo de la naturaleza de la función, podremos solicitar los datos personales necesarios y procesarlos dentro del ámbito de dicha función. El servicio no utilizará esos datos para otros fines sin el consentimiento correspondiente.

• El servicio conservará el nombre, la dirección de correo electrónico, la información de contacto y el tiempo de uso que proporcione al utilizar funciones interactivas, como buzones de servicio y cuestionarios.

• Durante la navegación general, el servidor registrará información como la dirección IP del dispositivo conectado, el tiempo de uso, el navegador utilizado y los registros de navegación y clics. Estos datos se utilizarán como referencia para mejorar los servicios del sitio web, serán de uso interno y no se harán públicos.

• Para prestar servicios precisos, se realizarán estadísticas y análisis sobre los cuestionarios recopilados. Los datos estadísticos o los textos explicativos podrán publicarse cuando sea necesario, sin incluir información que identifique a personas concretas.

3. PROTECCIÓN DE DATOS

El servicio exigirá el cumplimiento de las obligaciones de confidencialidad y adoptará los procedimientos de inspección necesarios para comprobar que se cumplen.

4. ENLACES EXTERNOS DEL SITIO WEB

Este servicio proporciona enlaces a otros sitios web. Sin embargo, esos sitios no están cubiertos por esta política de privacidad. Consulte la política de privacidad del sitio web correspondiente.

5. POLÍTICA SOBRE EL INTERCAMBIO DE DATOS PERSONALES CON TERCEROS

Este servicio no proporcionará, intercambiará, alquilará ni venderá datos personales a otras personas, grupos, empresas privadas u organismos públicos, excepto cuando exista una base legal u obligación contractual.

Las excepciones incluyen:

• Cuando exista consentimiento por escrito.
• Cuando la ley lo disponga expresamente.
• Cuando sea necesario para evitar un peligro para la vida, el cuerpo, la libertad o la propiedad.
• Cuando sea necesaria la cooperación con organismos públicos o instituciones de investigación académica para investigaciones de interés público o estadísticas, siempre que los datos divulgados no permitan identificar a una persona concreta.
• Cuando el comportamiento de un usuario infrinja las condiciones del servicio, perjudique los derechos o intereses del sitio web u otros usuarios, o cause daños, y la administración necesite investigar o emprender acciones legales.
• Cuando sea favorable a los intereses de la persona afectada.
• Cuando el servicio encargue a un proveedor la recopilación, el procesamiento o el uso de datos personales. En ese caso, el servicio será responsable de supervisar y gestionar al proveedor o a la persona subcontratada.

6. USO DE COOKIES

Para ofrecer un mejor servicio, este servicio podrá colocar y utilizar cookies en su dispositivo.

7. MODIFICACIONES DE LA POLÍTICA DE PRIVACIDAD

Esta política podrá modificarse en cualquier momento para responder a las necesidades del servicio. Las condiciones modificadas se publicarán en el sitio web.
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
          ),
        ),
      ),
    );
  }
}
