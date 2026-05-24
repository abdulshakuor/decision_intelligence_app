import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/loading_widget.dart';
import 'add_purchase_return_page.dart';

class PurchaseReturnPage extends StatefulWidget {
  const PurchaseReturnPage({super.key});

  @override
  State<PurchaseReturnPage> createState() => _PurchaseReturnPageState();
}

class _PurchaseReturnPageState extends State<PurchaseReturnPage> {
  final _apiClient = ApiClient();
  List<dynamic> _returns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReturns();
  }

  Future<void> _fetchReturns() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get(ApiConstants.purchaseReturns);
      if (response.data != null) {
        setState(() {
          _returns = response.data['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في جلب المرتجعات: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مرتجع المشتريات'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchReturns,
            ),
          ],
        ),
        body: _isLoading
            ? const LoadingWidget()
            : RefreshIndicator(
                onRefresh: _fetchReturns,
                child: _returns.isEmpty
                    ? const Center(child: Text('لا توجد عمليات مرتجع مشتريات'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _returns.length,
                        itemBuilder: (context, index) {
                          final r = _returns[index];
                          return Card(
                            child: ListTile(
                              leading: const Icon(
                                Icons.keyboard_return,
                                color: AppColors.primary,
                              ),
                              title: Text(
                                'مرتجع رقم: ${r['returnNumber'] ?? ''}',
                              ),
                              subtitle: Text(
                                'المورد: ${r['supplierName'] ?? 'غير محدد'} • ${r['returnDate']?.toString().split('T')[0] ?? ''}',
                              ),
                              trailing: Text(
                                '${r['totalAmount'] ?? 0} ر.س',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddPurchaseReturnPage()),
            );
            if (result == true) _fetchReturns();
          },
          label: const Text('مرتجع جديد'),
          icon: const Icon(Icons.undo),
          backgroundColor: AppColors.primary,
        ),
      ),
    );
  }
}
