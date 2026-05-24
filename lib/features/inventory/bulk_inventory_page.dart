import 'package:flutter/material.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/loading_widget.dart';

class BulkInventoryPage extends StatefulWidget {
  const BulkInventoryPage({super.key});

  @override
  State<BulkInventoryPage> createState() => _BulkInventoryPageState();
}

class _BulkInventoryPageState extends State<BulkInventoryPage> {
  final _apiClient = ApiClient();
  List<dynamic> _inventory = [];
  bool _isLoading = true;
  bool _isSaving = false;
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.get(ApiConstants.inventory);
      setState(() {
        _inventory = res.data['data'] ?? [];
        for (var item in _inventory) {
          _controllers[item['id']] = TextEditingController(
            text: item['quantity'].toString(),
          );
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAll() async {
    setState(() => _isSaving = true);
    try {
      final List<Map<String, dynamic>> updates = [];
      for (var item in _inventory) {
        final newQty = int.tryParse(_controllers[item['id']]!.text);
        if (newQty != null && newQty != item['quantity']) {
          updates.add({
            'productId': item['productId'],
            'branchId': item['branchId'],
            'quantity': newQty,
            'reorderLevel': item['reorderLevel'],
          });
        }
      }

      if (updates.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يوجد تغييرات لتعديلها')),
        );
        setState(() => _isSaving = false);
        return;
      }

      await _apiClient.put(
        '${ApiConstants.baseUrl}/inventory/bulk-update',
        data: updates,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم تحديث المخزون بنجاح')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('فشل تحديث المخزون')));
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التعديل الجماعي للمخزون'),
          actions: [
            if (!_isLoading)
              TextButton.icon(
                onPressed: _isSaving ? null : _saveAll,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  'حفظ الكل',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
        body: _isLoading
            ? const LoadingWidget(message: 'جاري تحميل البيانات...')
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _inventory.length,
                itemBuilder: (context, index) {
                  final item = _inventory[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['productName'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  item['branchName'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 100,
                            child: TextField(
                              controller: _controllers[item['id']],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                labelText: 'الكمية',
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
