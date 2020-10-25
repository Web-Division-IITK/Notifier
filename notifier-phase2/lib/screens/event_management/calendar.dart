
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:notifier/database/reminder.dart';
import 'package:notifier/model/posts.dart';
import 'package:table_calendar/table_calendar.dart';

final Map<DateTime, List> _holidays = {
  DateTime(2020, 1, 1): ['New Year\'s Day'],
  DateTime(2020, 1, 6): ['Epiphany'],
  DateTime(2020, 10, 14): ['Valentine\'s Day'],
  DateTime(2020, 10, 21): ['Easter Sunday'],
  DateTime(2020, 10, 22): ['Easter Monday'],
};

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> with TickerProviderStateMixin{
  Map<DateTime, List<PostsSort>> _events;
  List<PostsSort> _selectedEvents;
  AnimationController _animationController;
  CalendarController _calendarController;
    final _selectedDay = DateTime.now();
    @override
  void initState() {
    super.initState();
    _events = {};
    // _events = await DatabaseProvider().getAllPostswithDate(_selectedDay);
    // _events = {
    //   _selectedDay.subtract(Duration(days: 30)): [
    //     'Event A0',
    //     'Event B0',
    //     'Event C0'
    //   ],
    //   _selectedDay.subtract(Duration(days: 27)): ['Event A1'],
    //   _selectedDay.subtract(Duration(days: 20)): [
    //     'Event A2',
    //     'Event B2',
    //     'Event C2',
    //     'Event D2'
    //   ],
    //   _selectedDay.subtract(Duration(days: 16)): ['Event A3', 'Event B3'],
    //   _selectedDay.subtract(Duration(days: 10)): [
    //     'Event A4',
    //     'Event B4',
    //     'Event C4'
    //   ],
    //   _selectedDay.subtract(Duration(days: 4)): [
    //     'Event A5',
    //     'Event B5',
    //     'Event C5'
    //   ],
    //   _selectedDay.subtract(Duration(days: 2)): ['Event A6', 'Event B6'],
    //   _selectedDay: ['Event A7', 'Event B7', 'Event C7', 'Event D7'],
    //   _selectedDay.add(Duration(days: 1)): [
    //     'Event A8',
    //     'Event B8',
    //     'Event C8',
    //     'Event D8'
    //   ],
    //   _selectedDay.add(Duration(days: 3)):
    //       Set.from(['Event A9', 'Event A9', 'Event B9']).toList(),
    //   _selectedDay.add(Duration(days: 7)): [
    //     'Event A10',
    //     'Event B10',
    //     'Event C10'
    //   ],
    //   _selectedDay.add(Duration(days: 11)): ['Event A11', 'Event B11'],
    //   _selectedDay.add(Duration(days: 17)): [
    //     'Event A12',
    //     'Event B12',
    //     'Event C12',
    //     'Event D12'
    //   ],
    //   _selectedDay.add(Duration(days: 22)): ['Event A13', 'Event B13'],
    //   _selectedDay.add(Duration(days: 26)): [
    //     'Event A14',
    //     'Event B14',
    //     'Event C14'
    //   ],
    // };

    // _selectedEvents = _events[_selectedDay] ?? [];
    _calendarController = CalendarController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events, List holidays) {
    print('CALLBACK: _onDaySelected');
    // print(events);
    // print(day);
    print(_events);
    setState(() {
      _selectedEvents = _events[DateTime(day.year,day.month,day.day)]??[];
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) async{
    _events = await DatabaseProvider().getAllPostswithDate(first);
    setState((){});
    print('CALLBACK: _onVisibleDaysChanged');
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) async{
    _events = await DatabaseProvider().getAllPostswithDate(first)/*.then((events){
      setState(() {
        _selectedEvents = events[_selectedDay]??[];
      } );
      return events;
    })*/;
    
    print(_events);
    setState(() {
      print('setting state .... ');
        _selectedEvents = _events[DateTime(_selectedDay.year,_selectedDay.month,_selectedDay.day)]??[];
      } );
    
    print('CALLBACK: _onCalendarCreated');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Switch(value: Theme.of(context).brightness == Brightness.dark,
           onChanged: (value){
             DynamicTheme.of(context).setBrightness(
                                Theme.of(context).brightness == Brightness.light
                                  ? Brightness.dark
                                  : Brightness.light);
           })
        ],
      ),
      body: /*FutureBuilder(
        future: DatabaseProvider().getAllPostswithDate(_selectedDay),
        builder: (context, _events){
          if(_events.connectionState == ConnectionState.done){
            _selectedEvents = _events.data[_selectedDay] ?? [];
            return */Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                // Switch out 2 lines below to play with TableCalendar's settings
                //-----------------------
                _buildTableCalendar(),
                // _buildTableCalendarWithBuilders(),
                // const SizedBox(height: 8.0),
                // _buildButtons(),
                const SizedBox(height: 8.0),
                Expanded(child: _buildEventList()),
              ],
            )/*;
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),*/
    );
  }

  // Simple TableCalendar configuration (using Styles)
  Widget _buildTableCalendar() {
    return TableCalendar(
      calendarController: _calendarController,
      events: _events,
      holidays: _holidays,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        selectedColor: Theme.of(context).accentColor,
        todayColor: Theme.of(context).primaryColor,
        markersColor: Theme.of(context).brightness == Brightness.dark?
            Colors.amberAccent
            : Colors.blueGrey[900],
        outsideDaysVisible: false,
        holidayStyle: TextStyle(color:Colors.red),
        weekendStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark?
            Colors.white70
            : Colors.black45)
      ),
      onHeaderTapped: (date)async{
        return await DatePicker.showDatePicker(context,
          maxTime: DateTime(2050,12,31),
          minTime: DateTime(2018,1,1), 
          currentTime: date,
          theme: DatePickerTheme(
            itemHeight: 55,
            backgroundColor: Theme.of(context).backgroundColor,
            cancelStyle: TextStyle(
              color: Theme.of(context).highlightColor,
              fontSize: 20,
              fontFamily: 'Raleway'
            ),
            doneStyle: TextStyle(
              color: Colors.blue,
              fontSize: 20,
              fontFamily: 'Raleway'
            ),
            itemStyle: TextStyle(
              color: Theme.of(context).highlightColor,
              fontSize: 22,
              fontFamily: 'Raleway'
            ),
            containerHeight: MediaQuery.of(context).size.height *0.4,

          ),
          onConfirm: (newDate) async{
            if(newDate.month != date.month){
              return await DatabaseProvider().getAllPostswithDate(newDate).then((value){
                setState(() => _events = value??{});
                // print(_events);
                _calendarController.setSelectedDay(newDate, runCallback: true);
                // return value;
              }).catchError((onError) {print(onError); return {};});
            }
            return _calendarController.setSelectedDay(newDate, runCallback: true);
          },
        );
        
      },
      headerStyle: HeaderStyle(
        formatButtonTextStyle:
            TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        leftChevronIcon: Icon(Icons.chevron_left, color: Theme.of(context).highlightColor),
        rightChevronIcon: Icon(Icons.chevron_right, color: Theme.of(context).highlightColor),
      ),
      weekendDays: [DateTime.sunday],
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: Theme.of(context).highlightColor),
        weekendStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark?
            Colors.white70
            : Colors.black45 ),
      ),
      
      onDaySelected: _onDaySelected,
      onVisibleDaysChanged: _onVisibleDaysChanged,
      onCalendarCreated: _onCalendarCreated,
    );
  }

  // More advanced TableCalendar configuration (using Builders & Styles)
  Widget _buildTableCalendarWithBuilders() {
    return TableCalendar(
      locale: 'pl_PL',
      calendarController: _calendarController,
      events: _events,
      holidays: _holidays,
      initialCalendarFormat: CalendarFormat.month,
      formatAnimation: FormatAnimation.slide,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      availableGestures: AvailableGestures.all,
      availableCalendarFormats: const {
        CalendarFormat.month: '',
        CalendarFormat.week: '',
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendStyle: TextStyle().copyWith(color: Colors.blue[800]),
        holidayStyle: TextStyle().copyWith(color: Colors.blue[800]),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekendStyle: TextStyle().copyWith(color: Colors.blue[600]),
      ),
      headerStyle: HeaderStyle(
        centerHeaderTitle: true,
        formatButtonVisible: false,
      ),
      builders: CalendarBuilders(
        selectedDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
            child: Container(
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.only(top: 5.0, left: 6.0),
              color: Colors.deepOrange[300],
              width: 100,
              height: 100,
              child: Text(
                '${date.day}',
                style: TextStyle().copyWith(fontSize: 16.0),
              ),
            ),
          );
        },
        todayDayBuilder: (context, date, _) {
          return Container(
            margin: const EdgeInsets.all(4.0),
            padding: const EdgeInsets.only(top: 5.0, left: 6.0),
            color: Colors.amber[400],
            width: 100,
            height: 100,
            child: Text(
              '${date.day}',
              style: TextStyle().copyWith(fontSize: 16.0),
            ),
          );
        },
        markersBuilder: (context, date, events, holidays) {
          final children = <Widget>[];

          if (events.isNotEmpty) {
            children.add(
              Positioned(
                right: 1,
                bottom: 1,
                child: _buildEventsMarker(date, events),
              ),
            );
          }

          if (holidays.isNotEmpty) {
            children.add(
              Positioned(
                right: -2,
                top: -2,
                child: _buildHolidaysMarker(),
              ),
            );
          }

          return children;
        },
      ),
      onDaySelected: (date, events, holidays) {
        _onDaySelected(date, events, holidays);
        _animationController.forward(from: 0.0);
      },
      onVisibleDaysChanged: _onVisibleDaysChanged,
      onCalendarCreated: _onCalendarCreated,
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: _calendarController.isSelected(date)
            ? Colors.brown[500]
            : _calendarController.isToday(date)
                ? Colors.brown[300]
                : Colors.blue[400],
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  Widget _buildHolidaysMarker() {
    return Icon(
      Icons.add_box,
      size: 20.0,
      color: Colors.blueGrey[800],
    );
  }

  Widget _buildButtons() {
    final dateTime = _events.keys.elementAt(_events.length - 2);

    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RaisedButton(
              child: Text('Month'),
              onPressed: () {
                setState(() {
                  _calendarController.setCalendarFormat(CalendarFormat.month);
                });
              },
            ),
            RaisedButton(
              child: Text('2 weeks'),
              onPressed: () {
                setState(() {
                  _calendarController
                      .setCalendarFormat(CalendarFormat.twoWeeks);
                });
              },
            ),
            RaisedButton(
              child: Text('Week'),
              onPressed: () {
                setState(() {
                  _calendarController.setCalendarFormat(CalendarFormat.week);
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        RaisedButton(
          child: Text(
              'Set day ${dateTime.day}-${dateTime.month}-${dateTime.year}'),
          onPressed: () {
            _calendarController.setSelectedDay(
              DateTime(dateTime.year, dateTime.month, dateTime.day),
              runCallback: true,
            );
          },
        ),
      ],
    );
  }

  Widget _buildEventList() {
    return ListView(
      children: [
        _selectedEvents == null || _selectedEvents.isEmpty ?
          Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text('No events for this date'),
                  onTap: () => print('tapped!'),
                ),
          )
        : Column(
          children: _selectedEvents
          .map((event) => Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 0.8),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                margin:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text(event.title),
                  onTap: () => print('$event tapped!'),
                ),
              ))
          .toList(),
        )
      ]
        
    );
  }
}

