import 'dart:async';
import 'dart:convert';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_html/flutter_html.dart';

class ChartPage extends StatefulWidget{
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage>{

  @override
  Widget build(BuildContext context){
    return Scaffold(

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


    );
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