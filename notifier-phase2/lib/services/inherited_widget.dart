// import 'package:flutter/material.dart';
// import 'package:frideos/frideos.dart';
// import 'package:notifier/model/notification.dart';

// // class DataHolderAndProvider<T> extends InheritedWidget{
  
// //   final T data;
  
// //   DataHolderAndProvider({this.data,Widget child}):super (child:child);

// //   @override
// //   bool updateShouldNotify(DataHolderAndProvider oldWidget) {
// //     return data!=oldWidget.data.value;
// //   }

// //   static T of<T>(BuildContext context){
// //     return (context.dependOnInheritedWidgetOfExactType(aspect: DataHolderAndProvider<T>().runtimeType) as DataHolderAndProvider<T>).data;
// //   }

// // }


// class DataHolderAndProvider extends InheritedWidget{
//   final StreamedValue<SendToChildren> data;
//   DataHolderAndProvider({this.data,Widget child}):super(child:child);
//   @override 
//   bool updateShouldNotify(DataHolderAndProvider oldWidget) {
//     return data.value!=oldWidget.data.value;
//   }
//   static DataHolderAndProvider of(BuildContext context) =>
//   context.dependOnInheritedWidgetOfExactType<DataHolderAndProvider>();
// }

// class ImageInheritedWidget extends InheritedWidget{
//   final StreamedValue<SendToChildren> data;
//   ImageInheritedWidget({this.data,Widget child}):super(child:child);
//   @override 
//   bool updateShouldNotify(ImageInheritedWidget oldWidget) {
//     return data.value!=oldWidget.data.value;
//   }
//   static ImageInheritedWidget of(BuildContext context) =>
//   context.dependOnInheritedWidgetOfExactType(aspect: ImageInheritedWidget);
// }

// // class DataHolderAndProvider extends InheritedWidget {
// //   DataHolderAndProvider({Key key,this.data, this.child}) : super(key: key, child: child);
// //   final SendToChildren data;
// //   final Widget child;

// //   static DataHolderAndProvider of(BuildContext context) {
// //     return (context.dependOnInheritedWidgetOfExactType(aspect:DataHolderAndProvider));
// //   }

// //   @override
// //   bool updateShouldNotify( DataHolderAndProvider oldWidget) {
// //     return data !=oldWidget.data;
// //   }
// // }
// // }
