import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:practical_google_maps_example/data/model/user_model.dart';

class AuthRepo {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<Either<String, String>> registerUser(
      {required String email, required String userName, required String password}) async {
    try {
      UserCredential userCredential =
          await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;
      await firestore.collection("users").doc(uid).set({
        "email": email,
        "userName": userName,
        "uid": uid,
      });

      return Right("User created successfully");
    } on FirebaseAuthException catch (e) {
      return Left("Email or password is incorrect");
    } catch (e) {
      return Left("Something went wrong $e");
    }
  }

  Future<Either<String, UserModel>> loginUser(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential =
          await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
          .collection("users")
          .where("uid", isEqualTo: userCredential.user!.uid)
          .get();
      final userData = querySnapshot.docs.first.data();
      print(userData.toString());
      UserModel userModel = UserModel.fromJson(userData);
      print(userModel.toString());
      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      return Left("Email or password is incorrect");
    } catch (e) {
      print(e);
      return Left("Error when login $e");
    }
  }
}
