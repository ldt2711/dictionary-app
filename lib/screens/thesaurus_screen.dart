import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/thesaurus_provider.dart';
import '../models/thesaurus_model.dart';

class ThesaurusScreen extends StatefulWidget {
  const ThesaurusScreen({super.key});

  @override
  State<ThesaurusScreen> createState() => _ThesaurusScreenState();
}

class _ThesaurusScreenState extends State<ThesaurusScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Các biến quản lý Focus và Overlay cho popup lịch sử
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
        // Delay 150ms để xử lý sự kiện click trước khi ẩn popup
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
      context.read<ThesaurusProvider>().searchThesaurus(query);
    }
  }

  // --- LOGIC OVERLAY ---
  void _showSearchHistory() {
    final provider = context.read<ThesaurusProvider>();
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
            child: Consumer<ThesaurusProvider>(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 30),
              Expanded(
                child: Consumer<ThesaurusProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // 1. Priority: Show error state if the word wasn't found (404)
                    if (provider.errorMessage != null) {
                      return _buildErrorState(provider.errorMessage!);
                    }

                    // 2. Show result if data exists
                    final data = provider.result;
                    if (data == null) {
                      return _buildEmptyState();
                    }

                    return _buildSynonymList(data);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget: Search Bar logic
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

  // Widget: Default state before searching
  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "Type a word to find its synonyms",
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }

  // Widget: Error state (Orange Sad Face) - Matches DictionaryScreen for consistency
  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.sentiment_dissatisfied, 
            size: 80, 
            color: Colors.orangeAccent
          ),
          const SizedBox(height: 15),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.w500, 
              color: Colors.black87
            ),
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

  // Widget: Displaying synonyms in a Wrap collection
  Widget _buildSynonymList(ThesaurusResult data) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          "Synonyms for \"${data.word}\"",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        
        // Final fallback if result came back but synonyms list is empty
        if (data.synonyms.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              "No synonyms found for this word.",
              style: TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: data.synonyms.map((s) => _buildSynonymChip(s)).toList(),
          ),
      ],
    );
  }

  // Widget: Individual Synonym Chip
  Widget _buildSynonymChip(String word) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFC4C4FF).withOpacity(0.4),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFC4C4FF)),
      ),
      child: Text(
        word,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}