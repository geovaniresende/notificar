import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Import necessário para FCM
import 'package:flutter/services.dart'; // Importação necessária para TextInputFormatter

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _carNameController =
      TextEditingController(); // Adicionando o controller para o nome do carro
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();
      final String name = _nameController.text.trim();
      final String phone = _phoneController.text.trim();
      final String plate = _plateController.text.trim().toUpperCase();
      final String carName =
          _carNameController.text.trim(); // Captura o nome do carro

      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        String userId = userCredential.user!.uid;

        // Salva os dados do usuário no Firestore
        await _firestore.collection('users').doc(userId).set({
          'name': name,
          'email': email,
          'phone': phone,
          'plate': plate,
          'carName': carName, // Salvando o nome do carro
          'createdAt': Timestamp.now(),
        });

        // Obtém o token FCM e salva no Firestore
        await _saveFCMToken(userId);

        // Navega para a tela de login
        Navigator.pushReplacementNamed(context, '/login');
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao conectar com o servidor.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao conectar com o servidor.')),
        );
      }
    }
  }

  // Método para salvar o FCM token no Firestore
  Future<void> _saveFCMToken(String userId) async {
    String? token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      await _firestore.collection('users').doc(userId).update({
        'fcm_token': token,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF303131),
        title: const Text(
          'Cadastro',
          style: TextStyle(color: Color(0xFFECC14A)),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFFECC14A),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Bem-vindo ao Notifi-car,\npreencha os campos abaixo para criar a sua conta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF303131),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _buildRoundedTextField(
                    hint: 'NOME',
                    controller: _nameController,
                    textInputType: TextInputType.text,
                  ),
                  const SizedBox(height: 16),
                  _buildRoundedTextField(
                    hint: 'EMAIL',
                    controller: _emailController,
                    textInputType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildRoundedTextField(
                    hint: 'CELULAR',
                    controller: _phoneController,
                    textInputType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildRoundedTextField(
                    hint: 'PLACA',
                    controller: _plateController,
                    inputFormatters: [UpperCaseTextInputFormatter()],
                  ),
                  const SizedBox(height: 16),
                  _buildRoundedTextField(
                    hint: 'NOME DO CARRO', // Novo campo adicionado
                    controller: _carNameController, // Novo controller
                    textInputType: TextInputType.text,
                  ),
                  const SizedBox(height: 16),
                  _buildRoundedTextField(
                    hint: 'SENHA',
                    controller: _passwordController,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  _buildRoundedTextField(
                    hint: 'CONFIRME SUA SENHA',
                    controller: _confirmPasswordController,
                    obscureText: true,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double
                        .infinity, // Faz o botão ocupar toda a largura disponível
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF303131),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                      ),
                      child: const Text(
                        'CADASTRAR',
                        style: TextStyle(
                          color: Color(0xFFECC14A),
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedTextField({
    required String hint,
    required TextEditingController controller,
    TextInputType textInputType = TextInputType.text,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return SizedBox(
      width: double.infinity, // Garante que os campos tenham largura total
      child: TextFormField(
        controller: controller,
        keyboardType: textInputType,
        obscureText: obscureText,
        inputFormatters: inputFormatters,
        textAlign: TextAlign.center, // Centraliza o texto dentro do campo
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.transparent,
          hintText: hint,
          hintStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF303131),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(
              color: Color(0xFF303131),
              width: 3.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(
              color: Color(0xFF303131),
              width: 3.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(
              color: Color(0xFF303131),
              width: 4.0,
            ),
          ),
        ),
      ),
    );
  }
}

// TextInputFormatter para converter texto para maiúsculas e remover espaços
class UpperCaseTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove espaços e converte para maiúsculas
    String newText = newValue.text.replaceAll(' ', '').toUpperCase();

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
