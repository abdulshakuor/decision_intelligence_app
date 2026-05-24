import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FinancialSummaryPage extends StatelessWidget {
  const FinancialSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الملخص المالي')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTotalCard(),
            const SizedBox(height: 24),
            Text(
              'التدفقات النقدية',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _cashFlowItem(
              'إجمالي المبيعات',
              '125,400.00 ر.س',
              AppColors.secondary,
              Icons.trending_up,
            ),
            _cashFlowItem(
              'إجمالي المشتريات',
              '45,200.00 ر.س',
              AppColors.danger,
              Icons.trending_down,
            ),
            _cashFlowItem(
              'إجمالي المصاريف',
              '12,500.00 ر.س',
              AppColors.accent,
              Icons.payments,
            ),
            const Divider(height: 32),
            _cashFlowItem(
              'صافي الربح التقديري',
              '67,700.00 ر.س',
              AppColors.primary,
              Icons.account_balance_wallet,
              isSpecial: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.info],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Text(
            'صافي الأرباح (هذا الشهر)',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            '67,700.00 ر.س',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '+12% عن الشهر الماضي',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _cashFlowItem(
    String title,
    String val,
    Color color,
    IconData icon, {
    bool isSpecial = false,
  }) {
    return Card(
      elevation: isSpecial ? 2 : 0,
      color: isSpecial ? color.withOpacity(0.05) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        trailing: Text(
          val,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
      ),
    );
  }
}
