import 'package:device_info_plus/device_info_plus.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplecalendar_raw/presentation/Entype.dart';

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
  var current = WordPair.random();
  var favorites = <WordPair>{};
  var uuid;

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorite() {
    if(favorites.contains(current)){
      favorites.remove(current);
    }else{
      favorites.add(current);
    }
    notifyListeners();
  }

  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    var androidDeviceInfo = await deviceInfo.androidInfo;

    if(androidDeviceInfo.isPhysicalDevice!){
      return Future.value("0");
    }
    return androidDeviceInfo.androidId; // unique ID on Android
  }

  String getUuid(){

    _getId().then((result){
      print("waa");
      print(result);
      setUuid(result!);
    });

    return uuid;
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
        page = FavoritesPage();
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
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var messages = appState.favorites;

    if(messages.isEmpty) {
      return Center(
        child: Text("No items yet"),
      );
    }

    return Center(
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text("You have ${messages.length} items."),
          ),
          for(var pair in messages)
            ListTile(
              title: Text(pair.asLowerCase),
              leading: Icon(Icons.favorite),
            )

        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var uuid = appState.getUuid();


    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 280,
            child: TextFormField(
              readOnly: true,
              decoration: const InputDecoration(
                icon: Icon(Icons.fingerprint_outlined),
                labelText: "Device Identifier",

              ),
              textAlign: TextAlign.center,
              initialValue: "id",
            ),
          )
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
