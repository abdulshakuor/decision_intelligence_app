import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiClient = ApiClient();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _change() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _apiClient.put('${ApiConstants.baseUrl}/users/profile', data: {
        'currentPassword': _currentCtrl.text,
        'newPassword': _newCtrl.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تغيير كلمة المرور'),
            backgroundColor: AppColors.secondary));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمة المرور الحالية غير صحيحة'),
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
        appBar: AppBar(title: const Text('تغيير كلمة المرور')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(key: _formKey, child: Column(children: [
            TextFormField(
              controller: _currentCtrl, obscureText: true,
              decoration: const InputDecoration(labelText: 'كلمة المرور الحالية'),
              validator: (v) => v!.isEmpty ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newCtrl, obscureText: true,
              decoration: const InputDecoration(labelText: 'كلمة المرور الجديدة'),
              validator: (v) => v!.length < 6 ? 'لا تقل عن 6 أحرف' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmCtrl, obscureText: true,
              decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور'),
              validator: (v) => v != _newCtrl.text ? 'غير متطابقة' : null,
            ),
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _change,
                child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('تغيير كلمة المرور'),
              )),
          ])),
        ),
      ),
    );
  }
}