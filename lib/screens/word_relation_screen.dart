import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/word_relation_provider.dart';
import '../widgets/error_state_widget.dart'; // Import widget mới

class WordRelationScreen extends StatefulWidget {
  const WordRelationScreen({super.key});

  @override
  State<WordRelationScreen> createState() => _WordRelationScreenState();
}

class _WordRelationScreenState extends State<WordRelationScreen> {
  final TextEditingController _searchController = TextEditingController();
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
    _hideSearchHistory();
    super.dispose();
  }

  void _submitSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _focusNode.unfocus();
      _hideSearchHistory();
      context.read<WordRelationProvider>().searchWordRelation(query);
    }
  }

  void _showSearchHistory() {
    final provider = context.read<WordRelationProvider>();
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
        width: _layerLink.leaderSize?.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0.0, 60.0),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            child: Consumer<WordRelationProvider>(
              builder: (context, provider, child) {
                if (provider.searchHistory.isEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) => _hideSearchHistory());
                  return const SizedBox.shrink();
                }
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
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
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            children: [
              _buildSearchBar(),
              const SizedBox(height: 30),
              Expanded(
                child: Consumer<WordRelationProvider>(
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

                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        Text("Results for \"${data.word}\"", 
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        
                        // Phần Đồng nghĩa
                        _buildSection("Synonyms", data.synonyms, const Color(0xFFC4C4FF)),
                        const SizedBox(height: 25),
                        
                        // Phần Trái nghĩa
                        _buildSection("Antonyms", data.antonyms, Colors.orangeAccent),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> words, Color color) {
    if (words.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: words.map((s) => _buildChip(s, color)).toList(),
        ),
      ],
    );
  }

  Widget _buildChip(String word, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color),
      ),
      child: Text(word, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildSearchBar() {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onSubmitted: (_) => _submitSearch(),
                decoration: const InputDecoration(
                  hintText: "Enter a word for synonyms...",
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
              icon: const Icon(Icons.search, color: Color(0xFFC85A48)),
              onPressed: _submitSearch,
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "Type a word to find its synonyms",
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }
}