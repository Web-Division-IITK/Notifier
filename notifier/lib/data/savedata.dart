// @override
//   void initState() {
//     super.initState();
//     _loadCounter();
//   }

//   //Loading counter value on start
//   _loadCounter() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _counter = (prefs.getInt('counter') ?? 0);
//     });
//   }

//   //Incrementing counter after click
//   _incrementCounter() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _counter = (prefs.getInt('counter') ?? 0) + 1;
//       prefs.setInt('counter', _counter);
//     });
//   }

