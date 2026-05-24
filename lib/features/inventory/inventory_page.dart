import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';
import 'inventory_detail_page.dart';
import 'bulk_inventory_page.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final _apiClient = ApiClient();
  List<dynamic> _inventory = [];
  bool _isLoading = true;
  String? _error;
  bool _criticalOnly = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final res = await _apiClient.get(
        ApiConstants.inventory,
        queryParams: {'criticalOnly': _criticalOnly},
      );

      if (!mounted) return;
      setState(() {
        _inventory = res.data['data'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'خطأ في تحميل المخزون';
        _isLoading = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'حرج':
        return AppColors.danger;
      case 'منخفض':
        return AppColors.warning;
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const LoadingWidget(message: 'جاري تحميل المخزون...');
    if (_error != null) return AppErrorWidget(message: _error!, onRetry: _load);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          // فلتر
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('الكل'),
                  selected: !_criticalOnly,
                  onSelected: (_) {
                    setState(() => _criticalOnly = false);
                    _load();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('حرج فقط'),
                  selected: _criticalOnly,
                  selectedColor: AppColors.danger.withOpacity(0.2),
                  onSelected: (_) {
                    setState(() => _criticalOnly = true);
                    _load();
                  },
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'تعديل جماعي',
                  icon: const Icon(Icons.edit_note, color: AppColors.primary),
                  onPressed: () async {
                    final refresh = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BulkInventoryPage(),
                      ),
                    );
                    if (refresh == true) _load();
                  },
                ),
                Text(
                  '${_inventory.length} سجل',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          // القائمة
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _inventory.length,
                itemBuilder: (context, index) {
                  final item = _inventory[index];
                  final status = item['status'] ?? 'جيد';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _statusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '${item['quantity']}',
                            style: TextStyle(
                              color: _statusColor(status),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        item['productName'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${item['branchName']} • حد الطلب: ${item['reorderLevel']}',
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: _statusColor(status),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                InventoryDetailPage(inventoryItem: item),
                          ),
                        );
                        _load();
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
