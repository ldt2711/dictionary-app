import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:provider/provider.dart';
import 'hover_builder.dart';
import '../providers/translation_provider.dart';
import '../providers/auth_provider.dart'; 

class TranslationCard extends StatefulWidget {
  final TextEditingController inputController;
  final Function(String) onPlayAudio;
  
  const TranslationCard({
    super.key, 
    required this.inputController, 
    required this.onPlayAudio,
  });

  @override
  State<TranslationCard> createState() => _TranslationCardState();
}

class _TranslationCardState extends State<TranslationCard> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _copyToClipboard(BuildContext context, String text) {
    if (text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Copied to clipboard!"),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          width: 250,
        ),
      );
    }
  }

  double _getResponsiveFontSize(String text) {
    if (text.length > 100) return 20;
    if (text.length > 50) return 26;
    return 34;
  }

  // Helper để viết hoa chữ cái đầu (vietnamese -> Vietnamese)
  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final translationData = context.watch<TranslationProvider>();

    return Container(
      width: 1000,
      height: 350, // Tăng nhẹ chiều cao để dropdown thoải mái hơn
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15)],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Nền xám bên trái
          Positioned(
            left: 0, top: 0, bottom: 0, width: 500, 
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50], 
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
              ),
            ),
          ),

          Row(
            children: [
              // LEFT PANE: SOURCE
              _buildInputPane(
                label: "From:",
                lang: translationData.sourceLanguage, 
                controller: widget.inputController,
                onChanged: (val) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 700), () {
                    if (val.isNotEmpty) {
                      final userId = context.read<AuthProvider>().userId;
                      translationData.handleTranslation(val, userId: userId);
                    }
                  });
                },
                onSubmitted: (val) async {
                  final userId = context.read<AuthProvider>().userId;
                  await translationData.handleTranslation(val, userId: userId);
                },
                onCopy: () => _copyToClipboard(context, widget.inputController.text),
                onAudio: () => widget.onPlayAudio(translationData.currentSourceAudio),
              ),
              
              VerticalDivider(width: 1, thickness: 1, color: Colors.grey[200]),
              
              // RIGHT PANE: RESULT
              _buildResultPane(
                label: "To:",
                lang: translationData.targetLanguage, 
                result: translationData.resultText,
                isLoading: translationData.isLoading,
                onCopy: () => _copyToClipboard(context, translationData.resultText),
                onAudio: () => widget.onPlayAudio(translationData.currentTargetAudio),
              ),
            ],
          ),
          
          // Nút đổi chiều ngôn ngữ
          _swapButton(onTap: () {
            translationData.swapLanguages(widget.inputController);
            // Sau khi swap, nếu có chữ thì dịch lại luôn
            if (widget.inputController.text.isNotEmpty) {
               translationData.handleTranslation(widget.inputController.text, 
                  userId: context.read<AuthProvider>().userId);
            }
          }),
        ],
      ),
    );
  }

  Widget _buildInputPane({
    required String label,
    required String lang,
    required TextEditingController controller,
    required Function(String) onChanged,
    required Function(String) onSubmitted,
    required VoidCallback onCopy, 
    required VoidCallback onAudio, 
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _langHeader(label, lang, isSource: true),
            const SizedBox(height: 15),
            Expanded( 
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(controller.text), 
                  fontWeight: FontWeight.w400,
                  color: Colors.black87
                ),
                decoration: const InputDecoration(
                  hintText: "Enter text...",
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent, 
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            _actionIcons(onCopy, onAudio), 
          ],
        ),
      ),
    );
  }

  Widget _buildResultPane({
    required String label,
    required String lang,
    required String result,
    required bool isLoading,
    required VoidCallback onCopy, 
    required VoidCallback onAudio, 
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _langHeader(label, lang, isSource: false),
            const SizedBox(height: 15),
            Expanded(
              child: isLoading 
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2)) 
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        result, 
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(result), 
                          fontWeight: FontWeight.w400,
                          color: Colors.blueGrey[800]
                        ),
                      ),
                    ),
            ),
            _actionIcons(onCopy, onAudio), 
          ],
        ),
      ),
    );
  }

  // --- DROPDOWN CHỌN NGÔN NGỮ ĐỘNG ---
  Widget _langHeader(String label, String currentLang, {required bool isSource}) {
    final translationData = context.read<TranslationProvider>();
    final supportedLangs = translationData.supportedLanguages;

    // Lấy danh sách key (tên tiếng Anh) từ API
    List<String> keys = supportedLangs.keys.toList();

    return Row(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        if (keys.isEmpty)
          const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
        else
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: keys.contains(currentLang) ? currentLang : keys.first,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Colors.blue),
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              items: keys.map((String key) {
                return DropdownMenuItem<String>(
                  value: key,
                  child: Text(_capitalize(key)), // Hiển thị: Vietnamese
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  if (isSource) {
                    translationData.setSourceLanguage(newValue);
                  } else {
                    translationData.setTargetLanguage(newValue);
                  }
                  // Tự động dịch lại khi đổi ngôn ngữ
                  if (widget.inputController.text.isNotEmpty) {
                     translationData.handleTranslation(widget.inputController.text, 
                        userId: context.read<AuthProvider>().userId);
                  }
                }
              },
            ),
          ),
      ],
    );
  }

  Widget _actionIcons(VoidCallback onCopy, VoidCallback onAudio) {
    return Row(
      children: [
        _actionIcon(Icons.copy_rounded, onTap: onCopy), 
        const SizedBox(width: 20),
        _actionIcon(Icons.volume_up_rounded, onTap: onAudio),
      ],
    );
  }

  Widget _actionIcon(IconData icon, {VoidCallback? onTap}) {
    return HoverBuilder(
      builder: (isHovered) => GestureDetector(
        onTap: onTap,
        child: Icon(
          icon,
          color: isHovered ? Colors.blue : Colors.grey[400],
          size: 20,
        ),
      ),
    );
  }

  Widget _swapButton({required VoidCallback onTap}) {
    return HoverBuilder(
      builder: (isHovered) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isHovered ? Colors.blue : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(color: isHovered ? Colors.blue.withOpacity(0.3) : Colors.black12, blurRadius: 8)
            ],
          ),
          child: Icon(
            Icons.swap_horiz_rounded, 
            color: isHovered ? Colors.white : Colors.blue, 
            size: 22
          ),
        ),
      ),
    );
  }
}