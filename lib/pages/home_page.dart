import 'package:flutter/material.dart';
import 'package:crudfirebase/services/firebase_services.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Escucha la coleccion en tiempo real: cualquier cambio se ve al instante
  final Stream<List> _usuarios = streamUsuarios();
  // uids eliminados que se ocultan mientras Firestore confirma el borrado
  final Set<String> _eliminados = {};
  String _busqueda = '';

  // Colores para los avatares
  static const List<Color> _paleta = [
    Color(0xFF5B5BD6),
    Color(0xFF0EA5A4),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF3B82F6),
    Color(0xFF10B981),
    Color(0xFF8B5CF6),
  ];

  Color _colorPara(String nombre) =>
      _paleta[nombre.hashCode.abs() % _paleta.length];

  String _iniciales(String nombre) {
    final partes =
        nombre.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (partes.isEmpty) return '?';
    return partes.take(2).map((p) => p[0].toUpperCase()).join();
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List>(
          stream: _usuarios,
          builder: (context, snapshot) {
            final todos = (snapshot.data ?? [])
                .where((u) => !_eliminados.contains(u['uid']))
                .toList();
            final q = _busqueda.toLowerCase();
            final usuarios = q.isEmpty
                ? todos
                : todos
                    .where((u) =>
                        '${u['nombre']} ${u['email']} ${u['nocuenta']}'
                            .toLowerCase()
                            .contains(q))
                    .toList();

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _encabezado(scheme, todos.length)),
                SliverToBoxAdapter(child: _buscador(scheme)),
                if (snapshot.hasError)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _estado(
                      icono: Icons.cloud_off_rounded,
                      titulo: 'Algo salió mal',
                      texto: '${snapshot.error}',
                    ),
                  )
                else if (!snapshot.hasData)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (usuarios.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _estado(
                      icono: q.isEmpty
                          ? Icons.group_outlined
                          : Icons.search_off_rounded,
                      titulo: q.isEmpty
                          ? 'No hay usuarios registrados'
                          : 'Sin resultados',
                      texto: q.isEmpty
                          ? 'Toca "Nuevo usuario" para agregar el primero.'
                          : 'Prueba con otro nombre, email o cuenta.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    sliver: SliverList.separated(
                      itemCount: usuarios.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _tarjeta(context, usuarios[index]),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      // CREATE: boton para ir a agregar (Tutorial II parte 3, paso 4)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final guardado = await Navigator.pushNamed(context, '/add');
          if (guardado == true) _mensaje('Usuario agregado');
        },
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Nuevo usuario'),
      ),
    );
  }

  Widget _encabezado(ColorScheme scheme, int total) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.30),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CRUD Firebase',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Usuarios',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Text(
                  '$total',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  total == 1 ? 'registro' : 'registros',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buscador(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: TextField(
        onChanged: (v) => setState(() => _busqueda = v.trim()),
        decoration: InputDecoration(
          hintText: 'Buscar por nombre, email o cuenta',
          prefixIcon: const Icon(Icons.search_rounded),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: scheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _estado({
    required IconData icono,
    required String titulo,
    required String texto,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icono, size: 48, color: scheme.primary),
          ),
          const SizedBox(height: 20),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _tarjeta(BuildContext context, Map usuario) {
    final scheme = Theme.of(context).colorScheme;
    final String nombre = usuario['nombre'];
    final color = _colorPara(nombre);

    // DELETE: deslizar a la derecha (Tutorial IV)
    return Dismissible(
      key: Key(usuario['uid']),
      direction: DismissDirection.startToEnd,
      background: Container(
        decoration: BoxDecoration(
          color: scheme.error,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Eliminar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        final bool? result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            icon: Icon(Icons.warning_amber_rounded, color: scheme.error),
            title: const Text('¿Eliminar usuario?'),
            content: Text(
              'Se eliminará a $nombre de forma permanente.',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  minimumSize: const Size(0, 44),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        );
        return result ?? false;
      },
      onDismissed: (direction) async {
        final String uid = usuario['uid'];
        setState(() => _eliminados.add(uid));
        try {
          await deleteUsuario(uid);
          _mensaje('$nombre eliminado');
        } catch (e) {
          setState(() => _eliminados.remove(uid));
          _mensaje('No se pudo eliminar: $e');
        }
      },
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          // UPDATE: tocar para editar (Tutorial III)
          onTap: () async {
            final guardado =
                await Navigator.pushNamed(context, '/edit', arguments: {
              'uid': usuario['uid'],
              'nombre': usuario['nombre'],
              'eMail': usuario['email'],
              'nCuenta': usuario['nocuenta'],
            });
            if (guardado == true) _mensaje('Cambios guardados');
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE9EBF3)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Text(
                    _iniciales(nombre),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre.isEmpty ? 'Sin nombre' : nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2340),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.mail_outline_rounded,
                              size: 14, color: scheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              usuario['email'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Cuenta ${usuario['nocuenta']}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded,
                    color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
