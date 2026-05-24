import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/loading_widget.dart';
import 'branch_detail_page.dart';

class BranchesPage extends StatefulWidget {
  const BranchesPage({super.key});

  @override
  State<BranchesPage> createState() => _BranchesPageState();
}

class _BranchesPageState extends State<BranchesPage> {
  final _apiClient = ApiClient();
  List<dynamic> _branches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await _apiClient.get(ApiConstants.branches);
      setState(() { _branches = res.data['data'] ?? []; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الفروع')),
        body: _isLoading ? const LoadingWidget() : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _branches.length,
          itemBuilder: (context, index) {
            final branch = _branches[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.store, color: AppColors.primary),
                ),
                title: Text(branch['name'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  '${branch['city'] ?? ''} • ${branch['companyName'] ?? ''}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => BranchDetailPage(
                    branchId: branch['id'],
                    branchName: branch['name'] ?? ''))),
              ),
            );
          },
        ),
      ),
    );
  }
}