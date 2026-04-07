import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/navbar.dart';
import '../widgets/dictionary_display.dart'; 
import '../providers/dictionary_provider.dart';
import 'translate_screen.dart'; 
import 'dictionary_screen.dart'; 
import 'thesaurus_screen.dart'; // <-- IMPORT ADDED HERE

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentNavTab = 'home';
  final TextEditingController _homeSearchController = TextEditingController();

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
              : _currentNavTab == 'thesaurus' // <-- ROUTING LOGIC ADDED HERE
                ? const ThesaurusScreen()
                : Center(child: Text("$_currentNavTab page coming soon!")),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2962FF),
            Color(0xFF7A9CFF),
            Color(0xFFD6E0FF),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 80),
            const Text(
              "The World in Every Word",
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 50),
            
            // Search Bar
            Container(
              width: 700,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
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
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                      child: const Text("Search", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            
            // Popular Searches
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Popular search",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(width: 15),
                _searchTag("Grieving"),
                _searchTag("Night"),
                _searchTag("Special"),
              ],
            ),

            // Word of the Day Card
            const SizedBox(height: 60),
            
            Consumer<DictionaryProvider>(
              builder: (context, dictProvider, child) {
                return Center(
                  child: DictionaryDisplayWidget(
                    data: dictProvider.result, 
                  ),
                );
              },
            ),
            
            const SizedBox(height: 80), // Padding for the bottom
          ],
        ),
      ),
    );
  }

  Widget _searchTag(String text) {
    return GestureDetector(
      onTap: () {
        _homeSearchController.text = text;
        _performSearch(text);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }
}