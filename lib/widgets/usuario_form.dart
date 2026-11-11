import 'package:flutter/material.dart';

/// Formulario reutilizable para agregar y editar usuarios.
class UsuarioForm extends StatefulWidget {
  const UsuarioForm({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.textoBoton,
    required this.onGuardar,
    this.nombreInicial = '',
    this.emailInicial = '',
    this.nocuentaInicial = '',
  });

  final String titulo;
  final String subtitulo;
  final IconData icono;
  final String textoBoton;
  final String nombreInicial;
  final String emailInicial;
  final String nocuentaInicial;
  final Future<void> Function(String nombre, String email, String nocuenta)
      onGuardar;

  @override
  State<UsuarioForm> createState() => _UsuarioFormState();
}

class _UsuarioFormState extends State<UsuarioForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController nombreController;
  late final TextEditingController emailController;
  late final TextEditingController nocuentaController;
  bool guardando = false;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.nombreInicial);
    emailController = TextEditingController(text: widget.emailInicial);
    nocuentaController = TextEditingController(text: widget.nocuentaInicial);
  }

  @override
  void dispose() {
    nombreController.dispose();
    emailController.dispose();
    nocuentaController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => guardando = true);
    try {
      await widget.onGuardar(
        nombreController.text.trim(),
        emailController.text.trim(),
        nocuentaController.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar: $e')),
      );
    }
  }

  InputDecoration _decoracion(String label, IconData icono) {
    final scheme = Theme.of(context).colorScheme;
    OutlineInputBorder borde(Color color, [double ancho = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: ancho),
        );
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icono, color: scheme.primary),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      enabledBorder: borde(const Color(0xFFE3E5EF)),
      focusedBorder: borde(scheme.primary, 2),
      errorBorder: borde(scheme.error),
      focusedErrorBorder: borde(scheme.error, 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              // Encabezado con icono
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [scheme.primary, scheme.tertiary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(widget.icono, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.subtitulo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: nombreController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: _decoracion('Nombre', Icons.person_outline),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Escribe el nombre'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: _decoracion('Email', Icons.alternate_email),
                validator: (v) {
                  final valor = v?.trim() ?? '';
                  if (valor.isEmpty) return 'Escribe el email';
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(valor)) {
                    return 'Email no válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nocuentaController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _guardar(),
                decoration: _decoracion('No. cuenta', Icons.badge_outlined),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Escribe el número de cuenta'
                    : null,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: guardando ? null : _guardar,
                icon: guardando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(guardando ? 'Guardando…' : widget.textoBoton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
