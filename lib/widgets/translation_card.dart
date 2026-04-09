import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:provider/provider.dart';
import 'hover_builder.dart';
import '../providers/translation_provider.dart';
import '../providers/dictionary_provider.dart';
import '../providers/thesaurus_provider.dart'; 

class TranslationCard extends StatefulWidget {
  final TextEditingController inputController;
  // 1. CHỈNH SỬA: Nhận thêm callback để chơi audio từ màn hình cha
  final Function(String) onPlayAudio;
  
  const TranslationCard({
    super.key, 
    required this.inputController, 
    required this.onPlayAudio, // Thêm vào constructor
  });

  @override
  State<TranslationCard> createState() => _TranslationCardState();
}

class _TranslationCardState extends State<TranslationCard> {

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

  @override
  Widget build(BuildContext context) {
    // Sử dụng context.watch để lắng nghe thay đổi từ Provider
    final translationData = context.watch<TranslationProvider>();
    final dictProvider = context.read<DictionaryProvider>();
    final thesaurusProvider = context.read<ThesaurusProvider>(); 

    return Container(
      width: 1000,
      height: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 500, 
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100], 
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
                onSubmitted: (val) async {
                  await translationData.handleTranslation(val);
                },
                onCopy: () => _copyToClipboard(context, widget.inputController.text),
                // 2. CHỈNH SỬA: Lấy audio link cho phía nguồn
                onAudio: () => widget.onPlayAudio(translationData.currentSourceAudio),
                hasMic: true,
              ),
              
              VerticalDivider(width: 1, thickness: 1, color: Colors.grey[300]),
              
              // RIGHT PANE: RESULT
              _buildResultPane(
                label: "To:",
                lang: translationData.targetLanguage, 
                result: translationData.resultText,
                isLoading: translationData.isLoading,
                onCopy: () => _copyToClipboard(context, translationData.resultText),
                // 3. CHỈNH SỬA: Lấy audio link cho phía dịch
                onAudio: () => widget.onPlayAudio(translationData.currentTargetAudio),
                onSeeMore: () {
                  final result = translationData.resultText;
                  dictProvider.searchWord(result);
                  thesaurusProvider.searchThesaurus(result);
                },
              ),
            ],
          ),
          
          _swapButton(onTap: () {
            translationData.swapLanguages(widget.inputController);
          }),
        ],
      ),
    );
  }

  Widget _buildInputPane({
    required String label,
    required String lang,
    required TextEditingController controller,
    required Function(String) onSubmitted,
    required VoidCallback onCopy, 
    required VoidCallback onAudio, // Thêm handler audio
    bool hasMic = false,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _langHeader(label, lang),
            const SizedBox(height: 30),
            TextField(
              controller: controller,
              onSubmitted: onSubmitted,
              style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w400),
              decoration: const InputDecoration(
                hintText: "Nhập văn bản...",
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent, 
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const Spacer(),
            _actionIcons(hasMic, onCopy, onAudio), 
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
    required VoidCallback onAudio, // Thêm handler audio
    required VoidCallback onSeeMore,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _langHeader(label, lang),
            const SizedBox(height: 30),
            isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : SingleChildScrollView(
                    child: Text(result, style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w400)),
                  ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _actionIcons(false, onCopy, onAudio), 
                if (result.isNotEmpty && !result.startsWith("Error:")) 
                  TextButton(
                    onPressed: onSeeMore,
                    child: const Text(
                      "See Details",
                      style: TextStyle(color: Color(0xFFB04B3A), fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _langHeader(String label, String lang) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Color.fromARGB(255, 52, 6, 6))),
        const SizedBox(width: 8),
        Text(lang, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  // 4. CHỈNH SỬA: Thêm onAudio vào helper icons
  Widget _actionIcons(bool hasMic, VoidCallback onCopy, VoidCallback onAudio) {
    return Row(
      children: [
        if (hasMic) _actionIcon(Icons.mic_none),
        if (hasMic) const SizedBox(width: 15),
        _actionIcon(Icons.copy, onTap: onCopy), 
        const SizedBox(width: 15),
        // Nút loa bây giờ đã có logic onTap
        _actionIcon(Icons.volume_up_outlined, onTap: onAudio),
      ],
    );
  }

  Widget _actionIcon(IconData icon, {VoidCallback? onTap}) {
    return HoverBuilder(
      builder: (isHovered) => GestureDetector(
        onTap: onTap,
        child: Icon(
          icon,
          color: isHovered ? Colors.blue : const Color.fromARGB(255, 39, 12, 12),
          size: 22,
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isHovered ? Colors.blue[700] : Colors.black,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.swap_horiz, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}