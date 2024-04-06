import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:learningdart/register_view.dart';
import 'package:learningdart/verify_email_view.dart';

import 'firebase_options.dart';
import 'login_view.dart';

void main() {
  //确保binding实例在使用前被正确初始化,因为有些实例是Future类型,不会进行同步加载
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: false,
        ),
        routes: {
          '/registerView/':(context) => const RegisterView(),
          '/loginView/':(context) => const LoginView()
        },
        home: const HomePage());
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
            //获取当前用户
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                if(user.emailVerified){
                  print('用户邮箱已完成验证');
                  return const LoginView();
                }else{
                  return const VerifyEmailView();
                }
              }else{
                print("用户是null");
              return const LoginView();
              }
            default:
              return const Center(
                child: CircularProgressIndicator()
              );
          }
        });
  }
}




