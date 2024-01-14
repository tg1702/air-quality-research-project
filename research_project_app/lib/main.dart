import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

void main() {
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
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: StreamBuilder<List>(

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
          builder: (BuildContext context, AsyncSnapshot<List> snapshot){
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
              // TODO: Show circular progress bar
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
                            NeedlePointer(value: double.parse(snapshot.data![0]))
                          ],
                        annotations: <GaugeAnnotation>[
                          GaugeAnnotation(
                            widget: Text(
                                '${snapshot.data![0]} ppm', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)
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
                                '${snapshot.data![0]} ppm',

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
                              '${snapshot.data![0]} ppm'
                          )
                        ],
                      ),

                    ]

                ),



                ];
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: children,
            );
          },


    ),
    ),
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
    _selectedIndex = index;
    //Navigator.push(context, MaterialPageRoute(builder: (context) => const Page2()) );
  }
}

const url = "https://api.thingspeak.com/channels";
const channelId = "2362111";

Stream<List> getFields()  {

  late final StreamController<List> controller;
  controller = StreamController<List>(
    onListen: () async {
      const complete_url = "$url/$channelId/feeds.json";
      final headers = {'Content-Type': 'application/json'};

      final response = await http.get(Uri.parse(complete_url), headers: headers);

      print(complete_url);
      Map<String,dynamic> originalJson = Map<String,dynamic>.from(json.decode(response.body));

      if (originalJson["feeds"] != []){
        controller.add([originalJson["feeds"][0]["field1"]]);
      }

    },
  );
  return controller.stream;
}

