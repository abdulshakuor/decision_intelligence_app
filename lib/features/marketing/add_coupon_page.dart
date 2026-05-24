import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/loading_widget.dart';

class AddCouponPage extends StatefulWidget {
  const AddCouponPage({super.key});

  @override
  State<AddCouponPage> createState() => _AddCouponPageState();
}

class _AddCouponPageState extends State<AddCouponPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiClient = ApiClient();

  final _codeController = TextEditingController();
  final _valueController = TextEditingController();
  String _type = 'نسبة';
  DateTime? _expiryDate;

  bool _isLoading = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final data = {
        'code': _codeController.text,
        'value': _type == 'شحن مجاني'
            ? 0
            : double.tryParse(_valueController.text) ?? 0,
        'type': _type == 'نسبة'
            ? 'Percentage'
            : (_type == 'مبلغ ثابت' ? 'Fixed' : 'FreeShipping'),
        'expiryDate': _expiryDate?.toIso8601String(),
        'status': 'Active',
      };

      await _apiClient.post(ApiConstants.coupons, data: data);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم إنشاء الكوبون بنجاح')));
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
        appBar: AppBar(title: const Text('إنشاء كوبون جديد')),
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
                        'تفاصيل الكوبون',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          labelText: 'كود الكوبون (مثلاً: SAVE20)',
                          prefixIcon: Icon(Icons.abc),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'يرجى إدخال الكود' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _type,
                        decoration: const InputDecoration(
                          labelText: 'نوع الخصم',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: ['نسبة', 'مبلغ ثابت', 'شحن مجاني']
                            .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _type = v!),
                      ),
                      const SizedBox(height: 16),
                      if (_type != 'شحن مجاني')
                        TextFormField(
                          controller: _valueController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: _type == 'نسبة'
                                ? 'النسبة (%)'
                                : 'المبلغ (ر.س)',
                            prefixIcon: const Icon(
                              Icons.monetization_on_outlined,
                            ),
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? 'يرجى إدخال القيمة'
                              : null,
                        ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'تاريخ الانتهاء',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        controller: TextEditingController(
                          text: _expiryDate == null
                              ? ''
                              : "${_expiryDate!.year}-${_expiryDate!.month}-${_expiryDate!.day}",
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(
                              const Duration(days: 30),
                            ),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setState(() => _expiryDate = date);
                          }
                        },
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('حفظ الكوبون'),
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
