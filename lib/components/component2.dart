import 'package:flutter/material.dart';
import 'package:spending_tracker/const/constants.dart';

class Component2 extends StatelessWidget {
  Component2(
      {required this.string, required this.width, required this.voidCallback});
  final string;
  final width;
  final voidCallback;

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    return InkWell(
      splashColor: Colors.amber,
      highlightColor: Colors.white,
      onTap: voidCallback,
      child: Container(
        height: _width / 8,
        width: _width / width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          string,
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }
}

// Widget component2(String string, double width, VoidCallback voidCallback) {
//     double _width = MediaQuery.of(context).size.width;
//     return InkWell(
//       splashColor: kPrimaryColor,
//       onTap: voidCallback,
//       child: Container(
//         height: _width / 8,
//         width: _width / width,
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           color: kPrimaryColor,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Text(
//           string,
//           style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
//         ),
//       ),
//     );
//   }