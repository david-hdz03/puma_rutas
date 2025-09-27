import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'database_helper.dart';
import 'dart:io' show Platform;
import 'route_detail_screen.dart';

Future<void> main() async {
  // Initialize FFI for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rutas Pumabus',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF65727A), // .color5
          brightness: Brightness.light,
          surface: const Color(0xFFD7DACF), // .color2
          onSurface: const Color(0xFF65727A), // .color5
          primary: const Color(0xFF65727A), // .color5
          onPrimary: const Color(0xFFE6E8E3), // .color1
          secondary: const Color(0xFF8F9A9C), // .color4
          onSecondary: const Color(0xFFE6E8E3), // .color1
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF65727A), // .color5
          foregroundColor: Color(0xFFE6E8E3), // .color1
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Color(0xFF65727A)),
          bodyMedium: TextStyle(color: Color(0xFF65727A)),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const RouteListScreen(),
    );
  }
}

class RouteListScreen extends StatefulWidget {
  const RouteListScreen({super.key});

  @override
  State<RouteListScreen> createState() => _RouteListScreenState();
}

class _RouteListScreenState extends State<RouteListScreen> {
  late Future<List<Map<String, dynamic>>> _bases;

  @override
  void initState() {
    super.initState();
    _bases = DatabaseHelper.instance.getBases();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutas Pumabus'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _bases,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay bases de datos disponibles.'));
          } else {
            final bases = snapshot.data!;
            return ListView.builder(
              itemCount: bases.length,
              itemBuilder: (context, index) {
                final base = bases[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      color: const Color(0xFFBEC3BC), // .color3
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        base['name'],
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: DatabaseHelper.instance.getRoutesForBase(base['id'] as int),
                      builder: (context, routeSnapshot) {
                        if (routeSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (routeSnapshot.hasError) {
                          return Center(child: Text('Error: ${routeSnapshot.error}'));
                        } else if (!routeSnapshot.hasData || routeSnapshot.data!.isEmpty) {
                          return const Center(child: Text('No hay rutas disponibles.'));
                        } else {
                          final routes = routeSnapshot.data!;
                          return Column(
                            children: routes.map((route) {
                              final routeId = route['id'] as int;
                              final routeName = route['name'] as String;
                              final routeColor = Color(route['color'] as int);
                              return Container(
                                color: const Color(0xFFD7DACF), // .color2
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RouteDetailScreen(
                                          routeId: routeId,
                                          routeName: routeName,
                                          routeColor: routeColor,
                                        ),
                                      ),
                                    );
                                  },
                                  leading: CircleAvatar(
                                      backgroundColor: routeColor,
                                      child: Text(
                                        routeName,
                                        style: TextStyle(
                                          color: routeColor.computeLuminance() > 0.5
                                              ? Colors.black
                                              : Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  title: Text(
                                    'Ruta $routeName',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }
                      },
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
