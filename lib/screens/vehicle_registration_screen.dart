import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notificar/screens/firebase_notification_service.dart';

class VehicleRegistrationScreen extends StatefulWidget {
  const VehicleRegistrationScreen({Key? key}) : super(key: key);

  @override
  _VehicleRegistrationScreenState createState() =>
      _VehicleRegistrationScreenState();
}

class _VehicleRegistrationScreenState extends State<VehicleRegistrationScreen> {
  final TextEditingController _plateController = TextEditingController();
  String? _selectedReason;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseNotificationService _notificationService =
      FirebaseNotificationService();

  final Map<String, String> notificationMessages = {
    'Carro preso': "Olá! Seu carro está bloqueando o meu veículo. 🚗",
    'Farol ligado': "Os faróis do seu carro estão ligados. 💡🔋",
    'Vidro aberto': "Um dos vidros do seu carro está aberto. 🚘",
    'Estacionamento irregular':
        "Seu carro está estacionado de forma irregular. 🅿",
    'Outro': "Notificação importante sobre seu veículo! 🔔",
  };

  void _sendNotification(String plate, String reason) async {
    String message =
        notificationMessages[reason] ?? "Notificação sobre seu veículo.";
    String senderId = FirebaseAuth.instance.currentUser?.uid ?? "desconhecido";

    try {
      // Criando notificação na aba "Realizadas"
      await _firestore
          .collection('sentRequests')
          .doc(senderId)
          .collection('notifications')
          .add({
        'plate': plate,
        'reason': reason,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'sentBy': senderId,
      });

      // Criando notificação na aba "Recebidas"
      await _firestore
          .collection('receivedRequests')
          .doc(plate)
          .collection('notifications')
          .add({
        'reason': reason,
        'plate': plate,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'sentBy': senderId,
      });

      // Enviar notificação push
      var userDoc = await _firestore.collection('users').doc(plate).get();
      if (userDoc.exists) {
        String? token = userDoc.data()?['fcmToken'];
        if (token != null) {
          _notificationService.sendPushNotification(
              token, "Alerta de Veículo", message);
        }
      }
    } catch (e) {
      print("Erro ao enviar notificação: $e");
    }
  }

  void _onNotifyPressed(BuildContext context) async {
    if (_plateController.text.trim().isNotEmpty && _selectedReason != null) {
      _sendNotification(_plateController.text.trim(), _selectedReason!);
      if (mounted) {
        Navigator.pushNamed(context, '/quadros_screen');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Notificação', style: TextStyle(color: Colors.amber)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.amber),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _plateController,
              decoration: InputDecoration(
                labelText: 'Placa',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
            const SizedBox(height: 20),
            _buildRadioOption('Carro preso'),
            _buildRadioOption('Farol ligado'),
            _buildRadioOption('Vidro aberto'),
            _buildRadioOption('Estacionamento irregular'),
            _buildRadioOption('Outro'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _onNotifyPressed(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('Notificar',
                  style: TextStyle(color: Colors.amber)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(String value) {
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedReason,
      onChanged: (value) {
        setState(() {
          _selectedReason = value;
        });
      },
      title: Text(value),
    );
  }
}
