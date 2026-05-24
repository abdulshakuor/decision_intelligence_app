import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/loading_widget.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  final _apiClient = ApiClient();
  List<dynamic> _insights = [];
  bool _isLoading = true;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);

    try {
      final params = <String, dynamic>{'limit': 50};
      if (_filter != 'all') {
        params['severity'] = {'critical': 3, 'warning': 2, 'opportunity': 4, 'info': 1}[_filter];
      }

      final res = await _apiClient.get(ApiConstants.insights, queryParams: params);
      setState(() { _insights = res.data['data'] ?? []; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Color _severityColor(int level) {
    switch (level) {
      case 3: return AppColors.critical;
      case 2: return AppColors.warning;
      case 4: return AppColors.opportunity;
      default: return AppColors.info;
    }
  }

  IconData _severityIcon(int level) {
    switch (level) {
      case 3: return Icons.error;
      case 2: return Icons.warning;
      case 4: return Icons.trending_up;
      default: return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(children: [
        // فلاتر
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            for (final f in [
              {'key': 'all', 'label': 'الكل'},
              {'key': 'critical', 'label': 'حرج'},
              {'key': 'warning', 'label': 'تحذير'},
              {'key': 'opportunity', 'label': 'فرصة'},
              {'key': 'info', 'label': 'معلومة'},
            ]) ...[
              FilterChip(
                label: Text(f['label']!),
                selected: _filter == f['key'],
                onSelected: (_) { setState(() => _filter = f['key']!); _load(); },
              ),
              const SizedBox(width: 8),
            ],
          ]),
        ),

        // القائمة
        Expanded(
          child: _isLoading ? const LoadingWidget() :
            _insights.isEmpty ? const Center(child: Text('لا توجد رؤى')) :
            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _insights.length,
              itemBuilder: (context, index) {
                final insight = _insights[index];
                final level = insight['severityLevel'] ?? 1;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _severityColor(level).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10)),
                          child: Icon(_severityIcon(level),
                            color: _severityColor(level), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _severityColor(level).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20)),
                          child: Text(insight['severity'] ?? '',
                            style: TextStyle(
                              color: _severityColor(level),
                              fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        const Spacer(),
                        if (insight['isActionTaken'] == true)
                          const Icon(Icons.check_circle, color: AppColors.secondary, size: 20),
                      ]),
                      const SizedBox(height: 12),
                      Text(insight['insightText'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      if (insight['explanation'] != null) ...[
                        const SizedBox(height: 8),
                        Text(insight['explanation'],
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      ],
                    ]),
                  ),
                );
              },
            ),
        ),
      ]),
    );
  }
}