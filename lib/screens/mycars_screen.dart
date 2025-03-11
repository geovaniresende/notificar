import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyCarsScreen extends StatefulWidget {
  const MyCarsScreen({Key? key}) : super(key: key);

  @override
  _MyCarsScreenState createState() => _MyCarsScreenState();
}

class _MyCarsScreenState extends State<MyCarsScreen> {
  String carName = "Carro 1"; // Nome fixo do carro
  String plate = "";
  bool isLoading = true;
  String errorMessage = "";

  TextEditingController plateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCarData();
  }

  Future<void> _loadCarData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          errorMessage = "Usuário não está logado.";
          isLoading = false;
        });
        return;
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          plate = userDoc['plate'] ?? "Placa não cadastrada";
          plateController.text = plate; // Carrega a placa no campo de edição
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Dados do carro não encontrados.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Erro ao carregar: $e";
        isLoading = false;
      });
    }
  }

  // Função para editar os dados
  void _editCarData() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Editar Placa"),
          content: TextField(
            controller: plateController,
            decoration: const InputDecoration(labelText: "Placa"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                await _saveCarData();
                Navigator.of(context).pop(); // Fecha o diálogo após salvar
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  // Função para salvar os dados da placa
  Future<void> _saveCarData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          errorMessage = "Usuário não está logado.";
        });
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'plate': plateController.text, // Atualiza apenas a placa
      });

      setState(() {
        plate = plateController.text;
        errorMessage = "";
      });
    } catch (e) {
      setState(() {
        errorMessage = "Erro ao salvar dados: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Meus Carros',
          style: TextStyle(color: Color(0xFFD4A017)),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color(0xFFB8860B)), // Cor amarela mostarda
          onPressed: () {
            Navigator.of(context).pop(); // Função de voltar
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child:
                      Text(errorMessage, style: TextStyle(color: Colors.red)))
              : Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      // Caixa preta com o nome do carro fixo e a placa
                      Card(
                        color: Colors.black,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(15.0),
                          leading: Image.asset(
                            'assets/images/car_icon2.png',
                            width: 40,
                            height: 40,
                          ),
                          title: Text(
                            carName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD4A017)), // Amarelo mostarda
                          ),
                          subtitle: Text(
                            plate,
                            style: const TextStyle(
                                color: Color(0xFFD4A017)), // Amarelo mostarda
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit,
                                color: Color(0xFFD4A017)), // Amarelo mostarda
                            onPressed: _editCarData, // Abre o editor de placa
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
