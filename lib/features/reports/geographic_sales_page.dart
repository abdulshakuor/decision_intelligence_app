import 'package:flutter/material.dart';

class GeographicSalesReportPage extends StatelessWidget {
  const GeographicSalesReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تقرير المبيعات الجغرافي')),
        body: Column(
          children: [
            Container(
              height: 300,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://maps.googleapis.com/maps/api/staticmap?center=24.7136,46.6753&zoom=5&size=600x300&key=YOUR_API_KEY',
                  ),
                  fit: BoxFit.cover,
                  opacity: 0.5,
                ),
              ),
              child: const Center(
                child: Text(
                  'خريطة توزيع المبيعات (قيد التطوير)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _regionSale('المنطقة الوسطى', '452,000 ر.س', 45, Colors.blue),
                  _regionSale(
                    'المنطقة الغربية',
                    '312,000 ر.س',
                    30,
                    Colors.green,
                  ),
                  _regionSale(
                    'المنطقة الشرقية',
                    '185,000 ر.س',
                    18,
                    Colors.orange,
                  ),
                  _regionSale(
                    'المنطقة الشمالية',
                    '52,000 ر.س',
                    5,
                    Colors.purple,
                  ),
                  _regionSale('المنطقة الجنوبية', '21,000 ر.س', 2, Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _regionSale(String region, String amount, int percent, Color color) {
    return Card(
      child: ListTile(
        leading: Container(width: 4, height: 40, color: color),
        title: Text(region),
        subtitle: Text('النسبة: $percent%'),
        trailing: Text(
          amount,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
