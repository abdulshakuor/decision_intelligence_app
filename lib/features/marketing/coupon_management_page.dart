import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/loading_widget.dart';
import 'add_coupon_page.dart';

class CouponManagementPage extends StatefulWidget {
  const CouponManagementPage({super.key});

  @override
  State<CouponManagementPage> createState() => _CouponManagementPageState();
}

class _CouponManagementPageState extends State<CouponManagementPage> {
  final _apiClient = ApiClient();
  List<dynamic> _coupons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.get(ApiConstants.coupons);
      setState(() {
        _coupons = res.data['data'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('كوبونات الخصم'),
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
          ],
        ),
        body: _isLoading
            ? const LoadingWidget()
            : RefreshIndicator(
                onRefresh: _load,
                child: _coupons.isEmpty
                    ? const Center(child: Text('لا توجد كوبونات مضافة'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _coupons.length,
                        itemBuilder: (context, index) {
                          final c = _coupons[index];
                          final status = c['status'] ?? 'Active';
                          final isActive = status == 'Active';

                          return Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: Colors.grey.withOpacity(0.2),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.confirmation_number,
                                  color: AppColors.accent,
                                ),
                              ),
                              title: Text(
                                c['code'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              subtitle: Text(
                                '${c['type'] == 'Percentage' ? 'نسبة' : 'مبلغ ثابت'} • ينتهي في: ${c['expiryDate']?.toString().split('T')[0] ?? 'بدون تاريخ'}',
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      (isActive
                                              ? AppColors.secondary
                                              : Colors.grey)
                                          .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  c['type'] == 'Percentage'
                                      ? '${c['value']}%'
                                      : '${c['value']} ر.س',
                                  style: TextStyle(
                                    color: isActive
                                        ? AppColors.secondary
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
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
              MaterialPageRoute(builder: (_) => const AddCouponPage()),
            );
            if (result == true) _load();
          },
          label: const Text('إنشاء كوبون'),
          icon: const Icon(Icons.add),
          backgroundColor: AppColors.accent,
        ),
      ),
    );
  }
}
