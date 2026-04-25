import 'dart:async'; 
import 'package:flutter/material.dart';
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
    final authProvider = context.watch<AuthProvider>();
    final isLoggedIn = authProvider.isLoggedIn;
    final username = authProvider.username ?? "";
    
    // Sử dụng LayoutBuilder để kiểm tra độ rộng màn hình thực tế
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 700;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 40, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.black12, width: 1)),
          ),
          child: Row(
            children: [
              // Logo
              GestureDetector(
                onTap: () => onTabSelected('home'),
                child: Text(
                  isMobile ? "N3" : "N3Dictionary", // Thu gọn tên logo nếu màn hình quá bé
                  style: const TextStyle(color: Color(0xFFC85A48), fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              
              const Spacer(),
              
              // Menu Items: Trên Mobile chỉ hiện Icon, trên Desktop hiện cả Icon + Text
              _navItem(context, Icons.home_outlined, isMobile ? "" : "Home", "home"),
              _navItem(context, Icons.book_outlined, isMobile ? "" : "Dictionary", "dictionary"),
              _navItem(context, Icons.translate, isMobile ? "" : "Translate", "translate"),
              _navItem(context, Icons.waves_rounded, isMobile ? "" : "Word Relation", "wordrelation"),
              
              const Spacer(),

              // Auth Section
              isLoggedIn 
                ? Row(
                    children: [
                      if (!isMobile) // Chỉ hiện "Hi, user" trên màn hình rộng
                        Text("Hi, $username", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC85A48))),
                      const SizedBox(width: 10),
                      const ProfileAvatarMenu(),
                    ],
                  )
                : ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF29B6F6),
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("Sign in", style: TextStyle(color: Colors.white)),
                  ),
            ],
          ),
        );
      }
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