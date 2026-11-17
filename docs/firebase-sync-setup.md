# Configuración pendiente de Firebase — Calendario 3.0

Proyecto asociado en los archivos FlutterFire: `calendario-turnos-8453d`.

## Lo que ya está implementado en la app
- Firebase Core se inicializa de forma opcional; si falla, la app sigue en modo local.
- Registro e inicio de sesión por correo/contraseña.
- Crear un calendario compartido a partir de un cuadrante local.
- Código de invitación aleatorio de 12 caracteres; en Firestore solo se almacena su hash.
- Unirse al grupo y limitarlo a 10 miembros.
- Sincronización manual de turnos del cuadrante seleccionado (las notas y preferencias personales no se suben).
- Comparación de tres vías con detección de ediciones simultáneas y resolución explícita.
- Reglas de Firestore con acceso restringido a miembros del grupo.

## Activación necesaria en Firebase Console
1. Abre el proyecto `calendario-turnos-8453d`.
2. Authentication → Sign-in method → activa **Email/Password**.
3. Firestore Database → crea la base de datos en modo producción.
4. Desde la raíz del proyecto, instala Firebase CLI si no está disponible y autentícate con una cuenta propietaria del proyecto.
5. Publica únicamente las reglas: `firebase deploy --only firestore:rules --project calendario-turnos-8453d`.

El repositorio contiene `firebase.json`, `.firebaserc`, `firestore.rules` y `firestore.indexes.json`. Las reglas no se han desplegado desde este entorno: no se dispone de Firebase CLI autenticada y no se ha autorizado un cambio directo de backend.

## Prueba antes de usar datos reales
- Crear una cuenta de prueba y un grupo con un cuadrante de prueba.
- Unirse desde un segundo dispositivo con otra cuenta.
- Probar alta, edición y borrado en un único dispositivo.
- Editar el mismo día en ambos dispositivos y verificar que aparece el diálogo de conflicto.
- Probar una desconexión de red y volver a sincronizar.
- Verificar que las notas personales nunca aparecen en Firestore.

Hasta desplegar las reglas y habilitar Email/Password, la pantalla de sincronización puede mostrar `permission-denied` o `operation-not-allowed`. Esto no afecta al calendario local.
