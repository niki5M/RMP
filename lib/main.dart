import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:testik2/init_dependencies.dart';
import 'package:testik2/core/theme/theme.dart';
import 'package:testik2/screens/adjust_screen.dart';
import 'package:testik2/screens/blur_screen.dart';
import 'package:testik2/screens/crop_screen.dart';
import 'package:testik2/screens/edit_screen.dart';
import 'package:testik2/screens/filter_screen.dart';
import 'package:testik2/screens/fit_screen.dart';
import 'package:testik2/home/presentation/home_page.dart';
import 'package:testik2/providers/image_provider.dart';
import 'package:testik2/screens/sticker_screen.dart';
import 'package:testik2/screens/text_screen.dart';
import 'package:testik2/screens/tint_screen.dart';

import 'auth/presentation/bloc/auth_bloc.dart';
import 'auth/presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(
    MultiProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<AuthBloc>()),
        ChangeNotifierProvider(create: (_) => AppImageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black54),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/edit': (context) => const EditScreen(),
        '/crop': (context) => const CropScreen(),
        '/adjust': (context) => const AdjustScreen(),
        '/blur': (context) => const BlurScreen(),
        '/filter': (context) => const FilterScreen(),
        '/fit': (context) => const FitScreen(),
        '/sticker': (context) => const StickerScreen(),
        '/text': (context) => const TextScreen(),
        '/tint': (context) => const TintScreen(),
      },
    );
  }
}



