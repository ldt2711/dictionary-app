import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/translation_card.dart';
import '../providers/translation_provider.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  bool _isHistoryOpen = false;
  // --- THÊM: Khai báo controller tại đây để dùng chung ---
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80, bottom: 50, left: 40, right: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(
                      Icons.access_time, 
                      color: _isHistoryOpen ? Colors.blue : Colors.black54,
                      size: 28,
                    ),
                    onPressed: () => setState(() => _isHistoryOpen = !_isHistoryOpen),
                  ),
                ),
                const SizedBox(height: 20),
                // --- TRUYỀN CONTROLLER VÀO CARD ---
                TranslationCard(inputController: _inputController),
              ],
            ),
          ),

          if (_isHistoryOpen)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 350,
              margin: const EdgeInsets.only(left: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: _buildHistoryPanel(context),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Nhật ký", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _isHistoryOpen = false),
              )
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Consumer<TranslationProvider>(
            builder: (context, provider, child) {
              if (provider.history.isEmpty) {
                return const Center(child: Text("Chưa có lịch sử dịch", style: TextStyle(color: Colors.grey)));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(15),
                itemCount: provider.history.length,
                separatorBuilder: (context, index) => const Divider(height: 30),
                itemBuilder: (context, index) {
                  final item = provider.history[index];
                  // --- THÊM GESTURE DETECTOR ĐỂ BẮT SỰ KIỆN CLICK ---
                  return InkWell(
                    onTap: () {
                      // Gọi hàm load từ Provider và truyền controller vào
                      provider.loadHistoryItem(item, _inputController);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${item.fromLang} → ${item.toLang}", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        const SizedBox(height: 5),
                        Text(item.origin, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text(item.translated, style: const TextStyle(fontSize: 16, color: Colors.blueAccent)),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}