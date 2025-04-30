import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/vehicle_registration_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/sobre_screen.dart';
import 'screens/quadros_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/mycars_screen.dart';
import 'screens/terms_and_privacy_screen.dart';
import 'screens/recuperacao_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Solicitar permissão para notificações (Android 13+)
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission();
  print('Permissão concedida: ${settings.authorizationStatus}');

  // Obter o token FCM e salvar se autenticado
  String? token = await messaging.getToken();
  print("Token FCM: $token");

  // Salvar token FCM apenas se o usuário estiver autenticado
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null && token != null) {
    await _checkAndSaveToken(user.uid, token);
  }

  // Configurar notificações locais
  var initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  );
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Configurar notificações em primeiro plano
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print(
        'Mensagem recebida em primeiro plano: ${message.notification?.title}');
    print('Mensagem recebida em primeiro plano: ${message.notification?.body}');
    _showNotification(flutterLocalNotificationsPlugin, message);
  });

  // Configurar notificações em segundo plano
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp(
    initialRoute: '',
  ));
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Mensagem recebida em segundo plano: ${message.notification?.title}');
  print('Mensagem recebida em segundo plano: ${message.notification?.body}');
}

void _showNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    RemoteMessage message) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'channel_id',
    'channel_name',
    importance: Importance.high,
    priority: Priority.high,
  );

  const NotificationDetails platformDetails = NotificationDetails(
    android: androidDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    message.notification?.title ?? '',
    message.notification?.body ?? '',
    platformDetails,
  );
}

// Função para verificar e salvar o token FCM no Firestore
Future<void> _checkAndSaveToken(String userId, String token) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentReference tokenRef = firestore.collection('users').doc(userId);

  DocumentSnapshot doc = await tokenRef.get();
  if (doc.exists) {
    print('Token já existe no Firestore, não será substituído.');
  } else {
    await tokenRef.set({
      'fcm_token': token,
      'createdAt': FieldValue.serverTimestamp(),
    });
    print('Token FCM salvo com sucesso no Firestore.');
  }
}

// 🌟 AuthWrapper gerencia a tela inicial baseada no login
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const NotificationScreen(); // Usuário autenticado
        }
        return LoginScreen(); // Usuário não autenticado
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required String initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notificar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF3C343),
      ),
      home: const AuthWrapper(), // 🔥 Definição automática da tela inicial
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/vehicle': (context) => const VehicleRegistrationScreen(),
        '/notification': (context) => const NotificationScreen(),
        '/sobre_screen': (context) => const SobreScreen(),
        '/quadros_screen': (context) => QuadrosScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/mycars_screen': (context) => MyCarsScreen(),
        '/terms_and_privacy_screen': (context) => TermsAndPrivacyScreen(),
        '/recuperacao_screen': (context) => const RecuperacaoScreen(),
      },
    );
  }
}
