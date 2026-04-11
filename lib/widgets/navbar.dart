import 'dart:async'; 
import 'package:flutter/material.dart';
import 'dart:html' as html; 
import 'hover_builder.dart'; 
import '../screens/auth_screen.dart'; // IMPORT YOUR NEW AUTH SCREEN HERE

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
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.black12, width: 1)),
      ),
      child: Row(
        children: [
          // Logo - Reloads the page
          GestureDetector(
            onTap: () => html.window.location.reload(),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: const Text(
                "N3Dictionary",
                style: TextStyle(
                  color: Color(0xFFC85A48), 
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const Spacer(),
          
          // Menu Items
          _navItem(Icons.home_outlined, "Home", "home"),
          _navItem(Icons.book_outlined, "Dictionary", "dictionary"),
          _navItem(Icons.translate, "Translate", "translate"),
          _navItem(Icons.waves_rounded, "Thesaurus", "thesaurus"),
          
          const Spacer(),
          
          // Language
          const Row(
            children: [
              Icon(Icons.language, size: 20),
              SizedBox(width: 8),
              Text("English(US)", style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(width: 30),
          
          // --- Fixed Hoverable Profile Section ---
          const ProfileAvatarMenu(),
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
          Color contentColor = isSelected ? const Color(0xFFC85A48) : (isHovered ? Colors.blue : Colors.black87);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Icon(icon, size: 20, color: contentColor),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(color: contentColor, fontSize: 15, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- UPDATED SUB-WIDGET WITH TIMER & CLICK FIX ---
class ProfileAvatarMenu extends StatefulWidget {
  const ProfileAvatarMenu({super.key});

  @override
  State<ProfileAvatarMenu> createState() => _ProfileAvatarMenuState();
}

class _ProfileAvatarMenuState extends State<ProfileAvatarMenu> {
  final OverlayPortalController _tooltipController = OverlayPortalController();
  Timer? _hideTimer;

  void _showMenu() {
    _hideTimer?.cancel(); 
    if (!_tooltipController.isShowing) {
      _tooltipController.show();
    }
  }

  void _hideMenu() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 200), () {
      _tooltipController.hide();
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _showMenu(),
      onExit: (_) => _hideMenu(),
      child: OverlayPortal(
        controller: _tooltipController,
        overlayChildBuilder: (context) {
          return Positioned(
            top: 60, // Sits right below the navbar
            right: 40,
            child: MouseRegion(
              onEnter: (_) => _showMenu(), // Keeps it open when hovering the menu itself
              onExit: (_) => _hideMenu(),
              child: _buildSignOutButton(context), // Pass context here for navigation
            ),
          );
        },
        child: Stack(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey,
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
      ),
    );
  }

  // We add BuildContext here so we can use the Navigator
  Widget _buildSignOutButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          debugPrint("Sign Out Clicked!");
          _tooltipController.hide();
          
          // Navigate to the AuthScreen and replace the current screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AuthScreen()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout, size: 18, color: Colors.black87),
              SizedBox(width: 10), // Removed the const keyword here due to parent const constraints
              Text(
                "Sign out", 
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14)
              ),
            ],
          ),
        ),
      ),
    );
  }
}