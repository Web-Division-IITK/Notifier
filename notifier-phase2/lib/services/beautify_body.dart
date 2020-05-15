import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:notifier/widget/showtoast.dart';
// import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';

class BeautifyPostBody extends StatefulWidget {
  final String body;
  final TextStyle linkStyle;
  final TextStyle textStyle;
  BeautifyPostBody({this.body,this.linkStyle,this.textStyle});
  @override
  _BeautifyPostBodyState createState() => _BeautifyPostBodyState();
}

class _BeautifyPostBodyState extends State<BeautifyPostBody> {
  List<TextSpan> textSpansOfBody = [];
// final CallsAndMessagesService _service = locator<CallsAndMessagesService>();
  @override
  void initState() {
    var body = urlify(widget.body);
    body = molify(body);
    body = emailify(body);
    var bodyList = body.split('<a href=');
    bodyList = makeList(bodyList, '<a mob=');
    bodyList = makeList(bodyList, '<a mailto=');
    // var bodyList = widget.body.split(' ');
    print('jhvhj\'\'' + bodyList.length.toString());
    for(var i in bodyList){
      editingbodyList(i);
    }
    super.initState();
  }
   makeList(bodyList,String splitString){
    var temp = [];
    for (var i in bodyList) {
      temp += i.split(splitString);
    }
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    return 
        RichText(

           text: TextSpan(
            // text: body,
              style:widget.textStyle,
//                  ??TextStyle(
//                  color: Colors.black,
//                  fontSize: 18.0,
//                  fontFamily: "Raleway"
//              ),
//          ),
            children: textSpansOfBody
          ),
      //   ),
      //   RaisedButton(onPressed: (){
      //     // _service.sendEmail('adtgupta@gmail.com');
      //     launchMail('adtgupta@gmail.com');
      //   },
      //   child: Text('jygjh'),
      //   )
      textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
      // ],
    );
  }
  void editingbodyList(String i){
    if(i.startsWith('www.') || i.startsWith('https://')|| i.startsWith('http://')){
      var b= i.split('/a>');
      var v= b[0].replaceAll('https://', '');
      v= v.replaceAll('http://', '');
      textSpansOfBody.add(
        TextSpan(
          text: v,
          style: TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = (){
                launchUrl(b[0]);
            },
        ),);
      textSpansOfBody.add(
          TextSpan(
            text: b[1],
            style:widget.textStyle 
          ),
        );
      
    }
    else if(i.contains(RegExp(r'[a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9_-]+'))){
        var b= i.split('/a>');
      textSpansOfBody.add(TextSpan(
          text: b[0] ,
          style: TextStyle(
            color: Colors.blue,
            // decoration: TextDecoration.underline
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = (){
                // _service.sendEmail(b[0]);
                launchMail(b[0]);
            },
        ),);
      textSpansOfBody.add(
          TextSpan(
            text: b[1],
            style:widget.textStyle 
          ),
        );
      
    }
    else if(i.startsWith(RegExp(r'(?:[+0]91(-|[\s])?)?[0-9]{10,12}\b'))){
      // print('mobileno' + i);
        var b= i.split('/a>');
      textSpansOfBody.add(TextSpan(
          text: b[0] ,
          style: TextStyle(
            color: Colors.blue,
            // decoration: TextDecoration.underline
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = (){
                launchCaller(b[0]);
            },
        ),);
      textSpansOfBody.add(
          TextSpan(
            text: b[1],
            style:widget.textStyle??TextStyle(
              color: Colors.black,
              fontSize: 18.0,
              fontFamily: "Raleway"
            )
          ),
        );
      
    }
    else{
        textSpansOfBody.add(
          TextSpan(
            text: i + ' ',
            style:widget.textStyle 
          ),
        );
      // }
    }
  }
  checkAndBreakemail(String i){
    
  }
  emailify(String text){
    var regex = RegExp(r'[a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9_-]+');
    return text.splitMapJoin(regex,
      onMatch: (url) => '<a mailto=' + url.group(0).toString()+'/a>',
      onNonMatch: (n) => '${n.substring(0)}'
    );
  }
  molify(String text){
    var regex = RegExp(r'\W(?:[+0]91(-|[\s])?)?[0-9]{10,12}\b');
    return text.splitMapJoin(regex,
      onMatch: (url) {
        var v = url.group(0).toString();
        return v[0] + '<a mob=' + v.substring(1) + '/a>';
      },
      onNonMatch: (n) => '${n.substring(0)}'
    );
  }
  urlify(String text) {
    var urlRegex = RegExp(r'((https?:\/\/)|(www.))[^\s]+\w(\/)?');
    // var v= text.split(urlRegex);
    return text.splitMapJoin(urlRegex,
      onMatch: (url) => '<a href=' + url.group(0).toString()+'/a>',
      onNonMatch: (n) => '${n.substring(0)}'
    );
    // return text.replaceAll(urlRegex,(url){

    // } );
    // or alternatively
    // return text.replace(urlRegex, '<a href="$1">$1</a>')
}
}

launchUrl(link) async {
    print(link);
    // if(link.startsWith('https://') || link.startsWith('http://')){
      print('islink');
      if (await canLaunch(link)) {

      await launch(link);
    } else {
      // throw 'Could not launch $link';
      showErrorToast('Could not launch url');
    }
    // }
    // else if(link.url.contains('mailto:')){
    //   var url = link.url;
    //   print(link.url);
      
    //    if (await canLaunch(url)) {
    //   await launch(url);
    // } else {
    //   throw 'Could not launch $link';
    // }
    // }
    // else{
    //   var url = "tel:$link.url";   
    // if (await canLaunch(url)) {
    //    await launch(url);
    // } else {
    //   throw 'Could not launch $url';
    // } 
    // }
    
  }
Future launchCaller(String number) async {
    var url = "tel:$number";   
    if (await canLaunch(url)) {
       await launch(url);
    } else {
      showErrorToast('Could not launch number');
      // throw 'Could not launch $url';
    }   
}
launchMail(String mailId) async{
  print(mailId);
  // final String subject = "Subject:";
  //   final String stringText = "Same Message:";
  //   String uri = 'mailto:administrator@gmail.com?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(stringText)}';
  //   if (await canLaunch(uri)) {
  //     await launch(uri);
  //   } else {
  //     print("No email client found");
  //   }
      try {
        final Email email = Email(
          body: '',
          subject: '',
          recipients: ['$mailId'],
          // cc: ['cc@example.com'],
          // bcc: ['bcc@example.com'],
          // attachmentPaths: ['/path/to/attachment.zip'],
          isHTML: false,
        );

        await FlutterEmailSender.send(email);
      } catch (e) {
        print(e);
        showErrorToast('Could not launch mail app');
      }
    // } else {
    //   print( 'Could not launch $url');
    //   showErrorToast('Could not launch mail app');
    // }
}

// GetIt locator = GetIt();

// void setupLocator() {
//   locator.registerSingleton(CallsAndMessagesService());
// }
// class CallsAndMessagesService {
//   void call(String number) => launch("tel://$number");

//   void sendSms(String number) => launch("sms:$number");

//   void sendEmail(String email) => launch("mailto:$email");
// }
