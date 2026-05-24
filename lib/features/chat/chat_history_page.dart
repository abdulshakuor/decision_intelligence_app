import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ChatHistoryPage extends StatelessWidget {
  const ChatHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> chats = [
      {
        'title': 'تحليل مبيعات شهر يناير',
        'date': '2024-02-01',
        'preview': 'بناءً على البيانات، لوحظ ارتفاع في مبيعات قسم...',
      },
      {
        'title': 'استفسار عن المخزون الحرج',
        'date': '2024-02-05',
        'preview': 'المنتجات التي وصلت للحد الأدنى هي...',
      },
      {
        'title': 'توقعات الأسبوع القادم',
        'date': '2024-02-12',
        'preview': 'يتوقع زيادة في الطلب بنسبة 15% على...',
      },
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('سجل المحادثات الذكية')),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final c = chats[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.info.withOpacity(0.1),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: AppColors.info,
                  ),
                ),
                title: Text(
                  c['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  c['preview'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  c['date'],
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                onTap: () {},
              ),
            );
          },
        ),
      ),
    );
  }
}
