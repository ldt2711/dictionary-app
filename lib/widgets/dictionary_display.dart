import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/word_model.dart';

class DictionaryDisplayWidget extends StatefulWidget {
  final DictionaryResult? data;

  const DictionaryDisplayWidget({super.key, this.data});

  @override
  State<DictionaryDisplayWidget> createState() =>
      _DictionaryDisplayWidgetState();
}

class _DictionaryDisplayWidgetState extends State<DictionaryDisplayWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String url) async {
    if (url.isNotEmpty) {
      try {
        await _audioPlayer.play(UrlSource(url));
      } catch (e) {
        debugPrint("Audio error: $e");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No audio available for this word")),
      );
    }
  }

  // Hàm cho phần Word
  Widget _buildWordSection(String word, String pronunciation, String audioUrl, bool isNarrow) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Đảm bảo chỉ chiếm diện tích tối thiểu
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          word,
          style: TextStyle(
            fontSize: isNarrow ? 28 : 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2962FF),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.volume_up_outlined, color: Color(0xFF6B52FF), size: 22),
              onPressed: () => _playAudio(audioUrl),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(width: 8),
            Text(pronunciation, style: const TextStyle(fontSize: 16)),
          ],
        ),
        if (isNarrow) const SizedBox(height: 30),
      ],
    );
  }

  // Hàm cho phần Definition
  Widget _buildDefinitionSection(List<String> definitions) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Definition", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        ...definitions.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${entry.key + 1}. ", style: const TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text(entry.value, style: const TextStyle(height: 1.5))),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data == null) {
      return const SizedBox.shrink();
    }

    final String word = widget.data!.word;
    final String pronunciation = widget.data!.pronunciation;
    final String audioUrl = widget.data!.audio;
    final List<String> definitions = widget.data!.definitions
        .map((d) => d.meaning)
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Xác định nếu màn hình nhỏ (ví dụ nhỏ hơn 600px)
        bool isNarrow = constraints.maxWidth < 600;

        return Container(
          // Thay vì fix cứng width 800, ta dùng constraints maxWidth
          constraints: const BoxConstraints(maxWidth: 800),
          width: double.infinity,
          padding: EdgeInsets.all(
            isNarrow ? 20 : 40,
          ), // Giảm padding trên mobile
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Word of the day",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),

              // Sử dụng Flex để thay đổi hướng linh hoạt
              Flex(
                direction: isNarrow ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // THÊM DÒNG NÀY: Để Flex không cố chiếm hết chiều cao vô tận
                children: [
                  // PHẦN 1: Từ vựng
                  isNarrow 
                    ? _buildWordSection(word, pronunciation, audioUrl, isNarrow)
                    : Expanded(
                        flex: 1,
                        child: _buildWordSection(word, pronunciation, audioUrl, isNarrow),
                      ),

                  // PHẦN 2: Định nghĩa
                  // Nếu là Mobile, KHÔNG dùng Expanded. Nếu là Desktop, BẮT BUỘC dùng Expanded.
                  isNarrow 
                    ? _buildDefinitionSection(definitions) // Không bọc Expanded
                    : Expanded(
                        flex: 2,
                        child: _buildDefinitionSection(definitions),
                      ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
