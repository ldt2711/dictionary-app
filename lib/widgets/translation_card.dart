import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 1. Required for Clipboard
import 'package:provider/provider.dart';
import 'hover_builder.dart';
import '../providers/translation_provider.dart';
import '../providers/dictionary_provider.dart';
import '../providers/thesaurus_provider.dart'; 

class TranslationCard extends StatefulWidget {
  const TranslationCard({super.key});

  @override
  State<TranslationCard> createState() => _TranslationCardState();
}

class _TranslationCardState extends State<TranslationCard> {
  final TextEditingController _inputController = TextEditingController();

  // 2. Helper method to handle copying and feedback
  void _copyToClipboard(BuildContext context, String text) {
    if (text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Copied to clipboard!"),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          width: 250,
        ),
      );
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final translationData = Provider.of<TranslationProvider>(context);
    final dictProvider = Provider.of<DictionaryProvider>(context);
    final thesaurusProvider = Provider.of<ThesaurusProvider>(context); 

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
          Row(
            children: [
              // LEFT PANE (From)
              _buildInputPane(
                label: "From:",
                lang: "Tiếng Việt",
                controller: _inputController,
                onSubmitted: (val) async {
                  await translationData.handleTranslation(val);
                  if (mounted) {
                    final result = translationData.resultText;
                    context.read<DictionaryProvider>().searchWord(result);
                  }
                },
                // Pass the copy logic for input text
                onCopy: () => _copyToClipboard(context, _inputController.text),
                hasMic: true,
              ),
              
              VerticalDivider(width: 1, thickness: 1, color: Colors.grey[300]),
              
              // RIGHT PANE (To)
              _buildResultPane(
                label: "To:",
                lang: "English",
                result: translationData.resultText,
                isLoading: translationData.isLoading,
                // Pass the copy logic for result text
                onCopy: () => _copyToClipboard(context, translationData.resultText),
                onSeeMore: () {
                  final result = translationData.resultText;
                  dictProvider.searchWord(result);
                  thesaurusProvider.searchThesaurus(result);
                },
              ),
            ],
          ),
          
          _swapButton(),
        ],
      ),
    );
  }

  // --- HELPER METHODS ---

  Widget _buildInputPane({
    required String label,
    required String lang,
    required TextEditingController controller,
    required Function(String) onSubmitted,
    required VoidCallback onCopy, // Added
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
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const Spacer(),
            _actionIcons(hasMic, onCopy), // Pass callback
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
    required VoidCallback onCopy, // Added
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
                : Text(result, style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w400)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _actionIcons(false, onCopy), // Pass callback
                if (result.isNotEmpty && result != "Hello") 
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
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(width: 8),
        Text(lang, style: const TextStyle(fontWeight: FontWeight.bold)),
        const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
      ],
    );
  }

  Widget _actionIcons(bool hasMic, VoidCallback onCopy) {
    return Row(
      children: [
        if (hasMic) _actionIcon(Icons.mic_none),
        if (hasMic) const SizedBox(width: 15),
        _actionIcon(Icons.copy, onTap: onCopy), // Triggers copy
        const SizedBox(width: 15),
        _actionIcon(Icons.volume_up_outlined),
      ],
    );
  }

  Widget _actionIcon(IconData icon, {VoidCallback? onTap}) {
    return HoverBuilder(
      builder: (isHovered) => GestureDetector(
        onTap: onTap,
        child: Icon(
          icon,
          color: isHovered ? Colors.blue : Colors.grey[600],
          size: 22,
        ),
      ),
    );
  }

  Widget _swapButton() {
    return HoverBuilder(
      builder: (isHovered) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isHovered ? Colors.blue[700] : Colors.black,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.swap_horiz, color: Colors.white, size: 20),
      ),
    );
  }
}