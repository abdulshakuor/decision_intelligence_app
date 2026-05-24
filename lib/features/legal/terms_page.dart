import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('شروط الخدمة')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'شروط وأحكام الاستخدام',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                '1. مقدمة',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'أهلاً بك في منصة محاسبك في جيبك. باستخدامك لهذا التطبيق، فأنت توافق على الالتزام بالشروط الآتية...',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),
              const Text(
                '2. حقوق الملكية',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'كافة المحتويات والرموز البرمجية هي ملك لشركة الذكاء الاصطناعي للقرارات...',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),
              const Text(
                '3. البيانات والخصوصية',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'نحن نلتزم بحفظ بياناتك وتشفيرها وفق أعلى المعايير الأمنية...',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
