import '../services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/translation_provider.dart';
import '../config/api_config.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true; 
  bool _obscurePassword = true;
  bool _isLoading = false;
  
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showSnackBar("Vui lòng nhập đầy đủ Username và Password", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      
      if (_isLogin) {
        final success = await authProvider.login(username, password);
        
        if (success && mounted) {
          final userId = authProvider.userId;
          
          if (userId != null) {
            // Lấy session ID động thay vì "user_001"
            String currentSessionId = ApiConfig.sessionId; 

            try {
              await ApiService().mergeHistory(userId, currentSessionId);
            } catch (e) {
              debugPrint("Lỗi gộp lịch sử: $e");
            }

            context.read<TranslationProvider>().clearHistory();
            try {
              await context.read<TranslationProvider>().fetchUserHistory(userId);
            } catch (e) {
              debugPrint("Không thể tải lịch sử sau khi gộp: $e");
            }
          }

          _showSnackBar("Welcome back, $username!");
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          
        } else if (!success) {
          _showSnackBar("Login failed. Please check your credentials!", isError: true);
        }
      } else {
        final success = await authProvider.register(username, password);
        if (success && mounted) {
          _showSnackBar("Welcome! Please login with your new account.");
          setState(() {
            _isLogin = true;
          });
          _passwordController.clear();
        } else {
          _showSnackBar("Registration failed. Username may already exist!", isError: true);
        }
      }
    } catch (e) {
      _showSnackBar("Lỗi kết nối: Server chưa bật hoặc sai đường dẫn ($e)", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 850;

    return Scaffold(
      body: SingleChildScrollView( // Chống lỗi tràn khi hiện bàn phím
        child: Container(
          height: isMobile ? null : MediaQuery.of(context).size.height,
          constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          child: Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            children: [
              // PHẦN LOGO / GIỚI THIỆU
              Expanded(
                flex: isMobile ? 0 : 1,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF29B6F6), Color(0xFFB3E5FC)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "N3Dictionary",
                        style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "More than just\na dictionary.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black87, fontSize: 22, fontFamily: 'Courier'),
                      ),
                    ],
                  ),
                ),
              ),
              // PHẦN FORM ĐĂNG NHẬP
              Expanded(
                flex: isMobile ? 0 : 1,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
                  child: Center(
                    child: ConstrainedBox( // Giới hạn độ rộng Form trên Desktop
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isLogin ? "Login" : "Sign up",
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 40),
                          const Text("Username", style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text("Password", style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF29B6F6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              onPressed: _isLoading ? null : _handleSubmit,
                              child: _isLoading 
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(_isLogin ? "Sign in" : "Create Account", style: const TextStyle(color: Colors.white, fontSize: 18)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: TextButton(
                              onPressed: () => setState(() => _isLogin = !_isLogin),
                              child: Text(_isLogin ? "Don't have an account? Sign up" : "Already have an account? Login"),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}