import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CustomerDetailPage extends StatelessWidget {
  final Map<String, dynamic> customer;
  const CustomerDetailPage({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(customer['name'])),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildStatRow(),
            const SizedBox(height: 32),
            const Text(
              'سجل المشتريات الأخير',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildOrderItem('طلب #ORD-7741', '2024-02-10', '450.00 ر.س'),
            _buildOrderItem('طلب #ORD-7622', '2024-01-25', '1,200.00 ر.س'),
            _buildOrderItem('طلب #ORD-7510', '2023-12-15', '850.00 ر.س'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            customer['name'][0],
            style: const TextStyle(
              fontSize: 40,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          customer['name'],
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(customer['phone'], style: const TextStyle(color: Colors.grey)),
        Text(customer['email'], style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildStatRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _statCard('إجمالي المشتريات', '${customer['totalPurchases']}'),
        _statCard('النقاط المكتسبة', '${customer['points']}'),
        _statCard('عدد الطلبات', '12'),
      ],
    );
  }

  Widget _statCard(String label, String val) {
    return Column(
      children: [
        Text(
          val,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.primary,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildOrderItem(String id, String date, String price) {
    return Card(
      child: ListTile(
        title: Text(id),
        subtitle: Text(date),
        trailing: Text(
          price,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
      ),
    );
  }
}
