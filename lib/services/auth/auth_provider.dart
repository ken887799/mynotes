
import 'auth_user.dart';

abstract class AuthProvider{
  //用户可以为null
  AuthUser? get currentUser;

  //用户登录,这里的返回值是AuthUser而非Firebase的userCredential,无法输出相关信息
  Future<AuthUser> login({
    required String email,
    required String password,
});

  //用户注册
  Future<AuthUser> createUser({
    required String email,
    required String password,
  });

  //用户退出登录
  Future<void> logout();

  //用户验证邮箱
  Future<void> sendEmailVerification();
}