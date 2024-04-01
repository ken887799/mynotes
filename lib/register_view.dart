import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  late final Future<FirebaseApp> _firebaseApp;
  @override
  void initState() {
    //The framework will call this method exactly once for each State object it creates.
    //在_RegisterViewState对象创建时执行
    //在创建控件的时候初始化文本编辑控制器
    _email = TextEditingController();
    _pwd = TextEditingController();
    _firebaseApp =
        Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        appBar: AppBar(title: const Text('注册界面')),
        body: FutureBuilder(
            future: _firebaseApp,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  return Column(
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
                            await Firebase.initializeApp(
                                options:
                                DefaultFirebaseOptions.currentPlatform);
                            //通过绑定点击按钮来实现文本获取
                            final email = _email.text;
                            final pwd = _pwd.text;
                            final credential = await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                email: email, password: pwd);
                            print(credential);
                          },
                          child: const Text('注册')),
                    ],
                  );
                default:
                  return const Center(
                    child:Text('加载中。。。') ,
                  );
              }
            }));
  }
}