import 'package:flutter/material.dart';

// Importaciones de Firebase (Tutorial I, paso 14)
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Paginas
import 'package:crudfirebase/pages/home_page.dart';
import 'package:crudfirebase/pages/add_usuario_page.dart';
import 'package:crudfirebase/pages/edit_usuario_page.dart';

// Tutorial I, paso 15: inicializar Firebase antes de runApp
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF5B5BD6),
      surface: const Color(0xFFF6F7FB),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CRUD Firebase',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.surface,
          foregroundColor: const Color(0xFF1F2340),
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      // Sistema de rutas (Tutorial II parte 3 y Tutorial III paso 2)
      initialRoute: '/',
      routes: {
        '/': (context) => const Home(),
        '/add': (context) => const AddUsuario(),
        '/edit': (context) => const EditUsuario(),
      },
    );
  }
}
