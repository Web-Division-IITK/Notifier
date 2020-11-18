
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:notifier/main.dart';
import 'package:notifier/services/database.dart';
import 'package:intl/intl.dart';
import 'package:notifier/colors.dart';
import 'package:notifier/database/reminder.dart';
import 'package:notifier/model/posts.dart';
import 'package:notifier/constants.dart';
import 'package:notifier/screens/event_management/create_event.dart';
import 'package:notifier/screens/event_management/event_description.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/screens/posts/post_desc.dart';
import 'package:table_calendar/table_calendar.dart';

final Map<DateTime, List> _holidays = {
  DateTime(2020, 1, 1): [Posts(title: 'New Year\'s Day')],
  DateTime(2020, 1, 6): [Posts(title: 'Epiphany')],
  DateTime(2020, 10, 14): [Posts(title: 'Valentine\'s Day')],
  DateTime(2020, 10, 21): [Posts(title: 'Easter Sunday')],
  DateTime(2020, 10, 22): [Posts(title: 'Easter Monday')],
};

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> with TickerProviderStateMixin{
  Map<DateTime, List<Posts>> _events;
  List<Posts> _selectedEvents;
  List<Posts> _selectedDayHolidays;
  AnimationController _animationController;
  CalendarController _calendarController;
  DateTime _selectedDay = DateTime.now();
  final DateTime _today = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day);
    @override
  void initState() {
    super.initState();
    _events = {};
    _calendarController = CalendarController();
    _selectedDay = DateTime(_selectedDay.year,_selectedDay.month,_selectedDay.day);
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
    _selectedDay = DateTime(day.year,day.month,day.day);
    print(holidays);
    print(_events);
    setState(() {
      _selectedDayHolidays = _holidays[_selectedDay]?.cast<Posts>();
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
    _events = await DatabaseProvider().getAllPostswithDate(first);
    
    print(_events);
    setState(() {
      print('setting state .... ');
        _selectedDayHolidays = _holidays[_selectedDay]?.cast<Posts>();
        _selectedEvents = _events[DateTime(_selectedDay.year,_selectedDay.month,_selectedDay.day)]??[];
      } );
    
    print('CALLBACK: _onCalendarCreated');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Schedule"),
        /*actions: [
          Switch(value: Theme.of(context).brightness == Brightness.dark,
           onChanged: (value){
             DynamicTheme.of(context).setBrightness(
                                Theme.of(context).brightness == Brightness.light
                                  ? Brightness.dark
                                  : Brightness.light);
           })
        ],*/
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: (){
      //     Navigator.push(context, MaterialPageRoute(
      //       builder: (context) => CreateEditEvent(
      //         'create', 0, Posts(owner: id,)))).then((value) => setState((){}));
      //   },
      //   child: Icon(Icons.add),
      //   tooltip: "Create event",
      // ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            // height: MediaQuery.of(context).size.height * 0.45,
            child: _buildTableCalendar(),
          ),
          Divider(),
          // Align(
          //   alignment: Alignment.topRight,
          //   child: FlatButton(
          //     onPressed: (){}, 
          //     child: Text(
          //       'Check TimeTable',
          //       style: TextStyle(
          //         color: Colors.blue,
          //       ),
          //     )
          //   ),
          // ),
          Expanded(child: _buildEvents()),
        ],
      )
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
        selectedColor: CustomColors(context).accentColor,
        todayColor: CustomColors(context).primaryColor,
        markersColor: CustomColors(context).markerColor,
        outsideDaysVisible: false,
        holidayStyle: TextStyle().copyWith(color: Colors.red,fontWeight: FontWeight.w900),
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
            backgroundColor: CustomColors(context).bgColor,
            cancelStyle: TextStyle(
              color: CustomColors(context).textColor,
              fontSize: 20,
              fontFamily: 'Raleway'
            ),
            doneStyle: TextStyle(
              color: Colors.blue,
              fontSize: 20,
              fontFamily: 'Raleway'
            ),
            itemStyle: TextStyle(
              color: CustomColors(context).textColor,
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
          color: CustomColors(context).textColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        formatButtonVisible: false,
        centerHeaderTitle: true,
        leftChevronIcon: Icon(Icons.chevron_left, color: CustomColors(context).iconColor),
        rightChevronIcon: Icon(Icons.chevron_right, color: CustomColors(context).iconColor),
      ),
      builders: CalendarBuilders(
        holidayDayBuilder: (context, date, events) {
          date = DateTime(date.year,date.month,date.day);
          return Tooltip(
            message: _holidays[date].length == 1 ?'${_holidays[date][0].title}' : '${_holidays[date][0].title}, ....' ,
            child: Container(
              margin: const EdgeInsets.all(4.0),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: _selectedDay == date ?
                    CustomColors(context).accentColor :
                    (date == _today?
                    CustomColors(context).primaryColor :
                    Colors.transparent) ,
              ),
              child: Center(
                child: Text(
                  '${date.day}',
                  style: TextStyle().copyWith(color: _selectedDay != date ?Colors.red:Colors.white,fontWeight: FontWeight.w900),
                ),
              ),
            ),
          );
        },
      ),
      weekendDays: [DateTime.sunday],
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: CustomColors(context).textColor),
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
      calendarController: _calendarController,
      events: _events,
      holidays: _holidays,
      initialCalendarFormat: CalendarFormat.month,
      formatAnimation: FormatAnimation.slide,
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendStyle: TextStyle().copyWith(color: Colors.blue[800]),
        holidayStyle: TextStyle().copyWith(color: Colors.red),
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
  Widget _buildEvents() {
    return ListView(
      shrinkWrap: true,
      children: [
        Padding(
          padding: const EdgeInsets.only(top:8.0, bottom: 10,left: 10),
          child: Text('Saved Events',style:TextStyle(fontSize: 20),
            // textAlign: TextAlign.center,
          )
        ),
        FutureBuilder(
          future: DatabaseProvider().getAllEventsWithCouncil(
            _selectedDay.millisecondsSinceEpoch, _selectedDay.add(Duration(hours: 23,minutes: 59)).millisecondsSinceEpoch,
            NOTF_TYPE_CREATE
          ),
          builder: (context, AsyncSnapshot<List<Posts>> snapshot){
            if(snapshot != null && 
              snapshot.connectionState == ConnectionState.done){
              if(snapshot.hasData){
                return _buildEventList(snapshot.data?? [],false);
              }else{
                //TODO: implement for this and others
                return _buildEventList([],false);
              }
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
        _selectedDayHolidays != null && _selectedDayHolidays.isNotEmpty?
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top:8.0, bottom: 10,left: 10),
              child: Text('Holidays',style:TextStyle(fontSize: 20),
                // textAlign: TextAlign.center,
              )
            ),
            _buildEventList(_selectedDayHolidays, true)
          ],
        ): Container(),
        // Padding(
        //   padding: const EdgeInsets.only(top:8.0, bottom: 10,left: 10),
        //   child: Text('My Events',style:TextStyle(fontSize: 20),
        //     // textAlign: TextAlign.center,
        //   )
        // ),
        // FutureBuilder(
        //   future: DatabaseProvider().getAllEventsWithCouncil(
        //     _selectedDay.millisecondsSinceEpoch, _selectedDay.add(Duration(hours: 23,minutes: 59)).millisecondsSinceEpoch,
        //     EVENT_TYPE
        //   ),
        //   builder: (context, AsyncSnapshot<List<Posts>> snapshot){
        //     if(snapshot != null && 
        //       snapshot.connectionState == ConnectionState.done){
        //       if(snapshot.hasData){
        //         return _buildEventList(snapshot.data?? [],true);
        //       }else{
        //         //TODO: implement for this and others
        //         return _buildEventList([],true);
        //       }
        //     }
        //     return Center(child: CircularProgressIndicator());
        //   },
        // ),
      ],
    );
  }
  Widget _buildEventList(List<Posts> _eventList,bool isCreated) {
    void handleClick(String value,String _postId,DateTime date,int index) {
        // print(date);
        date = DateTime(date.year,date.month,date.day);
        // print(date);
        switch (value) {
          case 'Delete': print("Delted");
            // DatabaseProvider().deletePost(_postId);
            if(_events[date] != null){
              ReminderNotification('Event has been cancelled',id: _events[date][index].timeStamp.toSigned(31)).cancel;
            // print(_calendarController.visibleEvents[date]);
              if(_events[date].length != 1){
                _events[date].removeAt(index);
              }
              // else _calendarController.visibleEvents.remove(date);
              else setState(()=>_events.remove(date));
              DatabaseProvider().deletePost(_postId);
              DBProvider().updateQuery(GetPosts(queryColumn: REMINDER,queryData: 0,id: _postId));
              // else setState(()=>_calendarController.visibleEvents.remove(date));
              print(_calendarController.visibleEvents);
            }
            break;
          case 'Settings':
            break;
        }
    }
    return Column(
      children: [
        _eventList == null || _eventList.isEmpty ?
        Container(
          margin:
            const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            title: Text(
            isCreated == true?
            'You have\'t created any events for this date. Tap \'+\' button to create one!!!' :
            'You don\'t have any saved event for this date',
              textAlign: TextAlign.center,
              style:TextStyle(
                color: CustomColors(context).textColor
              )
            ),
            enabled: false,
          ),
        )
        : Column(
          children: List.generate(_eventList.length, 
            (index) =>
          /*)
          _eventList
          .map((event) =>*/ Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: CustomColors(context).textColor
                )
                // color: CustomColors(context).exapndedTileColor,
              ),
              width: MediaQuery.of(context).size.width,
                margin:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                child: ListTile(
                  trailing: isCreated? null :
                    PopupMenuButton<String>(
                      onSelected: (value)=>handleClick(
                        value,
                        _eventList[index].id,
                        DateTime.fromMillisecondsSinceEpoch(_eventList[index].startTime),
                        index
                      ),
                      itemBuilder: (BuildContext context) {
                        return {'Delete',}.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      },
                    ),
                  // },
                  focusColor: CustomColors(context).accentColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: AutoSizeText(
                    _eventList[index].title,
                    // "bvv m nmmbjb nmbjk jb vhjv gb bj vgchb bnvjhbjfyhj  ghgjbvfjhfuihjb dtytuge5tfdsaweerdvb ghhkjnmnjiokljn ",
                    maxLines: 1,
                    maxFontSize: 17,
                    minFontSize: 16,
                    overflow: TextOverflow.ellipsis,
                     style:TextStyle(
                      color: CustomColors(context).textColor
                    )
                  ),
                  subtitle: isCreated? 
                  null
                  : Row(
                    children: [
                      Flexible(
                        // flex: 6,
                        child: AutoSizeText(
                          DateFormat("d/M/y hh:mm a").format(
                            DateTime.fromMillisecondsSinceEpoch(_eventList[index].startTime)
                          ).toUpperCase(),
                          maxLines: 1,
                        ),
                      ),
                      Text(" - "),
                      Flexible(
                        // flex: 5,
                        child: AutoSizeText(
                          DateFormat("d/M/y hh:mm a").format(
                            DateTime.fromMillisecondsSinceEpoch(_eventList[index].endTime)
                          ).toUpperCase(),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  enabled: !isCreated,
                  onTap: () =>Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context){
                        // if(_eventList[index].type == NOTF_TYPE_CREATE){
                          return FeatureDiscovery(
                            child: PostDescription(
                              listOfPosts: _eventList, 
                              type: PostDescType.DISPLAY,
                              index:index,
                          ));
                        // }else{
                        //   return EventDescription(
                        //     listOfPosts: _eventList,
                        //     type: 'display',
                        //     index: index,
                        //   );
                        // }
                      }
                    )
                  ).then((value)async{
                    List<Posts> post = await DatabaseProvider().getAllEventsWithCouncil(
                      _selectedDay.millisecondsSinceEpoch, _selectedDay.add(Duration(hours: 23,minutes: 59)).millisecondsSinceEpoch,
                      NOTF_TYPE_CREATE
                    );
                    if(post == null || post.isEmpty)
                      _calendarController.visibleEvents.remove(_selectedDay);
                    else _calendarController.visibleEvents.update(_selectedDay, 
                      (value) => value..addAll(post?.cast<dynamic>()), ifAbsent: () => post?.cast<dynamic>(),);
                    setState(() {});
                  }
                  ),
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
