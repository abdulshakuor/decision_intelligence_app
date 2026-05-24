import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/loading_widget.dart';

class AddSalesReturnPage extends StatefulWidget {
  const AddSalesReturnPage({super.key});

  @override
  State<AddSalesReturnPage> createState() => _AddSalesReturnPageState();
}

class _AddSalesReturnPageState extends State<AddSalesReturnPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiClient = ApiClient();

  final _orderNumberController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _reasonController = TextEditingController();

  List<dynamic> _branches = [];
  List<dynamic> _products = [];
  int? _selectedBranchId;
  int? _selectedProductId;
  final _quantityController = TextEditingController(text: '1');
  final _amountController =
      TextEditingController(); // Total amount for the return

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final branchesRes = await _apiClient.get(ApiConstants.branches);
      // Products API returns PagedResponse — items are under data['items']
      final productsRes = await _apiClient.get(
        ApiConstants.products,
        queryParams: {'page': 1, 'size': 100},
      );

      setState(() {
        _branches = branchesRes.data['data'] ?? [];
        // PagedResponse wraps the list in 'items', not 'data'
        final productsData = productsRes.data['data'];
        _products = productsData is Map
            ? (productsData['items'] ?? [])
            : (productsData ?? []);
        if (_branches.isNotEmpty) _selectedBranchId = _branches[0]['id'];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في جلب البيانات: $e')));
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBranchId == null || _selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار الفرع والمنتج')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final qty = int.tryParse(_quantityController.text) ?? 1;
      final totalAmount = double.tryParse(_amountController.text) ?? 0;

      final data = {
        'orderNumber': _orderNumberController.text,
        'customerName': _customerNameController.text,
        'reason': _reasonController.text,
        'totalAmount': totalAmount,
        'branchId': _selectedBranchId,
        'returnDate': DateTime.now().toIso8601String(),
        'items': [
          {
            'productId': _selectedProductId,
            'quantity': qty,
            'unitPrice': totalAmount / qty, // Rough estimation if not provided
          },
        ],
      };

      await _apiClient.post(ApiConstants.salesReturns, data: data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تسجيل المرتجع وتحديث المخزون بنجاح'),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في التسجيل: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تسجيل مرتجع مبيعات احترافي')),
        body: (_isLoading || _isSaving)
            ? const LoadingWidget()
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const Text(
                      'بيانات الطلب الأصلي',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _orderNumberController,
                      decoration: const InputDecoration(
                        labelText: 'رقم الفاتورة الأصلي',
                        prefixIcon: Icon(Icons.receipt),
                      ),
                      validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedBranchId,
                      decoration: const InputDecoration(
                        labelText: 'الفرع المستلم للمرتجع',
                        prefixIcon: Icon(Icons.store),
                      ),
                      items: _branches
                          .map(
                            (b) => DropdownMenuItem<int>(
                              value: b['id'],
                              child: Text(b['name']),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedBranchId = v),
                      validator: (v) => v == null ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const Text(
                      'تفاصيل المنتج المرتجع',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedProductId,
                      decoration: const InputDecoration(
                        labelText: 'اختر المنتج',
                        prefixIcon: Icon(Icons.inventory_2_outlined),
                      ),
                      items: _products
                          .map(
                            (p) => DropdownMenuItem<int>(
                              value: p['id'],
                              child: Text(p['name']),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedProductId = v),
                      validator: (v) => v == null ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            decoration: const InputDecoration(
                              labelText: 'الكمية المرتجعة',
                              prefixIcon: Icon(Icons.add_shopping_cart),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _amountController,
                            decoration: const InputDecoration(
                              labelText: 'إجمالي المبلغ',
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _reasonController,
                      decoration: const InputDecoration(
                        labelText: 'سبب الإرجاع',
                        prefixIcon: Icon(Icons.info_outline),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        'حفظ المرتجع وتحديث المخزون',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
