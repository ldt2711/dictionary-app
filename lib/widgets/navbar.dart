import 'dart:async'; 
import 'package:flutter/material.dart';
import 'dart:html' as html; 
import 'package:provider/provider.dart'; 
import 'hover_builder.dart'; 
import '../providers/auth_provider.dart'; 
import '../providers/translation_provider.dart';

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
    // 1. Kiểm tra trạng thái đăng nhập từ AuthProvider
    final authProvider = context.watch<AuthProvider>();
    final isLoggedIn = authProvider.isLoggedIn;
    final username = authProvider.username ?? "";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.black12, width: 1)),
      ),
      child: Row(
        children: [
          // Logo - Bấm vào load lại trang web
          GestureDetector(
            onTap: () => html.window.location.reload(),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: const Text(
                "N3Dictionary",
                style: TextStyle(
                  color: Color(0xFFC85A48), 
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          
          const Spacer(),
          
          // Menu Items (Logic xóa kết quả dịch khi chuyển tab)
          _navItem(context, Icons.home_outlined, "Home", "home"),
          _navItem(context, Icons.book_outlined, "Dictionary", "dictionary"),
          _navItem(context, Icons.translate, "Translate", "translate"),
          _navItem(context, Icons.waves_rounded, "Thesaurus", "thesaurus"),
          
          const Spacer(),

          // Auth Section: Hiển thị Lời chào + Avatar hoặc nút Sign in
          isLoggedIn 
            ? Row(
                children: [
                  Text(
                    "Hi, $username", 
                    style: const TextStyle(
                      fontSize: 15, 
                      fontWeight: FontWeight.bold, 
                      color: Color(0xFFC85A48)
                    ),
                  ),
                  const SizedBox(width: 15),
                  const ProfileAvatarMenu(), // Avatar UI
                ],
              )
            : ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF29B6F6),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text(
                  "Sign in", 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)
                ),
              ),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, String tabId) {
    bool isSelected = currentTab == tabId;
    return GestureDetector(
      onTap: () {
        // --- LOGIC QUAN TRỌNG: Xóa kết quả dịch cũ khi đổi tab ---
        context.read<TranslationProvider>().resetCurrentTranslation();
        onTabSelected(tabId);
      },
      child: HoverBuilder(
        builder: (isHovered) {
          Color contentColor = isSelected ? const Color(0xFFC85A48) : (isHovered ? Colors.blue : Colors.black87);
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
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal
                  )
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- PROFILE AVATAR: Thiết kế Viền mỏng + Icon mặc định ---
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
    if (!_tooltipController.isShowing) _tooltipController.show();
  }

  void _hideMenu() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 200), () => _tooltipController.hide());
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
            top: 65, 
            right: 40,
            child: MouseRegion(
              onEnter: (_) => _showMenu(),
              onExit: (_) => _hideMenu(),
              child: _buildSignOutButton(context), 
            ),
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Viền mỏng và Icon mặc định (Giống Figma)
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black54, // Viền xám mỏng
                  width: 1.0, 
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: Color(0xFF374151), // Màu xám đậm cho icon
                ),
              ),
            ),
            // 2. Chấm xanh Online có viền trắng
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E), // Màu xanh lá chuẩn
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.0), 
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _tooltipController.hide();
          // Xóa lịch sử hiển thị và đăng xuất
          context.read<TranslationProvider>().clearHistory();
          context.read<AuthProvider>().logout();
          // Đưa về trang chủ dưới danh nghĩa khách
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 8))
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout_rounded, size: 18, color: Colors.black87),
              SizedBox(width: 12),  
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