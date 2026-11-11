import 'package:cloud_firestore/cloud_firestore.dart';

// Variable db de tipo FirebaseFirestore
FirebaseFirestore db = FirebaseFirestore.instance;

// READ: trae los documentos de la coleccion "usuarios" (incluye el uid)
Future<List> getUsuarios() async {
  List usuarios = [];
  CollectionReference collectionReferenceUsuarios = db.collection('usuarios');
  QuerySnapshot queryUsuarios = await collectionReferenceUsuarios.get();

  for (var documento in queryUsuarios.docs) {
    final Map<String, dynamic> data = documento.data() as Map<String, dynamic>;
    final usuario = {
      'uid': documento.id,
      'nombre': data['nombre'] ?? '',
      'email': data['email'] ?? '',
      'nocuenta': data['nocuenta'] ?? '',
    };
    usuarios.add(usuario);
  }
  return usuarios;
}

// READ en tiempo real: emite la lista cada vez que cambia la coleccion
Stream<List> streamUsuarios() {
  return db.collection('usuarios').snapshots().map((query) {
    return query.docs.map((documento) {
      final data = documento.data();
      return {
        'uid': documento.id,
        'nombre': data['nombre'] ?? '',
        'email': data['email'] ?? '',
        'nocuenta': data['nocuenta'] ?? '',
      };
    }).toList();
  });
}

// CREATE: guarda un nuevo usuario
Future<void> agregarUsuario(String nNombre, String nEmail, String nCuenta) async {
  await db.collection('usuarios').add({
    'nombre': nNombre,
    'email': nEmail,
    'nocuenta': nCuenta,
  });
}

// UPDATE: actualiza un usuario por su uid
Future<void> editUsuario(String uid, String eNombre, String eMail, String eCuenta) async {
  await db.collection('usuarios').doc(uid).set({
    'nombre': eNombre,
    'email': eMail,
    'nocuenta': eCuenta,
  });
}

// DELETE: elimina un usuario por su uid
Future<void> deleteUsuario(String uid) async {
  await db.collection('usuarios').doc(uid).delete();
}
