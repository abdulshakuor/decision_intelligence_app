import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';

class InventoryDetailPage extends StatefulWidget {
  final dynamic inventoryItem;
  const InventoryDetailPage({super.key, required this.inventoryItem});

  @override
  State<InventoryDetailPage> createState() => _InventoryDetailPageState();
}

class _InventoryDetailPageState extends State<InventoryDetailPage> {
  final _apiClient = ApiClient();
  List<dynamic> _branchStatus = [];
  bool _isLoading = true;
  String? _error;
  late int _currentQuantity;
  late int _currentReorderLevel;

  @override
  void initState() {
    super.initState();
    _currentQuantity = widget.inventoryItem['quantity'] ?? 0;
    _currentReorderLevel = widget.inventoryItem['reorderLevel'] ?? 0;
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final res = await _apiClient.get(
        '${ApiConstants.baseUrl}/inventory/status',
        queryParams: {'productId': widget.inventoryItem['productId']},
      );
      setState(() {
        _branchStatus = res.data['data'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'خطأ في تحميل بيانات الفروع';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStock() async {
    final quantityController = TextEditingController(
      text: widget.inventoryItem['quantity'].toString(),
    );
    final reorderController = TextEditingController(
      text: widget.inventoryItem['reorderLevel'].toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تحديث المخزون'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'الكمية الحالية'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reorderController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'حد الطلب'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await _apiClient.put(
                    '${ApiConstants.baseUrl}/inventory/update',
                    data: {
                      'productId': widget.inventoryItem['productId'],
                      'branchId': widget.inventoryItem['branchId'],
                      'quantity': int.parse(quantityController.text),
                      'reorderLevel': int.parse(reorderController.text),
                    },
                  );
                  setState(() {
                    _currentQuantity = int.parse(quantityController.text);
                    _currentReorderLevel = int.parse(reorderController.text);
                  });
                  _loadStatus();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تحديث المخزون بنجاح')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('فشل في تحديث المخزون'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                }
              },
              child: const Text('تحديث'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.inventoryItem;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(item['productName'] ?? 'تفاصيل المخزون')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // بطاقة المعلومات العامة
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['productName'] ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'SKU: ${item['productSKU'] ?? 'N/A'}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _infoItem('الكمية الحالية', '$_currentQuantity'),
                        _infoItem('حد الطلب', '$_currentReorderLevel'),
                        _infoItem(
                          'الحالة',
                          item['status'],
                          color: _getStatusColor(item['status']),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _updateStock,
                        icon: const Icon(Icons.edit),
                        label: const Text('تعديل مخزون هذا الفرع'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'حالة المخزون في جميع الفروع',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Center(child: Text(_error!))
            else
              ..._branchStatus.map(
                (b) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(b['branchName'] ?? ''),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(b['status']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${b['quantity']} وحدة (${b['status']})',
                        style: TextStyle(
                          color: _getStatusColor(b['status']),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    if (status == 'حرج') return AppColors.danger;
    if (status == 'منخفض') return AppColors.warning;
    return AppColors.secondary;
  }
}
