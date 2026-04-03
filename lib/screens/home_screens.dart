import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/navbar.dart';
import '../widgets/dictionary_display.dart';
import '../providers/dictionary_provider.dart';
import 'translate_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentNavTab = 'home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top Navbar
          Navbar(
            currentTab: _currentNavTab,
            onTabSelected: (selectedTab) {
              setState(() {
                _currentNavTab = selectedTab;
              });
            },
          ),
          
          // Main Body
          Expanded(
            child: _currentNavTab == 'home' 
              ? _buildHomeContent() 
              : _currentNavTab == 'translate'
                ? const TranslateScreen()
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
            Color(0xFF2962FF), // Deep blue top
            Color(0xFF7A9CFF), // Mid blue
            Color(0xFFD6E0FF), // Light blue bottom
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
            // Hero Title
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
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search English",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {},
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
            
            const SizedBox(height: 60),
            
            // Word of the Day Card
            Consumer<DictionaryProvider>(
              builder: (context, dictProvider, child) {
                // If you don't have data loaded yet, you might want to show a default/mocked "Lucullan" card here
                // to exactly match the Figma until a search happens.
                if (dictProvider.result == null && !dictProvider.isLoading) {
                  return const DictionaryDisplayWidget(data: null); // Pass null to show default design
                }
                
                if (dictProvider.isLoading) {
                  return const CircularProgressIndicator(color: Colors.white);
                }
                
                return DictionaryDisplayWidget(data: dictProvider.result);
              },
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _searchTag(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2), // Transparent white
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
    );
  }
}