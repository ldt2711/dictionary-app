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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<ThesaurusProvider>().searchThesaurus(query);
    }
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
              // --- Search Section ---
              _buildSearchBar(),
              
              const SizedBox(height: 30),

              // --- Results Section ---
              Expanded(
                child: Consumer<ThesaurusProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

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

  Widget _buildSearchBar() {
    return Container(
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
              onSubmitted: (_) => _submitSearch(),
              decoration: const InputDecoration(
                hintText: "Enter a word for synonyms...",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFFC85A48)),
            onPressed: _submitSearch,
          ),
          const SizedBox(width: 10),
        ],
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

  // This is the core "Synonyms-only" display
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
        
        // Wrap handles the chip layout automatically
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: data.synonyms.map((s) => _buildSynonymChip(s)).toList(),
        ),
      ],
    );
  }

  Widget _buildSynonymChip(String word) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFC4C4FF).withOpacity(0.4), // Soft blue
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