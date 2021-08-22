import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:spending_tracker/components/component1.dart';
import 'package:spending_tracker/components/component2.dart';
import 'package:spending_tracker/components/loading_screen.dart';
import 'package:spending_tracker/const/constants.dart';
import 'package:spending_tracker/main.dart';

class LoginPage extends StatefulWidget {
  LoginPage({
    required this.login,
    required this.email,
    required this.appState,
  });
  final ApplicationState appState;
  final String email;
  final Future<void> Function(String email, String password) login;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;

  final _formKey = GlobalKey<FormState>(debugLabel: '_LoginPage');
  TextEditingController emailId = new TextEditingController();
  TextEditingController password = new TextEditingController();

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
                          height: _width * 1.12,
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
                                  'Account Login',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black.withOpacity(.7)),
                                ),
                                SizedBox(),
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Component2(
                                        string: 'LOGIN',
                                        width: 2.6,
                                        voidCallback: () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            FocusScope.of(context)
                                                .requestFocus(new FocusNode());
                                            context.loaderOverlay.show();
                                            await new Future.delayed(
                                                Duration(seconds: 3));
                                            await widget
                                                .login(
                                              emailId.text,
                                              password.text,
                                            )
                                                .whenComplete(() {
                                              if (mounted) {
                                                context.loaderOverlay.hide();
                                              }
                                            });
                                          }
                                        }),
                                    SizedBox(width: _width / 25),
                                    Container(
                                      width: _width / 2.6,
                                      alignment: Alignment.center,
                                      child: RichText(
                                        text: TextSpan(
                                          text: 'Forgotten password?',
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.light
                                                  ? kSecondaryColor
                                                  : Colors.white),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              widget.appState
                                                  .forgotPasswdButton();
                                            },
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(),
                                RichText(
                                  text: TextSpan(
                                    text: 'Create a new Account!',
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Theme.of(context).brightness ==
                                                Brightness.light
                                            ? kSecondaryColor
                                            : Colors.white),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        widget.appState.createButton();
                                      },
                                  ),
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
