import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ActivityLogPage extends StatelessWidget {
  const ActivityLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('سجل النشاطات')),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 10,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.history, color: AppColors.primary),
              title: const Text('تم تعديل بيانات منتج "آيفون 15"'),
              subtitle: const Text('بواسطة أحمد - منذ 10 دقائق'),
              trailing: const Icon(Icons.info_outline, size: 16),
              onTap: () {},
            );
          },
        ),
      ),
    );
  }
}
