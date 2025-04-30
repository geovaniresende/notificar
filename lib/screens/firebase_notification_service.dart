import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

class FirebaseNotificationService {
  final String _fcmUrl =
      'https://fcm.googleapis.com/v1/projects/notificar-backend-16117/messages:send';
  late String _accessToken;

  /// Obtém um token de acesso OAuth 2.0
  Future<void> _getAccessToken() async {
    try {
      // Carrega o JSON da conta de serviço
      final jsonString = await rootBundle.loadString(
        'assets/notificar-backend-16117-firebase-adminsdk-fbsvc-4cda64d184.json',
      );

      final credentials = ServiceAccountCredentials.fromJson(jsonString);

      // Autentica e obtém o token OAuth 2.0
      final client = await clientViaServiceAccount(
        credentials,
        ['https://www.googleapis.com/auth/firebase.messaging'],
      );

      _accessToken = (await client.credentials).accessToken.data;
      print("🔑 Token de acesso gerado com sucesso!");
    } catch (e) {
      print("❌ Erro ao obter o token de acesso: $e");
      throw Exception("Falha ao autenticar no OAuth 2.0");
    }
  }

  /// Envia uma notificação via FCM
  Future<void> sendPushNotification(
      String fcmToken, String title, String message) async {
    try {
      // Obtém um novo token de acesso
      await _getAccessToken();

      final response = await http.post(
        Uri.parse(_fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({
          'message': {
            'token': fcmToken,
            'notification': {
              'title': title,
              'body': message,
            },
            'android': {
              'priority': 'high',
              'notification': {
                'sound': 'default',
                'channel_id': 'high_importance_channel',
              }
            },
            'apns': {
              'payload': {
                'aps': {
                  'sound': 'default',
                },
              },
            },
          },
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Notificação enviada com sucesso para o token: $fcmToken");
      } else {
        print("❌ Falha ao enviar notificação: ${response.body}");
      }
    } catch (e) {
      print("⚠️ Erro ao enviar notificação: $e");
    }
  }
}
