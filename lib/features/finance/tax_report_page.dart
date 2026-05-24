import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class TaxReportPage extends StatelessWidget {
  const TaxReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الإقرار الضريبي')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(),
              const SizedBox(height: 32),
              const Text(
                'تفاصيل الضريبة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildRow(
                'إجمالي مبيعات الفترة (شامل الضريبة)',
                '150,000.00 ر.س',
              ),
              _buildRow('إجمالي المبيعات الخاضعة للضريبة', '130,434.78 ر.س'),
              _buildRow(
                'ضريبة المخرجات (15%)',
                '19,565.22 ر.س',
                isHighlight: true,
              ),
              const Divider(height: 40),
              _buildRow('إجمالي المشتريات الخاضعة للضريبة', '45,200.00 ر.س'),
              _buildRow(
                'ضريبة المدخلات (15%)',
                '6,780.00 ر.س',
                isHighlight: true,
              ),
              const Divider(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildRow(
                  'صافي الضريبة المستحقة للدولة',
                  '12,785.22 ر.س',
                  isBold: true,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'الربع الحالي (Q1 2024)',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            const Text(
              '12,785.22 ر.س',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'إجمالي الضريبة المستحقة',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    bool isHighlight = false,
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isHighlight ? AppColors.info : null,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
