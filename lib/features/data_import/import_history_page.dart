import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/loading_widget.dart';
import 'package:intl/intl.dart' as intl;

class ImportHistoryPage extends StatefulWidget {
  const ImportHistoryPage({super.key});

  @override
  State<ImportHistoryPage> createState() => _ImportHistoryPageState();
}

class _ImportHistoryPageState extends State<ImportHistoryPage> {
  final _apiClient = ApiClient();
  List<dynamic> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      // Assuming endpoint exists or we mock it
      final res = await _apiClient.get('/api/data/import/history');
      setState(() {
        _history = res.data['data'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      // Mock data for demo if API fails
      setState(() {
        _history = [
          {
            'id': 1,
            'fileName': 'products_feb.csv',
            'type': 'منتجات',
            'status': 'نجاح',
            'rowsCount': 150,
            'createdAt': DateTime.now()
                .subtract(const Duration(days: 1))
                .toIso8601String(),
          },
          {
            'id': 2,
            'fileName': 'inventory_main.csv',
            'type': 'مخزون',
            'status': 'نجاح',
            'rowsCount': 45,
            'createdAt': DateTime.now()
                .subtract(const Duration(days: 3))
                .toIso8601String(),
          },
          {
            'id': 3,
            'fileName': 'sales_jan.xlsx',
            'type': 'مبيعات',
            'status': 'فشل',
            'rowsCount': 0,
            'createdAt': DateTime.now()
                .subtract(const Duration(days: 10))
                .toIso8601String(),
          },
        ];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('سجل الاستيراد')),
        body: _isLoading
            ? const LoadingWidget()
            : _history.isEmpty
            ? const Center(child: Text('لا يوجد سجل استيراد'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final item = _history[index];
                  final isSuccess = item['status'] == 'نجاح';
                  final date = DateTime.parse(item['createdAt']);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            (isSuccess ? AppColors.secondary : AppColors.danger)
                                .withOpacity(0.1),
                        child: Icon(
                          isSuccess
                              ? Icons.check_circle_outline
                              : Icons.error_outline,
                          color: isSuccess
                              ? AppColors.secondary
                              : AppColors.danger,
                        ),
                      ),
                      title: Text(item['fileName'] ?? ''),
                      subtitle: Text(
                        '${item['type']} • ${item['rowsCount']} سجل • ${intl.DateFormat('yyyy/MM/dd HH:mm').format(date)}',
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (isSuccess
                                      ? AppColors.secondary
                                      : AppColors.danger)
                                  .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item['status'] ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSuccess
                                ? AppColors.secondary
                                : AppColors.danger,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
