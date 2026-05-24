import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class InventoryLogPage extends StatelessWidget {
  const InventoryLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> logs = [
      {
        'product': 'آيفون 15 برومكس',
        'action': 'إضافة مخزون',
        'qty': '+10',
        'user': 'أحمد',
        'time': '10:30 ص',
      },
      {
        'product': 'ساعة آبل S9',
        'action': 'مبيعات',
        'qty': '-2',
        'user': 'النظام',
        'time': '11:15 ص',
      },
      {
        'product': 'سماعات AirPods',
        'action': 'تعديل يدوي',
        'qty': '-1',
        'user': 'خالد',
        'time': '01:00 م',
      },
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('سجل حركات المخزون')),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final l = logs[index];
            final isPlus = l['qty'].startsWith('+');

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (isPlus ? AppColors.secondary : AppColors.danger)
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPlus ? Icons.add : Icons.remove,
                      color: isPlus ? AppColors.secondary : AppColors.danger,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l['product'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${l['action']} بواسطة ${l['user']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l['qty'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isPlus
                              ? AppColors.secondary
                              : AppColors.danger,
                        ),
                      ),
                      Text(
                        l['time'],
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
