import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class BranchPerformancePage extends StatelessWidget {
  const BranchPerformancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> branches = [
      {
        'name': 'فرع الرياض - الرئيسي',
        'sales': 85000.0,
        'customers': 420,
        'growth': '+15%',
      },
      {
        'name': 'فرع جدة - شارع فلسطين',
        'sales': 62000.0,
        'customers': 310,
        'growth': '+8%',
      },
      {
        'name': 'فرع الدمام - الكورنيش',
        'sales': 45000.0,
        'customers': 215,
        'growth': '-2%',
      },
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('مقارنة أداء الفروع')),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: branches.length,
          itemBuilder: (context, index) {
            final b = branches[index];
            final isPositive = b['growth'].startsWith('+');

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          b['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (isPositive
                                        ? AppColors.secondary
                                        : AppColors.danger)
                                    .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            b['growth'],
                            style: TextStyle(
                              color: isPositive
                                  ? AppColors.secondary
                                  : AppColors.danger,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _metric(
                          Icons.monetization_on_outlined,
                          'المبيعات',
                          '${b['sales']} ر.س',
                        ),
                        const SizedBox(width: 32),
                        _metric(
                          Icons.people_outline,
                          'العملاء',
                          '${b['customers']}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: b['sales'] / 100000.0,
                      backgroundColor: Colors.grey.shade100,
                      color: AppColors.primary,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
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

  Widget _metric(IconData icon, String label, String val) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(val, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }
}
