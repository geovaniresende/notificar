import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuadrosScreen extends StatefulWidget {
  @override
  _QuadrosScreenState createState() => _QuadrosScreenState();
}

class _QuadrosScreenState extends State<QuadrosScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? userUID;
  String? userPlate;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      userUID = user.uid;
      print("Usuário autenticado: $userUID");

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userUID).get();

      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          userPlate = (userDoc.data() as Map<String, dynamic>)['plate'];
          print("Placa carregada: $userPlate");
          isLoading = false;
        });
      } else {
        print("Nenhum documento encontrado para o usuário.");
        setState(() => isLoading = false);
      }
    } else {
      print("Nenhum usuário autenticado.");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Solicitações',
              style: TextStyle(color: Color(0xFFD4A017))),
          backgroundColor: Color(0xFF303131),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Color(0xFFD4A017)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          bottom: TabBar(
            indicatorColor: Color(0xFFD4A017),
            tabs: [
              Tab(
                  child: Text('Realizadas',
                      style: TextStyle(color: Color(0xFFD4A017)))),
              Tab(
                  child: Text('Recebidas',
                      style: TextStyle(color: Color(0xFFD4A017)))),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildSentRequests(),
                  _buildReceivedRequests(),
                ],
              ),
      ),
    );
  }

  Widget _buildSentRequests() {
    if (userUID == null) {
      return const Center(child: Text("Erro ao carregar notificações."));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('sentRequests')
          .doc(userUID)
          .collection('notifications')
          .orderBy('timestamp',
              descending: true) // Ordena por data e hora (descendente)
          .snapshots(),
      builder: (context, snapshot) {
        return _buildList(snapshot, "Realizadas");
      },
    );
  }

  Widget _buildReceivedRequests() {
    if (userPlate == null) {
      return const Center(child: Text("Erro ao carregar notificações."));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('receivedRequests')
          .doc(userPlate)
          .collection('notifications')
          .orderBy('timestamp',
              descending: true) // Ordena por data e hora (descendente)
          .snapshots(),
      builder: (context, snapshot) {
        return _buildList(snapshot, "Recebidas");
      },
    );
  }

  Widget _buildList(AsyncSnapshot<QuerySnapshot> snapshot, String tipo) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return const Center(child: Text("Erro ao carregar dados."));
    }
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return Center(child: Text("Nenhuma notificação."));
    }

    return ListView(
      padding: EdgeInsets.all(10),
      children: snapshot.data!.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final Timestamp? timestamp = data['timestamp'];
        final DateTime? dateTime = timestamp?.toDate();

        return Container(
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xFF303131),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('assets/images/placa.png', data['plate']),
              SizedBox(height: 5),
              _buildInfoRow('assets/images/razao.png', data['reason']),
              SizedBox(height: 10),
              _buildTimestampRow(dateTime),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoRow(String imagePath, String? text) {
    return Row(
      children: [
        Image.asset(imagePath, width: 20, height: 20),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text ?? "Desconhecido",
            style: TextStyle(color: Color(0xFFD4A017), fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildTimestampRow(DateTime? dateTime) {
    String formattedDate = dateTime != null
        ? "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}"
        : "Data não disponível";

    return Row(
      children: [
        Image.asset('assets/images/relogio.png', width: 20, height: 20),
        SizedBox(width: 10),
        Text(
          formattedDate,
          style: TextStyle(color: Color(0xFFD4A017), fontSize: 16),
        ),
      ],
    );
  }
}
