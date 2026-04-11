import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true; // Set to true to show Login screen first
  bool _obscurePassword = true;
  
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                  colors: [Color(0xFF29B6F6), Color(0xFFB3E5FC)], // Light blue gradient
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "N3Dictionary", // Used N3Dictionary as per your new mockup
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 50),
                  const Text(
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
                      // Header Text
                      Text(
                        _isLogin ? "Login to N3Dictionary" : "Sign up for N3Dictionary",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 35),
                      
                      // Username Field
                      const Text("User name", style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Password Field
                      const Text("Password", style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 35),

                      // Action Button (Sign in / Sign up)
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF29B6F6), 
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            // TODO: Add your Flask API authentication logic here
                            debugPrint("Username: ${_usernameController.text}");
                            debugPrint("Password: ${_passwordController.text}");
                            debugPrint("Mode: ${_isLogin ? 'Login' : 'Sign Up'}");
                          },
                          child: Text(
                            _isLogin ? "Sign in" : "Sign up", // Toggle button text
                            style: const TextStyle(
                              fontSize: 18, 
                              color: Colors.white, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Toggle between Login and Sign Up
                      Center(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              _isLogin ? "Don't have an account? " : "Already have an account? ",
                              style: const TextStyle(color: Colors.black87, fontSize: 14),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(
                                _isLogin ? "Sign up" : "Sign in", // Toggle link text
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