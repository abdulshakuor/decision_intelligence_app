import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';

class CreateSalePage extends StatefulWidget {
  final Map<String, dynamic>? sale;
  const CreateSalePage({super.key, this.sale});

  @override
  State<CreateSalePage> createState() => _CreateSalePageState();
}

class SaleItem {
  int productId = 0;
  String productName = '';
  final TextEditingController quantityCtrl;
  final TextEditingController priceCtrl;

  SaleItem({int quantity = 1, double price = 0.0})
    : quantityCtrl = TextEditingController(text: quantity.toString()),
      priceCtrl = TextEditingController(text: price.toString());

  void dispose() {
    quantityCtrl.dispose();
    priceCtrl.dispose();
  }

  int get quantity => int.tryParse(quantityCtrl.text) ?? 0;
  double get unitPrice => double.tryParse(priceCtrl.text) ?? 0.0;
}

class _CreateSalePageState extends State<CreateSalePage> {
  final _apiClient = ApiClient();
  final _customerNameCtrl = TextEditingController();
  final _customerPhoneCtrl = TextEditingController();
  final List<SaleItem> _items = [];
  List<Map<String, dynamic>> _allProducts = [];
  List<dynamic> _branches = [];
  List<dynamic> _inventory = [];
  int? _selectedBranchId;
  bool _isLoading = false;
  bool _isFetchingData = true;

  @override
  void initState() {
    super.initState();
    if (widget.sale != null) {
      _customerNameCtrl.text = widget.sale!['customerName'] ?? '';
      _customerPhoneCtrl.text = widget.sale!['customerPhone'] ?? '';
      _selectedBranchId = widget.sale!['branchId'];
      final itemsData = widget.sale!['items'] as List? ?? [];
      for (var item in itemsData) {
        final saleItem = SaleItem(
          quantity: (item['quantity'] as num?)?.toInt() ?? 1,
          price: (item['unitPrice'] as num?)?.toDouble() ?? 0.0,
        );
        saleItem.productId = item['productId'] ?? 0;
        saleItem.productName = item['productName'] ?? '';
        _items.add(saleItem);
      }
    }
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _apiClient.get(
          ApiConstants.products,
          queryParams: {'page': 1, 'size': 500},
        ),
        _apiClient.get(ApiConstants.branches),
        _apiClient.get(ApiConstants.inventory),
      ]);

      if (mounted) {
        setState(() {
          final productsData = results[0].data['data'];
          _allProducts =
              (productsData is Map
                      ? (productsData['items'] ?? [])
                      : (productsData ?? []))
                  .cast<Map<String, dynamic>>();

          _branches = results[1].data['data'] ?? [];
          if (_branches.isNotEmpty && _selectedBranchId == null) {
            _selectedBranchId = _branches[0]['id'];
          }

          _inventory = results[2].data['data'] ?? [];
          _isFetchingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFetchingData = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تحميل البيانات: $e')));
      }
    }
  }

  int _getStock(int productId) {
    if (_selectedBranchId == null) return 0;
    try {
      final item = _inventory.firstWhere(
        (inv) =>
            inv['productId'] == productId &&
            inv['branchId'] == _selectedBranchId,
        orElse: () => null,
      );
      return item?['quantity'] ?? 0;
    } catch (_) {
      return 0;
    }
  }

  double get _total =>
      _items.fold(0, (sum, i) => sum + (i.quantity * i.unitPrice));

  void _addItem() {
    setState(() {
      _items.add(SaleItem());
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
    });
  }

  @override
  void dispose() {
    _customerNameCtrl.dispose();
    _customerPhoneCtrl.dispose();
    for (var item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('أضف منتج واحد على الأقل')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = {
        'customerName': _customerNameCtrl.text.trim(),
        'customerPhone': _customerPhoneCtrl.text.trim(),
        'branchId': _selectedBranchId,
        'items': _items
            .map(
              (i) => {
                'productId': i.productId,
                'quantity': i.quantity,
                'unitPrice': i.unitPrice,
              },
            )
            .toList(),
      };

      if (widget.sale != null) {
        await _apiClient.put(
          ApiConstants.saleById(widget.sale!['id']),
          data: data,
        );
      } else {
        await _apiClient.post(ApiConstants.sales, data: data);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      String errorMsg = 'خطأ في إنشاء الفاتورة';
      if (e is DioException &&
          e.response?.data != null &&
          e.response?.data is Map) {
        errorMsg = e.response?.data['message'] ?? errorMsg;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: AppColors.danger),
      );
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
          title: Text(widget.sale != null ? 'تعديل فاتورة' : 'فاتورة جديدة'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // بيانات العميل والفرع
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<int>(
                      value: _selectedBranchId,
                      decoration: const InputDecoration(
                        labelText: 'الفرع',
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
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _customerNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'اسم العميل',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _customerPhoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'رقم الجوال',
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // عناصر الفاتورة
            Row(
              children: [
                Text(
                  'عناصر الفاتورة (${_items.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ...List.generate(
              _items.length,
              (i) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Autocomplete<Map<String, dynamic>>(
                              displayStringForOption: (option) {
                                final stock = _getStock(option['id']);
                                return '${option['name']} (المتوفر: $stock)';
                              },
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                    if (textEditingValue.text == '') {
                                      return const Iterable<
                                        Map<String, dynamic>
                                      >.empty();
                                    }
                                    return _allProducts.where((option) {
                                      final name = option['name']
                                          .toString()
                                          .toLowerCase();
                                      final sku = (option['sku'] ?? '')
                                          .toString()
                                          .toLowerCase();
                                      final search = textEditingValue.text
                                          .toLowerCase();
                                      return name.contains(search) ||
                                          sku.contains(search);
                                    });
                                  },
                              onSelected: (Map<String, dynamic> selection) {
                                setState(() {
                                  _items[i].productId = selection['id'];
                                  _items[i].productName = selection['name'];
                                  _items[i].priceCtrl.text =
                                      ((selection['sellingPrice'] as num?)
                                                  ?.toDouble() ??
                                              0.0)
                                          .toString();
                                });
                              },
                              fieldViewBuilder:
                                  (
                                    context,
                                    controller,
                                    focusNode,
                                    onFieldSubmitted,
                                  ) {
                                    if (controller.text.isEmpty &&
                                        _items[i].productName.isNotEmpty) {
                                      controller.text = _items[i].productName;
                                    }
                                    return TextField(
                                      controller: controller,
                                      focusNode: focusNode,
                                      decoration: InputDecoration(
                                        labelText: 'البحث عن منتج (اسم أو SKU)',
                                        isDense: true,
                                        suffixIcon: _isFetchingData
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: Padding(
                                                  padding: EdgeInsets.all(4.0),
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                ),
                                              )
                                            : const Icon(
                                                Icons.search,
                                                size: 20,
                                              ),
                                      ),
                                    );
                                  },
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _items[i].quantityCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'الكمية',
                                      isDense: true,
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (v) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _items[i].priceCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'السعر',
                                      isDense: true,
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (v) => setState(() {}),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.danger),
                        onPressed: () => _removeItem(i),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // الإجمالي
            Card(
              color: AppColors.primary.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      'الإجمالي',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_total.toStringAsFixed(2)} ر.س',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.sale != null
                            ? 'حفظ التعديلات'
                            : 'إنشاء الفاتورة',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
