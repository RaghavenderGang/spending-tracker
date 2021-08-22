import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/components/add_item_component.dart';
import 'package:spending_tracker/components/item_card.dart';
import 'package:spending_tracker/const/constants.dart';
import 'package:spending_tracker/models/items_list.dart';

class Analysis extends StatefulWidget {
  const Analysis({Key? key}) : super(key: key);

  @override
  _AnalysisState createState() => _AnalysisState();
}

class _AnalysisState extends State<Analysis> {
  num amount = 0;
  late double _dailyLimit = 1;
  double percentage = 0;

  TextEditingController dailyLimit = TextEditingController();

  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    loadDailyLimit();
    super.initState();
  }

  void loadDailyLimit() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyLimit = prefs.getDouble('dailyLimit') ?? 1000;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              spendingWidget(),
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: OutlinedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (_) => Dialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              child: Container(
                                padding: EdgeInsets.all(kDefaultPadding),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Change Daily Limit',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    AddItemComponent(
                                      labelText: 'Limit:',
                                      textController: dailyLimit,
                                      isNumber: true,
                                      isLast: true,
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
                                          child: Text('OK'),
                                          onPressed: () async {
                                            if (double.tryParse(
                                                    dailyLimit.text) !=
                                                null) {
                                              setState(() {
                                                _dailyLimit = double.parse(
                                                    dailyLimit.text);
                                              });
                                              final prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              prefs.setDouble(
                                                  'dailyLimit',
                                                  double.parse(
                                                      dailyLimit.text));
                                              dailyLimit.text = '';
                                              Navigator.of(context).pop();
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ));
                  },
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 40),
                    title: Text(
                      'Daily limit',
                      style: TextStyle(fontSize: 17),
                    ),
                    trailing: Text(
                      '\$$_dailyLimit',
                      style: TextStyle(color: kSecondaryColor),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ItemCard(
                item: Item(isDate: true, date: 'Recent'),
              ),
              expansionTileView(true, 'Purchased items'),
              expansionTileView(false, 'Places'),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }

  FutureBuilder<DocumentSnapshot> spendingWidget() {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection(DateFormat('yyyy-MM-dd').format(DateTime.now()))
          .doc('spendings')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.hasData && snapshot.data!.exists) {
          amount = snapshot.data!.data()!['amount'];
          percentage = (amount / _dailyLimit) * 100;
        } else {
          amount = 0;
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 40, 20, 30),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Today Spendings',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    flex: 5,
                  ),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: Text(
                        '\$$amount',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: kSecondaryColor),
                      ),
                    ),
                    flex: 4,
                  ),
                ],
              ),
            ),
            CircularPercentIndicator(
              radius: 100,
              animation: true,
              // animationDuration: 1000,
              lineWidth: 13,
              percent: percentage <= 100 ? percentage / 100 : 1,
              center: Text(
                percentage < 1000
                    ? percentage.toStringAsFixed(1) + '%'
                    : '>999%',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              footer: Text(
                'Spending Percentage',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: kPrimaryColor,
            ),
          ],
        );
      },
    );
  }

  ExpansionTile expansionTileView(bool isItemNames, String titleName) {
    return ExpansionTile(
      key: PageStorageKey<String>(titleName),
      leading: CircleAvatar(
        child: Icon(
          Icons.view_list_rounded,
          color: Colors.white,
        ),
        backgroundColor: kSecondaryColor,
      ),
      tilePadding:
          const EdgeInsets.symmetric(horizontal: kDefaultPadding, vertical: 5),
      title: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
        child: Text(titleName),
      ),
      children: [
        isItemNames
            ? recentItems('itemNames', 'itemName')
            : recentItems('places', 'place'),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  StreamBuilder<QuerySnapshot> recentItems(
      String collectionName, String fieldName) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection(collectionName)
            .orderBy(
              fieldName,
            )
            .limit(25)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: 100,
              width: 100,
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 8,
                semanticsLabel: 'loading...',
              ),
            );
          }

          List<Widget> items = [];
          items = snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 85, vertical: 8),
                      child: Text(
                        '-> ' + data[fieldName],
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w400),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList();

          return Column(
            children: items,
          );
        });
  }
}
