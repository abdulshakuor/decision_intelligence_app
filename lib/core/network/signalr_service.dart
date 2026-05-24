import 'package:signalr_netcore/signalr_client.dart';
import 'package:injectable/injectable.dart';
import '../utils/token_manager.dart';
import '../constants/api_constants.dart';

@singleton
class SignalRService {
  late HubConnection _hubConnection;
  Function(Map<String, dynamic>)? onNotificationReceived;

  Future<void> connect() async {
    final token = await TokenManager.getToken();

    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    _hubConnection = HubConnectionBuilder()
        .withUrl(
          '$baseUrl/hubs/notifications',
          options: HttpConnectionOptions(
            accessTokenFactory: () async => token ?? '',
          ),
        )
        .withAutomaticReconnect()
        .build();

    // الاستماع للإشعارات
    _hubConnection.on('ReceiveNotification', (args) {
      if (args != null && args.isNotEmpty) {
        final data = args[0] as Map<String, dynamic>;
        onNotificationReceived?.call(data);
      }
    });

    try {
      await _hubConnection.start();
    } catch (e) {
      // إعادة المحاولة بعد 5 ثوان
      Future.delayed(const Duration(seconds: 5), connect);
    }
  }

  Future<void> disconnect() async {
    await _hubConnection.stop();
  }
}
