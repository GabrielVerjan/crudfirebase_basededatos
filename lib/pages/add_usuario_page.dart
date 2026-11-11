import 'package:crudfirebase/services/firebase_services.dart';
import 'package:crudfirebase/widgets/usuario_form.dart';
import 'package:flutter/material.dart';

class AddUsuario extends StatelessWidget {
  const AddUsuario({super.key});

  @override
  Widget build(BuildContext context) {
    return const UsuarioForm(
      titulo: 'Agregar usuario',
      subtitulo: 'Completa los datos para registrar un nuevo usuario.',
      icono: Icons.person_add_alt_1_rounded,
      textoBoton: 'Guardar',
      // CREATE (Tutorial II)
      onGuardar: agregarUsuario,
    );
  }
}
