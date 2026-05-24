import 'package:flutter/foundation.dart';

class ApiConstants {
  // ====== Railway Production URL ======
  static const String _productionUrl =
      'https://decisionintelligence-api-production.up.railway.app/api';

  // للتطوير المحلي غيّر هذا لـ true
  static const bool _useLocalServer = false;

  static String get baseUrl {
    if (_useLocalServer) {
      if (kIsWeb) {
        return 'http://localhost:5005/api';
      }
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'http://172.16.110.190:5005/api';
      }
      return 'http://localhost:5005/api';
    }

    return _productionUrl;
  }

  // Auth
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get forgotPassword => '$baseUrl/auth/forgot-password';
  static String get resetPassword => '$baseUrl/auth/reset-password';
  static String get googleLogin => '$baseUrl/auth/google-login';

  // Dashboard
  static String get kpiSummary => '$baseUrl/dashboard/kpi-summary';

  // Products
  static String get products => '$baseUrl/Products';
  static String productById(int id) => '$baseUrl/Products/$id';
  static String get topSelling => '$baseUrl/Products/top-selling';

  // Sales
  static String get sales => '$baseUrl/Sales';
  static String saleById(int id) => '$baseUrl/Sales/$id';

  // Inventory
  static String get inventory => '$baseUrl/inventory';
  static String get inventoryUpdate => '$baseUrl/inventory/update';

  // Insights
  static String get insights => '$baseUrl/insights';
  static String get insightStats => '$baseUrl/insights/stats';

  // Notifications
  static String get notifications => '$baseUrl/notifications';
  static String get unreadCount => '$baseUrl/notifications/unread-count';
  static String get readAll => '$baseUrl/notifications/read-all';

  // Categories
  static String get categories => '$baseUrl/categories';

  // Branches
  static String get branches => '$baseUrl/branches';

  // Data Import
  static String get importProducts => '$baseUrl/data/import/products';
  static String get importInventory => '$baseUrl/data/import/inventory';

  // Users
  static String get users => '$baseUrl/users';

  // New Management Endpoints
  static String get customers => '$baseUrl/customers';
  static String get expenses => '$baseUrl/expenses';
  static String get coupons => '$baseUrl/coupons';
  static String get purchaseOrders => '$baseUrl/purchaseorders';
  static String get suppliers => '$baseUrl/suppliers';
  static String get salesReturns => '$baseUrl/salesreturns';
  static String get purchaseReturns => '$baseUrl/purchasereturns';

  // AI
  static String get askAi => '$baseUrl/Ai/ask';
}
