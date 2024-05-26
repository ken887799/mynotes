import 'package:flutter/material.dart';
import 'package:learningdart/services/auth/auth_service.dart';
import 'package:learningdart/views/notes_view.dart';
import 'package:learningdart/views/register_view.dart';
import 'package:learningdart/views/verify_email_view.dart';
import 'constant/routes.dart';
import 'views/login_view.dart';
import 'dart:developer' as devtools show log;

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
          registerRoute: (context) => const RegisterView(),
          loginRoute: (context) => const LoginView(),
          noteRoute:(context) => const NotesView(),
          verifyEmailRoute:(context) => const VerifyEmailView(),
        },
        home: const HomePage());
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              //获取当前用户
              final user = AuthService.firebase().currentUser;
              if (user != null) {
                if (user.isEmailVerified) {
                  devtools.log('用户邮箱已完成验证');
                  return const NotesView();
                } else {
                  return const VerifyEmailView();
                }
              } else {
                devtools.log("用户是null");
                return const LoginView();
              }
            default:
              return const Center(child: CircularProgressIndicator());
          }
        });
  }
}


