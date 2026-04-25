import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/navbar.dart';
import '../widgets/dictionary_display.dart'; 
import '../providers/dictionary_provider.dart';
import 'translate_screen.dart'; 
import 'dictionary_screen.dart'; 
import 'word_relation_screen.dart'; // <-- IMPORT ADDED HERE

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentNavTab = 'home';
  final TextEditingController _homeSearchController = TextEditingController();

@override
  void initState() {
    super.initState();
    // --- ADD THIS BLOCK ---
    // This triggers as soon as the Home Screen is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DictionaryProvider>().fetchWordOfTheDay();
    });
  }

  @override
  void dispose() {
    _homeSearchController.dispose();
    super.dispose();
  }

  void _performSearch(String word) {
    if (word.trim().isNotEmpty) {
      context.read<DictionaryProvider>().searchWord(word.trim());
      setState(() {
        _currentNavTab = 'dictionary';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Navbar(
            currentTab: _currentNavTab,
            onTabSelected: (selectedTab) {
              setState(() {
                _currentNavTab = selectedTab;
              });
            },
          ),
          Expanded(
            child: _currentNavTab == 'home' 
              ? _buildHomeContent() 
              : _currentNavTab == 'dictionary'
                ? const DictionaryScreen()
              : _currentNavTab == 'translate'
                ? const TranslateScreen()
              : _currentNavTab == 'wordrelation' // <-- ROUTING LOGIC ADDED HERE
                ? const WordRelationScreen()
                : Center(child: Text("$_currentNavTab page coming soon!")),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 700;

        return Container(
          width: double.infinity,
          // Mobile thì không cần margin hai bên, Desktop thì để 10
          margin: EdgeInsets.only(
            left: isMobile ? 0 : 10, 
            right: isMobile ? 0 : 10, 
            top: isMobile ? 0 : 10
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2962FF),
                Color(0xFF7A9CFF),
                Color(0xFFD6E0FF),
              ],
              stops: [0.0, 0.55, 1.0],
            ),
            // Mobile thì không cần bo góc phía trên
            borderRadius: isMobile 
              ? BorderRadius.zero 
              : const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 24, 
                vertical: isMobile ? 40 : 32
              ),
              child: Column(
                children: [
                  SizedBox(height: isMobile ? 40 : 80),
                  Text(
                    "The World in Every Word",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      // Chữ nhỏ hơn trên Mobile
                      fontSize: isMobile ? 32 : 42,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                          blurRadius: 12,
                          color: Colors.black26,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isMobile ? 30 : 50),
                  
                  // --- SEARCH BAR---
                  Container(
                    // Dùng ConstrainedBox để giới hạn chiều rộng tối đa thay vì fix cứng 700
                    constraints: const BoxConstraints(maxWidth: 700),
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 20, right: 10),
                          child: Icon(Icons.search, color: Colors.grey),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _homeSearchController,
                            onSubmitted: (value) => _performSearch(value),
                            decoration: const InputDecoration(
                              hintText: "Search English",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        // Ẩn bớt nút Search text trên mobile nếu màn hình quá hẹp, chỉ để icon
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () => _performSearch(_homeSearchController.text),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5B85FF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 15 : 30, 
                                vertical: 15
                              ),
                            ),
                            child: isMobile 
                              ? const Icon(Icons.arrow_forward) 
                              : const Text("Search", style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // --- POPULAR SEARCHES (ĐÃ FIX TRÀN HÀNG) ---
                  Wrap( // Dùng Wrap thay vì Row để tự xuống dòng nếu màn hình hẹp
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10, // Khoảng cách ngang
                    runSpacing: 10, // Khoảng cách dọc khi xuống dòng
                    children: [
                      const Text(
                        "Popular search",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      _searchTag("Grieving"),
                      _searchTag("Night"),
                      _searchTag("Special"),
                    ],
                  ),

                  const SizedBox(height: 60),
                  
                  // Word of the Day Card
                  Consumer<DictionaryProvider>(
                    builder: (context, dictProvider, child) {
                      if (dictProvider.wordOfTheDay == null) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white)
                        );
                      }
                      return Container(
                        // Giới hạn độ rộng card để không bị quá to trên màn hình lớn
                        constraints: const BoxConstraints(maxWidth: 850),
                        child: DictionaryDisplayWidget(
                          data: dictProvider.wordOfTheDay,
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _searchTag(String text) {
    return InkWell( // Thay GestureDetector bằng InkWell để có hiệu ứng nhấn
      onTap: () {
        setState(() {
          _homeSearchController.text = text;
        });
        _performSearch(text); // Tự động search khi bấm vào tag
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}