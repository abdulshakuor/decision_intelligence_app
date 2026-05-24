import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CashierPerformancePage extends StatelessWidget {
  const CashierPerformancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> cashiers = [
      {
        'name': 'محمد العتيبي',
        'sales': 12400.0,
        'orders': 45,
        'avg': 275.5,
        'rating': 4.8,
      },
      {
        'name': 'سعد الشهري',
        'sales': 9800.0,
        'orders': 38,
        'avg': 257.9,
        'rating': 4.5,
      },
      {
        'name': 'خالد العنزي',
        'sales': 15600.0,
        'orders': 52,
        'avg': 300.0,
        'rating': 4.9,
      },
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('أداء الموظفين')),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: cashiers.length,
          itemBuilder: (context, index) {
            final c = cashiers[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Icon(Icons.person, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 14,
                                ),
                                Text(
                                  ' ${c['rating']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${c['sales']} ر.س',
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _stat('الطلبات', '${c['orders']}'),
                        _stat('متوسط الفاتورة', '${c['avg']} ر.س'),
                        _stat('نسبة الإنجاز', '95%'),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}
