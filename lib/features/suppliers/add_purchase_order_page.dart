import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/loading_widget.dart';

class AddPurchaseOrderPage extends StatefulWidget {
  const AddPurchaseOrderPage({super.key});

  @override
  State<AddPurchaseOrderPage> createState() => _AddPurchaseOrderPageState();
}

class _AddPurchaseOrderPageState extends State<AddPurchaseOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiClient = ApiClient();

  final _supplierController = TextEditingController();
  final _amountController = TextEditingController();
  String _status = 'Draft';

  bool _isLoading = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final data = {
        'orderNumber':
            "PO-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
        'supplierName': _supplierController.text,
        'totalAmount': double.tryParse(_amountController.text) ?? 0,
        'status': _status,
        'orderDate': DateTime.now().toIso8601String(),
      };

      await _apiClient.post(ApiConstants.purchaseOrders, data: data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنشاء أمر الشراء بنجاح')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في الحفظ: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('أمر شراء جديد')),
        body: _isLoading
            ? const LoadingWidget()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'تفاصيل أمر الشراء',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _supplierController,
                        decoration: const InputDecoration(
                          labelText: 'المورد',
                          prefixIcon: Icon(Icons.business_outlined),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'يرجى إدخال اسم المورد'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'المبلغ الإجمالي المتوقع',
                          prefixIcon: Icon(Icons.monetization_on_outlined),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'يرجى إدخال المبلغ' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _status,
                        decoration: const InputDecoration(
                          labelText: 'الحالة الأولية',
                          prefixIcon: Icon(Icons.info_outline),
                        ),
                        items:
                            [
                                  {'label': 'مسودة', 'value': 'Draft'},
                                  {
                                    'label': 'بانتظار الموافقة',
                                    'value': 'Pending',
                                  },
                                  {'label': 'أرسل للمورد', 'value': 'Approved'},
                                ]
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s['value'] as String,
                                    child: Text(s['label'] as String),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => setState(() => _status = v!),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('حفظ أمر الشراء'),
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
