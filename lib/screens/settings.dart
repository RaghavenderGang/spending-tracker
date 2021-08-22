import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spending_tracker/components/dropdown_btn.dart';
import 'package:spending_tracker/const/constants.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({
    required this.signOut,
  });
  final void Function() signOut;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final String? userName = FirebaseAuth.instance.currentUser!.displayName;
  final String? emailID = FirebaseAuth.instance.currentUser!.email;
  final UserMetadata umd = FirebaseAuth.instance.currentUser!.metadata;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Column(
        children: [
          customTile('Username', userName!),
          SizedBox(
            height: 10,
          ),
          customTile('Email', emailID!),
          SizedBox(
            height: 10,
          ),
          customTile(
              'Last Sign in',
              DateFormat('MMM dd, yyyy - HH:mm:ss')
                  .format(umd.lastSignInTime!)),
          SizedBox(
            height: 50,
          ),
          ListTile(
            title: Text('Theme Mode',
                style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: CustomDropDownButton(
              itemList: ['Light', 'Dark', 'System'],
              dropDownType: 'themeMode',
            ),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            title: Text('Change Password'),
                            content: Text('Do you want to change password?'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('No')),
                              TextButton(
                                  onPressed: () async {
                                    await FirebaseAuth.instance
                                        .sendPasswordResetEmail(email: emailID!)
                                        .then((value) {
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          duration: Duration(seconds: 2),
                                          content: const Text(
                                            'Reset link sent to mail successfully',
                                            textAlign: TextAlign.center,
                                          ),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                        ),
                                      );
                                    });
                                  },
                                  child: Text('Yes')),
                            ],
                          ));
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outlined,
                      size: 20,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text('Reset Password'),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.signOut();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.logout_outlined,
                      size: 20,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }

  Widget customTile(String _key, String _value) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 10, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _key,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.5,
              ),
            ),
            flex: 5,
          ),
          Expanded(
            child: Text(
              _value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            flex: 12,
          ),
        ],
      ),
    );
  }
}
