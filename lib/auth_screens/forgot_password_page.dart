import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:spending_tracker/components/component1.dart';
import 'package:spending_tracker/components/component2.dart';
import 'package:spending_tracker/components/custom_dialog.dart';
import 'package:spending_tracker/components/loading_screen.dart';
import 'package:spending_tracker/const/constants.dart';
import 'package:spending_tracker/main.dart';

class ForgotPasswordPage extends StatefulWidget {
  ForgotPasswordPage({
    required this.appState,
    required this.callback,
    required this.email,
  });
  final Future<void> Function(String email) callback;
  final String email;
  final ApplicationState appState;

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;

  final CustomDialog _customDialog = new CustomDialog();
  final _formKey = GlobalKey<FormState>(debugLabel: '_ForgotPwPageState');
  TextEditingController emailId = new TextEditingController();

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
          return widget.appState.backButtonForgotPasswd();
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
                          width: _width * .9,
                          height: _width * .9,
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
                                  'Reset Password',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(),
                                Component1(
                                  icon: Icons.email_outlined,
                                  hintText: 'Email...',
                                  isPassword: false,
                                  isEmail: true,
                                  isConfirmPassword: false,
                                  isUsername: false,
                                  isLast: true,
                                  emailId: emailId,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Component2(
                                      string: 'Reset',
                                      width: 2.6,
                                      voidCallback: () async {
                                        if (_formKey.currentState!.validate()) {
                                          FocusScope.of(context)
                                              .requestFocus(new FocusNode());
                                          context.loaderOverlay.show();
                                          await widget
                                              .callback(emailId.text)
                                              .whenComplete(() =>
                                                  context.loaderOverlay.hide());
                                          if (widget
                                              .appState.isPasswdResetSuccess) {
                                            widget.appState
                                                .isPasswdResetSuccess = false;
                                            print("123");
                                            _customDialog.showSuccessDialog(
                                                context,
                                                'Success',
                                                "Reset password link send successfully",
                                                () {
                                              widget.appState
                                                  .passwdKnownButton();
                                            });
                                          }
                                        }
                                      },
                                    ),
                                    SizedBox(width: _width / 10),
                                    TextButton(
                                        onPressed: () {
                                          widget.appState.passwdKnownButton();
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.arrow_left,
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.light
                                                  ? Colors.blueAccent
                                                  : Colors.amber[600],
                                              size: 27,
                                            ),
                                            Text(
                                              'Go back',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.light
                                                    ? kSecondaryColor
                                                    : Colors.amber[600],
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        )),
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




// decoration: BoxDecoration(
//   gradient: LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [
//       // Color(0xffFEC37B),
//       // Color(0xffFF4184),
//       kPrimaryColor,
//       kSecondaryColor
//     ],
//   ),
// ),