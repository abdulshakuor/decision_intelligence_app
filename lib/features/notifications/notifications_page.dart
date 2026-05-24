import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/loading_widget.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _apiClient = ApiClient();
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);

    try {
      final res = await _apiClient.get(ApiConstants.notifications);
      setState(() {
        _notifications = res.data['data']['items'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(int id) async {
    try {
      await _apiClient.put('${ApiConstants.notifications}/$id/read');
      _load();
    } catch (_) {}
  }

  Future<void> _markAllAsRead() async {
    try {
      await _apiClient.put(ApiConstants.readAll);
      _load();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإشعارات'),
          actions: [
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('قراءة الكل'),
            ),
          ],
        ),
        body: _isLoading ? const LoadingWidget() :
          _notifications.isEmpty
            ? const Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('لا توجد إشعارات', style: TextStyle(color: Colors.grey)),
                ],
              ))
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notif = _notifications[index];
                    final isRead = notif['isRead'] == true;

                    return Container(
                      color: isRead ? null : AppColors.primary.withOpacity(0.03),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: isRead
                              ? Colors.grey.withOpacity(0.1)
                              : AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle),
                          child: Icon(
                            isRead ? Icons.notifications_none : Icons.notifications,
                            color: isRead ? Colors.grey : AppColors.primary),
                        ),
                        title: Text(notif['message'] ?? '',
                          style: TextStyle(
                            fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
                        subtitle: Text(_formatDate(notif['createdAt']),
                          style: const TextStyle(fontSize: 12)),
                        onTap: isRead ? null : () => _markAsRead(notif['id']),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null) return '';
    final d = DateTime.tryParse(date);
    if (d == null) return date;
    return '${d.year}/${d.month}/${d.day} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
  }
}