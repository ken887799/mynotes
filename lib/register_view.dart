import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:learningdart/utilities/show_error_dialog.dart';
import 'dart:developer' as devtools show log;

import 'constant/routes.dart';

//因为textfield会在点击按钮后被获取,页面有变动,所以是可变状态控件
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  //用late修饰的final属性不需要赋初值,也不需要在构造器内赋初值
  late final TextEditingController _email;
  late final TextEditingController _pwd;

  @override
  void initState() {
    //The framework will call this method exactly once for each State object it creates.
    //在_RegisterViewState对象创建时执行
    //在创建控件的时候初始化文本编辑控制器
    _email = TextEditingController();
    _pwd = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    //在控件结束声明周期时销毁文本编辑控制器
    _email.dispose();
    _pwd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('注册'),
      ),
      body: Column(
        children: [
          TextField(
              //绑定相应的文本控制器
              controller: _email,
              enableSuggestions: true,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: '邮箱地址')),
          TextField(
              //绑定相应的文本控制器
              controller: _pwd,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(hintText: '密码')),
          TextButton(
              onPressed: () async {
                //通过绑定点击按钮来实现文本获取
                final email = _email.text;
                final pwd = _pwd.text;
                try {
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: email, password: pwd);
                  // 验证邮箱
                  final user = FirebaseAuth.instance.currentUser;
                  await user?.sendEmailVerification();
                  //迁移到邮箱验证界面
                  if (!context.mounted) return;
                  Navigator.of(context).pushNamed(verifyEmailRoute);
                } on FirebaseAuthException catch (e) {
                  switch (e.code) {
                    case 'weak-password':
                      devtools.log('error:${e.code}');
                      if (!context.mounted) return;
                      await errorDialog(context, '密码过于简单');
                    case 'email-already-in-use':
                      devtools.log('error:${e.code}');
                      if (!context.mounted) return;
                      await errorDialog(context, '此邮箱已被使用');
                    case 'invalid-email':
                      devtools.log('error:${e.code}');
                      if (!context.mounted) return;
                      await errorDialog(context, '无效的邮箱地址');
                    default:
                      devtools.log('error:${e.code}');
                      if (!context.mounted) return;
                      await errorDialog(context, 'error:${e.code}');
                  }
                } catch (e) {
                  devtools.log('系统错误 ${e.toString()}');
                }
              },
              child: const Text('注册')),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(loginRoute, (route) => false);
              },
              child: const Text("已注册，请登录"))
        ],
      ),
    );
  }
}