// import 'package:flutter_calendar_carousel/classes/event.dart';
// import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
// import 'package:syncfusion_flutter_calendar/calendar.dart';

// class Calendar extends StatefulWidget {
//   @override
//   _CalendarState createState() => _CalendarState();
// }

// class _CalendarState extends State<Calendar> {
//   DateTime _currentDate;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: CalendarCarousel<Event>(
//         onDayPressed: (DateTime date, List<Event> events) {
//         this.setState(() => _currentDate = date);
//       },
//       weekendTextStyle: TextStyle(
//         color: Colors.red,
//       ),
//       thisMonthDayBorderColor: Colors.grey,

// //      weekDays: null, /// for pass null when you do not want to render weekDays
// //      headerText: Container( /// Example for rendering custom header
// //        child: Text('Custom Header'),
// //      ),
//       customDayBuilder: (   /// you can provide your own build function to make custom day containers
//         bool isSelectable,
//         int index,
//         bool isSelectedDay,
//         bool isToday,
//         bool isPrevMonthDay,
//         TextStyle textStyle,
//         bool isNextMonthDay,
//         bool isThisMonthDay,
//         DateTime day,
//       ) {
//           /// If you return null, [CalendarCarousel] will build container for current [day] with default function.
//           /// This way you can build custom containers for specific days only, leaving rest as default.

