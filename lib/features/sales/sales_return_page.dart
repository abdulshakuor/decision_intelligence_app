import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/loading_widget.dart';
import 'add_sales_return_page.dart';

class SalesReturnPage extends StatefulWidget {
  const SalesReturnPage({super.key});

  @override
  State<SalesReturnPage> createState() => _SalesReturnPageState();
}

class _SalesReturnPageState extends State<SalesReturnPage> {
  final _apiClient = ApiClient();
  List<dynamic> _returns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReturns();
  }

  Future<void> _fetchReturns() async {
    try {
      final response = await _apiClient.get(ApiConstants.salesReturns);
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
        appBar: AppBar(title: const Text('مرتجع المبيعات')),
        body: _isLoading
            ? const LoadingWidget()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _returns.length,
                itemBuilder: (context, index) {
                  final r = _returns[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.assignment_return,
                        color: AppColors.danger,
                      ),
                      title: Text('مرتجع لطلب #${r['orderNumber'] ?? ''}'),
                      subtitle: Text(
                        'العميل: ${r['customerName'] ?? 'عام'} - ${r['returnDate']?.toString().split('T')[0] ?? ''}',
                      ),
                      trailing: Text(
                        '${r['totalAmount'] ?? 0} ر.س',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddSalesReturnPage()),
            );
            if (result == true) {
              setState(() => _isLoading = true);
              _fetchReturns();
            }
          },
          label: const Text('إضافة مرتجع'),
          icon: const Icon(Icons.add),
          backgroundColor: AppColors.danger,
        ),
      ),
    );
  }
}
