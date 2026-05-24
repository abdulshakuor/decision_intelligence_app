import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/token_manager.dart';
import '../../core/widgets/loading_widget.dart';
import '../auth/login_page.dart';
import 'edit_profile_page.dart';
import 'change_password_page.dart';
import 'users_management_page.dart';
import 'company_settings_page.dart';
import 'app_preferences_page.dart';
import '../customers/customer_management_page.dart';
import '../suppliers/supplier_management_page.dart';
import '../suppliers/purchase_order_page.dart';
import '../expenses/expense_management_page.dart';
import '../finance/tax_report_page.dart';
import '../marketing/coupon_management_page.dart';
import '../chat/chat_history_page.dart';
import '../reports/cashier_performance_page.dart';
import '../inventory/inventory_log_page.dart';
import '../branches/branch_performance_page.dart';
import '../finance/financial_summary_page.dart';
import '../hr/employee_management_page.dart';
import '../help/help_center_page.dart';
import '../loyalty/points_history_page.dart';
import '../legal/terms_page.dart';
import '../inventory/warehouse_management_page.dart';
import '../sales/sales_return_page.dart';
import '../marketing/review_management_page.dart';
import '../reports/geographic_sales_page.dart';
import '../reports/heat_map_page.dart';
import '../reports/ai_forecast_page.dart';
import 'activity_log_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _apiClient = ApiClient();
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  String _role = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await _apiClient.get('${ApiConstants.baseUrl}/users/profile');
      final role = await TokenManager.getRole();
      setState(() {
        _profile = res.data['data'];
        _role = role ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الإعدادات')),
        body: _isLoading
            ? const LoadingWidget()
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // بطاقة الملف الشخصي
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Text(
                              (_profile?['fullName'] ?? 'م')[0],
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _profile?['fullName'] ?? '',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '@${_profile?['username'] ?? ''}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _profile?['role'] ?? '',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _profile?['branchName'] ?? '',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // خيارات
                  _buildOption(
                    icon: Icons.person_outline,
                    title: 'تعديل الملف الشخصي',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfilePage(profile: _profile!),
                        ),
                      );
                      _load();
                    },
                  ),
                  _buildOption(
                    icon: Icons.lock_outline,
                    title: 'تغيير كلمة المرور',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChangePasswordPage(),
                      ),
                    ),
                  ),
                  _buildOption(
                    icon: Icons.business_outlined,
                    title: 'إعدادات الشركة',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CompanySettingsPage(),
                      ),
                    ),
                  ),
                  _buildOption(
                    icon: Icons.settings_suggest_outlined,
                    title: 'تفضيلات التطبيق',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AppPreferencesPage(),
                      ),
                    ),
                  ),
                  _buildOption(
                    icon: Icons.people_outline,
                    title: 'إدارة العملاء',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CustomerManagementPage(),
                      ),
                    ),
                  ),
                  _buildOption(
                    icon: Icons.local_shipping_outlined,
                    title: 'إدارة الموردين',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SupplierManagementPage(),
                      ),
                    ),
                  ),
                  _buildOption(
                    icon: Icons.shopping_basket_outlined,
                    title: 'أوامر الشراء',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PurchaseOrderPage(),
                      ),
                    ),
                  ),
                  _buildOption(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'إدارة المصروفات',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ExpenseManagementPage(),
                      ),
                    ),
                  ),

                  _buildOption(
                    icon: Icons.confirmation_num_outlined,
                    title: 'الكوبونات والتسويق',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CouponManagementPage(),
                      ),
                    ),
                  ),
                  _buildOption(
                    icon: Icons.chat_bubble_outline,
                    title: 'سجل المحادثات الذكية',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChatHistoryPage(),
                      ),
                    ),
                  ),
                  _buildOption(
                    icon: Icons.badge_outlined,
                    title: 'أداء الموظفين',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CashierPerformancePage(),
                      ),
                    ),
                  ),
                  _buildOption(
                    icon: Icons.people_outline,
                    title: 'إدارة الموظفين والرواتب',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EmployeeManagementPage(),
                      ),
                    ),
                  ),
                  _buildOption(
                    icon: Icons.store_outlined,
                    title: 'مقارنة أداء الفروع',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BranchPerformancePage(),
                      ),
                    ),
                  ),
                  _buildOption(
                    icon: Icons.history_edu_outlined,
                    title: 'سجل حركات المخزون',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InventoryLogPage(),
                      ),
                    ),
                  ),
                  _buildOption(
                    icon: Icons.receipt_long_outlined,
                    title: 'الضرائب والتقارير المالية',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TaxReportPage()),
                    ),
                  ),
                  _buildOption(
                    icon: Icons.account_balance_outlined,
                    title: 'الملخص المالي الشامل',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FinancialSummaryPage(),
                      ),
                    ),
                  ),
                  _buildOption(
                    icon: Icons.warehouse_outlined,
                    title: 'إدارة المستودعات',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WarehouseManagementPage(),
                      ),
                    ),
                  ),
                  _buildOption(
                    icon: Icons.assignment_return_outlined,
                    title: 'مرتجع المبيعات',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SalesReturnPage(),
                      ),
                    ),
                  ),
                  _buildOption(
                    icon: Icons.stars_outlined,
                    title: 'نقاط الولاء والمكافآت',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PointsHistoryPage(),
                      ),
                    ),
                  ),
                  _buildOption(
                    icon: Icons.help_outline,
                    title: 'مركز المساعدة والدعم',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HelpCenterPage()),
                    ),
                  ),
                  _buildOption(
                    icon: Icons.map_outlined,
                    title: 'تقرير المبيعات الجغرافي',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const GeographicSalesReportPage(),
                      ),
                    ),
                  ),
                  _buildOption(
                    icon: Icons.layers_outlined,
                    title: 'الخريطة الحرارية للمبيعات',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HeatMapPage()),
                    ),
                  ),
                  _buildOption(
                    icon: Icons.auto_graph_outlined,
                    title: 'توقعات الذكاء الاصطناعي',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AIForecastPage()),
                    ),
                  ),
                  _buildOption(
                    icon: Icons.rate_review_outlined,
                    title: 'إدارة التقييمات',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReviewManagementPage(),
                      ),
                    ),
                  ),
                  _buildOption(
                    icon: Icons.list_alt_outlined,
                    title: 'سجل النشاطات',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ActivityLogPage(),
                      ),
                    ),
                  ),
                  _buildOption(
                    icon: Icons.gavel_outlined,
                    title: 'شروط الخدمة',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TermsOfServicePage(),
                      ),
                    ),
                  ),

                  // إدارة المستخدمين (Admin فقط)
                  if (_role == 'Admin') ...[
                    const Divider(height: 32),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'إدارة النظام',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildOption(
                      icon: Icons.people_outline,
                      title: 'إدارة المستخدمين',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UsersManagementPage(),
                        ),
                      ),
                    ),
                  ],

                  const Divider(height: 32),

                  // تسجيل الخروج
                  _buildOption(
                    icon: Icons.logout,
                    title: 'تسجيل الخروج',
                    color: AppColors.danger,
                    onTap: _logout,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.primary),
        title: Text(title, style: TextStyle(color: color)),
        trailing: Icon(Icons.chevron_left, color: color ?? Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
