import '../services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/translation_provider.dart';

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
        // --- 1. LOGIC ĐĂNG NHẬP ---
        final success = await authProvider.login(username, password);
        
        if (success && mounted) {
          final userId = authProvider.userId;
          
          if (userId != null) {
            // LƯU Ý QUAN TRỌNG: Thay "user_001" bằng session_id thực tế 
            // mà bạn đang dùng khi khách vãng lai dịch từ. 
            // Ví dụ: context.read<TranslationProvider>().sessionId
            String currentSessionId = "user_001"; 

            // LUÔN GỌI GỘP LỊCH SỬ CHO MỌI LẦN ĐĂNG NHẬP
            try {
              await ApiService().mergeHistory(userId, currentSessionId);
            } catch (e) {
              debugPrint("Lỗi gộp lịch sử: $e");
            }

            // Xóa lịch sử cũ trên UI và tải lại lịch sử mới nhất từ DB
            context.read<TranslationProvider>().clearHistory();
            try {
              await context.read<TranslationProvider>().fetchUserHistory(userId);
            } catch (e) {
              debugPrint("Không thể tải lịch sử sau khi gộp: $e");
            }
          }

          _showSnackBar("Welcome back, $username!");
          // VỀ TRANG CHỦ MẶC ĐỊNH
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          
        } else if (!success) {
          _showSnackBar("Login failed. Please check your credentials!", isError: true);
        }
      } else {
        // --- 2. LOGIC ĐĂNG KÝ ---
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
      _showSnackBar("Lỗi kết nối: Server Flask chưa bật hoặc sai đường dẫn ($e)", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // LEFT PANE: Branding & Gradient
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF29B6F6), Color(0xFFB3E5FC)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "N3Dictionary",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 50),
                  Text(
                    "More than just\na dictionary.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 26,
                      fontFamily: 'Courier', 
                    ),
                  ),
                ],
              ),
            ),
          ),

          // RIGHT PANE: Auth Form
          Expanded(
            child: Container(
              color: Colors.white,
              child: Center(
                child: Container(
                  width: 450,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade400, width: 1),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isLogin ? "Login to N3Dictionary" : "Sign up for N3Dictionary",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 35),
                      
                      const Text("User name", style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _usernameController,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 25),

                      const Text("Password", style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Colors.grey,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 35),

                      // Nút hành động
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF29B6F6), 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            elevation: 0,
                          ),
                          onPressed: _isLoading ? null : _handleSubmit,
                          child: _isLoading 
                            ? const SizedBox(
                                height: 20, 
                                width: 20, 
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              )
                            : Text(
                                _isLogin ? "Sign in" : "Sign up",
                                style: const TextStyle(
                                  fontSize: 18, 
                                  color: Colors.white, 
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Chuyển đổi form
                      Center(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              _isLogin ? "Don't have an account? " : "Already have an account? ",
                              style: const TextStyle(color: Colors.black87, fontSize: 14),
                            ),
                            InkWell(
                              onTap: _isLoading ? null : () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                  _usernameController.clear();
                                  _passwordController.clear();
                                });
                              },
                              child: Text(
                                _isLogin ? "Sign up" : "Sign in",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}