import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('مركز المساعدة')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'كيف يمكننا مساعدتك؟',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن إجابات...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildCategory(Icons.help_outline, 'الأسئلة الشائعة'),
            _buildCategory(Icons.menu_book, 'دليل المستخدم'),
            _buildCategory(Icons.video_library, 'شروحات الفيديو'),
            _buildCategory(Icons.forum, 'تواصل مع الدعم الفني'),
            const SizedBox(height: 32),
            const Text(
              'تذاكر الدعم الحالية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildTicket(
              'مشكلة في استيراد البيانات',
              'قيد التنفيذ',
              '#TKT-2241',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          label: const Text('تذكرة جديدة'),
          icon: const Icon(Icons.add_comment),
          backgroundColor: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildCategory(IconData icon, String title) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_left),
      ),
    );
  }

  Widget _buildTicket(String title, String status, String id) {
    return Card(
      color: AppColors.primary.withOpacity(0.05),
      child: ListTile(
        title: Text(title),
        subtitle: Text(id),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: const TextStyle(color: AppColors.info, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
