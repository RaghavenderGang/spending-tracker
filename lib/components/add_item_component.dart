import 'package:flutter/material.dart';

class AddItemComponent extends StatelessWidget {
  const AddItemComponent(
      {Key? key,
      required this.labelText,
      this.isNumber = false,
      required this.textController,
      this.isLast = false})
      : super(key: key);
  final labelText;
  final isNumber;
  final textController;
  final isLast;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
            flex: 2,
            child: Text(
              labelText,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            )),
        Expanded(
          flex: 5,
          child: Container(
            alignment: Alignment.center,
            height: 45,
            // color: Colors.amber,
            child: TextField(
              style: TextStyle(
                fontSize: 16.2,
              ),
              controller: textController,
              textCapitalization: TextCapitalization.words,
              keyboardType:
                  isNumber ? TextInputType.number : TextInputType.text,
              textInputAction:
                  isLast ? TextInputAction.done : TextInputAction.next,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.fromLTRB(12, 0, 5, 0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
