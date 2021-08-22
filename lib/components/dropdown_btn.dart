import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDropDownButton extends StatefulWidget {
  CustomDropDownButton({required this.itemList, required this.dropDownType});
  final List<String> itemList;
  final String dropDownType;

  @override
  _CustomDropDownButtonState createState() => _CustomDropDownButtonState();
}

class _CustomDropDownButtonState extends State<CustomDropDownButton> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _loadSelectedValue();
  }

  void _loadSelectedValue() async {
    final prefs = await SharedPreferences.getInstance();
    final adaptiveThemeMode = await AdaptiveTheme.getThemeMode();

    if (!prefs.containsKey(widget.dropDownType)) {
      if (adaptiveThemeMode == AdaptiveThemeMode.light) {
        await prefs.setString(widget.dropDownType, widget.itemList[0]);
      } else if (adaptiveThemeMode == AdaptiveThemeMode.dark) {
        await prefs.setString(widget.dropDownType, widget.itemList[1]);
      } else {
        await prefs.setString(widget.dropDownType, widget.itemList[2]);
      }
    }

    setState(() {
      _selectedValue = prefs.getString(widget.dropDownType);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _selectedValue,
      items: widget.itemList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) async {
        final prefs = await SharedPreferences.getInstance();
        setState(() {
          _selectedValue = newValue!;
        });
        await prefs.setString(widget.dropDownType, _selectedValue!);
        if (_selectedValue == widget.itemList[0]) {
          AdaptiveTheme.of(context).setLight();
        } else if (_selectedValue == widget.itemList[1]) {
          AdaptiveTheme.of(context).setDark();
        } else if (_selectedValue == widget.itemList[2]) {
          AdaptiveTheme.of(context).setSystem();
        }
      },
    );
  }
}
