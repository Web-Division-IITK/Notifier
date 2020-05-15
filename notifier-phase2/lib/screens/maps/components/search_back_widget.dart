import 'package:notifier/screens/maps/helper/ui_helper.dart';
import 'package:flutter/material.dart';

class SearchBackWidget extends StatelessWidget {
  final double currentSearchPercent;
  final ValueChanged<String> updateAction;
  final Function(bool) animateSearch;

  const SearchBackWidget(
      {Key key,
      this.currentSearchPercent,
      this.animateSearch,
      this.updateAction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: realH(93),
      right: realW(27),
      child: Opacity(
        opacity: currentSearchPercent,
        child: Container(
          width: realW(320),
          height: realH(71),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: realW(17)),
          child: Row(
            children: <Widget>[
              Transform.scale(
                scale: currentSearchPercent,
                child: Icon(
                  Icons.search,
                  size: realW(34),
                ),
              ),
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    updateAction(value);
                  },
                  enabled: currentSearchPercent == 1.0,
                  cursorColor: Color(0xFF707070),
                  decoration: InputDecoration(
                    hintText: "Search here",
                    alignLabelWithHint: true,
                    border: InputBorder.none,
                  ),
                  style: TextStyle(fontSize: realW(22)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
