import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:spending_tracker/components/component1.dart';
import 'package:spending_tracker/components/component2.dart';
import 'package:spending_tracker/components/custom_dialog.dart';
import 'package:spending_tracker/components/loading_screen.dart';
import 'package:spending_tracker/const/constants.dart';
import 'package:spending_tracker/main.dart';

class SignupPage extends StatefulWidget {
  SignupPage(
      {required this.registerAccount,
      required this.cancel,
      required this.email,
      required this.appState});
  final ApplicationState appState;
  final String email;
  final Future<void> Function(String email, String displayName, String password)
      registerAccount;
  final void Function() cancel;

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;

  final _formKey = GlobalKey<FormState>(debugLabel: 'SignupPage');
  TextEditingController username = new TextEditingController();
  TextEditingController emailId = new TextEditingController();
  TextEditingController password = new TextEditingController();
  TextEditingController confirmPassword = new TextEditingController();

  final CustomDialog _customDialog = new CustomDialog();

  @override
  void initState() {
    super.initState();
    emailId.text = widget.email;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    _animation1 = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.ease))
          ..addListener(() {
            setState(() {});
          });

    _animation2 = Tween<double>(begin: 2, end: 1).animate(CurvedAnimation(
        parent: _controller, curve: Curves.fastLinearToSlowEaseIn));

    if (mounted) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    return LoaderOverlay(
      overlayOpacity: 0.5,
      overlayColor: Colors.blueGrey,
      useDefaultLoading: false,
      overlayWidget: LoadingScreen(),
      child: WillPopScope(
        onWillPop: () async {
          return widget.appState.backButtonLoginPage();
        },
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Scaffold(
            body: ScrollConfiguration(
              behavior: MyBehavior(),
              child: SingleChildScrollView(
                child: SizedBox(
                  height: _height,
                  child: Container(
                    alignment: Alignment.center,
                    child: Opacity(
                      opacity: _animation1.value,
                      child: Transform.scale(
                        scale: _animation2.value,
                        child: Container(
                          width: _width * 0.92,
                          height: _width * 1.2,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.white
                                    : kSecondaryColor,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.3),
                                blurRadius: 60,
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(),
                                Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(),
                                Component1(
                                    icon: Icons.account_circle_outlined,
                                    hintText: 'User name...',
                                    isPassword: false,
                                    isEmail: false,
                                    isConfirmPassword: false,
                                    isUsername: true,
                                    username: username),
                                Component1(
                                  icon: Icons.email_outlined,
                                  hintText: 'Email...',
                                  isPassword: false,
                                  isEmail: true,
                                  isConfirmPassword: false,
                                  isUsername: false,
                                  emailId: emailId,
                                ),
                                Component1(
                                  icon: Icons.lock_outline,
                                  hintText: 'Password...',
                                  isPassword: true,
                                  isEmail: false,
                                  isConfirmPassword: false,
                                  isUsername: false,
                                  password: password,
                                ),
                                Component1(
                                  icon: Icons.lock_outline,
                                  hintText: 'Confirm Password...',
                                  isPassword: false,
                                  isEmail: false,
                                  isConfirmPassword: true,
                                  isUsername: false,
                                  isLast: true,
                                  confirmPassword: confirmPassword,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Component2(
                                      string: 'SIGN UP',
                                      width: 2.6,
                                      voidCallback: () async {
                                        if (_formKey.currentState!.validate()) {
                                          if (password.text ==
                                              confirmPassword.text) {
                                            FocusScope.of(context)
                                                .requestFocus(new FocusNode());
                                            context.loaderOverlay.show();
                                            await widget
                                                .registerAccount(
                                              emailId.text,
                                              username.text,
                                              password.text,
                                            )
                                                .whenComplete(() {
                                              if (mounted) {
                                                context.loaderOverlay.hide();
                                              }
                                            });
                                          } else {
                                            _customDialog.showErrorDialog(
                                                context,
                                                'Password not matched',
                                                Exception(),
                                                'Confirm password is not matched with Passsword.',
                                                () {});
                                          }
                                        }
                                      },
                                    ),
                                    SizedBox(width: _width / 25),
                                    Container(
                                      width: _width / 2.6,
                                      alignment: Alignment.center,
                                      child: RichText(
                                        text: TextSpan(
                                          text: 'Already have account?',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.light
                                                  ? kSecondaryColor
                                                  : Colors.white),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = widget.cancel,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
