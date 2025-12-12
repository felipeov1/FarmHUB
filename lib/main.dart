import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_hub/screens/login.dart';
import 'package:farm_hub/screens/welcome.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  runApp(const MaterialApp(
    home: Login(),
    debugShowCheckedModeBanner: false,
  ));
}

