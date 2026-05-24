import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppPreferencesPage extends StatefulWidget {
  const AppPreferencesPage({super.key});

  @override
  State<AppPreferencesPage> createState() => _AppPreferencesPageState();
}

class _AppPreferencesPageState extends State<AppPreferencesPage> {
  bool _enableNotifications = true;
  bool _darkMode = false;
  String _language = 'العربية';
  String _currency = 'SAR';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تفضيلات التطبيق')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _SectionHeader(title: 'العرض والمظهر'),
            SwitchListTile(
              title: const Text('الوضع الداكن'),
              subtitle: const Text('تفعيل السمة الداكنة للتطبيق'),
              value: _darkMode,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _darkMode = v),
            ),
            ListTile(
              title: const Text('لغة التطبيق'),
              trailing: Text(
                _language,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              title: const Text('العملة الافتراضية'),
              trailing: Text(
                _currency,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {},
            ),
            const Divider(),
            const _SectionHeader(title: 'التنبيهات'),
            SwitchListTile(
              title: const Text('إشعارات النظام'),
              subtitle: const Text('استلام تنبيهات حول المخزون والمبيعات'),
              value: _enableNotifications,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _enableNotifications = v),
            ),
            const Divider(),
            const _SectionHeader(title: 'النظام'),
            ListTile(
              leading: const Icon(Icons.cloud_sync, color: AppColors.secondary),
              title: const Text('مزامنة البيانات'),
              subtitle: const Text('آخر مزامنة: منذ دقيقتين'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep, color: AppColors.danger),
              title: const Text('مسح التخزين المؤقت'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
