import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _login() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog('Por favor, preencha todos os campos.');
      return;
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenLogin', true);

      // Obtendo o token FCM
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await prefs.setString('fcmToken', fcmToken);
        print('✅ FCM Token salvo: $fcmToken');
      } else {
        print('⚠️ Erro ao obter FCM Token.');
      }

      Navigator.pushReplacementNamed(context, '/terms_and_privacy_screen');
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Falha no login, tente novamente.';
      if (e.code == 'user-not-found') {
        errorMessage = 'Usuário não encontrado.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Senha incorreta.';
      }
      _showErrorDialog(errorMessage);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/icone-notificar.png',
                width: 120, height: 120),
            const SizedBox(height: 40),
            _buildTextField(controller: _emailController, hintText: 'EMAIL'),
            const SizedBox(height: 15),
            _buildTextField(
                controller: _passwordController,
                hintText: 'SENHA',
                obscureText: true),
            const SizedBox(height: 25),
            SizedBox(
              width: 260,
              height: 45,
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF303131),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: const Text(
                  'ENTRAR',
                  style: TextStyle(
                    color: Color(0xFFECC14A), // Cor do texto do botão
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Ainda não tem uma conta?',
              style: TextStyle(
                color: Color(0xFF303131),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/register'),
              child: const Text(
                'Cadastre-se aqui',
                style: TextStyle(
                  color: Color(0xFF303131),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/recuperacao_screen'),
              child: const Text(
                'Esqueceu seu email?',
                style: TextStyle(
                  color: Color(0xFF303131),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/recuperacao_screen'),
              child: const Text(
                'Recupere sua conta',
                style: TextStyle(
                  color: Color(0xFF303131),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: SizedBox(
        width: 260,
        height: 45,
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFF303131),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: const BorderSide(
                color: Color(0xFF303131), // Cor da borda normal
                width: 3.0, // Espessura inicial
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: const BorderSide(
                color: Color(0xFF303131), // Cor da borda normal
                width: 3.0, // Espessura inicial
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: const BorderSide(
                color: Color(0xFF303131), // Mantendo a mesma cor
                width: 4.0, // Aumenta a espessura ao focar
              ),
            ),
            filled: true,
            fillColor: Colors.transparent, // Caixa transparente
            contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
          ),
          style: const TextStyle(
            color: Color(0xFF303131),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
