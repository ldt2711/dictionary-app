import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- Screens ---
import 'screens/home_screens.dart';

// --- Providers ---
import 'providers/translation_provider.dart';
import 'providers/dictionary_provider.dart';
import 'providers/thesaurus_provider.dart';

void main() {
  // Ensures that Flutter's engine is ready before we start loading 
  // assets or initialized providers. Crucial for apps using local JSON/Assets.
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TranslationProvider()),
        ChangeNotifierProvider(create: (_) => DictionaryProvider()),
        ChangeNotifierProvider(create: (_) => ThesaurusProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'N3Dictionary',
      debugShowCheckedModeBanner: false,
      
      // Professional Theme Setup
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.light,
        ),
        
        // Setting a global text theme makes your Dictionary & Translation 
        // screens look consistent across the whole group project.
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        
        // Makes all your search bars and input fields look uniform
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      
      home: const HomeScreen(), 
    );
  }
}