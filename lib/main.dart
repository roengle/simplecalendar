import 'package:device_info_plus/device_info_plus.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:simplecalendar_raw/presentation/Entype.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'SimpleCalendar',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Color.fromRGBO(113, 237, 204, 1.0)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var uuid;

  Future<String?> getId() async {
    var deviceInfo = DeviceInfoPlugin();
    var androidDeviceInfo = await deviceInfo.androidInfo;

    if(androidDeviceInfo.isPhysicalDevice!){
      return Future.value("0");
    }
    return androidDeviceInfo.androidId; // unique ID on Android
  }

  String getUuid(){
    getId().then((result){
      setUuid(result);
    });

    return uuid != null ? uuid : "0";
  }

  setUuid(String? result){
    uuid = result;
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  void initState(){
    MyAppState().getUuid();
    //Init code here
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch(selectedIndex){
      case 0:
        //Home Page
        page = HomePage();
        break;
      case 1:
        //Friends
        page = MyFriendPage();
        break;
      case 2:
        //Settings
        page = SettingsPage();
        break;
      case 3:
        //Info
        page = InfoPage();
        break;
      default:
        throw UnimplementedError("no widget for $selectedIndex");
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                        icon: Icon(Entype.shareable),
                        label: Text("Friends")
                    ),
                    NavigationRailDestination(
                        icon: Icon(Icons.settings),
                        label: Text("Settings")
                    ),
                    NavigationRailDestination(
                        icon: Icon(Icons.info),
                        label: Text("Info")
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}


class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source){
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}

class _HomePageState extends State<HomePage> {
  CalendarController _controller = CalendarController();
  var calendarView = CalendarView.day;

  List<Meeting> _getDataSource() {
    final List<Meeting> meetings = <Meeting>[];
    final DateTime today = DateTime.now();
    DateTime startTime =
    DateTime(today.year, today.month, today.day, 10, 0, 0);
    DateTime endTime = startTime.add(const Duration(minutes: 75));
    meetings.add(
      Meeting('CS4750 Presentation', startTime, endTime, const Color(0xFF0F8644), false)
    );

    startTime =
    DateTime(today.year, today.month, today.day, 14, 30, 0);
    endTime = startTime.add(const Duration(hours: 2));
    meetings.add(
        Meeting("HRT3120 Presentation", startTime, endTime, const Color(0xFF0F8644), false)
    );

    startTime =
        DateTime(today.year, today.month, today.day, 12, 30, 0);
    endTime = startTime.add(const Duration(minutes: 90));
    meetings.add(
        Meeting("Joe - Gym", startTime, endTime, const Color.fromRGBO(255, 0, 0, 1), false)
    );

    return meetings;
  }

  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: (){
                setState(() {
                  _controller.view = CalendarView.day;
                });
              }, child: Text("Day")),
              SizedBox(width: 10),
              ElevatedButton(onPressed: (){
                setState(() {
                  _controller.view = CalendarView.week;
                });
              }, child: Text("Week")),
              SizedBox(width: 10),
              ElevatedButton(onPressed: (){
                setState(() {
                  _controller.view = CalendarView.month;
                });
              }, child: Text("Month")),
              SizedBox(width: 10),
              ElevatedButton.icon(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (content) => NewCalendarItemPage()));
              }, icon: Icon(Icons.add), label: Text("Add"))
            ],
          ),
          Expanded(
            child: SfCalendar(
              view: calendarView,
              controller: _controller,
              monthViewSettings: MonthViewSettings(showAgenda: true),
              dataSource: MeetingDataSource(_getDataSource()),
            ),
          ),
        ]
      ),
    );
  }
}

class NewCalendarItemPage extends StatefulWidget{
  @override
  State<NewCalendarItemPage> createState() => _NewCalendarItemPageState();
}

class _NewCalendarItemPageState extends State<NewCalendarItemPage> {
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    String startDay = DateFormat("MM/dd, yyyy").format(now);
    String startTime = "00:00";
    String endDay = DateFormat("MM/dd, yyyy").format(now);
    String endTime = "00:00";