//           // Example: every 15th of month, we have a flight, we can place an icon in the container like that:
//           // if (day.day == 15) {
//           //   return Center(
//           //     child: Icon(Icons.local_airport),
//           //   );
//           // } else {
//             return null;
//           // }
//       },
//       weekFormat: false,
//       markedDatesMap: EventList(events: {}),
//       height: 420.0,
//       selectedDateTime: _currentDate,
//       daysHaveCircularBorder: null, /// null for not rendering any border, true for circular border, false for rectangular border
//       )
//       // SfCalendar(
//       //   view: CalendarView.month,
//       // )
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
// // import "package:googleapis_auth/auth_io.dart";
// // import 'package:googleapis/calendar/v3.dart';
// import 'package:notifier/screens/event_management/calendar_client.dart';

// class Calendar extends StatefulWidget {
//   @override
//   _CalendarState createState() => _CalendarState();
// }

// class _CalendarState extends State<Calendar> {
//   CalendarClient calendarClient = CalendarClient();
//   DateTime startTime = DateTime.now();
//   DateTime endTime = DateTime.now().add(Duration(days: 1));
//   TextEditingController _eventName = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: _body(context),
//     );
//   }
//   _body(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Row(
//             children: <Widget>[
//               FlatButton(
//                   onPressed: () {
//                     DatePicker.showDateTimePicker(context,
//                         showTitleActions: true,
//                         minTime: DateTime(2019, 3, 5),
//                         maxTime: DateTime(2200, 6, 7), onChanged: (date) {
//                       print('change $date');
//                     }, onConfirm: (date) {
//                       setState(() {
//                         this.startTime = date;
//                       });
//                     }, currentTime: DateTime.now(), locale: LocaleType.en);
//                   },
//                   child: Text(
//                     'Event Start Time',
//                     style: TextStyle(color: Colors.blue),
//                   )),
//               Text('$startTime'),
//             ],
//           ),
//           Row(
//             children: <Widget>[
//               FlatButton(
//                   onPressed: () {
//                     DatePicker.showDateTimePicker(context,
//                         showTitleActions: true,
//                         minTime: DateTime(2019, 3, 5),
//                         maxTime: DateTime(2200, 6, 7), onChanged: (date) {
//                       print('change $date');
//                     }, onConfirm: (date) {
//                       setState(() {
//                         this.endTime = date;
//                       });
//                     }, currentTime: DateTime.now(), locale: LocaleType.en);
//                   },
//                   child: Text(
//                     'Event End Time',
//                     style: TextStyle(color: Colors.blue),
//                   )),
//               Text('$endTime'),
//             ],
//           ),
//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: TextField(
//               controller: _eventName,
//               decoration: InputDecoration(hintText: 'Enter Event name'),
//             ),
//           ),
//           RaisedButton(
//               child: Text(
//                 'Insert Event',
//               ),
//               color: Colors.grey,
//               onPressed: () {
//                 //log('add event pressed');
//                 calendarClient.insert(
//                   _eventName.text,
//                   startTime,
//                   endTime,
//                 );
//               }),
//         ],
//       ),
//     );
//   }
// }

// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:feature_discovery/feature_discovery.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_icons/flutter_icons.dart';
// import 'package:intl/intl.dart';
// import 'package:notifier/database/reminder.dart';
// import 'package:notifier/model/posts.dart';
// import 'package:notifier/screens/posts/post_desc.dart';
// import 'package:notifier/services/database.dart';
// import 'package:notifier/widget/showtoast.dart';

// class Calendar extends StatefulWidget {
//   @override
//   _CalendarState createState() => _CalendarState();
// }

// class _CalendarState extends State<Calendar> {
//   DateTime time = DateTime.now();
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//           appBar: AppBar(title: Text("Events")),
//           floatingActionButton: FloatingActionButton(
//             onPressed: () {},
//             child: Icon(Icons.add),
//           ),
//           body: ListView(
//             shrinkWrap: true,
//             children: <Widget>[
//               Container(
//                 height: MediaQuery.of(context).size.height * 0.45,
//                 child: CalendarDatePicker(
//                   selectableDayPredicate: (time){
                    
//                   },
//                   initialDate: DateTime.now(),
//                   firstDate: DateTime(
//                     DateTime.now().year - 10,
//                   ),
//                   lastDate: DateTime(DateTime.now().year + 30),
//                   onDateChanged: (dateTime) {
//                     setState(() {
//                       time = dateTime;
//                     });
//                   },
//                   currentDate: DateTime.now(),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 0,left: 16,bottom: 10),
//                 child: Text(
//                   "Personal Events",
//                   style: TextStyle(fontSize: 18.0),
//                   textAlign: TextAlign.left,
//                 ),
//               ),
//               Card(
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16.0)),
//                 child: Container(
//                   padding: EdgeInsets.fromLTRB(16.0, 0, 16, 0),
//                   child: FutureBuilder(
//                       future: /* Future.sync(() => (*/
//                           DatabaseProvider().getAllPostswithDate(time),
//                       // )),
//                       builder: (context, snapshot) {
//                         switch (snapshot.connectionState) {
//                           case ConnectionState.done:
//                             List<PostsSort> array =
//                                 (snapshot == null || snapshot.data == null)
//                                     ? []
//                                     : snapshot.data;
//                             if (array.length == 0) {
//                               return Container(
//                                 height: 80.0,
//                                 child: Center(
//                                   child: Text('No post available right now'),
//                                 ),
//                               );
//                             }
//                             return Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 displayCalendarContent(array),
//                                 Container(
//                                     padding: EdgeInsets.only(bottom: 8),
//                                     alignment: Alignment.bottomRight,
//                                     child: RichText(
//                                         text: TextSpan(
//                                             text: "See All ...",
//                                             style: TextStyle(
//                                                 fontFamily: "Raleway",
//                                                 fontSize: 12.0,
//                                                 color: Colors.blue),
//                                             recognizer: TapGestureRecognizer()
//                                               ..onTap = () {
//                                                 // Navigator.of(context).push(MaterialPageRoute(
//                                                 //       //   builder: (BuildContext context) {
//                                                 //       //     return AllPostGetData(widget.userModel);}));
//                                               }))),
//                               ],
//                             );
//                             break;
//                           default:
//                             return Container(
//                                 height: 80,
//                                 child: Center(
//                                   child: CircularProgressIndicator(),
//                                 ));
//                         }
//                       }),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 16,left: 16,bottom: 10),
//                 child: Text(
//                   "My Events",
//                   style: TextStyle(fontSize: 18.0),
//                   textAlign: TextAlign.left,
//                 ),
//               ),
//               Card(
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16.0)),
//                 child: Container(
//                   padding: EdgeInsets.fromLTRB(16.0, 0, 16, 0),
//                   child: FutureBuilder(
//                       future: /* Future.sync(() => (*/
//                           DatabaseProvider().getAllPostswithDate(time),
//                       // )),
//                       builder: (context, snapshot) {
//                         switch (snapshot.connectionState) {
//                           case ConnectionState.done:
//                             List<PostsSort> array =
//                                 (snapshot == null || snapshot.data == null)
//                                     ? []
//                                     : snapshot.data;
//                             if (array.length == 0) {
//                               return Container(
//                                 height: 80.0,
//                                 child: Center(
//                                   child: Text('No post available right now'),
//                                 ),
//                               );
//                             }
//                             return Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 displayCalendarContent(array),
//                                 Container(
//                                     padding: EdgeInsets.only(bottom: 8),
//                                     alignment: Alignment.bottomRight,
//                                     child: RichText(
//                                         text: TextSpan(
//                                             text: "See All ...",
//                                             style: TextStyle(
//                                                 fontFamily: "Raleway",
//                                                 fontSize: 12.0,
//                                                 color: Colors.blue),
//                                             recognizer: TapGestureRecognizer()
//                                               ..onTap = () {
//                                                 // Navigator.of(context).push(MaterialPageRoute(
//                                                 //       //   builder: (BuildContext context) {
//                                                 //       //     return AllPostGetData(widget.userModel);}));
//                                               }))),
//                               ],
//                             );
//                             break;
//                           default:
//                             return Container(
//                                 height: 80,
//                                 child: Center(
//                                   child: CircularProgressIndicator(),
//                                 ));
//                         }
//                       }),
//                 ),
//               )
//             ],
//           )),
//     );
//   }

