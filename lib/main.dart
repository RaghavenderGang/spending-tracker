import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:spending_tracker/auth_services.dart';
import 'package:spending_tracker/const/theme.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
        create: (context) => ApplicationState(),
        builder: (context, _) => MyApp()),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: lightThemeData(context),
      dark: darkThemeData(context),
      initial: AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => MaterialApp(
        title: 'Spending Tracker',
        theme: theme,
        darkTheme: darkTheme,
        debugShowCheckedModeBanner: false,
        home: Consumer<ApplicationState>(
          builder: (context, appState, _) => Authentication(
            appState: appState,
            email: appState.email,
            loginState: appState.loginState,
            passwordChange: appState.passwordChange,
            startLoginFlow: appState.startLoginFlow,
            verifyEmail: appState.verifyEmail,
            signInWithEmailAndPassword: appState.signInWithEmailAndPassword,
            cancelRegistration: appState.cancelRegistration,
            registerAccount: appState.registerAccount,
            signOut: appState.signOut,
          ),
        ),
      ),
    );
  }
}

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  Future<void> init() async {
    await Firebase.initializeApp();

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loginState = ApplicationLoginState.loggedIn;
        var user = FirebaseAuth.instance.currentUser!;
        _uid = user.uid;
        _emailId = user.email!;
        _displayName = user.displayName!;
      } else {
        _loginState = ApplicationLoginState.loggedOut;
      }
      isPasswdResetSuccess = false;
      notifyListeners();
    });
  }

  ApplicationLoginState _loginState = ApplicationLoginState.loggedOut;
  ApplicationLoginState get loginState => _loginState;

  String _uid = '';
  String get uid => _uid;
  String _emailId = '';
  String get emailId => _emailId;
  String _displayName = '';
  String get displayName => _displayName;

  String? _email;
  String? get email => _email;
  bool isPasswdResetSuccess = false;

  void createButton() {
    _loginState = ApplicationLoginState.register;
    notifyListeners();
  }

  void forgotPasswdButton() {
    _loginState = ApplicationLoginState.changePassword;
    notifyListeners();
  }

  void passwdKnownButton() {
    _loginState = ApplicationLoginState.password;
    notifyListeners();
  }

  Future<bool> backButtonForgotPasswd() async {
    _loginState = ApplicationLoginState.password;
    notifyListeners();
    return false;
  }

  Future<bool> backButtonLoginPage() async {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
    return false;
  }

  Future<void> passwordChange(
    String email,
    void Function(FirebaseAuthException e) errorCallback,
  ) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      isPasswdResetSuccess = true;
      _email = email;
      // _loginState = ApplicationLoginState.password;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void startLoginFlow() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  Future<void> verifyEmail(
    String email,
    void Function(FirebaseAuthException e) errorCallback,
  ) async {
    try {
      var methods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.contains('password')) {
        _loginState = ApplicationLoginState.password;
      } else {
        _loginState = ApplicationLoginState.register;
      }
      _email = email;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  Future<void> signInWithEmailAndPassword(
    String email,
    String password,
    void Function(FirebaseAuthException e) errorCallback,
  ) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void cancelRegistration() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  Future<void> registerAccount(
      String email,
      String displayName,
      String password,
      void Function(FirebaseAuthException e) errorCallback) async {
    try {
      var credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await credential.user!.updateDisplayName(displayName);
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }
}
