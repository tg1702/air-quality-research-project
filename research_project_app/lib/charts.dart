import 'dart:async';
import 'dart:convert';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_html/flutter_html.dart';

import 'main.dart';

class MainChartPage extends StatelessWidget {
  const MainChartPage({super.key});

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
      home: const ChartPage(),
    );
  }
}

class ChartPage extends StatefulWidget{
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage>{

  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("Research App"),
      ),

      body: Center(
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
          // TODO: Show circular progress bar
          }
          else if (snapshot.connectionState ==  ConnectionState.active) {

            children = <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Html(
                      data: snapshot.data?[0]
                  ),

                ]
              ),
              const Text(
                'Testing'
              )

            ];
          }

            return Column(
            mainAxisSize: MainAxisSize.min,
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


    );


  }

  void _navigate(int index){
    _selectedIndex = index;
    if (_selectedIndex == 0)
      Navigator.push(context, MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Research App')) );
  }
}

Stream<List> _getCharts(){
  late final StreamController<List> controller;

  controller = StreamController<List>(
    onListen: () async{
      final url = dotenv.env['URL'];
      final channelId = dotenv.env['CHANNEL_ID'];

      final liveReadingsUrl = '$url/$channelId/charts/1?bgcolor=%23ffffff&color=%23d62020&dynamic=true&results=60&type=line&update=15';
      final headers = {"Content-Type": "text/html"};

      final response =  await http.get(Uri.parse(liveReadingsUrl), headers: headers);


      final iframe = """"<iframe width="450" height="260" style="border: 1px solid #cccccc;" src="$liveReadingsUrl"></iframe>""";


      controller.add([iframe]);
    }
  );
  return controller.stream;
}

