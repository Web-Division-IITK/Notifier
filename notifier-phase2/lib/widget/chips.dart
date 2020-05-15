import 'package:flutter/material.dart';

class CreateChips extends StatefulWidget {
  var tags;
  String _tag;
  CreateChips(this._tag,this.tags);
  @override
  _CreateChipsState createState() => _CreateChipsState();
}

class _CreateChipsState extends State<CreateChips> {

  // List<Widget> tagAsChips = [];
          Iterable<Widget> get tagAsChips sync*{
            if(widget.tags != null && widget.tags.length!=0){
            for (var i in widget.tags){
              // tagAsChips.add(
               yield Chip(label: Text(i.toString()),
                  deleteIcon: Icon(Icons.close),
                  onDeleted: (){
                    setState(() {
                      // widget._tag.replaceAll((i + ' ;'), '');
                      widget.tags.remove(i);
                      // widget.
                      
                      print(widget._tag);
                      // tagAsChips.removeWhere((tag){
                      //   return 
                      // })
                    });
                  },
                // )
                );
            } 
          }
          else{
            yield Container();
          }
            
          }
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5.0,
      children: tagAsChips.toList(),
    );
  }
}