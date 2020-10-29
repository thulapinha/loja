import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lojaronilson/helpers/firebase_errors.dart';
import 'package:lojaronilson/models/user.dart';

class UserManager extends ChangeNotifier {



  UserManager(){
    _loadCurrentUser();
  }

  final FirebaseAuth auth = FirebaseAuth.instance;
  final Firestore firestore = Firestore.instance;
  final gooleSignIn = GoogleSignIn();

  User user, users;


  bool _loading = false;
  bool get loading => _loading;

  bool get isLoggedIn => user  != null;


  Future<void> signIn({User user, Function onFail, Function onSuccess}) async {
    loading = true;
    try {
      final AuthResult result = await auth.signInWithEmailAndPassword(
          email: user.email, password: user.password);

      await _loadCurrentUser(firebaseUser: result.user);

      onSuccess();
    } on PlatformException catch (e){
      onFail(getErrorString(e.code));
    }
    loading = false;
  }

 Future<void> facebookLogin({Function onFail, Function onSuccess}) async {
    loading = true;

    final result = await FacebookLogin().logIn(['email', 'public_profile']);

    switch(result.status){
      case FacebookLoginStatus.loggedIn:
        final credential = FacebookAuthProvider.getCredential(
            accessToken: result.accessToken.token
        );

        final authResult = await auth.signInWithCredential(credential);

        if(authResult.user != null){
          final firebaseUser = authResult.user;

          user = User(
              id: firebaseUser.uid,
              name: firebaseUser.displayName,
              email: firebaseUser.email
          );

          await user.saveData();

          onSuccess();
        }
        break;
      case FacebookLoginStatus.cancelledByUser:
        break;
      case FacebookLoginStatus.error:
        onFail(result.errorMessage);
        break;
    }

    loading = false;
  }
  // Google login
  // ignore: missing_return
 Future<void> googleSignIn({Null Function() onFail, Null Function() onSuccess}) async {
    final GoogleSignInAccount googleSignInAccount = await gooleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      final AuthResult authResult = await auth.signInWithCredential(credential);


      if(authResult.user != null){

        final firebaseUser = authResult.user;

       users = User(
            id: firebaseUser.uid,
            name: firebaseUser.displayName,
            email: firebaseUser.email
        );

        await users.saveData();

        onSuccess();
      }
      final FirebaseUser user = await auth.currentUser();
      // ignore: avoid_print
      print(user.uid);

      // ignore: void_checks
      return Future.value(true);
    }
    loading = false;

  }
  Future<void> signOutUser() async {
    FirebaseUser user = await auth.currentUser();

    // ignore: avoid_print
    print(user.providerData[1].providerId);
    if (user.providerData[1].providerId == 'google.com') {
      await gooleSignIn.disconnect();
    }

    await auth.signOut();
    // ignore: void_checks
    return Future.value(true);
  }

//fim
  Future<void> signUp({User user, Function onFail, Function onSuccess}) async {
    loading = true;
    try {
      final AuthResult result = await auth.createUserWithEmailAndPassword(
          email: user.email, password: user.password);

      user.id = result.user.uid;
      this.user = user;

      await user.saveData();

      onSuccess();
    } on PlatformException catch (e){
      onFail(getErrorString(e.code));
    }
    loading = false;
  }

  void signOut(){
    auth.signOut();
    user = null;
    notifyListeners();
  }

  set loading(bool value){
    _loading = value;
    notifyListeners();
  }

  Future<void> _loadCurrentUser({FirebaseUser firebaseUser}) async {
    final FirebaseUser currentUser = firebaseUser ?? await auth.currentUser();
    if(currentUser != null){
      final DocumentSnapshot docUser = await firestore.collection('users')
          .document(currentUser.uid).get();
      user = User.fromDocument(docUser);

      final docAdmin = await firestore.collection('admins').document(user.id).get();
      if(docAdmin.exists){
        user.admin = true;
      }

      notifyListeners();
    }
  }

  bool get adminEnabled => user != null && user.admin;
}