import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_screen.dart'; // Certifique-se de ter o arquivo 'notification_screen.dart'

class TermsAndPrivacyScreen extends StatelessWidget {
  Future<void> _markTermsSeen(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenTerms', true);

    // Navega para a tela de notificações
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => NotificationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF303131),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Color(0xFFD4A017),
          onPressed: () {
            Navigator.pop(context); // Voltar para a tela anterior
          },
        ),
        title: const Text(
          'Privacidade e Termos de Uso',
          style: TextStyle(color: Color(0xFFD4A017)),
        ),
        centerTitle: true, // Isso vai centralizar o título
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            const Text(
              '1. Aceitação dos Termos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ao acessar ou usar este serviço, você concorda com os termos e condições aqui descritos.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              '2. Uso do Serviço',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'O uso do serviço está sujeito a restrições de idade e geográficas. Você não pode utilizar o serviço se for menor de idade ou se estiver em uma jurisdição onde o serviço é ilegal.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              '3. Privacidade',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Respeitamos sua privacidade e garantimos a proteção de suas informações pessoais. Utilizamos dados de maneira responsável e de acordo com a legislação aplicável.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              '4. Responsabilidades do Usuário',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Você é responsável por manter a confidencialidade de sua conta e senha. Não deve compartilhar ou divulgar suas informações de login com terceiros.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              '5. Propriedade Intelectual',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'O conteúdo do serviço, incluindo textos, gráficos, imagens, marcas e logos, é de propriedade exclusiva do serviço e protegido por direitos autorais e outras leis de propriedade intelectual.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              '6. Modificações no Serviço',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'O serviço pode ser modificado ou descontinuado a qualquer momento, sem aviso prévio. Não seremos responsáveis por qualquer dano ou perda decorrente dessas modificações.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              '7. Limitação de Responsabilidade',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'O serviço é fornecido "como está" e não nos responsabilizamos por qualquer erro, interrupção ou dano causado pelo uso do serviço. O uso é por sua conta e risco.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              '8. Alterações nos Termos de Serviço',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Reservamo-nos o direito de alterar estes termos a qualquer momento. As alterações serão publicadas nesta página e, ao continuar utilizando o serviço, você concorda com as novas condições.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              '9. Suspensão da Conta',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Podemos suspender ou encerrar sua conta se você violar qualquer uma das condições descritas neste contrato.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              '10. Proibição de Uso Indevido',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Você não deve utilizar o serviço para fins ilegais, prejudiciais ou que infrinjam os direitos de outros usuários.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              '11. Serviços de Terceiros',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'O serviço pode incluir links ou integrações com serviços de terceiros. Não nos responsabilizamos por esses serviços ou seu conteúdo.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              '12. Garantias',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Não fornecemos garantias de que o serviço estará livre de erros ou interrupções.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              '13. Indenização',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Você concorda em nos indenizar por qualquer dano, perda ou responsabilidade resultante do uso indevido do serviço.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              '14. Acesso Internacional',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'O serviço pode ser acessado de diferentes países, mas é sua responsabilidade garantir que o uso do serviço esteja em conformidade com as leis locais.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              '15. Força Maior',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Não seremos responsáveis por falhas no serviço causadas por eventos fora de nosso controle, como desastres naturais ou falhas de sistemas.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              '16. Transferência de Direitos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Podemos transferir nossos direitos e obrigações para terceiros sem aviso prévio.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              '17. Compromisso com a Segurança',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Adotamos medidas para proteger suas informações, mas não podemos garantir 100% de segurança.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              '18. Direitos dos Consumidores',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Seus direitos como consumidor não serão afetados por esses termos, conforme as leis de proteção ao consumidor aplicáveis.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              '19. Resolução de Disputas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Qualquer disputa será resolvida de acordo com as leis do país em que o serviço está registrado.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              '20. Disposições Finais',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Estes termos representam o contrato completo entre as partes. Se qualquer cláusula for considerada inválida, as demais permanecem em vigor.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _markTermsSeen(context);
              },
              child: Text(
                'Aceitar e continuar',
                style: TextStyle(color: Color(0xFFD4A017)), // Texto amarelo
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF303131), // Cor de fundo preta
              ),
            ),
          ],
        ),
      ),
    );
  }
}
