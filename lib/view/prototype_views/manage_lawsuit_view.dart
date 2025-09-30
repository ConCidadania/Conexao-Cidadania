import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:con_cidadania/controller/lawsuit_controller.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ManageLawsuitView extends StatefulWidget {
  const ManageLawsuitView({super.key});

  @override
  State<ManageLawsuitView> createState() => _ManageLawsuitViewState();
}

class _ManageLawsuitViewState extends State<ManageLawsuitView> {
  final ctrl = GetIt.I.get<LawsuitController>();
  final Color primaryColor = Color(0xFF00796B);
  final Color accentColor = Color(0xFFB2DFDB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*
       *  AppBar
       */
      appBar: AppBar(
        title: Text("Gerenciar Ação", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      /*
       *  Body
       */
      body: Padding(
          padding: EdgeInsets.fromLTRB(30, 50, 30, 30),
          child: FutureBuilder<DocumentSnapshot>(
            future: ctrl.getCurrentLawsuit(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text("Erro ${snapshot.error}");
              } else {
                DocumentSnapshot currLawsuit =
                    snapshot.data as DocumentSnapshot;

                String name = currLawsuit['name'];
                String createdAt = currLawsuit['createdAt'];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyle(fontSize: 20)),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text("Aberto em: ",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(createdAt, style: TextStyle(fontSize: 20)),
                    SizedBox(
                      height: 10.0,
                    ),
                  ],
                );
              }
            },
          )),
    );
  }
}
