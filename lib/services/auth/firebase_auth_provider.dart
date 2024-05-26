import 'package:firebase_core/firebase_core.dart';
import "package:learningdart/services/auth/auth_provider.dart";
import "package:learningdart/services/auth/auth_user.dart";
import 'package:firebase_auth/firebase_auth.dart';
import '../../firebase_options.dart';
import 'auth_exceptions.dart';


class FirebaseAuthProvider implements AuthProvider{
  @override
  AuthUser? get currentUser{
     final user = FirebaseAuth.instance.currentUser;
    if(user != null){
      return AuthUser.fromFirebase(user);
    }else{
      return null;
    }
  }

  @override
  Future<AuthUser> createUser ({required String email, required String password}) async{
    try{

    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    final user = currentUser;
    if(user != null){
      return user;
    }else{
      throw UserNotLoggedInAuthException();
    }
    } on FirebaseAuthException catch(e){
      if(e.code == 'weak-password'){
        throw WeakPasswordAuthException();
      }else if(e.code == 'email-already-in-use'){
        throw EmailAlreadyInUseAuthException();
      }else if(e.code == 'invalid-email'){
        throw InvalidEmailAuthException();
      }else{
        throw GenericAuthException();
      }
    }catch(_){
      //在 catch 中使用 _ 表示不关心异常对象
      throw GenericAuthException();
    }
  }

  @override
  Future<AuthUser> login({required String email, required String password}) async {
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      final user = currentUser;
      if(user != null){
        return user;
      }else{
        throw UserNotLoggedInAuthException();
      }
    }on FirebaseAuthException catch(e){
      if(e.code == 'INVALID_LOGIN_CREDENTIALS'){
        throw InvalidLoginCredentialsException();
      }else{
        throw GenericAuthException();
      }
    }catch(_){
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logout() async{
    final user = FirebaseAuth.instance.currentUser;
    if(user != null){
    await FirebaseAuth.instance.signOut();
    }else{
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async{
    final user = FirebaseAuth.instance.currentUser;
    if(user != null){
      await user.sendEmailVerification();
    }else{
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> initialize() async{
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

}