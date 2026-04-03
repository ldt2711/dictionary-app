import 'package:flutter/material.dart';
import 'hover_builder.dart'; 

class Navbar extends StatelessWidget {
  final String currentTab;
  final Function(String) onTabSelected;

  const Navbar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          // Logo
          const Text(
            "N3Dictionary",
            style: TextStyle(
              color: Color(0xFFC85A48), // Adjusted to match the brownish-red
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          
          // Menu Items
          _navItem(Icons.home_outlined, "Home", "home"),
          _navItem(Icons.book_outlined, "Dictionary", "dictionary"),
          _navItem(Icons.translate, "Translate", "translate"),
          _navItem(Icons.layers_outlined, "Thesaurus", "thesaurus"),
          
          const Spacer(),
          
          // Language & Profile
          const Row(
            children: [
              Icon(Icons.language, size: 20),
              SizedBox(width: 8),
              Text("English(US)", style: TextStyle(fontWeight: FontWeight.w500)),
              Icon(Icons.keyboard_arrow_down, size: 20),
            ],
          ),
          const SizedBox(width: 30),
          
          // Profile Avatar with green dot
          Stack(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey,
                // Using a generic image placeholder for the cat avatar
                backgroundImage: NetworkImage('https://i.pinimg.com/736x/8f/c2/f7/8fc2f71661cb5561a7a2e2f3bb1f5c61.jpg'), 
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent[700],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, String tabId) {
    bool isSelected = currentTab == tabId;
    
    return GestureDetector(
      onTap: () => onTabSelected(tabId),
      child: HoverBuilder(
        builder: (isHovered) {
          Color contentColor = isSelected 
              ? const Color(0xFFC85A48) 
              : (isHovered ? Colors.blue : Colors.black87);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Icon(icon, size: 20, color: contentColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: contentColor,
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}