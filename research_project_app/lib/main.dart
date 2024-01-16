import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


import 'charts.dart';

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


  late final body_1 = Center(
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

          children = <Widget> [
            SfRadialGauge(
              title: const GaugeTitle(
                  text: 'PPM Meter',
                  textStyle: TextStyle(fontSize: 50, fontWeight: FontWeight.bold)
              ),
              axes: <RadialAxis>[
                RadialAxis(minimum: 0, maximum: 300, ranges: <GaugeRange>[
                  GaugeRange(
                      startValue: 0,
                      endValue: 90,
                      color: Colors.green,
                      startWidth: 10,
                      endWidth: 10),
                  GaugeRange(
                    startValue: 91,
                    endValue: 220,
                    color: Colors.yellow,
                    startWidth: 10,
                    endWidth: 10,
                  ),
                  GaugeRange(
                    startValue: 221,
                    endValue: 300,
                    color: Colors.red,
                    startWidth: 10,
                    endWidth: 10,
                  ),
                ],
                  pointers: <GaugePointer>[
                    NeedlePointer(value: double.parse(snapshot.data!["field1"]))
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                        widget: Text(
                            '${snapshot.data!["field1"]} ppm', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)
                        ),
                        angle: 90,
                        positionFactor: 0.5
                    ),
                  ],
                )
              ],


            ),

            Row(
                mainAxisSize:MainAxisSize.min,
                children: <Widget> [
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 50.0, 0),
                      child: Column(
                        children: [
                          const Text(
                              'Daily Average',
                              style: TextStyle(fontWeight: FontWeight.bold)
                          ),

                          Text(
                            '${snapshot.data!["fields"]} ppm',

                          ),
                        ],
                      )
                  ),


                  Column(
                    children: [
                      const Text(
                          'Weekly Average',
                          style: TextStyle(fontWeight: FontWeight.bold)
                      ),
                      Text(
                          '${test} ppm'
                      )
                    ],
                  ),

                ]

            ),



          ];
        }

        return ListView(
            shrinkWrap: true,

            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: children,
                ),
              )

            ]
        );
      },


    ),
  );

  late final body_2 = Center(
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
                        "Daily Readings",
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
                          "Weekly Readings",
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
    body_1,
    body_2
  ];





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
      body: bodyOptions[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.stacked_line_chart), label: 'Charts'),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.black,
              onTap: _navigate,

          ),


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
    print("Starting");
    Timer.periodic(const Duration(seconds: 10), (Timer timer) async {
      // Fetch data from the API and update your state

          final completeUrl = "$url/$channelId/feeds.json?results=1";
          final headers = {'Content-Type': 'application/json'};


          final response = await http.get(Uri.parse(completeUrl), headers: headers);

          Map<String,dynamic> originalJson = Map<String,dynamic>.from(json.decode(response.body));

          if (originalJson["feeds"] != []){
            controller.add({
              "field1":
              originalJson["feeds"][0]["field1"]
              ,
            });



          }

    });
    return controller.stream;



  }

  Stream<List> _getCharts(){
    final StreamController<List> controller = StreamController<List>.broadcast();

    Timer.periodic(const Duration(seconds: 30), (Timer timer) async{
      final url = dotenv.env['URL'];
      final channelId = dotenv.env['CHANNEL_ID'];

      final liveReadingsUrl = '$url/$channelId/charts/1?bgcolor=%23ffffff&color=%23d62020&dynamic=true&results=60&type=line&update=15&height=auto&width=auto';
      final dailyReadingsUrl = '$url/$channelId/charts/2?bgcolor=%23ffffff&color=%23d62020&dynamic=true&results=60&type=line&update=15&height=auto&width=auto';
      final weeklyReadingsUrl = '$url/$channelId/charts/3?bgcolor=%23ffffff&color=%23d62020&dynamic=true&results=60&type=line&update=15&height=auto&width=auto';

      final liveIframe = """"<iframe width="460" height="350" style="border: 1px solid #cccccc;" src="$liveReadingsUrl"></iframe>""";
      final dailyIframe = """<iframe width="460" height="350" style="border: 1px solid #cccccc;" src="$dailyReadingsUrl"></iframe>""";
      final weeklyIframe = """<iframe width="460" height="350" style="border: 1px solid #cccccc;" src="$weeklyReadingsUrl"></iframe>""";

      controller.add([liveIframe, dailyIframe, weeklyIframe]);
    });



    return controller.stream;
  }
}








