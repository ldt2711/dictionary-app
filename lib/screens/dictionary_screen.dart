import 'package:dictionary_app/config/api_config.dart';
import 'package:dictionary_app/models/word_model.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/dictionary_provider.dart';
import '../widgets/error_state_widget.dart'; // Import widget mới

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showSearchHistory();
      } else {
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
    _audioPlayer.dispose();
    _hideSearchHistory();
    super.dispose();
  }

  Future<void> _playPronunciation(String url) async {
    if (url.isEmpty) return;

    try {
      await _audioPlayer.stop();

      // Kiểm tra nguồn API
      bool isOurApi = url.contains("ngrok-free.dev") || url.startsWith("/");

      if (isOurApi) {
        // Tạo URL chuẩn
        Uri parsedUri = Uri.parse(url);
        String text = parsedUri.queryParameters['text'] ?? '';
        String lang = parsedUri.queryParameters['lang'] ?? 'en';
        String safeUrl = "${ApiConfig.baseUrl}/tts?text=$text&lang=$lang";

        // Tải audio bytes
        final response = await http.get(Uri.parse(safeUrl), headers: {"ngrok-skip-browser-warning": "true"});

        if (response.statusCode == 200) {
          if (kIsWeb) {
            // WEB: Dùng Base64
            String base64Audio = base64Encode(response.bodyBytes);
            await _audioPlayer.play(UrlSource("data:audio/mpeg;base64,$base64Audio"));
          } else {
            // WINDOWS / ANDROID: Lưu ra file tạm rồi phát
            final tempDir = await getTemporaryDirectory();
            final file = File('${tempDir.path}/temp_pronounce.mp3');
            await file.writeAsBytes(response.bodyBytes);
            await _audioPlayer.play(DeviceFileSource(file.path));
          }
        }
      } else {
        // URL từ điển bên ngoài (Google API...) - phát trực tiếp
        await _audioPlayer.play(UrlSource(url));
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _submitSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _focusNode.unfocus(); 
      _hideSearchHistory(); 
      context.read<DictionaryProvider>().searchWord(query);
    }
  }

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
          offset: const Offset(0.0, 65.0), 
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
                          _searchController.text = word;
                          _searchController.selection = TextSelection.fromPosition(
                            TextPosition(offset: word.length),
                          );
                          _submitSearch();
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
              _buildSearchBar(),
              const SizedBox(height: 30),
              Expanded(
                child: Consumer<DictionaryProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (provider.errorMessage != null) {
                      // Sử dụng Widget dùng chung
                      return ErrorStateWidget(message: provider.errorMessage!);
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

  Widget _buildSearchBar() {
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
}