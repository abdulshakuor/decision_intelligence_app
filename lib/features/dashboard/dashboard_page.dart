import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/token_manager.dart';
import '../../core/network/signalr_service.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';
import '../products/products_page.dart';
import '../inventory/inventory_page.dart';
import '../sales/sales_page.dart';
import '../insights/insights_page.dart';
import '../notifications/notifications_page.dart';
import '../ai/ai_chat_page.dart';
import '../auth/login_page.dart';
import 'widgets/kpi_card.dart';
import '../settings/settings_page.dart';
import '../reports/reports_page.dart';
import '../data_import/data_import_page.dart';
import '../suppliers/purchase_order_page.dart';
import '../suppliers/supplier_management_page.dart';
import '../suppliers/purchase_return_page.dart';
import 'kpi_detail_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _apiClient = ApiClient();
  int _currentIndex = 0;
  Map<String, dynamic>? _kpiData;
  bool _isLoading = true;
  String? _error;
  String _username = '';
  int _unreadNotifications = 0;

  final List<Widget> _pages = [];

  final _signalR = SignalRService();
  // في initState
  @override
  void initState() {
    super.initState();
    _loadData();
    _connectSignalR();
  }

  Future<void> _connectSignalR() async {
    _signalR.onNotificationReceived = (data) {
      // تحديث عداد الإشعارات
      setState(() => _unreadNotifications++);

      // عرض SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'إشعار جديد'),
            action: SnackBarAction(
              label: 'عرض',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              ),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    };

    await _signalR.connect();
  }

  // في dispose
  @override
  void dispose() {
    _signalR.disconnect();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _apiClient.get(ApiConstants.kpiSummary),
        _apiClient.get(ApiConstants.unreadCount),
        TokenManager.getUsername(),
      ]);

      if (!mounted) return;
      setState(() {
        _kpiData = (results[0] as Response).data['data'];
        _unreadNotifications = (results[1] as Response).data['data'] ?? 0;
        _username = results[2] as String? ?? 'مستخدم';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'خطأ في تحميل البيانات';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await TokenManager.clearToken();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    final pages = [
      _buildDashboardContent(),
      const ProductsPage(),
      const InventoryPage(),
      const SalesPage(),
      const PurchaseOrderPage(),
      const SupplierManagementPage(),
      const PurchaseReturnPage(),
      const InsightsPage(),
    ];

    final List<_NavigationItem> navigationItems = [
      const _NavigationItem(
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
        label: 'الرئيسية',
      ),
      const _NavigationItem(
        icon: Icons.inventory_2_outlined,
        selectedIcon: Icons.inventory_2,
        label: 'المنتجات',
      ),
      const _NavigationItem(
        icon: Icons.warehouse_outlined,
        selectedIcon: Icons.warehouse,
        label: 'المخزون',
      ),
      const _NavigationItem(
        icon: Icons.receipt_long_outlined,
        selectedIcon: Icons.receipt_long,
        label: 'المبيعات',
      ),
      const _NavigationItem(
        icon: Icons.shopping_basket_outlined,
        selectedIcon: Icons.shopping_basket,
        label: 'المشتريات',
      ),
      const _NavigationItem(
        icon: Icons.business_outlined,
        selectedIcon: Icons.business,
        label: 'الموردون',
      ),
      const _NavigationItem(
        icon: Icons.assignment_return_outlined,
        selectedIcon: Icons.assignment_return,
        label: 'مرتجع المشتريات',
      ),
      const _NavigationItem(
        icon: Icons.lightbulb_outlined,
        selectedIcon: Icons.lightbulb,
        label: 'الرؤى',
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _currentIndex == 0
                ? 'مرحباً، $_username'
                : [
                    '',
                    'المنتجات',
                    'المخزون',
                    'المبيعات',
                    'المشتريات',
                    'الموردون',
                    'مرتجع المشتريات',
                    'الرؤى',
                  ][_currentIndex],
          ),
          leading: isDesktop
              ? const Icon(Icons.insights, color: AppColors.primary)
              : null,
          actions: [
            IconButton(
              icon: const Icon(Icons.chat_outlined),
              tooltip: 'الدردشة الذكية',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AiChatPage()),
              ),
            ),
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsPage(),
                    ),
                  ),
                ),
                if (_unreadNotifications > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$_unreadNotifications',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.assessment_outlined),
              tooltip: 'التقارير',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportsPage()),
              ),
            ),
            if (isDesktop)
              IconButton(
                icon: const Icon(Icons.cloud_upload_outlined),
                tooltip: 'استيراد البيانات',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DataImportPage()),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'الإعدادات',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'تسجيل الخروج',
              onPressed: _logout,
            ),
          ],
        ),
        body: Row(
          children: [
            if (isDesktop)
              NavigationRail(
                selectedIndex: _currentIndex,
                onDestinationSelected: (i) => setState(() => _currentIndex = i),
                labelType: NavigationRailLabelType.all,
                backgroundColor: Theme.of(context).cardColor,
                destinations: navigationItems
                    .map(
                      (item) => NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon),
                        label: Text(item.label),
                      ),
                    )
                    .toList(),
              ),
            if (isDesktop) const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: pages[_currentIndex]),
          ],
        ),
        bottomNavigationBar: isDesktop
            ? null
            : NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: (i) => setState(() => _currentIndex = i),
                destinations: navigationItems
                    .map(
                      (item) => NavigationDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon),
                        label: item.label,
                      ),
                    )
                    .toList(),
              ),
      ),
    );
  }

  // --- Helper Methods ---

  Widget _buildDashboardContent() {
    if (_isLoading)
      return const LoadingWidget(message: 'جاري تحميل البيانات...');
    if (_error != null)
      return AppErrorWidget(message: _error!, onRetry: _loadData);

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // بطاقات KPI
          _buildKpiCards(),
          const SizedBox(height: 24),

          // مخطط المبيعات
          _buildSalesChart(),
          const SizedBox(height: 24),

          // المنتجات الأكثر مبيعاً
          _buildTopProducts(),
        ],
      ),
    );
  }

  Widget _buildKpiCards() {
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _clickableKpi(
          title: 'مبيعات اليوم',
          value: '${_kpiData?['todaySales']?.toStringAsFixed(0) ?? 0} ر.س',
          icon: Icons.trending_up,
          color: AppColors.primary,
        ),
        _clickableKpi(
          title: 'عدد الفواتير',
          value: '${_kpiData?['todayInvoicesCount'] ?? 0}',
          icon: Icons.receipt_long,
          color: AppColors.secondary,
        ),
        _clickableKpi(
          title: 'متوسط الفاتورة',
          value: '${_kpiData?['avgInvoiceValue']?.toStringAsFixed(0) ?? 0} ر.س',
          icon: Icons.analytics,
          color: AppColors.accent,
        ),
        _clickableKpi(
          title: 'مخزون حرج',
          value: '${_kpiData?['criticalStockProducts'] ?? 0}',
          icon: Icons.warning_amber,
          color: AppColors.danger,
        ),
      ],
    );
  }

  Widget _clickableKpi({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => KPIDetailPage(
            title: title,
            value: value,
            icon: icon,
            color: color,
          ),
        ),
      ),
      child: KpiCard(title: title, value: value, icon: icon, color: color),
    );
  }

  Widget _buildSalesChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المبيعات الشهرية',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${_kpiData?['monthlySales']?.toStringAsFixed(0) ?? 0} ر.س',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (_kpiData?['monthlyGrowthPercentage'] ?? 0) >= 0
                        ? AppColors.secondary.withOpacity(0.1)
                        : AppColors.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(_kpiData?['monthlyGrowthPercentage'] ?? 0) >= 0 ? '+' : ''}${_kpiData?['monthlyGrowthPercentage'] ?? 0}%',
                    style: TextStyle(
                      color: (_kpiData?['monthlyGrowthPercentage'] ?? 0) >= 0
                          ? AppColors.secondary
                          : AppColors.danger,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 3),
                        FlSpot(1, 4),
                        FlSpot(2, 3.5),
                        FlSpot(3, 5),
                        FlSpot(4, 4),
                        FlSpot(5, 6),
                        FlSpot(6, 5.5),
                      ],
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProducts() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المنتجات الأكثر مبيعاً',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // هنا نجلب البيانات من API — مثال بسيط
            ...List.generate(
              5,
              (i) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(color: AppColors.primary),
                  ),
                ),
                title: Text('منتج ${i + 1}'),
                trailing: Text(
                  '${(100 - i * 15)} وحدة',
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
