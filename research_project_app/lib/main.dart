/*
TODO: Do null checking in getFields to check in the case that fields contain null values.
Possible also converting the fields to double within the function itself would be cleaner

Try to reduce size of StreamBuilders, especially on second page
Dispose of controllers
*/

import 'dart:async';
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:water_bottle/water_bottle.dart';


Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Research App',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Research App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int _selectedIndex = 0;
  late Map<String,dynamic> test = {};


  @override
  void initState(){
    super.initState();

  }

  @override
  void dispose(){

    super.dispose();
  }


  late final home = Center(
    // Center is a layout widget. It takes a single child and positions it
    // in the middle of the parent.
    child: StreamBuilder<Map<String,dynamic>>(

      // Column is also a layout widget. It takes a list of children and
      // arranges them vertically. By default, it sizes itself to fit its
      // children horizontally, and tries to be as tall as its parent.
      //
      // Invoke "debug painting" (press "p" in the console, choose the
      // "Toggle Debug Paint" action from the Flutter Inspector in Android
      // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
      // to see the wireframe for each widget.
      //
      // Column has various properties to control how it sizes itself and
      // how it positions its children. Here we use mainAxisAlignment to
      // center the children vertically; the main axis here is the vertical
      // axis because Columns are vertical (the cross axis would be
      // horizontal).
      stream: getFields(),
      builder: (BuildContext context, AsyncSnapshot<Map<String,dynamic>> snapshot){
        List<Widget> children = [];
        if (snapshot.hasError){
          children = const <Widget>
          [
            Text(
                "Some Error has occurred. Check your internet connection"
            ),
          ];

        }
        else if (snapshot.connectionState ==  ConnectionState.none){

        }
        else if (snapshot.connectionState ==  ConnectionState.waiting){
           return const CircularProgressIndicator();
        }
        else if (snapshot.connectionState ==  ConnectionState.active){
          double minHeight = 16.36;
          plainBottleRef.currentState?.waterLevel = 1.0 - snapshot.data?["water_levels"] / minHeight;

          children = <Widget> [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 60.0),
              child: createGauge("Water Level", minHeight - snapshot.data?["water_levels"]),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: SizedBox(
                width: 100,
                height: 400,
                child:  WaterBottle(
                    key: plainBottleRef,
                    waterColor: Colors.blue,
                    bottleColor: Colors.lightBlue,
                    capColor: Colors.blueGrey),
              ),
            ),

          Text("Water Level: ${minHeight - snapshot.data?["water_levels"]} "),

          ];
        }

        return ListView(
            shrinkWrap: true,

            children:
            [
              Column(
                children: children,
              )
            ]
            ,
        );
      },


    ),
  );

  late final charts = Center(
    child: StreamBuilder<List>(
      stream: _getCharts(),
      builder: (BuildContext context, AsyncSnapshot<List> snapshot){
        List <Widget> children = [];

        if (snapshot.hasError){
          children = const <Widget>
          [
            Text(
                "Some Error has occurred. Check your internet connection"
            ),
          ];

        }
        else if (snapshot.connectionState ==  ConnectionState.none){

        }
        else if (snapshot.connectionState ==  ConnectionState.waiting){
          return const CircularProgressIndicator();
        }
        else if (snapshot.connectionState ==  ConnectionState.active) {


          children = <Widget>[

            SizedBox(
                width: 500,
                height: 500,
                child: Card(child:  Column(
                    children: [
                      const Text(
                          "Live Readings",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)
                      ),
                      Html(
                        data: snapshot.data?[0],

                      ),
                    ]
                ))
            ),

            SizedBox(
                width: 500,
                height: 500,
                child: Card(child:  Column(
                    children: [
                      const Text(
                        "Hourly Readings",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)
                      ),
                      Html(
                        data: snapshot.data?[1],

                      ),
                    ]
                  ))
            ),

            SizedBox(
                width: 500,
                height: 500,
                child: Card(child:  Column(
                    children: [
                      const Text(
                          "Daily Readings",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)
                      ),
                      Html(
                        data: snapshot.data?[2],

                      ),
                    ]
                ))
            ),





          ];
        }

        return ListView(
          shrinkWrap: true,
          children: [
          Column(

          children: children,
          )
          ]
        );

      },


    ),


  );

  late final bodyOptions = [
    home
  ];


  final plainBottleRef = GlobalKey<WaterBottleState>();


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: bodyOptions[0],



          // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _navigate(int index){

    setState((){
      _selectedIndex = index;
    });



  }
  final url = dotenv.env['URL'];
  final channelId = dotenv.env['CHANNEL_ID'];



  Stream<Map<String, dynamic>> getFields()  {
    StreamController<Map<String, dynamic>> controller = StreamController<Map<String,dynamic>>.broadcast();

    Timer.periodic(const Duration(seconds: 10), (Timer timer) async {
      // Fetch data from the API and update your state

            controller.add({
              "water_levels":
              await getSingleField(2362111, 1)


            });



    });

    return controller.stream;

  }

  Future<double> getSingleField(int channelId, int num) async{
    final requestUrl = "$url/$channelId/fields/$num/last.json";

    final headers = {'Content-Type': 'application/json'};


    try{
      final response = await http.get(Uri.parse(requestUrl), headers: headers);
      Map<String,dynamic> recentFeeds = Map<String,dynamic>.from(json.decode(response.body));

      return double.parse(double.parse(recentFeeds["field$num"]).toStringAsFixed(2));
    }
    catch(e){
      print(e);
      return -1;
    }

  }


  Widget createGauge(String title, double reading){
    return  SfRadialGauge(
      title: GaugeTitle(
          text: title,
          textStyle: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)
      ),
      axes: <RadialAxis>[
        RadialAxis(minimum: 0, maximum: 16.36,
          axisLabelStyle: const GaugeTextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15
          ),
          ranges: <GaugeRange>[
            GaugeRange(
                startValue: 0,
                endValue: 9.9,
                color: Colors.green,
                startWidth: 20,
                endWidth: 20),
            GaugeRange(
              startValue: 10.0,
              endValue: 11.9,
              color: Colors.yellow,
              startWidth: 20,
              endWidth: 20,
            ),
            GaugeRange(
              startValue: 12.0,
              endValue: 16.36,
              color: Colors.red,
              startWidth: 20,
              endWidth: 20,
            ),
          ],
          pointers: <GaugePointer>[
            NeedlePointer(value: (reading), enableAnimation: true)
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
                widget: Text(
                    'Current reading: $reading  inches', style: const TextStyle(fontSize: 20)
                ),
                angle: 90,
                positionFactor: 1.0
            ),
          ],
        )
      ],


    );
  }

  Widget displayHistoricalData(double hourly, double daily){
    return Row(
        mainAxisSize:MainAxisSize.min,
        children: <Widget> [
          Padding(
              padding: const EdgeInsets.fromLTRB(0, 50, 50.0, 0),
              child: Column(
                children: [
                  const Text(
                      'Previous Hourly Average',
                      style: TextStyle(fontWeight: FontWeight.bold)
                  ),

                  Text(
                    '${hourly.toString()} ppb',

                  ),
                ],
              )
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
            child: Column(
              children: [
                const Text(
                    'Previous Daily Average',
                    style: TextStyle(fontWeight: FontWeight.bold)
                ),
                Text(
                    '${daily.toString()} ppb'
                )
              ],
            ),
          ),


        ]

    );
  }

  Stream<List> _getCharts(){
    final StreamController<List> controller = StreamController<List>.broadcast();

    Timer.periodic(const Duration(seconds: 10), (Timer timer) async {
      const liveReadingsUrl = 'https://api.thingspeak.com/channels/2362111/charts/1?bgcolor=%23ffffff&color=%23000000&dynamic=true&results=60&type=line&update=15&height=auto&width=auto';
      const hourlyReadingsUrl = 'https://api.thingspeak.com/channels/2340013/charts/1?bgcolor=%23ffffff&color=%23000000&dynamic=true&results=60&type=line&update=15&height=auto&width=auto';
      const dailyReadingsUrl = 'https://api.thingspeak.com/channels/2340013/charts/2?bgcolor=%23ffffff&color=%23000000&dynamic=true&results=60&type=line&update=15&height=auto&width=auto';

      const liveIframe = """ <iframe width="460" height="250" style="border: 1px solid #cccccc;" src="$liveReadingsUrl"></iframe>""";
      const hourlyIframe = """<iframe width="460" height="250" style="border: 1px solid #cccccc;" src="$hourlyReadingsUrl"></iframe>""";
      const dailyIframe = """<iframe width="460" height="250" style="border: 1px solid #cccccc;" src="$dailyReadingsUrl"></iframe>""";

      controller.add([liveIframe, hourlyIframe, dailyIframe]);
    });




    return controller.stream;
  }
}








