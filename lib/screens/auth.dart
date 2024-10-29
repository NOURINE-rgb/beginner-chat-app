import 'package:chat_app/widgets/user_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  String? emailAddress;
  String? password;
  File? selectedImage;
  String? userName;
  bool isAuthenticating = false;
  final key = GlobalKey<FormState>();

  void submit() async {
    if (!key.currentState!.validate()) {
      return;
    }
    if (selectedImage == null && !isLogin) {
      // show an error message
      return;
    }
    key.currentState!.save();
    try {
      setState(() {
        isAuthenticating = true;
      });
      if (isLogin) {
        final userInfo = await _firebase.signInWithEmailAndPassword(
            email: emailAddress!, password: password!);
        print(userInfo);
      } else {
        final user = await _firebase.createUserWithEmailAndPassword(
            email: emailAddress!, password: password!);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${user.user!.uid}.jpg');
        await storageRef.putFile(selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();
        print('$imageUrl ***********************');
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.user!.uid)
            .set({
          'username': userName,
          'email': emailAddress,
          'imageUrl': imageUrl,
          'fcmToken' : 'to be done ....',
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // ....;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? " Authentication failed"),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      setState(() {
        isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                    top: 30, bottom: 20, right: 20, left: 20),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: key,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isLogin)
                            UserImage(onPeak: (pickedImage) {
                              selectedImage = pickedImage;
                            }),
                          if(!isLogin)
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'User name'),
                            enableSuggestions: false,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().length < 4) {
                                return "Please enter a at least 4 characters";
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              userName = newValue;
                            },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Email Address'),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains("@")) {
                                return "Error , Please enter a valid email";
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              emailAddress = newValue;
                            },
                          ),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Password'),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return "Please enter a strong password";
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              password = newValue;
                            },
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          if (isAuthenticating)
                            const CircularProgressIndicator(),
                          if (!isAuthenticating)
                            ElevatedButton(
                              onPressed: submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              child: Text(isLogin ? "Login" : "Sign up"),
                            ),
                          if (!isAuthenticating)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isLogin = !isLogin;
                                });
                              },
                              child: Text(
                                isLogin
                                    ? "create an account"
                                    : "I already have an account",
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
