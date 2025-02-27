import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  // AuthController.instance..
  static AuthController instace = Get.find();
  // email, password, name ..
  late Rx<User?> _user;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(_auth.currentUser);
    // our user would be notified
    _user.bindStream(_auth.userChanges());
    ever(_user, _initialScreen);
  }

  _initialScreen(User? user) {
    if (user == null) {
      print("login page");
      Get.offAllNamed('/login'); // jika belum login, ke login page
    } else {
      Get.offAllNamed('/home'); // jika sudah login, ke home
    }
  }

  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  //Register with username & phone number
  Future<void> register(String username, email, phone, password) async {
    try {
      // buat akun di firebase authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ambil UID dari akun yang baru dibuat
      String uid = userCredential.user!.uid;

      // simpan data tambahan ke firestore
      await _firestore.collection("users").doc(uid).set({
        "uid": uid,
        "username": username,
        "email": email,
        "phone": phone,
        "createdAt": DateTime.now(),
      });
      Get.snackbar("Success", "Account created successfully!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  // login with email & password
  Future<void> login(String email, password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Get.snackbar("Success", "Logged in successfully");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