//   void student() async {
//     await DatabaseProvider().getAllPosts().then((value) {
//       value.forEach((element) {
//         // element.startTime
//       });
//     });
//   }

//   Widget displayCalendarContent(List<PostsSort> array) {
//     return ListView.builder(
//         // padding: EdgeInsets.only(top: 16),
//         shrinkWrap: true,
//         itemCount: array.length > 1 ? 1 : array.length,
//         itemBuilder: (content, index) {
//           return Container(
//               // child: StreamBuilder(
//               //   stream: Stream.periodic(Duration(minutes: 1)),
//               //   builder: (context, snapshot) {
//               child: Tile(
//             key: ValueKey(DateTime.now().millisecondsSinceEpoch),
//             index: index,
//             arrayWithPrefs: array,
//           )
//               //   }
//               // ),
//               );
//         });
//   }
// }

// class Tile extends StatefulWidget {
//   final int index;
//   final List<PostsSort> arrayWithPrefs;
//   Tile({key, this.index, /*this.time,*/ this.arrayWithPrefs /*,this.stream*/})
//       : super(key: key);
//   @override
//   _TileState createState() => _TileState();
// }

// class _TileState extends State<Tile> {
//   // Timer timer;
//   var time;
//   @override
//   void initState() {
//     super.initState();
//     var timeStamp = DateTime.fromMillisecondsSinceEpoch(
//         widget.arrayWithPrefs[widget.index].timeStamp);
//     time = DateFormat("hh:mm a, dd MMMM yyyy").format(timeStamp);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 5.0,
//       margin: EdgeInsets.symmetric(vertical: 10.0),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(16.0),
//         onTap: () async {
//           return await Navigator.of(context)
//               .push(MaterialPageRoute(builder: (BuildContext context) {
//             return FeatureDiscovery(
//                 child: PostDescription(
//               listOfPosts: widget.arrayWithPrefs,
//               type: 'display',
//               index: widget.index,
//             ));
//           }));
//         },
//         child: Stack(
//           children: <Widget>[
//             Positioned(
//               bottom: 15.0,
//               right: 0.0,
//               child: IconButton(
//                   tooltip: 'Save Post',
//                   icon: widget.arrayWithPrefs[widget.index].bookmark
//                       ? Icon(MaterialIcons.bookmark)
//                       : Icon(MaterialIcons.bookmark_border),
//                   onPressed: () async {
//                     setState(() {
//                       widget.arrayWithPrefs[widget.index].bookmark =
//                           !widget.arrayWithPrefs[widget.index].bookmark;
//                     });
//                     // DataHolderAndProvider.of(context).data.value.globalPostMap[widget.arrayWithPrefs[index].id].bookmark = false ;
//                     // DataHolderAndProvider.of(context).data.value.globalPostsArray.firstWhere((test) => test.id == widget.arrayWithPrefs[index].id).bookmark = false ;
//                     // DataHolderAndProvider.of(context).data.refresh();
//                     await DBProvider().updateQuery(GetPosts(
//                         queryColumn: 'bookmark',
//                         queryData: (widget.arrayWithPrefs[widget.index].bookmark
//                             ? 1
//                             : 0),
//                         id: widget.arrayWithPrefs[widget.index].id));
//                     if (widget.arrayWithPrefs[widget.index].bookmark == true) {
//                       showSuccessToast('Bookmarked');
//                     } else {
//                       // showInfoToast('Removed From Saved');
//                     }
//                     // printPosts(await DBProvider().getPosts(GetPosts(queryColumn: 'id',queryData: widget.arrayWithPrefs[widget.index].id)));
//                   }),
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 Container(
//                   padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
//                   child: AutoSizeText(widget.arrayWithPrefs[widget.index].sub,
//                       // 'Science and Texhnology Council',
//                       textAlign: TextAlign.start,
//                       style: TextStyle(
//                         color: Theme.of(context).brightness == Brightness.light
//                             ? Colors.blueGrey
//                             : Colors.white70,
//                         // fontWeight: FontStyle.italic,
//                         fontSize: 10.0,
//                       )),
//                 ),
//                 Container(
//                   // alignment: Alignment.center,
//                   constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width - 90),
//                   padding: EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 10.0),
//                   child: AutoSizeText(widget.arrayWithPrefs[widget.index].title,

//                       // 'Sit commodo fugiat duis consectetur sunt ipsum cupidatat adipisicing mollit et magna duis.',
//                       minFontSize: 15.0,
//                       overflow: TextOverflow.ellipsis,
//                       maxLines: 2,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 17.0,
//                       )),
//                 ),
//                 Container(
//                   padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 5.0),
//                   constraints: BoxConstraints(
//                     maxWidth: MediaQuery.of(context).size.width - 116.0,
//                   ),
//                   // decoration: BoxDecoration(
//                   //   border: Border.all(
//                   //     color: Colors.black
//                   //   )
//                   // ),
//                   child: AutoSizeText(
//                     // timenot['message'],
//                     widget.arrayWithPrefs[widget.index].message,
//                     // 'Dolor consectetur in dolore anim reprehenderit djhbjdhsbvelit pariatur veniam nostrud id ex exercitation.',
//                     maxLines: 2,
//                     style: TextStyle(
//                       fontSize: 12.0,
//                       color: Theme.of(context).brightness == Brightness.light
//                           ? Colors.grey[850]
//                           : Colors.white70,
//                     ),
//                   ),
//                 ),
//                 Container(
//                     padding: EdgeInsets.fromLTRB(0.0, 0.0, 16.0, 5.0),
//                     alignment: Alignment.bottomRight,
//                     child: Text(
//                       time,
//                       style: TextStyle(
//                         fontSize: 8.0,
//                         color: Theme.of(context).brightness == Brightness.light
//                             ? Colors.grey
//                             : Colors.white70,
//                       ),
//                     )),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
