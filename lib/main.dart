import 'package:device_info_plus/device_info_plus.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:simplecalendar_raw/presentation/Entype.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

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
    MyAppState().getId();
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
        //Favorites
        page = MyCalendarPage();
        break;
      case 2:
        //Friends
        page = Placeholder();
        break;
      case 3:
        //Settings
        page = SettingsPage();
        break;
      case 4:
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
                      icon: Icon(Entype.calendar),
                      label: Text('My Schedule'),
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


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Center(
      
    );
  }
}

class MyCalendarPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Center(

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

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
