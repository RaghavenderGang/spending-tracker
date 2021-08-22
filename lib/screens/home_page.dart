import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spending_tracker/components/add_item_component.dart';
import 'package:spending_tracker/const/constants.dart';
import 'package:spending_tracker/screens/analysis.dart';
import 'package:spending_tracker/screens/dashboard.dart';
import 'package:spending_tracker/screens/settings.dart';

class HomePage extends StatefulWidget {
  HomePage({
    required this.signOut,
  });
  final void Function() signOut;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  TextEditingController itemName = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController quantity = TextEditingController();
  TextEditingController place = TextEditingController();
  TextEditingController datePurchased = TextEditingController();

  late DateFormat formatter;
  DateTime? _date = DateTime.now();

  late String userId;
  late DocumentReference firestore;

  @override
  void initState() {
    super.initState();

    formatter = DateFormat.yMMMd();
    datePurchased.text = formatter.format(_date!);
    userId = FirebaseAuth.instance.currentUser!.uid;
    firestore = FirebaseFirestore.instance.collection('users').doc(userId);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: buildAppBar(),
        body: _selectedIndex == 0
            ? Dashboard()
            : _selectedIndex == 1
                ? Analysis()
                : SettingsPage(signOut: widget.signOut),
        floatingActionButton: _selectedIndex == 0
            ? FloatingActionButton(
                onPressed: () {
                  addItemDialogBox(context);
                },
                tooltip: 'Add Item',
                backgroundColor: kPrimaryColor,
                // label: Text(
                //   'Add Item',
                //   style: TextStyle(
                //     color: Colors.white,
                //   ),
                // ),
                child: Icon(
                  Icons.add,
                  size: 36,
                  color: Colors.white,
                ),
              )
            : null,
        bottomNavigationBar: buildBottomNavigatorBar(),
      ),
    );
  }

  Future<dynamic> addItemDialogBox(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: EdgeInsets.all(kDefaultPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Item',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20,
              ),
              AddItemComponent(
                labelText: 'Name:',
                textController: itemName,
              ),
              SizedBox(
                height: 15,
              ),
              AddItemComponent(
                labelText: 'Price:',
                isNumber: true,
                textController: price,
              ),
              SizedBox(
                height: 15,
              ),
              AddItemComponent(
                labelText: 'Quantity:',
                isNumber: true,
                textController: quantity,
              ),
              SizedBox(
                height: 15,
              ),
              AddItemComponent(
                labelText: 'Place:',
                textController: place,
                isLast: true,
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                      // alignment: Alignment.center,
                      height: 45,
                      child: TextField(
                        readOnly: true,
                        style: TextStyle(
                          fontSize: 16.2,
                        ),
                        controller: datePurchased,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 5),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                      flex: 5,
                      child: ElevatedButton(
                        onPressed: () async {
                          _date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (_date != null) {
                            datePurchased.text = formatter.format(_date!);
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 45,
                          child: Text(
                            'Purchase Date',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                      )),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  TextButton(
                    child: Text('Exit'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Spacer(),
                  TextButton(
                    child: Text('Reset'),
                    onPressed: () {
                      itemName.clear();
                      price.clear();
                      quantity.clear();
                      place.clear();
                    },
                  ),
                  TextButton(
                    child: Text('Add'),
                    onPressed: () async {
                      if (itemName.text != '' &&
                          num.tryParse(price.text) != null &&
                          num.tryParse(quantity.text) != null) {
                        Navigator.of(context).pop();

                        await onPressAddItem(datePurchased.text, itemName.text,
                            price.text, quantity.text, place.text);

                        itemName.clear();
                        price.clear();
                        quantity.clear();
                        place.clear();
                        _date = DateTime.now();
                        datePurchased.text = formatter.format(_date!);
                      } else {
                        if (itemName.text == '') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: Duration(seconds: 2),
                              content: const Text(
                                'Name can\'t be empty',
                                textAlign: TextAlign.center,
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        } else if (num.tryParse(price.text) == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: Duration(seconds: 2),
                              content: const Text(
                                'Enter a number for Price',
                                textAlign: TextAlign.center,
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: Duration(seconds: 2),
                              content: const Text(
                                'Enter a number for Quantity',
                                textAlign: TextAlign.center,
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onPressAddItem(String datePurchased, String itemName,
      String price, String quantity, String place) async {
    await firestore.collection(requiredDateFormatForFB(datePurchased)).add({
      'name': itemName,
      'price': num.tryParse(price),
      'quantity': num.tryParse(quantity),
      'place': place,
      'timestamp': DateTime.now(),
    }).then((value) async {
      print(value.id);
      num amount = 0;
      await firestore
          .collection(requiredDateFormatForFB(datePurchased))
          .doc('spendings')
          .get()
          .then((value) {
        if (value.exists && value.data()!.containsKey('amount')) {
          amount = value.data()!['amount'];
        }
      });
      await firestore
          .collection(requiredDateFormatForFB(datePurchased))
          .doc('spendings')
          .set({
        'amount': amount + (num.parse(price) * num.parse(quantity)),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 3),
          content: Text(
            itemName + ' successfully added.',
            textAlign: TextAlign.center,
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    });

    await addvalueToDB(datePurchased, 'dates', 'date');
    await addvalueToDB(itemName, 'itemNames', 'itemName');
    if (place != '') {
      await addvalueToDB(place, 'places', 'place');
    }
  }

  Future<void> addvalueToDB(
      String value, String collectionName, String fieldName) async {
    var snapshot = await firestore
        .collection(collectionName)
        .where(fieldName,
            isEqualTo:
                fieldName == 'date' ? requiredDateFormatForFB(value) : value)
        .get();

    if (snapshot.size == 0) {
      await firestore.collection(collectionName).add({
        fieldName: fieldName == 'date' ? requiredDateFormatForFB(value) : value,
      });
    }
  }

  String requiredDateFormatForFB(String _date) {
    var date = DateFormat.yMMMd().parse(_date);
    return DateFormat('yyyy-MM-dd').format(date);
  }

  AppBar buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text('Spending Tracker'),
      centerTitle: true,
    );
  }

  BottomNavigationBar buildBottomNavigatorBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (value) {
        setState(() {
          _selectedIndex = value;
        });
      },
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.list), label: "Items"),
        BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "Analysis"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      ],
    );
  }
}
