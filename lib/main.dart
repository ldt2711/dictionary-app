import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- Screens ---
import 'screens/home_screens.dart';
import 'screens/auth_screen.dart'; 

// --- Providers ---
import 'providers/translation_provider.dart';
import 'providers/dictionary_provider.dart';
import 'providers/thesaurus_provider.dart';
import 'providers/auth_provider.dart'; 

void main() async {
  // 1. Đảm bảo các dịch vụ của Flutter đã sẵn sàng
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Khởi tạo TranslationProvider trước để tải danh sách ngôn ngữ từ API
  final translationProvider = TranslationProvider();
  
  // Tải danh sách 100+ ngôn ngữ từ Flask Server ngay khi mở App
  // Việc này giúp Dropdown không bị trống khi người dùng mở tab Translate
  await translationProvider.loadLanguagesFromServer();

  runApp(
    MultiProvider(
      providers: [
        // Khởi tạo Auth
        ChangeNotifierProvider(create: (_) => AuthProvider()), 
        
        // Sử dụng .value vì chúng ta đã khởi tạo và load data cho translationProvider ở trên
        ChangeNotifierProvider.value(value: translationProvider),
        
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
      
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      
      // Trang chủ (/) giờ là HomeScreen (Chế độ Guest)
      initialRoute: '/', 
      routes: {
        '/': (context) => const HomeScreen(),      
        '/login': (context) => const AuthScreen(), 
      },
    );
  }
}