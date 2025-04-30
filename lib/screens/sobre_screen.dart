import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para usar o Clipboard

class SobreScreen extends StatefulWidget {
  const SobreScreen({Key? key}) : super(key: key);

  @override
  _SobreScreenState createState() => _SobreScreenState();
}

class _SobreScreenState extends State<SobreScreen> {
  // Variáveis para controlar o número de telefone e e-mail visíveis
  String? _contactInfo;
  String? _contactLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF303131), // Cor de fundo da AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color(0xFFD4A017)), // Seta amarela
          onPressed: () {
            Navigator.pop(context); // Voltar para a tela anterior
          },
        ),
        title: const Text(
          'Sobre esse app',
          style: TextStyle(color: Color(0xFFD4A017)), // Texto amarelo
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),

            // Imagem centralizada com tamanho reduzido
            Image.asset(
              'assets/images/logo_grande.png', // Substitua pelo caminho da sua imagem
              height: 100, // Tamanho reduzido da imagem
            ),
            const SizedBox(height: 16),

            // Texto da versão
            const Text(
              'Versão 1.0.1',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Linha separadora com a cor preta
            const Divider(
              color: Colors.black,
              thickness: 1,
              indent: 40,
              endIndent: 40,
            ),
            const SizedBox(height: 16),

            // Texto "Dúvidas fale conosco"
            const Text(
              'Dúvidas? Fale conosco:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            // Botões "Telefone" e "E-mail" um em cima do outro
            _buildRoundedButton(
              context,
              label: 'Telefone',
              onPressed: () {
                setState(() {
                  _contactInfo = '61 9934-8059'; // Número de telefone
                  _contactLabel = 'Telefone';
                });
              },
            ),
            const SizedBox(height: 16),
            _buildRoundedButton(
              context,
              label: 'E-mail',
              onPressed: () {
                setState(() {
                  _contactInfo = 'easywaytecnologia@gmail.com'; // E-mail
                  _contactLabel = 'E-mail';
                });
              },
            ),
            const SizedBox(height: 20),

            // Se tiver informações de contato, exibe o número ou e-mail e o botão de copiar
            if (_contactInfo != null) ...[
              Text(
                _contactInfo ?? '', // Garante que não seja nulo
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(
                      text: _contactInfo!)); // Garantia de não nulo aqui
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Número copiado para a área de transferência!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF303131), // Cor de fundo preta
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Copiar',
                  style: TextStyle(
                    color: Color(0xFFD4A017), // Texto amarelo
                  ),
                ),
              ),
            ],

            const Spacer(),
          ],
        ),
      ),
    );
  }

  // Botão arredondado reutilizável
  Widget _buildRoundedButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF303131), // Cor de fundo preta
        minimumSize:
            const Size(double.infinity, 50), // Largura total e altura fixa
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Bordas arredondadas
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFD4A017), // Texto branco
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
