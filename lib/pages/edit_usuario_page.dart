import 'package:crudfirebase/services/firebase_services.dart';
import 'package:crudfirebase/widgets/usuario_form.dart';
import 'package:flutter/material.dart';

class EditUsuario extends StatelessWidget {
  const EditUsuario({super.key});

  @override
  Widget build(BuildContext context) {
    // Recibimos los argumentos enviados desde Home (Tutorial III, paso 5)
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;

    return UsuarioForm(
      titulo: 'Editar usuario',
      subtitulo: 'Modifica los datos y presiona Actualizar para guardarlos.',
      icono: Icons.edit_note_rounded,
      textoBoton: 'Actualizar',
      nombreInicial: arguments['nombre'],
      emailInicial: arguments['eMail'],
      nocuentaInicial: arguments['nCuenta'],
      // UPDATE (Tutorial III)
      onGuardar: (nombre, email, nocuenta) =>
          editUsuario(arguments['uid'], nombre, email, nocuenta),
    );
  }
}
