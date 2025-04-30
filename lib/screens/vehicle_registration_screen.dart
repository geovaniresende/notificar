import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_notification_service.dart';

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
      List<String> tokens = [];
      var usersSnapshot = await _firestore.collection('users').get();

      for (var userDoc in usersSnapshot.docs) {
        var userData = userDoc.data();
        var platesField = userData['plates'];

        if (userData['plate'] == plate) {
          if (userData['fcm_token'] != null) {
            tokens.add(userData['fcm_token']);
          }
        }

        if (platesField is List) {
          for (var plateObj in platesField) {
            if (plateObj is Map<String, dynamic> &&
                plateObj['plate'] == plate) {
              if (userData['fcm_token'] != null) {
                tokens.add(userData['fcm_token']);
              }
            }
          }
        }
      }

      if (tokens.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Placa inexistente")),
        );
        return;
      }

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

      for (var token in tokens) {
        await _notificationService.sendPushNotification(
            token, "Alerta de Veículo", message);
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Notificação', style: TextStyle(color: Colors.amber)),
        backgroundColor: Color(0xFF303131),
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
              maxLength: 7, // <-- Limite de 7 caracteres
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                counterText: '', // Esconde o contador de caracteres
                hintText: 'PLACA',
                hintStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF303131)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide:
                        const BorderSide(color: Color(0xFF303131), width: 3.0)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide:
                        const BorderSide(color: Color(0xFF303131), width: 3.0)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide:
                        const BorderSide(color: Color(0xFF303131), width: 4.0)),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
              onChanged: (value) {
                _plateController.value = _plateController.value.copyWith(
                  text: value.toUpperCase().replaceAll(' ', ''),
                  selection: TextSelection.collapsed(offset: value.length),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildRadioOption('Carro preso'),
            _buildRadioOption('Farol ligado'),
            _buildRadioOption('Vidro aberto'),
            _buildRadioOption('Estacionamento irregular'),
            _buildRadioOption('Outro'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _onNotifyPressed(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF303131),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                ),
                child: const Text('Notificar',
                    style: TextStyle(color: Colors.amber)),
              ),
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
