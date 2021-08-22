import 'package:flutter/material.dart';
import 'package:spending_tracker/const/constants.dart';

class Component1 extends StatefulWidget {
  Component1(
      {required this.icon,
      required this.hintText,
      this.isPassword = false,
      this.isEmail = false,
      this.isUsername = false,
      this.isConfirmPassword = false,
      this.isLast = false,
      this.username,
      this.emailId,
      this.password,
      this.confirmPassword});

  final icon;
  final hintText;
  final isPassword;
  final isEmail;
  final isUsername;
  final isConfirmPassword;
  final username;
  final emailId;
  final password;
  final confirmPassword;
  final isLast;

  @override
  _Component1State createState() => _Component1State();
}

class _Component1State extends State<Component1> {
  bool isHidden = false;
  @override
  void initState() {
    super.initState();
    isHidden = (widget.isPassword || widget.isConfirmPassword);
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    return Container(
      height: _width / 5.5,
      width: _width / 1.2,
      alignment: Alignment.center,
      padding: EdgeInsets.only(right: _width / 30),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.black.withOpacity(.1)
            : Colors.red.withOpacity(.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        validator: (value) {
          if (value!.isEmpty) {
            return 'Entry can\'t be empty!';
          }
          return null;
        },
        style: TextStyle(fontSize: 18),
        textCapitalization: widget.isUsername
            ? TextCapitalization.words
            : TextCapitalization.none,
        cursorColor: kSecondaryColor,
        obscureText: isHidden,
        obscuringCharacter: '*',
        controller: widget.isUsername
            ? widget.username
            : widget.isEmail
                ? widget.emailId
                : widget.isPassword
                    ? widget.password
                    : widget.confirmPassword,
        textInputAction:
            widget.isLast ? TextInputAction.done : TextInputAction.done,
        keyboardType:
            widget.isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: (widget.isPassword || widget.isConfirmPassword)
            ? InputDecoration(
                prefixIcon: Icon(
                  widget.icon,
                  color: Theme.of(context).iconTheme.color!.withOpacity(0.7),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.fromLTRB(14, 2, 0, 0),
                suffixIcon: IconButton(
                    onPressed: () {
                      // FocusScope.of(context).requestFocus(FocusNode());
                      setState(() {
                        isHidden = !isHidden;
                      });
                    },
                    icon: isHidden
                        ? Icon(Icons.visibility)
                        : Icon(Icons.visibility_off)),
                hintMaxLines: 1,
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  fontSize: 14,
                ),
                errorStyle: TextStyle(
                  color: Colors.amber[600],
                  fontSize: 12.5,
                ),
                labelText: widget.hintText,
                labelStyle: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black.withOpacity(.8)
                      : Colors.white.withOpacity(.8),
                ),
              )
            : InputDecoration(
                prefixIcon: Icon(
                  widget.icon,
                  color: Theme.of(context).iconTheme.color!.withOpacity(0.7),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.fromLTRB(14, 2, 0, 0),
                hintMaxLines: 1,
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  fontSize: 14,
                ),
                errorStyle: TextStyle(
                  color: Colors.amber[600],
                  fontSize: 12.5,
                ),
                labelText: widget.hintText,
                labelStyle: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black.withOpacity(.8)
                      : Colors.white.withOpacity(.8),
                ),
              ),
      ),
    );
  }
}

//       
//               labelText: hintText,
//               labelStyle: TextStyle(
//                 fontSize: 16,
//                 color: Colors.white.withOpacity(.8),
//               ),
//               hintStyle:
//                   TextStyle(fontSize: 14, color: Colors.white.withOpacity(.5)),
//             ),