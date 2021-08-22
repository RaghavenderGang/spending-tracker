import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spending_tracker/components/expansion_tile.dart';
import 'package:spending_tracker/components/filled_outline_button.dart';
import 'package:spending_tracker/components/item_card.dart';
import 'package:spending_tracker/const/constants.dart';
import 'package:spending_tracker/models/items_list.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({
    Key? key,
  }) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  DateTime? _date = DateTime.now();
  late DateFormat formatter;
  late String uid;
  late String? name;

  bool isToday = true;
  bool isViewAll = false;
  bool isSelectDate = false;
  DateTime? queryDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    name = FirebaseAuth.instance.currentUser!.displayName;
    uid = FirebaseAuth.instance.currentUser!.uid;

    formatter = DateFormat('yyyy-MM-dd');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(
                kDefaultPadding, 0, kDefaultPadding, kDefaultPadding),
            color: kPrimaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FillOutlineButton(
                  press: () {
                    if (!isToday) {
                      setState(() {
                        isViewAll = false;
                        isToday = true;
                        isSelectDate = false;

                        queryDate = DateTime.now();
                      });
                    }
                  },
                  text: 'Today',
                  isFilled: isToday,
                ),
                FillOutlineButton(
                  press: () {
                    if (!isViewAll) {
                      setState(() {
                        isViewAll = true;
                        isToday = false;
                        isSelectDate = false;
                      });
                    }
                  },
                  text: 'View all',
                  isFilled: isViewAll,
                ),
                FillOutlineButton(
                  press: () {
                    setState(() {
                      isViewAll = false;
                      isToday = false;
                      isSelectDate = true;

                      queryDate = _date;
                    });
                  },
                  text: 'Select date',
                  isFilled: isSelectDate,
                ),
              ],
            ),
          ),
          Expanded(
            child:
                isViewAll ? viewAllStreamBuilder() : singleDateStreamBuilder(),
          ),
        ],
      ),
      floatingActionButton: isSelectDate
          ? FloatingActionButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _date!,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                setState(() {
                  isViewAll = false;
                  isToday = false;
                  isSelectDate = true;

                  if (date != null) {
                    _date = date;
                  }
                  queryDate = _date;
                });
              },
              tooltip: 'Select date',
              backgroundColor: kPrimaryColor,
              child: Icon(
                Icons.date_range_outlined,
                size: 30,
                color: Colors.white,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  StreamBuilder<QuerySnapshot> singleDateStreamBuilder() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection(formatter.format(queryDate!))
          .orderBy('name')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Container(
              height: 100,
              width: 100,
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 8,
                semanticsLabel: 'loading...',
              ),
            ),
          );
        }

        List<ItemCard> _items = [];
        _items.add(ItemCard(
            item: Item(
                isDate: true,
                date: DateFormat.yMMMMEEEEd().format(queryDate!))));

        _items = _items +
            snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              final item = Item(
                  name: data['name'],
                  place: data['place'],
                  price: data['price'],
                  quantity: data['quantity']);
              return ItemCard(item: item);
            }).toList();

        return _items.length == 1
            ? Column(
                children: [
                  _items[0],
                  SizedBox(
                    height: 50,
                  ),
                  Icon(
                    Icons.cloud_off,
                    size: 100,
                  ),
                  Text('No data found!'),
                ],
              )
            : ListView.builder(
                itemCount: _items.length + 1,
                itemBuilder: (context, index) {
                  if (index == _items.length) {
                    return SizedBox(
                      height: 60,
                    );
                  } else {
                    return _items[index];
                  }
                },
              );
      },
    );
  }

  StreamBuilder<QuerySnapshot> viewAllStreamBuilder() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('dates')
          .orderBy('date', descending: true)
          .limit(25)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Container(
              height: 100,
              width: 100,
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 8,
                semanticsLabel: 'loading...',
              ),
            ),
          );
        }

        List<DateTime> _data =
            snapshot.data!.docs.map((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          return DateFormat('yyyy-MM-dd').parse(data['date']);
        }).toList();

        return _data.length == 0
            ? Column(
                children: [
                  SizedBox(
                    height: 100,
                  ),
                  Icon(
                    Icons.cloud_off,
                    size: 100,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text('No data found!'),
                ],
              )
            : CustomExpansionTile(data: _data);
      },
    );
  }
}
