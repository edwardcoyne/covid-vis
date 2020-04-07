import 'package:charts_flutter/flutter.dart';
import 'package:covid_vis/data_store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';
import 'log.dart';
import 'package:flutter/services.dart';
import 'graph.dart';
import 'data.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'covid_vis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<DataPoint> data = [];
  List<DataPoint> deltaData = [];
  DataStore dataStore;

  @override
  void initState() {
    super.initState();
    Init();
  }

  int Now() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  void Init() {
    // Keep the device awake and screen on.
    Wakelock.enable();

    // Hide the system UI.
    SystemChrome.setEnabledSystemUIOverlays([]);
    log.info("Initialized");
    dataStore = new DataStore((List<DataPoint> data) {
      setState(() {
        this.data = data;

        // List is changes from one day to the next, we drop the first as it
        // isn't meaningful.
        DataPoint last = DataPoint(null, 0, 0);
        this.deltaData = data.map((entry) {
          var out = DataPoint(entry.date, entry.confirmed - last.confirmed, entry.deaths - last.deaths);
          last = entry;
          return out;
        }).toList();
        if (this.deltaData.length > 0) {
          this.deltaData.removeAt(0);
        }
      });
    });
    dataStore.StartProcessing();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Expanded(child: LogView()),
        resizeToAvoidBottomPadding: false,
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage("assets/background.png"),
              ),
            ),
            child:
          Column(
          children: <Widget>[
            Expanded(
              child: SimpleLineChart.withData(
                  data, MaterialPalette.blue, MaterialPalette.deepOrange, "Total - SF Peninsula"),
            ),
            Expanded(
              child: SimpleLineChart.withData(
                  deltaData, MaterialPalette.blue, MaterialPalette.deepOrange, "New Each Day"),
            ),
          ],
        )));
  }
}
