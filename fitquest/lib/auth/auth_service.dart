import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../models/usermodel.dart';

class AuthService extends GetxController {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  RxBool isLoading = false.obs;


  // for login
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password,);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('no user found');
      } else if (e.code == 'wrong-password') {
        print('wrong password');
      } else {
        print(e.code);
      }
    } catch (e) {
      print(e);
    }
    isLoading.value = false;
  }

//signup
  Future<void> signUp(String name,String age,String email, String password) async {
    isLoading.value = true;
    try {
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await initUser(name,age,email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('weak password');
      } else if (e.code == 'email-already-in-use') {
        print('email alredy exists');
      } else {
        print(e.code);
      }
    } catch (e) {
      print(e);
    }
    isLoading.value = false;
  }

  //sign otut
  Future<void> signOut() async {
    await auth.signOut();
    Get.offAllNamed("/authPage");
  }


  Future<void> initUser(String name,String age,String email) async {
    var newUser = UserModel(
      id: auth.currentUser!.uid,
      name: name,
      age: age,
      email: email,

    );
    try {
      await db.collection("users").doc(auth.currentUser!.uid).set(
          newUser.toJson());
    }catch(e)
    {
      print(e);
    }

  }
}