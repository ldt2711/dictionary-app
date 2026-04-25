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

  double _getResponsiveFontSize(String text, bool isMobile) {
    double baseSize = isMobile ? 18 : 24; // Giảm size chữ một chút trên mobile
    if (text.length > 100) return baseSize;
    if (text.length > 50) return baseSize + 6;
    return baseSize + 10;
  }

  // Helper để viết hoa chữ cái đầu (vietnamese -> Vietnamese)
  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final translationData = context.watch<TranslationProvider>();
    final userId = context.read<AuthProvider>().userId;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Kiểm tra nếu màn hình hẹp hơn 800px thì coi là Mobile
        bool isMobile = constraints.maxWidth < 800;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000), // Rộng tối đa 1000px
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15)],
              ),
              child: Stack(
                alignment: isMobile ? Alignment.center : Alignment.center,
                children: [
                  Flex(
                    direction: isMobile ? Axis.vertical : Axis.horizontal,
                    children: [
                      // LEFT/TOP PANE: SOURCE
                      Expanded(
                        flex: isMobile ? 0 : 1,
                        child: Container(
                          height: isMobile ? 250 : 350,
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: isMobile 
                                ? const BorderRadius.vertical(top: Radius.circular(24))
                                : const BorderRadius.horizontal(left: Radius.circular(24)),
                          ),
                          child: _buildInputPane(
                            isMobile: isMobile,
                            label: "From:",
                            lang: translationData.sourceLanguage,
                            controller: widget.inputController,
                            onChanged: (val) {
                              if (_debounce?.isActive ?? false) _debounce!.cancel();
                              _debounce = Timer(const Duration(milliseconds: 700), () {
                                if (val.isNotEmpty) {
                                  translationData.handleTranslation(val, userId: userId);
                                }
                              });
                            },
                            onSubmitted: (val) async {
                              await translationData.handleTranslation(val, userId: userId);
                            },
                            onCopy: () => _copyToClipboard(context, widget.inputController.text),
                            onAudio: () => widget.onPlayAudio(translationData.currentSourceAudio),
                          ),
                        ),
                      ),

                      if (!isMobile) VerticalDivider(width: 1, thickness: 1, color: Colors.grey[200]),
                      if (isMobile) Divider(height: 1, thickness: 1, color: Colors.grey[200]),

                      // RIGHT/BOTTOM PANE: RESULT
                      Expanded(
                        flex: isMobile ? 0 : 1,
                        child: Container(
                          height: isMobile ? 250 : 350,
                          child: _buildResultPane(
                            isMobile: isMobile,
                            label: "To:",
                            lang: translationData.targetLanguage,
                            result: translationData.resultText,
                            isLoading: translationData.isLoading,
                            onCopy: () => _copyToClipboard(context, translationData.resultText),
                            onAudio: () => widget.onPlayAudio(translationData.currentTargetAudio),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Nút đổi chiều ngôn ngữ (Positioned giữa hai pane)
                  Positioned(
                    top: isMobile ? 225 : null, // Căn giữa đường gạch chia trên mobile
                    child: _swapButton(
                      isMobile: isMobile,
                      onTap: () {
                        translationData.swapLanguages(widget.inputController);
                        if (widget.inputController.text.isNotEmpty) {
                          translationData.handleTranslation(widget.inputController.text, userId: userId);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputPane({
    required bool isMobile,
    required String label,
    required String lang,
    required TextEditingController controller,
    required Function(String) onChanged,
    required Function(String) onSubmitted,
    required VoidCallback onCopy,
    required VoidCallback onAudio,
  }) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 20.0 : 30.0),
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
                fontSize: _getResponsiveFontSize(controller.text, isMobile),
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
    );
  }

  Widget _buildResultPane({
    required bool isMobile,
    required String label,
    required String lang,
    required String result,
    required bool isLoading,
    required VoidCallback onCopy,
    required VoidCallback onAudio,
  }) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 20.0 : 30.0),
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
                      fontSize: _getResponsiveFontSize(result, isMobile),
                      fontWeight: FontWeight.w400,
                      color: Colors.blueGrey[800]
                    ),
                  ),
                ),
          ),
          _actionIcons(onCopy, onAudio),
        ],
      ),
    );
  }

  Widget _langHeader(String label, String currentLang, {required bool isSource}) {
    final translationData = context.read<TranslationProvider>();
    final supportedLangs = translationData.supportedLanguages;
    List<String> keys = supportedLangs.keys.toList();

    return Row(
      mainAxisSize: MainAxisSize.min,
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
                  child: Text(_capitalize(key)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  if (isSource) {
                    translationData.setSourceLanguage(newValue);
                  } else {
                    translationData.setTargetLanguage(newValue);
                  }
                  if (widget.inputController.text.isNotEmpty) {
                    translationData.handleTranslation(widget.inputController.text, userId: context.read<AuthProvider>().userId);
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

  Widget _swapButton({required bool isMobile, required VoidCallback onTap}) {
    return HoverBuilder(
      builder: (isHovered) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isHovered ? Colors.blue : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(color: isHovered ? Colors.blue.withOpacity(0.3) : Colors.black12, blurRadius: 8)
            ],
          ),
          child: Icon(
            isMobile ? Icons.swap_vert_rounded : Icons.swap_horiz_rounded,
            color: isHovered ? Colors.white : Colors.blue,
            size: 22
          ),
        ),
      ),
    );
  }
}