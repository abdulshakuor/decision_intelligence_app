import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import 'widgets/csv_import_widget.dart';

class DataImportPage extends StatefulWidget {
  const DataImportPage({super.key});

  @override
  State<DataImportPage> createState() => _DataImportPageState();
}

class _DataImportPageState extends State<DataImportPage> {
  final _apiClient = ApiClient();
  String _importType = 'products';
  final _jsonCtrl = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _jsonCtrl.dispose();
    super.dispose();
  }

  Future<void> _import() async {
    if (_jsonCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('أدخل البيانات')));
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final endpoint = _importType == 'products'
          ? ApiConstants.importProducts
          : ApiConstants.importInventory;

      final res = await _apiClient.post(endpoint, data: _jsonCtrl.text.trim());
      setState(() {
        _result = res.data['data'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('استيراد البيانات'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'نص JSON', icon: Icon(Icons.code)),
                Tab(text: 'ملف CSV', icon: Icon(Icons.file_present)),
              ],
            ),
          ),
          body: TabBarView(
            children: [_buildJsonImport(), const CsvImportWidget()],
          ),
        ),
      ),
    );
  }

  Widget _buildJsonImport() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'نوع البيانات',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _typeChip('products', 'منتجات', Icons.inventory_2),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _typeChip('inventory', 'مخزون', Icons.warehouse),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: AppColors.info.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'صيغة البيانات المطلوبة (JSON)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _importType == 'products'
                      ? '[{"sku":"P001","name":"منتج","costPrice":10,"sellingPrice":20,"categoryId":1}]'
                      : '[{"productId":1,"branchId":1,"quantity":100,"reorderLevel":10}]',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _jsonCtrl,
          maxLines: 8,
          decoration: InputDecoration(
            labelText: 'ألصق بيانات JSON هنا',
            alignLabelWithHint: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _import,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.upload),
            label: Text(_isLoading ? 'جاري الاستيراد...' : 'استيراد البيانات'),
          ),
        ),
        const SizedBox(height: 16),
        if (_result != null)
          Card(
            color: AppColors.secondary.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'تم الاستيراد بنجاح',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_result!['created'] != null)
                    _resultRow('تم إنشاؤه', '${_result!['created']}'),
                  if (_result!['updated'] != null)
                    _resultRow('تم تحديثه', '${_result!['updated']}'),
                  if (_result!['errors'] != null && _result!['errors'] > 0)
                    _resultRow('أخطاء', '${_result!['errors']}'),
                  if (_result!['processed'] != null)
                    _resultRow('تمت معالجته', '${_result!['processed']}'),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _typeChip(String value, String label, IconData icon) {
    final isSelected = _importType == value;
    return GestureDetector(
      onTap: () => setState(() => _importType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
