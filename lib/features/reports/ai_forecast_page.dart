import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AIForecastPage extends StatelessWidget {
  const AIForecastPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('توقعات الذكاء الاصطناعي')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildPredictionCard(
              'توقع المبيعات للشهر القادم',
              '125,000 ر.س',
              'بزيادة قدرها 15% متوقعة',
              Icons.trending_up,
              Colors.green,
            ),
            const SizedBox(height: 24),
            _buildPredictionCard(
              'الطلب المتوقع على "آيفون 15"',
              '850 وحدة',
              'بناءً على اتجاهات الشراء التاريخية',
              Icons.inventory_2,
              AppColors.primary,
            ),
            const SizedBox(height: 32),
            const Text(
              'تحليلات سلوك العملاء',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _behaviorItem('العملاء الأكثر ولاءً', 'زيادة بنسبة 8% هذا الربع'),
            _behaviorItem('معدل الارتداد', 'انخفاض بنسبة 4% متوقع'),
            _behaviorItem(
              'وقت الذروة الشرائي',
              'بين الساعة 7 مساءً و 10 مساءً',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionCard(
    String title,
    String val,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey)),
                Text(
                  val,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _behaviorItem(String title, String desc) {
    return Card(
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
        trailing: const Icon(Icons.bolt, color: Colors.amber),
      ),
    );
  }
}
