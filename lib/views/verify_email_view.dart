import 'package:flutter/material.dart';
import 'package:learningdart/services/auth/auth_service.dart';
import '../constant/routes.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {

    // 获取当前路由
    ModalRoute? route = ModalRoute.of(context);
    // 获取路由的是否是最底层
    bool? isFirst = route?.isFirst;

    return Scaffold(
      appBar: AppBar(
        title: const Text('验证邮箱'),
      ),
      body: Column(
        children: [
          const Text("我们已向您的邮箱发送了验证邮件,请注意查收。"),
          const Text('如果没有收到邮件，请点击下方按钮'),
          TextButton(
              onPressed: () async {
                final user = AuthService.firebase().currentUser;
                await AuthService.firebase().sendEmailVerification();
              },
              child: const Text("重新发送")),
          //在list中可以添加if判断语句,但是不能不能有{}
          //因为重新加载后验证界面会出现在最底层，如果是最底层则显示按钮，如果不是则不显示
          if(isFirst??false)
          TextButton(onPressed: (){
            Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
          }, child: const Text('返回登录界面'))
        ],
      ),
    );
  }
}