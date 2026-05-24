import 'package:flutter/material.dart';

class HeatMapPage extends StatelessWidget {
  const HeatMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الخريطة الحرارية للمبيعات')),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            image: const DecorationImage(
              image: NetworkImage(
                'https://maps.googleapis.com/maps/api/staticmap?center=24.7136,46.6753&zoom=6&size=640x640&key=YOUR_API_KEY',
              ),
              fit: BoxFit.cover,
              opacity: 0.3,
            ),
          ),
          child: Stack(
            children: [
              _buildPulse(200, 300, Colors.red, 'الرياض - مركز الطلب مرتفع'),
              _buildPulse(400, 150, Colors.orange, 'جدة - طلب متوسط'),
              _buildPulse(150, 500, Colors.green, 'الدمام - نمو مستعرض'),
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'توزيع الكثافة الشرائية',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _legendItem(Colors.red, 'مرتفع جداً'),
                            _legendItem(Colors.orange, 'متوسط'),
                            _legendItem(Colors.green, 'منخفض'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPulse(double top, double left, Color color, String label) {
    return Positioned(
      top: top,
      left: left,
      child: Tooltip(
        message: label,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.3),
          ),
          child: Center(
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
          ),
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
