import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:learningdart/register_view.dart';
import 'package:learningdart/verify_email_view.dart';

import 'firebase_options.dart';
import 'login_view.dart';
import 'dart:developer' as devtools show log;

void main() {
  //确保binding实例在使用前被正确初始化,因为有些实例是Future类型,不会进行同步加载
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

enum MenuAction { logout }

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
          '/registerView/': (context) => const RegisterView(),
          '/loginView/': (context) => const LoginView()
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
                if (user.emailVerified) {
                  print('用户邮箱已完成验证');
                  return const NotesView();
                } else {
                  return const VerifyEmailView();
                }
              } else {
                print("用户是null");
                return const LoginView();
              }
            default:
              return const Center(child: CircularProgressIndicator());
          }
        });
  }
}

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main UI'),
        actions: <Widget>[
          //用material3的情况下使用menuAnchor，低版本可以使用popupmenubutton
          // MenuAnchor(
          //   builder:(BuildContext context, MenuController controller, Widget? child){
          //     return IconButton(onPressed: (){
          //       if(controller.isOpen){
          //         controller.close();
          //       }else{
          //         controller.open();
          //       }
          //     },
          //         icon: const Icon(Icons.more_vert)
          //         ,tooltip: 'show menu');
          //   },
          //   menuChildren:  <MenuItemButton>[
          //     MenuItemButton(
          //       onPressed: (){
          //
          //       },
          //         child:const Text('log out'))
          //   ],
          // )
          PopupMenuButton<MenuAction>(
              //onSelected是typedef,其参数类型是T value，返回值是void
              //typedef PopupMenuItemSelected<T> = void Function(T value);
              //表示选择具体的选项后应该有什么表现
              onSelected: (itemValue) async {
                switch (itemValue) {
                  case MenuAction.logout:
                    final bool shouldLogout = await logoutDialog(context);
                    if (shouldLogout) {
                      if (!context.mounted) return;
                      //DON'T use BuildContext across asynchronous gaps.
                      //在异步处理中存储 BuildContext 并在稍后使用它可能导致难以诊断的崩溃。
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/loginView/', (route) => false);
                    }
                }
              },
              //itemBuilder是typedef，其类型是参数为(BuildContext context)
              //返回值是List<PopupMenuEntry<T>>
              //typedef PopupMenuItemBuilder<T> = List<PopupMenuEntry<T>> Function(BuildContext context);
              //创建具体的下拉选项
              itemBuilder: (BuildContext context) =>
                  const <PopupMenuEntry<MenuAction>>[
                    PopupMenuItem(
                      //value是与onSelected的参数绑定的
                      value: MenuAction.logout,
                      //child中的Text内容是展示给用户的
                      child: Text('退出登录'),
                    ),
                  ])
        ],
      ),
    );
  }
}

Future<bool> logoutDialog(BuildContext context) {
  //showDialog函数返回Future<T?>类型，T可为null
  return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('退出登录'),
          content: const Text('是否退出登录'),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  //pop方法的参数为可选，在dialog中可以返回true或false表示选择结果
                  Navigator.of(context).pop(true);
                },
                child: const Text('退出')),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('取消'))
          ],
        );
        //logoutDialog函数的返回值为Future<bool>，showDialog函数返回Future<T?>
        //当T为null的时候需要将赋值为bool的结果，使用then函数，其中参数value为返回值
      }).then((value) => value ?? false);
}
