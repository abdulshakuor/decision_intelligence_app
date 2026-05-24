import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/loading_widget.dart';
import 'add_user_page.dart';

class UsersManagementPage extends StatefulWidget {
  const UsersManagementPage({super.key});

  @override
  State<UsersManagementPage> createState() => _UsersManagementPageState();
}

class _UsersManagementPageState extends State<UsersManagementPage> {
  final _apiClient = ApiClient();
  List<dynamic> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await _apiClient.get(ApiConstants.users);
      setState(() {
        _users = res.data['data']['items'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _changeRole(int userId, String currentRole) async {
    final roles = ['Admin', 'Manager', 'Viewer'];

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'تغيير الدور',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...roles.map(
              (role) => ListTile(
                leading: Icon(
                  role == currentRole
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color: role == currentRole ? AppColors.primary : Colors.grey,
                ),
                title: Text(_roleArabic(role)),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    await _apiClient.put(
                      '${ApiConstants.baseUrl}/users/$userId/role',
                      data: {'role': role},
                    );
                    _load();
                  } catch (_) {}
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteUser(int userId, String name) async {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل تريد حذف المستخدم "$name"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await _apiClient.delete(
                    '${ApiConstants.baseUrl}/users/$userId',
                  );
                  _load();
                } catch (_) {}
              },
              child: const Text(
                'حذف',
                style: TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _roleArabic(String role) {
    switch (role) {
      case 'Admin':
        return 'مدير النظام';
      case 'Manager':
        return 'مشرف';
      default:
        return 'مشاهد';
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'Admin':
        return AppColors.danger;
      case 'Manager':
        return AppColors.primary;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('إدارة المستخدمين (${_users.length})')),
        body: _isLoading
            ? const LoadingWidget()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  final role = user['role'] ?? 'Viewer';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        backgroundColor: _roleColor(role).withOpacity(0.1),
                        child: Text(
                          (user['fullName'] ?? user['username'] ?? '?')[0]
                              .toUpperCase(),
                          style: TextStyle(
                            color: _roleColor(role),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        user['fullName'] ?? user['username'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '@${user['username']} • ${user['email']}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _roleColor(role).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _roleArabic(role),
                                  style: TextStyle(
                                    color: _roleColor(role),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                user['branchName'] ?? '',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'role',
                            child: Text('تغيير الدور'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'حذف',
                              style: TextStyle(color: AppColors.danger),
                            ),
                          ),
                        ],
                        onSelected: (v) {
                          if (v == 'role') _changeRole(user['id'], role);
                          if (v == 'delete') {
                            _deleteUser(user['id'], user['fullName'] ?? '');
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddUserPage()),
            );
            if (result == true) _load();
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
