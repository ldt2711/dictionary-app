import 'package:dictionary_app/models/word_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dictionary_provider.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      // Trigger the search in the provider
      context.read<DictionaryProvider>().searchWord(query);
    }
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
    return Container(
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
              onSubmitted: (_) => _submitSearch(),
              decoration: const InputDecoration(
                hintText: "Search English...",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.blueAccent),
            onPressed: _submitSearch,
          ),
        ],
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
        // Word and Pronunciation
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
              onPressed: () {}, // Future Audio Logic
            ),
          ],
        ),

        const SizedBox(height: 10),
        
        // Parts of Speech Tags
        Wrap(
          spacing: 8,
          children: data.definitions
              .map<String>((d) => d.partOfSpeech)
              .toSet() // Remove duplicates
              .map<Widget>((pos) => Chip(
                    label: Text(pos),
                    backgroundColor: Colors.blue[50],
                    labelStyle: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                  ))
              .toList(),
        ),

        const Divider(height: 40, thickness: 1),

        // Definitions List
        const Text("Definitions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...data.definitions.map((def) => _buildDefinitionItem(def)).toList(),

        // Grammar Tips Section
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