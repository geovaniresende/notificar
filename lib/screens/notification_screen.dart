import 'package:flutter/material.dart';
import 'mycars_screen.dart';
import 'vehicle_registration_screen.dart';
import 'login_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF303131),
        automaticallyImplyLeading: false,
        title: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Image.asset(
                'assets/images/notification_icon.png',
                width: 100, // Mantendo um tamanho grande, mas sem exagero
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              left: 0, // Mantendo o botão no canto esquerdo
              child: IconButton(
                icon:
                    const Icon(Icons.menu, color: Color(0xFFECC14A), size: 30),
                onPressed: () {
                  _showMenu(context);
                },
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'O que você precisa notificar?',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VehicleRegistrationScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF303131),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 40),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/car_icon.png',
                    width: 32,
                    height: 32,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Faça sua solicitação',
                    style: TextStyle(
                      color: Color(0xFFD4A017),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF303131),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Image.asset(
                'assets/images/request_icon.png',
                width: 24,
                height: 24,
              ),
              title: const Text(
                'Solicitações',
                style: TextStyle(color: Color(0xFFD4A017)),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/quadros_screen');
              },
            ),
            ListTile(
              leading: Image.asset(
                'assets/images/car_icon.png',
                width: 24,
                height: 24,
              ),
              title: const Text(
                'Meus Carros',
                style: TextStyle(color: Color(0xFFD4A017)),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyCarsScreen()),
                );
              },
            ),
            ListTile(
              leading: Image.asset(
                'assets/images/profile_icon.png',
                width: 24,
                height: 24,
              ),
              title: const Text(
                'Editar Perfil',
                style: TextStyle(color: Color(0xFFD4A017)),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/edit_profile');
              },
            ),
            ListTile(
              leading: Image.asset(
                'assets/images/about_icon.png',
                width: 24,
                height: 24,
              ),
              title: const Text(
                'Sobre esse app',
                style: TextStyle(color: Color(0xFFD4A017)),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/sobre_screen');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.exit_to_app,
                color: Color(0xFFD4A017),
              ),
              title: const Text(
                'Sair',
                style: TextStyle(color: Color(0xFFD4A017)),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
