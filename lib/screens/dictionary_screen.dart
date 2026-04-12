import 'package:dictionary_app/models/word_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/dictionary_provider.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer(); // 2. Create the player instance
  // Các biến quản lý Focus và Overlay cho popup lịch sử
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    // Lắng nghe sự kiện click/focus vào thanh search
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showSearchHistory();
      } else {
        // --- GIẢI PHÁP SỬA LỖI: THÊM DELAY ---
        // Thêm một khoảng trễ nhỏ (150ms) để sự kiện onTap kịp kích hoạt 
        // trước khi Overlay bị gỡ bỏ khỏi cây Widget
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted && !_focusNode.hasFocus) {
            _hideSearchHistory();
          }
        });
      }
    });
  }

 @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    _audioPlayer.dispose(); // 3. Dispose the player to free up resources
    _hideSearchHistory();
    super.dispose();
  }

  // 4. Create the play logic function
  Future<void> _playPronunciation(String url) async {
    if (url.isNotEmpty) {
      try {
        await _audioPlayer.play(UrlSource(url));
      } catch (e) {
        debugPrint("Error playing audio: $e");
      }
    } else {
      // Optional: Show a message if no audio exists
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pronunciation audio not available"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _submitSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _focusNode.unfocus(); // Ẩn keyboard
      _hideSearchHistory(); // Đóng popup lịch sử
      context.read<DictionaryProvider>().searchWord(query);
    }
  }

  // --- Logic hiển thị Overlay (Popup lịch sử) ---
  void _showSearchHistory() {
    final provider = context.read<DictionaryProvider>();
    if (provider.searchHistory.isEmpty) return;

    if (_overlayEntry != null) return;

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideSearchHistory() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: _layerLink.leaderSize?.width ?? MediaQuery.of(context).size.width - 50,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0.0, 65.0), // Khoảng cách đẩy popup xuống dưới thanh search
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
            child: Consumer<DictionaryProvider>(
              builder: (context, provider, child) {
                if (provider.searchHistory.isEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) => _hideSearchHistory());
                  return const SizedBox.shrink();
                }
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shrinkWrap: true,
                    itemCount: provider.searchHistory.length,
                    itemBuilder: (context, index) {
                      final word = provider.searchHistory[index];
                      return ListTile(
                        leading: const Icon(Icons.history, color: Colors.black54),
                        title: Text(word, style: const TextStyle(fontSize: 16)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.black54),
                          onPressed: () => provider.removeFromHistory(word),
                        ),
                        onTap: () {
                          // --- CHỨC NĂNG TỰ ĐỘNG TÌM KIẾM ---
                          // 1. Gán từ vào thanh search
                          _searchController.text = word;
                          // 2. Đẩy con trỏ nhấp nháy về cuối chữ
                          _searchController.selection = TextSelection.fromPosition(
                            TextPosition(offset: word.length),
                          );
                          // 3. Thực hiện tìm kiếm
                          _submitSearch();
                          // 4. Buộc ẩn popup ngay lập tức sau khi chọn
                          _hideSearchHistory();
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Search Bar ---
              _buildSearchBar(),

              const SizedBox(height: 30),

              // --- 2. Result Area ---
              Expanded(
                child: Consumer<DictionaryProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    // 1. Check for Error Message first
                    if (provider.errorMessage != null) {
                      return _buildErrorState(provider.errorMessage!);
                    }

                    final data = provider.result;
                    if (data == null) {
                      return _buildEmptyState();
                    }

                    return _buildDictionaryResult(data);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget: The Rounded Search Bar
  Widget _buildSearchBar() {
    // Bọc thanh search bằng CompositedTransformTarget để làm điểm neo cho Overlay
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            const SizedBox(width: 15),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode, 
                onSubmitted: (_) => _submitSearch(),
                decoration: const InputDecoration(
                  hintText: "Search English...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (value) {
                  // Mở lại popup nếu người dùng gõ text và có lịch sử
                  if (_focusNode.hasFocus && _overlayEntry == null) {
                    _showSearchHistory();
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.blueAccent),
              onPressed: _submitSearch,
            ),
          ],
        ),
      ),
    );
  }

  // Widget: What to show when no word is searched
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 10),
          const Text(
            "Search for a word to see its definition",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Widget: The Actual Content (Word, Definitions, Tips)
  Widget _buildDictionaryResult(DictionaryResult data) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.word,
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                Text(
                  data.pronunciation,
                  style: const TextStyle(fontSize: 18, color: Colors.blueAccent, fontStyle: FontStyle.italic),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.volume_up, color: Colors.blueAccent, size: 30),
              onPressed: () => _playPronunciation(data.audio),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: data.definitions
              .map<String>((d) => d.partOfSpeech)
              .toSet() 
              .map<Widget>((pos) => Chip(
                    label: Text(pos),
                    backgroundColor: Colors.blue[50],
                    labelStyle: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                  ))
              .toList(),
        ),
        const Divider(height: 40, thickness: 1),
        const Text("Definitions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...data.definitions.map((def) => _buildDefinitionItem(def)).toList(),
        if (data.grammarTips.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text("Grammar Tips", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.grammarTips.map<Widget>((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text("• $tip", style: const TextStyle(fontSize: 15)),
              )).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDefinitionItem(Definition def) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            def.meaning,
            style: const TextStyle(fontSize: 17, height: 1.4),
          ),
          if (def.example.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 10),
              child: Text(
                "\"${def.example}\"",
                style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }
  
  // --- ADD THIS NEW WIDGET METHOD AT THE BOTTOM OF THE CLASS ---
  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sentiment_dissatisfied, size: 80, color: Colors.orangeAccent),
          const SizedBox(height: 15),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          const Text(
            "Check your spelling or try a different word.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}