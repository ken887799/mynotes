import 'package:firebase_auth/firebase_auth.dart' show User;

class AuthUser{
  //用户是否验证
   final bool isEmailVerified;
   //构造方法
   AuthUser({required this.isEmailVerified});
   //工厂构造方法
  factory AuthUser.fromFirebase(User user) => AuthUser(isEmailVerified : user.emailVerified);
}