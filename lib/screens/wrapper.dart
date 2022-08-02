import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parking_detection/screens/home_screen.dart';
import 'package:parking_detection/screens/map_screen.dart';
import 'package:parking_detection/screens/sign_in_screen.dart';
import 'package:parking_detection/services/firestore_functions.dart';
import 'package:provider/provider.dart';

import '../custom_widget.dart';
import '../globals.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasData) {
            return StreamProvider<List<ParkingLoc>>.value(
                value: ParkingFirestore().parkings,
                initialData: const [],
                child: HomeScreen());
            // child: const TextScreen());
          } else if (snapshot.hasError) {
            return Center(child: TextCustom('Error Logging in'));
          } else {
            return const SignInScreen();
          }
        },
      ),
    );
  }
}
