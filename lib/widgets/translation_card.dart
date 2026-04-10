import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:provider/provider.dart';
import 'hover_builder.dart';
import '../providers/translation_provider.dart';
import '../providers/dictionary_provider.dart';
import '../providers/thesaurus_provider.dart'; 

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
    if (text.length > 100) return 22;
    if (text.length > 50) return 28;
    return 38;
  }

  @override
  Widget build(BuildContext context) {
    final translationData = context.watch<TranslationProvider>();

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
                onChanged: (val) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 600), () {
                    if (val.isNotEmpty) {
                      translationData.handleTranslation(val);
                    }
                  });
                },
                onSubmitted: (val) async {
                  await translationData.handleTranslation(val);
                },
                onCopy: () => _copyToClipboard(context, widget.inputController.text),
                onAudio: () => widget.onPlayAudio(translationData.currentSourceAudio),
              ),
              
              VerticalDivider(width: 1, thickness: 1, color: Colors.grey[300]),
              
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
    required Function(String) onChanged,
    required Function(String) onSubmitted,
    required VoidCallback onCopy, 
    required VoidCallback onAudio, 
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _langHeader(label, lang),
            const SizedBox(height: 10),
            Expanded( 
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(controller.text), 
                  fontWeight: FontWeight.w400
                ),
                decoration: const InputDecoration(
                  hintText: "Nhập văn bản...",
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent, 
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(height: 10),
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
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _langHeader(label, lang),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading 
                  ? const Center(child: CircularProgressIndicator()) 
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        result, 
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(result), 
                          fontWeight: FontWeight.w400
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 10),
            // The Row now only contains the action icons
            _actionIcons(onCopy, onAudio), 
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

  Widget _actionIcons(VoidCallback onCopy, VoidCallback onAudio) {
    return Row(
      children: [
        _actionIcon(Icons.copy, onTap: onCopy), 
        const SizedBox(width: 15),
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