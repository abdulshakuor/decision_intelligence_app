import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/app_colors.dart';

class AddProductPage extends StatefulWidget {
  final Map<String, dynamic>? product;
  const AddProductPage({super.key, this.product});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiClient = ApiClient();
  final _skuCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController(text: '0');

  int? _categoryId;
  int? _branchId;
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _branches = [];
  bool _isLoading = false;
  bool _loadingData = true;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _skuCtrl.text = widget.product!['sku'] ?? '';
      _nameCtrl.text = widget.product!['name'] ?? '';
      _descCtrl.text = widget.product!['description'] ?? '';
      _costCtrl.text = widget.product!['costPrice']?.toString() ?? '';
      _priceCtrl.text = widget.product!['sellingPrice']?.toString() ?? '';
      _categoryId = widget.product!['categoryId'];
      _branchId = widget.product!['branchId'];
    }
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final results = await Future.wait([
        _apiClient.get(ApiConstants.categories),
        _apiClient.get(ApiConstants.branches),
      ]);

      // Categories
      final catData = results[0].data;
      List catItems = [];
      if (catData is Map && catData['data'] != null) {
        catItems = catData['data'] as List;
      } else if (catData is List) {
        catItems = catData;
      }

      // Branches
      final branchData = results[1].data;
      List branchItems = [];
      if (branchData is Map && branchData['data'] != null) {
        branchItems = branchData['data'] as List;
      } else if (branchData is List) {
        branchItems = branchData;
      }

      setState(() {
        _categories = catItems
            .map((e) => {'id': e['id'], 'name': e['name']})
            .toList()
            .cast<Map<String, dynamic>>();
        _branches = branchItems
            .map((e) => {'id': e['id'], 'name': e['name']})
            .toList()
            .cast<Map<String, dynamic>>();
        _loadingData = false;
      });
    } catch (e) {
      setState(() => _loadingData = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'sku': _skuCtrl.text.trim(),
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'costPrice': double.parse(_costCtrl.text),
        'sellingPrice': double.parse(_priceCtrl.text),
        'categoryId': _categoryId,
        'branchId': _branchId,
        if (widget.product == null)
          'initialQuantity': int.tryParse(_quantityCtrl.text) ?? 0,
      };

      if (widget.product != null) {
        await _apiClient.put(
          ApiConstants.productById(widget.product!['id']),
          data: data,
        );
      } else {
        await _apiClient.post(ApiConstants.products, data: data);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      String errorMsg = 'خطأ في حفظ المنتج';
      if (e is DioException &&
          e.response?.data != null &&
          e.response?.data is Map) {
        errorMsg = e.response?.data['message'] ?? errorMsg;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.product != null ? 'تعديل المنتج' : 'إضافة منتج جديد',
          ),
        ),
        body: _loadingData
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _skuCtrl,
                        decoration: const InputDecoration(
                          labelText: 'رمز المنتج (SKU) *',
                        ),
                        validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'اسم المنتج *',
                        ),
                        validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _descCtrl,
                        decoration: const InputDecoration(labelText: 'الوصف'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // ===== قائمة التصنيفات =====
                      DropdownButtonFormField<int>(
                        value: _categoryId,
                        decoration: const InputDecoration(
                          labelText: 'التصنيف *',
                          border: OutlineInputBorder(),
                        ),
                        hint: const Text('اختر تصنيفاً'),
                        items: _categories
                            .map(
                              (cat) => DropdownMenuItem<int>(
                                value: cat['id'] as int,
                                child: Text(cat['name'] as String),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => _categoryId = val),
                        validator: (v) =>
                            v == null ? 'يرجى اختيار تصنيف' : null,
                      ),
                      const SizedBox(height: 16),

                      // ===== قائمة الفروع =====
                      DropdownButtonFormField<int>(
                        value: _branchId,
                        decoration: const InputDecoration(
                          labelText: 'الفرع *',
                          border: OutlineInputBorder(),
                        ),
                        hint: const Text('اختر الفرع'),
                        items: _branches
                            .map(
                              (branch) => DropdownMenuItem<int>(
                                value: branch['id'] as int,
                                child: Text(branch['name'] as String),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => _branchId = val),
                        validator: (v) => v == null ? 'يرجى اختيار فرع' : null,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _costCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'سعر التكلفة *',
                              ),
                              validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _priceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'سعر البيع *',
                              ),
                              validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                            ),
                          ),
                        ],
                      ),
                      if (widget.product == null) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _quantityCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'الكمية الابتدائية (اختياري)',
                            prefixIcon: Icon(Icons.inventory),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _save,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text('حفظ المنتج'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
