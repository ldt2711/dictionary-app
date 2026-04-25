import 'package:dictionary_app/config/api_config.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../widgets/translation_card.dart';
import '../providers/translation_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  bool _isHistoryOpen = false;
  // --- THÊM: Khai báo controller tại đây để dùng chung ---
  final TextEditingController _inputController = TextEditingController();

  // 2. Initialize the AudioPlayer here
  final AudioPlayer _audioPlayer = AudioPlayer();
  @override
  void initState() {
    super.initState();
    // Một số trình duyệt cần "đánh thức" audio context
  } 

  @override
  void dispose() {
    _inputController.dispose();
    _audioPlayer.dispose(); // 3. Clean up the player
    super.dispose();
  }

  // 4. Helper function to play the TTS stream
  void _playTts(String path) async {
    if (path.isEmpty) return;

    try {
      // 1. Dừng player hiện tại
      await _audioPlayer.stop();
      await _audioPlayer.release(); // Giải phóng tài nguyên để thả file cũ ra

      Uri parsedUri = Uri.parse(path);
      String text = parsedUri.queryParameters['text'] ?? '';
      String lang = parsedUri.queryParameters['lang'] ?? 'vi';
      String safeUrl = "${ApiConfig.baseUrl}/tts?text=${Uri.encodeComponent(text)}&lang=$lang";

      final response = await http.get(
        Uri.parse(safeUrl), 
        headers: {"ngrok-skip-browser-warning": "true"}
      );

      if (response.statusCode == 200) {
        if (kIsWeb) {
          String base64Audio = base64Encode(response.bodyBytes);
          await _audioPlayer.play(UrlSource("data:audio/mpeg;base64,$base64Audio"));
        } else {
          // 2. TẠO TÊN FILE DUY NHẤT để tránh lỗi "file is being used"
          final tempDir = await getTemporaryDirectory();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final file = File('${tempDir.path}/tts_$timestamp.mp3'); 
          
          await file.writeAsBytes(response.bodyBytes);
          await _audioPlayer.play(DeviceFileSource(file.path));

          // 3. (Tùy chọn) Xóa các file cũ sau khi phát xong để tránh đầy bộ nhớ tạm
          _audioPlayer.onPlayerComplete.listen((_) {
             if (file.existsSync()) {
               file.delete().catchError((e) => debugPrint("Lỗi xóa file: $e"));
             }
          });
        }
      }
    } catch (e) {
      debugPrint("TTS Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Kiểm tra kích thước màn hình
        bool isMobile = constraints.maxWidth < 900;

        return Padding(
          // Padding linh hoạt: Desktop rộng rãi, Mobile gọn gàng
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 15 : 40,
            vertical: isMobile ? 20 : 60,
          ),
          child: isMobile 
            ? _buildMobileLayout() 
            : _buildDesktopLayout(),
        );
      },
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  // --- GIAO DIỆN WEB / TABLET RỘNG ---
Widget _buildDesktopLayout() {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Vùng chính bên trái
      Expanded(
        child: SingleChildScrollView( // THÊM CUỘN Ở ĐÂY ĐỂ TRÁNH TRÀN THEO CHIỀU DỌC
          child: Column(
            children: [
              _buildHistoryToggle(),
              const SizedBox(height: 20),
              // Đảm bảo card không bị bó buộc chiều cao cố định
              TranslationCard(
                inputController: _inputController,
                onPlayAudio: _playTts,
              ),
              const SizedBox(height: 20), // Padding thêm ở cuối để cuộn thoải mái
            ],
          ),
        ),
      ),
      
      // Panel Lịch sử bên phải
      if (_isHistoryOpen)
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 350,
          // Sử dụng BoxConstraints hoặc chiều cao linh hoạt thay vì để nó tự dãn
          height: double.infinity, // Cho phép history cao hết phần diện tích Row
          margin: const EdgeInsets.only(left: 30),
          decoration: _panelDecoration(),
          child: _buildHistoryPanel(context),
        ),
    ],
  );
}

// --- GIAO DIỆN MOBILE ---
Widget _buildMobileLayout() {
  return Stack(
    children: [
      // Chỉnh lại phần Column chính của Mobile để tránh lỗi overflow tương tự
      Column(
        children: [
          _buildHistoryToggle(),
          const SizedBox(height: 10),
          Expanded( // Dùng Expanded bọc SingleChildScrollView là chuẩn nhất
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  TranslationCard(
                    inputController: _inputController,
                    onPlayAudio: _playTts,
                  ),
                  const SizedBox(height: 100), // Khoảng trống an toàn ở cuối
                ],
              ),
            ),
          ),
        ],
      ),

      // Lớp phủ lịch sử trên Mobile
      if (_isHistoryOpen)
        Positioned.fill(
          child: Container(
            color: Colors.black26,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                // Giới hạn chiều cao history trên mobile để không bị đè mất toàn bộ
                height: MediaQuery.of(context).size.height * 0.9, 
                decoration: _panelDecoration(),
                child: _buildHistoryPanel(context),
              ),
            ),
          ),
        ),
    ],
  );
}

  // Widget nút bấm mở lịch sử
  Widget _buildHistoryToggle() {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
        icon: Icon(
          Icons.access_time_rounded,
          color: _isHistoryOpen ? Colors.blue : Colors.black54,
          size: 28,
        ),
        onPressed: () => setState(() => _isHistoryOpen = !_isHistoryOpen),
      ),
    );
  }

  // Style cho khung lịch sử
  BoxDecoration _panelDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 10),
        )
      ],
    );
  }

  Widget _buildHistoryPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("History", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => setState(() => _isHistoryOpen = false),
              )
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Consumer<TranslationProvider>(
            builder: (context, provider, child) {
              if (provider.history.isEmpty) {
                return const Center(
                  child: Text("No search history yet", 
                    style: TextStyle(color: Colors.grey)));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(15),
                itemCount: provider.history.length,
                separatorBuilder: (context, index) => const Divider(height: 25),
                itemBuilder: (context, index) {
                  final item = provider.history[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      provider.loadHistoryItem(item, _inputController);
                      if (MediaQuery.of(context).size.width < 900) {
                        setState(() => _isHistoryOpen = false); // Đóng history sau khi chọn trên mobile
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${_capitalize(item.fromLang)} → ${_capitalize(item.toLang)}", 
                            style: TextStyle(fontSize: 11, color: Colors.blue[700], fontWeight: FontWeight.w600)),
                          const SizedBox(height: 5),
                          Text(item.origin, 
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text(item.translated, 
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 15, color: Colors.black54)),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void deactivate() {
    _inputController.clear();
    super.deactivate();
  }
}