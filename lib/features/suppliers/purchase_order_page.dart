import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/loading_widget.dart';
import 'add_purchase_order_page.dart';

class PurchaseOrderPage extends StatefulWidget {
  const PurchaseOrderPage({super.key});

  @override
  State<PurchaseOrderPage> createState() => _PurchaseOrderPageState();
}

class _PurchaseOrderPageState extends State<PurchaseOrderPage> {
  final _apiClient = ApiClient();
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.get(ApiConstants.purchaseOrders);
      setState(() {
        _orders = res.data['data'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _statusArabic(String status) {
    switch (status) {
      case 'Draft':
        return 'مسودة';
      case 'Pending':
        return 'قيد الانتظار';
      case 'Approved':
        return 'معتمد';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('أوامر الشراء'),
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
          ],
        ),
        body: _isLoading
            ? const LoadingWidget()
            : RefreshIndicator(
                onRefresh: _load,
                child: _orders.isEmpty
                    ? const Center(child: Text('لا توجد أوامر شراء مضافة'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          final o = _orders[index];
                          return Card(
                            child: ListTile(
                              leading: const Icon(
                                Icons.shopping_cart_checkout,
                                color: AppColors.primary,
                              ),
                              title: Text(
                                'أمر شراء #${o['orderNumber'] ?? ''}',
                              ),
                              subtitle: Text(
                                'المورد: ${o['supplierName'] ?? 'غير محدد'} • ${_statusArabic(o['status'] ?? '')}',
                              ),
                              trailing: Text(
                                '${o['totalAmount'] ?? 0} ر.س',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                ),
                              ),
                              onTap: () {},
                            ),
                          );
                        },
                      ),
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddPurchaseOrderPage()),
            );
            if (result == true) _load();
          },
          label: const Text('أمر شراء جديد'),
          icon: const Icon(Icons.add_shopping_cart),
          backgroundColor: AppColors.primary,
        ),
      ),
    );
  }
}
