import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spending_tracker/components/item_card.dart';
import 'package:spending_tracker/const/constants.dart';
import 'package:spending_tracker/models/items_list.dart';

class CustomExpansionTile extends StatefulWidget {
  CustomExpansionTile({Key? key, required this.data}) : super(key: key);
  final List<DateTime> data;

  @override
  _CustomExpansionTileState createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        if (index == widget.data.length) {
          return EntryItem(DateTime(1800));
        } else {
          return EntryItem(widget.data[index]);
        }
      },
      itemCount: widget.data.length + 1,
    );
  }
}

class EntryItem extends StatelessWidget {
  EntryItem(this.entry);

  final DateTime entry;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return _buildTiles(entry);
  }

  Widget _buildTiles(DateTime entry) {
    return entry != DateTime(1800)
        ? ExpansionTile(
            key: PageStorageKey<DateTime>(entry),
            leading: CircleAvatar(
              child: Icon(
                Icons.view_list_rounded,
                color: Colors.white,
              ),
              backgroundColor: kSecondaryColor,
            ),
            tilePadding: const EdgeInsets.symmetric(
                horizontal: kDefaultPadding, vertical: 5),
            title: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
              child: Text(
                DateFormat('EEE, MMM d, yyyy').format(entry),
              ),
            ),
            children: [
              singleDateStreamBuilder(entry),
              SizedBox(
                height: 10,
              )
            ],
          )
        : SizedBox(
            height: 80,
          );
  }

  StreamBuilder<QuerySnapshot> singleDateStreamBuilder(DateTime _date) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection(DateFormat('yyyy-MM-dd').format(_date))
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

        List<ItemCard> _items =
            snapshot.data!.docs.map((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          final item = Item(
              name: data['name'],
              place: data['place'],
              price: data['price'],
              quantity: data['quantity']);
          return ItemCard(item: item);
        }).toList();

        return Column(
          children: _items,
        );
      },
    );
  }
}
