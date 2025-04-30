import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'notification_screen.dart';

class MyCarsScreen extends StatefulWidget {
  @override
  _MyCarsScreenState createState() => _MyCarsScreenState();
}

class _MyCarsScreenState extends State<MyCarsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late Future<List<Map<String, dynamic>>> _carsFuture;

  @override
  void initState() {
    super.initState();
    _carsFuture = getUserCars();
  }

  Future<List<Map<String, dynamic>>> getUserCars() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(user.uid).get();
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        List<Map<String, dynamic>> cars = [];

        if (data.containsKey('carName') && data.containsKey('plate')) {
          cars.add({
            'carName': data['carName'],
            'plate': data['plate'],
          });
        }

        if (data.containsKey('plates') && data['plates'] is List) {
          List platesList = data['plates'];
          for (var car in platesList) {
            cars.add({
              'carName': car['carName'],
              'plate': car['plate'],
            });
          }
        }

        return cars;
      }
    }
    return [];
  }

  void addCar(String carName, String plate) async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentReference userRef = _firestore.collection('users').doc(user.uid);
      String formattedPlate = plate.toUpperCase().replaceAll(' ', '');

      DocumentSnapshot userSnapshot = await userRef.get();
      List<dynamic> existingPlates = [];

      if (userSnapshot.exists) {
        var data = userSnapshot.data() as Map<String, dynamic>;
        if (data.containsKey('plates') && data['plates'] is List) {
          existingPlates = List.from(data['plates']);
        }
      }

      existingPlates.add({
        'carName': carName,
        'plate': formattedPlate,
      });

      await userRef.update({
        'plates': existingPlates,
      });

      Fluttertoast.showToast(msg: "Carro adicionado com sucesso!");
      setState(() {
        _carsFuture = getUserCars();
      });
    }
  }

  void editCar(int index, String newCarName, String newPlate) async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentReference userRef = _firestore.collection('users').doc(user.uid);
      DocumentSnapshot userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        var data = userSnapshot.data() as Map<String, dynamic>;
        List<dynamic> existingPlates = [];

        if (data.containsKey('plates') && data['plates'] is List) {
          existingPlates = List.from(data['plates']);
        }

        if (index == 0) {
          await userRef.update({
            'carName': newCarName,
            'plate': newPlate.toUpperCase(),
          });
        } else {
          existingPlates[index - 1] = {
            'carName': newCarName,
            'plate': newPlate.toUpperCase(),
          };

          await userRef.update({
            'plates': existingPlates,
          });
        }
      }
    }

    Fluttertoast.showToast(msg: "Carro atualizado!");
    setState(() {
      _carsFuture = getUserCars();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF303131),
        title: Center(
          child: Text(
            'Meus Carros',
            style: TextStyle(color: Color(0xFFD4A017)),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFFD4A017)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Color(0xFFD4A017)),
            onPressed: () async {
              String carName = '';
              String plate = '';

              await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Adicionar Carro'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          decoration:
                              InputDecoration(labelText: 'Nome do Carro'),
                          onChanged: (value) {
                            carName = value;
                          },
                        ),
                        TextField(
                          decoration: InputDecoration(labelText: 'Placa'),
                          textCapitalization: TextCapitalization.characters,
                          onChanged: (value) {
                            plate = value.toUpperCase().replaceAll(' ', '');
                          },
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          addCar(carName, plate);
                          Navigator.pop(context);
                        },
                        child: Text('Adicionar'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _carsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhum carro encontrado.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var car = snapshot.data![index];
              String carName = car['carName'];
              String plate = car['plate'];

              return Card(
                color: Color(0xFF303131),
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: ListTile(
                  leading: Image.asset(
                    'assets/images/car_icon2.png',
                    width: 50,
                    height: 50,
                  ),
                  title: Text(
                    carName,
                    style: TextStyle(color: Color(0xFFD4A017)),
                  ),
                  subtitle: Text(
                    plate,
                    style: TextStyle(color: Color(0xFFD4A017)),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.edit, color: Color(0xFFD4A017)),
                    onPressed: () {
                      String newCarName = carName;
                      String newPlate = plate;

                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Editar Carro'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  decoration: InputDecoration(
                                      labelText: 'Nome do Carro'),
                                  controller:
                                      TextEditingController(text: carName),
                                  onChanged: (value) {
                                    newCarName = value;
                                  },
                                ),
                                TextField(
                                  decoration:
                                      InputDecoration(labelText: 'Placa'),
                                  controller:
                                      TextEditingController(text: plate),
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  onChanged: (value) {
                                    newPlate =
                                        value.toUpperCase().replaceAll(' ', '');
                                  },
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  editCar(index, newCarName, newPlate);
                                  Navigator.pop(context);
                                },
                                child: Text('Salvar'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
