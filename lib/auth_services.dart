import 'package:flutter/material.dart';
import 'package:spending_tracker/auth_screens/forgot_password_page.dart';
import 'package:spending_tracker/auth_screens/login_page.dart';
import 'package:spending_tracker/auth_screens/signup_page.dart';
import 'package:spending_tracker/auth_screens/verify_email_page.dart';
import 'package:spending_tracker/auth_screens/welcome_page.dart';
import 'package:spending_tracker/components/custom_dialog.dart';
import 'package:spending_tracker/main.dart';
import 'package:spending_tracker/screens/home_page.dart';

enum ApplicationLoginState {
  loggedOut,
  emailAddress,
  register,
  password,
  loggedIn,
  changePassword,
}

final CustomDialog _customDialog = new CustomDialog();

class Authentication extends StatelessWidget {
  const Authentication({
    required this.appState,
    required this.loginState,
    required this.email,
    required this.startLoginFlow,
    required this.verifyEmail,
    required this.signInWithEmailAndPassword,
    required this.cancelRegistration,
    required this.registerAccount,
    required this.signOut,
    required this.passwordChange,
  });

  final ApplicationState appState;
  final ApplicationLoginState loginState;
  final String? email;
  final void Function() startLoginFlow;

  final Future<void> Function(
    String email,
    void Function(Exception e) error,
  ) passwordChange;

  final Future<void> Function(
    String email,
    void Function(Exception e) error,
  ) verifyEmail;

  final Future<void> Function(
    String email,
    String password,
    void Function(Exception e) error,
  ) signInWithEmailAndPassword;

  final void Function() cancelRegistration;

  final Future<void> Function(
    String email,
    String displayName,
    String password,
    void Function(Exception e) error,
  ) registerAccount;

  final void Function() signOut;

  @override
  Widget build(BuildContext context) {
    switch (loginState) {
      case ApplicationLoginState.changePassword:
        return ForgotPasswordPage(
            email: email!,
            appState: appState,
            callback: (email) => passwordChange(
                email,
                (e) => _customDialog.showErrorDialog(
                    context, 'Invalid email', e, "", () {})));

      case ApplicationLoginState.loggedOut:
        return WelcomePage(startProcess: startLoginFlow);

      case ApplicationLoginState.emailAddress:
        return VerifyEmailPage(
            callback: (email) => verifyEmail(
                email,
                (e) => _customDialog.showErrorDialog(
                    context, 'Invalid email', e, "", () {})));

      case ApplicationLoginState.password:
        return LoginPage(
          email: email!,
          appState: appState,
          login: (email, password) async {
            await signInWithEmailAndPassword(
                email,
                password,
                (e) => _customDialog.showErrorDialog(
                    context, 'Failed to sign in', e, "", () {}));
          },
        );

      case ApplicationLoginState.register:
        return SignupPage(
          appState: appState,
          email: email!,
          cancel: () {
            cancelRegistration();
          },
          registerAccount: (
            email,
            displayName,
            password,
          ) async {
            await registerAccount(
                email,
                displayName,
                password,
                (e) => _customDialog.showErrorDialog(
                    context, 'Failed to create account', e, "", () {}));
          },
        );

      case ApplicationLoginState.loggedIn:
        return HomePage(signOut: signOut);
      default:
        return Center(
          child: Container(
            alignment: Alignment.center,
            child: Text("Internal error, this shouldn't happen..."),
            color: Colors.amber,
          ),
        );
    }
  }
}
