import 'package:flutter/material.dart';
import 'package:notifier/data/data.dart';
import 'package:notifier/services/database.dart';

class Type1 extends StatefulWidget {
  final String id;
  Type1(this.id);
  @override
  _Type1State createState() => _Type1State();
}
List<String> selectedOptions;
class _Type1State extends State<Type1> {
  String _selectedLocation; 
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          // padding: EdgeInsets.only(top: 80.0),
          alignment: Alignment.bottomCenter,
          width: double.infinity,
          height: MediaQuery.of(context).size.height*0.2,
          child: ListView.builder(
            itemCount: selectionData.length,
            itemBuilder: (BuildContext context, int index){
              // List<String> options;
              // for( var i =0 ;i< selectionData[index].name.length;i++){
              //   options.add(selectionData[index].name[i]);
              // }
              var locations = selectionData[index].name;

              return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(selectionData[index].title),
           Center(
          child: DropdownButton(
            hint: Text('Choose..'), // Not necessary for Option 1
            value: _selectedLocation,
            onChanged: (newValue) {
              setState(() {
                _selectedLocation = newValue;
              });
            },
            items: locations.map((location) {
              return DropdownMenuItem(
                child: new Text(location),
                value: location,
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 40.0)
        ],
      ),
    );
            },
          ),
        ),
        RaisedButton(child: Text('Save'),
          onPressed: (){
            selectedOptions.add(_selectedLocation.toString());
            setState(() {
              print(_selectedLocation);
              
              submit(widget.id,selectedOptions);
            });
          },
        )
      ],
    );
  }
}
// String replaceSpace(String name){
//   return name = name.replaceAll(' ', '_');
//   //  return selectedOptions.add(name);
// }
class Layout extends StatefulWidget {
  final List<String> locations;
  final String title;
  final int index;
  Layout({this.locations,this.title,this.index});
  @override
  _LayoutState createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  // List<String> widget.locations = ['A', 'B', 'C', 'D']; // Option 2
  String _selectedLocation; 
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(widget.title),
           Center(
          child: DropdownButton(
            hint: Text('Please choose a ' + widget.title), // Not necessary for Option 1
            value: _selectedLocation,
            onChanged: (newValue) {
              setState(() {
                _selectedLocation = newValue;
              });
            },
            items: widget.locations.map((location) {
              return DropdownMenuItem(
                child: new Text(location),
                value: location,
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 40.0)
        ],
      ),
    );
  }
}