import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';

class EditProductPage extends StatefulWidget {
  final Map<String, dynamic> product;
  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiClient = ApiClient();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _costCtrl;
  late TextEditingController _priceCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.product['name']);
    _descCtrl = TextEditingController(text: widget.product['description'] ?? '');
    _costCtrl = TextEditingController(text: widget.product['costPrice']?.toString() ?? '');
    _priceCtrl = TextEditingController(text: widget.product['sellingPrice']?.toString() ?? '');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _apiClient.put(
        ApiConstants.productById(widget.product['id']),
        data: {
          'name': _nameCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'costPrice': double.parse(_costCtrl.text),
          'sellingPrice': double.parse(_priceCtrl.text),
          'categoryId': widget.product['categoryId'] ?? 1,
        });

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطأ في تحديث المنتج'),
          backgroundColor: AppColors.danger));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تعديل المنتج')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(key: _formKey, child: Column(children: [
            // SKU (للعرض فقط)
            TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: 'SKU',
                hintText: widget.product['sku'],
              ),
              controller: TextEditingController(text: widget.product['sku']),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'اسم المنتج *'),
              validator: (v) => v!.isEmpty ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'الوصف'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: TextFormField(
                controller: _costCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'سعر التكلفة *'),
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              )),
              const SizedBox(width: 16),
              Expanded(child: TextFormField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'سعر البيع *'),
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              )),
            ]),
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('حفظ التعديلات'),
              )),
          ])),
        ),
      ),
    );
  }
}