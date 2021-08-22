import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spending_tracker/components/component1.dart';
import 'package:spending_tracker/components/component2.dart';
import 'package:spending_tracker/components/loading_screen.dart';
import 'package:spending_tracker/const/constants.dart';
import 'package:loader_overlay/loader_overlay.dart';

class VerifyEmailPage extends StatefulWidget {
  VerifyEmailPage({required this.callback});
  final Future<void> Function(String email) callback;

  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;

  final _formKey = GlobalKey<FormState>(debugLabel: '_VerifyEmailPage');
  TextEditingController emailId = new TextEditingController();

  @override
  void initState() {
    super.initState();

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
                                'Account Login',
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
                              Component2(
                                string: 'Verify Email',
                                width: 2.6,
                                voidCallback: () async {
                                  if (_formKey.currentState!.validate()) {
                                    FocusScope.of(context)
                                        .requestFocus(new FocusNode());
                                    context.loaderOverlay.show();
                                    await widget
                                        .callback(emailId.text)
                                        .whenComplete(
                                            () => context.loaderOverlay.hide());
                                  }
                                },
                              ),
                              SizedBox(),
                              // RichText(
                              //   text: TextSpan(
                              //     text: 'Create a new Account',
                              //     style: TextStyle(
                              //       color: Theme.of(context).brightness ==
                              //               Brightness.light
                              //           ? kSecondaryColor
                              //           : Colors.white,
                              //       fontSize: 16,
                              //     ),
                              //     recognizer: TapGestureRecognizer()
                              //       ..onTap = () {
                              //         // Fluttertoast.showToast(
                              //         //   msg: 'Create a new Account button pressed',
                              //         // );
                              //       },
                              //   ),
                              // ),
                              // SizedBox(),
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
