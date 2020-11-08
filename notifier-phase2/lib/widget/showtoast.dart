import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:notifier/main.dart';


showInfoToast(String msg,){
  // return ToastUtils.showCustomToast(
  //   context,
  //   msg,
  //   Icon(Icons.info_outline,
  //   color: Colors.blue,size:30,),
  //   TextStyle(
  //     fontSize:15.0,
  //     color:Colors.blue,
  //   ),
  //   Theme.of(context).brightness == Brightness.dark ?Colors.grey[900]:Colors.white,
  //   Border.all(
  //     color:Colors.blue,
  //   )
  // );
  // var height;
  // if(msg.length >30){
  //   height: 
  // }
  // return showToastWidget(
  //   FlatButton.icon(
  //     onPressed: null, 
  //     icon: Icon(Icons.info_outline,
  //             color: Colors.blue,size:30,), 
  //     label:AutoSizeText(
  //            msg,
  //             style: TextStyle(
  //               fontSize:15.0,
  //               color:Colors.blue,
  //             ),
  //           ),)
  // );
  return showToastWidget(
    Container(
      // width: ,
      // height:50.0,
      constraints: BoxConstraints(
        minWidth: 120.0,
        minHeight: 50.0,
      ),
      padding:EdgeInsets.symmetric(horizontal: 15.0),
      decoration: BoxDecoration(
        color: Theme.of(MyApp.navigatorKey.currentContext).brightness == Brightness.dark ?Colors.grey[900]:Colors.white,
        border: Border.all(
          color:Colors.blue,
        ),
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Flexible(
            flex:1,
            child: Icon(Icons.info_outline,
              color: Colors.blue,size:30,),
          ),
          // SizedBox(width:10.0),
          // Spacer(flex: 1,),
          Flexible(
            flex: 9,
            child: Padding(
              padding: const EdgeInsets.only(left:8.0),
              child: AutoSizeText(
                msg,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                  fontSize:15.0,
                  color:Colors.blue,
                ),
              ),
            ),
          )
        ],
      ),
    ),
  );
}

showErrorToastWithButton(String msg, Function onTap){
   return showToastWidget(
    Container(
      constraints: BoxConstraints(
        minWidth: 120.0,
        minHeight: 50.0,
      ),
      padding:EdgeInsets.symmetric(horizontal: 15.0),
      decoration: BoxDecoration(
        color: Theme.of(MyApp.navigatorKey.currentContext).brightness == Brightness.dark ?Colors.grey[900]:Colors.white,
        border: Border.all(
          color:Colors.blue,
        ),
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Flexible(
            flex:1,
            child: Icon(Icons.info_outline,
              color: Colors.blue,size:30,),
          ),
          // SizedBox(width:10.0),
          // Spacer(flex: 1,),
          Flexible(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.only(left:8.0),
              child: AutoSizeText(
                msg,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                  fontSize:15.0,
                  color:Colors.blue,
                ),
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child:Container(
              padding: EdgeInsets.only(left: 8),
              child: FlatButton(
                child: Text('TRY AGAIN',style: TextStyle(
                  fontSize: 12,
                  color: Colors.amber),),
                onPressed: onTap,
                )
            ),)
        ],
      ),
    ),
    duration: Duration(seconds: 20),

  );
}
// showSuccessToast(context,String msg){
//   return ToastUtils.showCustomToast(
//     context,
//     msg,
//     // null,
//     Icon(
//       Feather.check_circle,
//     color: Colors.green,size:30,),
//     TextStyle(
//       fontSize:15.0,
//       color:Colors.green,
//     ),
//     Theme.of(context).brightness == Brightness.dark ?Colors.grey[900]:Colors.white,
//     Border.all(
//       color:Colors.green,
//     )
//   );
// }
showSuccessToast(String msg){
  
  return showToastWidget(
    Container(
      // width: ,
      // height:50.0,
      constraints: BoxConstraints(
        minWidth: 120.0,
        minHeight: 50.0,
      ),
      padding:EdgeInsets.symmetric(horizontal: 15.0),
      decoration: BoxDecoration(
        color: Theme.of(MyApp.navigatorKey.currentContext).brightness == Brightness.dark ?Colors.grey[900]:Colors.white,
        border: Border.all(
           color:Colors.green,
        ),
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Flexible(
            flex:1,
            child: Icon(
              Feather.check_circle,
              color: Colors.green,size:30,
            ),
          ),
          // SizedBox(width:10.0),
          // Spacer(flex: 1,),
          Flexible(
            flex: 9,
            child:  Padding(
              padding: const EdgeInsets.only(left:8.0),
              child: AutoSizeText(
                msg,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize:15.0,
                  color:Colors.green,
                ),
          ),
            ),
          )
        ],
      ),
    ),
    duration: Duration(seconds: 3),
  );
}
showErrorToast(String message){
  // return ToastUtils.showCustomToast(
  //   context,
  //   message,
  //   // null,
  //   Icon(Icons.error_outline,
  //   color: Colors.red,size:30,),
  //   TextStyle(
  //     fontSize:15.0,
  //     color:Colors.red,
  //   ),
  //   Theme.of(context).brightness == Brightness.dark ?Colors.grey[900]:Colors.white,
  //   Border.all(
  //     color: Colors.red,
  //   )
  //   );
    return showToastWidget(
      Container(
      // width: ,
      // height:50.0,
      constraints: BoxConstraints(
        minWidth: 120.0,
        minHeight: 50.0,
      ),
      padding:EdgeInsets.symmetric(horizontal: 15.0),
      decoration: BoxDecoration(
        color: Theme.of(MyApp.navigatorKey.currentContext).brightness == Brightness.dark ?Colors.grey[900]:Colors.white,
        border: Border.all(
           color:Colors.redAccent,
        ),
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Flexible(
            flex:1,
            child: Icon(FontAwesome.frown_o,
            color: Colors.red,size:30,),
          ),
          // SizedBox(width:10.0),
          // Spacer(flex: 1,),
          Flexible(
            flex: 9,
            child:  Padding(
              padding: const EdgeInsets.only(left:8.0),
              child: AutoSizeText(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize:15.0,
                  color:Colors.red,
                ),
          ),
            ),
          )
        ],
      ),
    ),
    // Container(
    //   height:50.0,
    //   padding:EdgeInsets.symmetric(horizontal: 15.0),
    //   decoration: BoxDecoration(
    //     color: Theme.of(MyApp.navigatorKey.currentContext).brightness == Brightness.dark ?Colors.grey[900]:Colors.white,
    //     border: Border.all(
    //       color:Colors.red,
    //     ),
    //     borderRadius: BorderRadius.circular(25.0),
    //   ),
    //   child: Row(
    //     mainAxisSize: MainAxisSize.min,
    //     children: <Widget>[
    //       Icon(FontAwesome.frown_o,
    //         color: Colors.red,size:30,),
    //       SizedBox(width:10.0),
    //       AutoSizeText(
    //         message,
    //         style: TextStyle(
    //           fontSize:15.0,
    //           color:Colors.red,
    //         ),
    //       )
    //     ],
    //   ),
    // ),
    duration: Duration(seconds: 3),
  );
  // return Fluttertoast.showToast(
  //   msg: message,
  //   backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black: Colors.white,
  //   textColor:Theme.of(context).brightness == Brightness.dark?Colors.white:  Colors.red, 
  // );
}