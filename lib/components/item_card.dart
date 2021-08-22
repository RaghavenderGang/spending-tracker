import 'package:flutter/material.dart';
import 'package:spending_tracker/const/constants.dart';
import 'package:spending_tracker/models/items_list.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({
    Key? key,
    required this.item,
  }) : super(key: key);

  final Item item;

  @override
  Widget build(BuildContext context) {
    return !item.isDate
        ? listItem(context)
        : Padding(
            padding: const EdgeInsets.symmetric(
                vertical: kDefaultPadding * 0.5,
                horizontal: kDefaultPadding * 4),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: kDefaultPadding * 0.75),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey[400]
                    : Colors.blueGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  item.date,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
  }

  InkWell listItem(BuildContext context) {
    return InkWell(
      onTap: () {},
      highlightColor: kSecondaryColor,
      splashColor: kSecondaryColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: kDefaultPadding, vertical: kDefaultPadding * 0.75),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 7,
                  child: Text(
                    item.name,
                    maxLines: 3,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    '\$' + item.price.toString(),
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Row(
              children: [
                Expanded(
                  flex: 7,
                  child: Opacity(
                    opacity: 0.64,
                    child: Text(
                      item.place,
                      maxLines: 3,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(),
                    ),
                  ),
                ),
                Spacer(),
                Expanded(
                  flex: 4,
                  child: Opacity(
                    opacity: 0.64,
                    child: Text(
                      'x' + item.quantity.toString(),
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: TextStyle(),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