    return SafeArea(
        child: Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(icon: Icon(Icons.arrow_back),
                    onPressed: (){
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(width: 290,),
                  TextButton(onPressed: (){

                  }, child: Text("Add"),)
                ],
              ),
              SizedBox(height: 50,),
              Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width: 20,),
                      DefaultTextStyle(
                        style: Theme.of(context).textTheme.titleMedium!,
                        child: Text('Name'),
                      ),
                    ],
                  ),
                  SizedBox(height: 20,),
                  Row(
                    children: [
                      SizedBox(width: 20,),
                      DefaultTextStyle(
                        style: Theme.of(context).textTheme.titleMedium!,
                        child: Text('Start'),
                      ),
                      SizedBox(width: 140),
                      ElevatedButton(
                          onPressed: (){
                            showDatePicker(context: context,
                                initialDate: now,
                                firstDate: DateTime(now.year, now.month, 0),
                                lastDate: DateTime(now.year, now.month + 1, 0)
                            );
                            },
                          child: Text(startDay)
                      ),
                      SizedBox(width: 10,),
                      ElevatedButton(
                        onPressed: (){
                          showTimePicker(context: context,
                              initialTime: TimeOfDay(hour: 0, minute: 0)
                          );
                        },
                        child: Text(startTime),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 20,),
                      DefaultTextStyle(
                        style: Theme.of(context).textTheme.titleMedium!,
                        child: Text('End'),
                      ),
                      SizedBox(width: 148),
                      ElevatedButton(
                          onPressed: (){
                            showDatePicker(context: context,
                                initialDate: now,
                                firstDate: DateTime(now.year, now.month, 0),
                                lastDate: DateTime(now.year, now.month + 1, 0)
                            );
                          },
                          child: Text(endDay)
                      ),
                      SizedBox(width: 10,),
                      ElevatedButton(
                        onPressed: (){
                          showTimePicker(context: context,
                              initialTime: TimeOfDay(hour: 0, minute: 0)
                          );
                        },
                        child: Text(endTime),
                      )
                    ],
                  )
                ],
              )
            ],
          ),
        )
    );
  }
}

class MyFriendPage extends StatefulWidget{
  @override
  State<MyFriendPage> createState() => _MyFriendPageState();
}

class _MyFriendPageState extends State<MyFriendPage> {
  final TextEditingController _textFieldController = TextEditingController();
  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Friend ID'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              controller: _textFieldController,
              decoration:
              const InputDecoration(hintText: "Friend ID"),
            ),
            actions: <Widget>[
              MaterialButton(
                color: Colors.red,
                textColor: Colors.white,
                child: const Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              MaterialButton(
                color: Colors.green,
                textColor: Colors.white,
                child: const Text('OK'),
                onPressed: () {
                  setState(() {
                    //Really should be checking DB and getting name for it, don't have time
                    if(valueText! == "1"){
                      friends.add("Joe");
                    }
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  var friends = <String>{};
  String? codeDialog;
  String? valueText;

  Set<String> getFriends(){
    return friends;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SafeArea(
        child: Column(
          children: [
            ElevatedButton(onPressed: (){
              _displayTextInputDialog(context);
            }, child: Text("Add")),
            for(var friendName in friends)
              Row(
                children: [
                  SizedBox(width: 20,),
                  SizedBox(width: 200, child: Text(friendName)),
                  ElevatedButton.icon(onPressed: (){
                    setState(() {
                      friends.remove(friendName);
                    });
                  }, icon: Icon(Icons.delete), label: Text("Delete"))
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    String uuid = appState.getUuid();


    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: TextFormField(
                  readOnly: true,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.fingerprint_outlined),
                    labelText: "Device Identifier",
                  ),
                  textAlign: TextAlign.left,
                  initialValue: uuid,
                ),
              ),
              ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: uuid));

                    final snackBar = SnackBar(
                      content: const Text("Copied to clipboard"),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  icon: Icon(Icons.copy),
                  label: Text("Copy"))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: TextFormField(
                  readOnly: false,
                  decoration: InputDecoration(
                    icon: Icon(Icons.person),
                    labelText: "Name"
                  ),
                ),
              ),
              ElevatedButton.icon(
                  onPressed: (){
                    final snackBar = SnackBar(
                      content: const Text("Name saved!"),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  icon: Icon(Icons.save),
                  label: Text("Save")),
            ],
          ),
        ],
      ),
    );
  }
}

class InfoPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20,),
          Image(image: AssetImage("assets/Logo140.png")),
          SizedBox(height: 20,),
          Text("SimpleCalendar"),
          Text("Version 0.1.0"),
          Text("Developed by Robert Engle for CS4750")
        ],
      ),
    );
  }
}
