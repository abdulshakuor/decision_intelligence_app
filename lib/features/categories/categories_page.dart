import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/loading_widget.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final _apiClient = ApiClient();
  List<dynamic> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.get(ApiConstants.categories);
      setState(() { _categories = res.data['data'] ?? []; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showAddEditDialog({Map<String, dynamic>? category}) {
    final nameCtrl = TextEditingController(text: category?['name'] ?? '');
    final descCtrl = TextEditingController(text: category?['description'] ?? '');
    final isEdit = category != null;

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(isEdit ? 'تعديل التصنيف' : 'إضافة تصنيف',
                style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'اسم التصنيف *')),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'الوصف'),
                maxLines: 2),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('إلغاء'),
                )),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) return;
                    Navigator.pop(ctx);
                    try {
                      if (isEdit) {
                        await _apiClient.put(
                          '${ApiConstants.categories}/${category!['id']}',
                          data: {
                            'name': nameCtrl.text.trim(),
                            'description': descCtrl.text.trim(),
                          });
                      } else {
                        await _apiClient.post(ApiConstants.categories,
                          data: {
                            'name': nameCtrl.text.trim(),
                            'description': descCtrl.text.trim(),
                          });
                      }
                      _load();
                    } catch (_) {}
                  },
                  child: Text(isEdit ? 'تحديث' : 'إضافة'),
                )),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(int id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.warning_amber, color: AppColors.danger, size: 48),
              const SizedBox(height: 12),
              Text('حذف التصنيف "$name"؟',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('لا يمكن حذف تصنيف يحتوي على منتجات',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('إلغاء'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    try {
                      await _apiClient.delete('${ApiConstants.categories}/$id');
                      _load();
                    } catch (_) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('لا يمكن حذف تصنيف يحتوي على منتجات'),
                          backgroundColor: AppColors.danger));
                      }
                    }
                  },
                  child: const Text('حذف'),
                )),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('التصنيفات (${_categories.length})')),
        body: _isLoading ? const LoadingWidget() : RefreshIndicator(
          onRefresh: _load,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.category,
                      color: AppColors.primary),
                  ),
                  title: Text(cat['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(cat['description'] ?? 'بدون وصف',
                    style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12)),
                      child: Text('${cat['productsCount'] ?? 0} منتج',
                        style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold,
                          color: AppColors.secondary)),
                    ),
                    PopupMenuButton(
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('تعديل')),
                        const PopupMenuItem(value: 'delete',
                          child: Text('حذف', style: TextStyle(color: AppColors.danger))),
                      ],
                      onSelected: (v) {
                        if (v == 'edit') _showAddEditDialog(category: cat);
                        if (v == 'delete') _showDeleteDialog(cat['id'], cat['name']);
                      },
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddEditDialog(),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}