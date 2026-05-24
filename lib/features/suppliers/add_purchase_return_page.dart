import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/loading_widget.dart';

class AddPurchaseReturnPage extends StatefulWidget {
  const AddPurchaseReturnPage({super.key});

  @override
  State<AddPurchaseReturnPage> createState() => _AddPurchaseReturnPageState();
}

class _AddPurchaseReturnPageState extends State<AddPurchaseReturnPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiClient = ApiClient();

  final _returnNumberController = TextEditingController(
    text: "PR-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
  );
  final _reasonController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _amountController = TextEditingController();

  List<dynamic> _branches = [];
  List<dynamic> _suppliers = [];
  List<dynamic> _products = [];

  int? _selectedBranchId;
  int? _selectedSupplierId;
  int? _selectedProductId;

  bool _isLoadingData = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final results = await Future.wait([
        _apiClient.get(ApiConstants.branches),
        _apiClient.get(ApiConstants.suppliers),
        _apiClient.get(
          ApiConstants.products,
          queryParams: {'page': 1, 'size': 100},
        ),
      ]);

      setState(() {
        _branches = results[0].data['data'] ?? [];
        _suppliers = results[1].data['data'] ?? [];

        final productsData = results[2].data['data'];
        _products = productsData is Map
            ? (productsData['items'] ?? [])
            : (productsData ?? []);

        if (_branches.isNotEmpty) _selectedBranchId = _branches[0]['id'];
        _isLoadingData = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingData = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في جلب البيانات: $e')));
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBranchId == null ||
        _selectedSupplierId == null ||
        _selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إكمال الحقول المطلوبة')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final qty = int.tryParse(_quantityController.text) ?? 1;
      final totalAmount = double.tryParse(_amountController.text) ?? 0;

      final data = {
        'returnNumber': _returnNumberController.text,
        'supplierId': _selectedSupplierId,
        'branchId': _selectedBranchId,
        'reason': _reasonController.text,
        'totalAmount': totalAmount,
        'returnDate': DateTime.now().toIso8601String(),
        'items': [
          {
            'productId': _selectedProductId,
            'quantity': qty,
            'unitPrice': totalAmount / qty,
          },
        ],
      };

      await _apiClient.post(ApiConstants.purchaseReturns, data: data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تسجيل مرتجع المشتريات بنجاح')),
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
        appBar: AppBar(title: const Text('تسجيل مرتجع مشتريات')),
        body: (_isLoadingData || _isSaving)
            ? const LoadingWidget()
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const Text(
                      'المعلومات الأساسية',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _returnNumberController,
                      decoration: const InputDecoration(
                        labelText: 'رقم المرتجع',
                        prefixIcon: Icon(Icons.tag),
                      ),
                      validator: (v) => v!.isEmpty ? 'يرجى إدخال الرقم' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedSupplierId,
                      decoration: const InputDecoration(
                        labelText: 'المورد',
                        prefixIcon: Icon(Icons.business),
                      ),
                      items: _suppliers
                          .map(
                            (s) => DropdownMenuItem<int>(
                              value: s['id'],
                              child: Text(s['name'] ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedSupplierId = v),
                      validator: (v) => v == null ? 'اختار المورد' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedBranchId,
                      decoration: const InputDecoration(
                        labelText: 'الفرع الذي نقص منه المخزون',
                        prefixIcon: Icon(Icons.store),
                      ),
                      items: _branches
                          .map(
                            (b) => DropdownMenuItem<int>(
                              value: b['id'],
                              child: Text(b['name'] ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedBranchId = v),
                      validator: (v) => v == null ? 'اختار الفرع' : null,
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const Text(
                      'تفاصيل الأصناف',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<int>(
                      value: _selectedProductId,
                      decoration: const InputDecoration(
                        labelText: 'المنتج المرتجع',
                        prefixIcon: Icon(Icons.inventory_2),
                      ),
                      items: _products
                          .map(
                            (p) => DropdownMenuItem<int>(
                              value: p['id'],
                              child: Text(p['name'] ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedProductId = v),
                      validator: (v) => v == null ? 'اختار المنتج' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            decoration: const InputDecoration(
                              labelText: 'الكمية',
                              prefixIcon: Icon(Icons.numbers),
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
                              labelText: 'المبلغ المسترد',
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
                        labelText: 'سبب المرتجع',
                        prefixIcon: Icon(Icons.info_outline),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'حفظ المرتجع وتحديث المخزون',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
