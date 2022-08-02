import 'package:flutter/material.dart';
import 'package:parking_detection/globals.dart';
import 'package:parking_detection/services/google_sign_in_provider.dart';
import 'package:provider/provider.dart';

import '../custom_widget.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment(0, 0),
          end: Alignment.topRight,
          colors: [Color(0xff181822), Color(0xff4e515a)],
        )),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 100),
                TextCustom(
                  "Welcome to",
                  color: Colors.white,
                  weight: FontWeight.w200,
                  size: 40,
                ),
                SizedBox(
                  height: 30,
                ),
                Center(
                  // child: TextCustom(
                  //   "PARKED",
                  //   size: 70,
                  //   weight: FontWeight.w700,
                  //   color: Colors.white,
                  // ),
                  child: Image.asset(
                    'assets/AppName2.png',
                    scale: 2,
                  ),
                ),
                SizedBox(
                  height: 100,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 36),
                  child: ElevatedButton(
                      style:
                          TextButton.styleFrom(backgroundColor: Colors.white),
                      onPressed: () {
                        final provider = Provider.of<GoogleSignInProvider>(
                            context,
                            listen: false);
                        provider.googleLogIn();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/GoogleLogo.png",
                            scale: 12,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          TextCustom('Sign In with Google')
                        ],
                      )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
