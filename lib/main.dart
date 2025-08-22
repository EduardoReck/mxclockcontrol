// ignore_for_file: unused_import

import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:infinite_listview/infinite_listview.dart';
import 'package:string_validator/string_validator.dart';

import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade900),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController alarmeController = TextEditingController();
  final TextEditingController horaController = TextEditingController();
  InternetAddress serverAddress = InternetAddress('192.168.1.255');
  String? ipHost;
  RawDatagramSocket? serverSocket;
  List<int> data = utf8.encode('enxe');
  int sendPort = 40000;
  int rcvPort = 40000;
  int hora = 0, minuto = 0, segundo = 0, ahora = 0, aminuto = 0, asegundo = 0;
  String? value;

  void onSocketCreated(RawDatagramSocket newsocket) {
    serverSocket = newsocket;
    serverSocket!.broadcastEnabled = true;
  }

  void printIps() async {
    for (var interface in await NetworkInterface.list()) {
      if (kDebugMode) print('== Interface: ${interface.name} ==');
      for (var addr in interface.addresses) {
        if (Platform.isWindows) {
          if (interface.name == 'Wi-Fi') {
            ipHost = addr.address;
            int fimIP = ipHost!.lastIndexOf('.');
            serverAddress = InternetAddress(
              ipHost!.replaceRange(fimIP, null, '.255'),
            );
          }
        } else {
          if (interface.name == 'wlan0') {
            ipHost = addr.address;
            int fimIP = ipHost!.lastIndexOf('.');
            serverAddress = InternetAddress(
              ipHost!.replaceRange(fimIP, null, '.255'),
            );
          }
        }
        if (kDebugMode) {
          print(
              '${addr.address} ${addr.host} ${addr.isLoopback} ${addr.rawAddress} ${addr.type.name} ${addr.hashCode}');
        }
      }
    }
    serverSocket = await RawDatagramSocket.bind(
      InternetAddress(ipHost!),
      sendPort,
      reuseAddress: true,
    );
    serverSocket!.broadcastEnabled = true;
  }

  @override
  void initState() {
    printIps();
    serverSocket?.broadcastEnabled = true;

    if (kDebugMode) print('cheguei');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        NumberPicker(
          value: hora,
          haptics: true,
          infiniteLoop: true,
          step: 1,
          minValue: 0,
          maxValue: 23,
          onChanged: (value) {
            setState(() => hora = value);
            horaController.text = '$hora:$minuto:$segundo';
          },
        ),
        Text(
          ':',
          textScaler: TextScaler.linear(2),
        ),
        NumberPicker(
          value: minuto,
          haptics: true,
          infiniteLoop: true,
          step: 1,
          minValue: 0,
          maxValue: 59,
          onChanged: (value) {
            setState(() => minuto = value);
            horaController.text = '$hora:$minuto:$segundo';
          },
        ),
        Text(
          ':',
          textScaler: TextScaler.linear(2),
        ),
        NumberPicker(
          value: segundo,
          haptics: true,
          infiniteLoop: true,
          step: 1,
          minValue: 0,
          maxValue: 59,
          onChanged: (value) {
            setState(() => segundo = value);
            horaController.text = '$hora:$minuto:$segundo';
          },
        ),
      ],
    );
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Configurar Alarme'),
          titleTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: alarmeController,
                onSubmitted: (value) {
                  if (serverSocket == null) return;
                  if (value.isEmpty == false) {
                    if (kDebugMode) print('E$value');
                    data = utf8.encode('E$value');
                    // if (isIn(alarmeController.text)) {
                    var essaaq = alarmeController.text.split(':');
                    ahora = int.parse(essaaq[0]);
                    aminuto = int.parse(essaaq[1]);
                    asegundo = int.parse(essaaq[2]);
                    // } else {
                    //   alarmeController.text = 'invalido';
                    // }
                  }
                },
                onTap: alarmeController.clear,
                decoration: InputDecoration(
                  hintText: 'hh:mm:ss',
                  labelText: 'Definir Alarme',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      if (kDebugMode) print('E$ahora:$aminuto:$asegundo');
                      data = utf8.encode('E$ahora:$aminuto:$asegundo');
                      serverSocket!.send(data, serverAddress, sendPort);
                      /*------------------------------------------------------*/
                      //tratamento pra mostrar na roda o que eu colocar na caixa de texto
                      /*------------------------------------------------------*/
                    },
                    icon: Icon(Icons.check),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NumberPicker(
                    value: ahora,
                    haptics: true,
                    infiniteLoop: true,
                    step: 1,
                    minValue: 0,
                    maxValue: 23,
                    onChanged: (value) {
                      setState(() => ahora = value);
                      alarmeController.text = '$ahora:$aminuto:$asegundo';
                    },
                  ),
                  Text(
                    ':',
                    textScaler: TextScaler.linear(2),
                  ),
                  NumberPicker(
                    value: aminuto,
                    haptics: true,
                    infiniteLoop: true,
                    step: 1,
                    minValue: 0,
                    maxValue: 59,
                    onChanged: (value) {
                      setState(() => aminuto = value);
                      alarmeController.text = '$ahora:$aminuto:$asegundo';
                    },
                  ),
                  Text(
                    ':',
                    textScaler: TextScaler.linear(2),
                  ),
                  NumberPicker(
                    value: asegundo,
                    haptics: true,
                    infiniteLoop: true,
                    step: 1,
                    minValue: 0,
                    maxValue: 59,
                    onChanged: (value) {
                      setState(() => asegundo = value);
                      alarmeController.text = '$ahora:$aminuto:$asegundo';
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextField(
                controller: horaController,
                onSubmitted: (String value) {
                  if (serverSocket == null) return;
                  if (value.isEmpty == false) {
                    if (kDebugMode) print('A$value');
                    data = utf8.encode('A$value');
                    // if (isNumeric(horaController.text)) {
                    var essaaq = horaController.text.split(':');
                    hora = int.parse(essaaq[0]);
                    minuto = int.parse(essaaq[1]);
                    segundo = int.parse(essaaq[2]);
                    // } else {
                    // horaController.text = 'invalido';
                    // }
                  }
                },
                onTap: horaController.clear,
                decoration: InputDecoration(
                  hintText: 'hh:mm:ss',
                  labelText: 'Definir Hora',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      if (kDebugMode) print('A$hora:$minuto:$segundo');
                      data = utf8.encode('A$hora:$minuto:$segundo');
                      serverSocket!.send(data, serverAddress, sendPort);
                    },
                    icon: Icon(Icons.check),
                  ),
                ),
              ),
              SizedBox(height: 16),
              row,
              SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (kDebugMode) print('B');
                      data = utf8.encode('B');
                      serverSocket!.send(data, serverAddress, sendPort);
                    },
                    child: Text('Salva Hora Atual'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (kDebugMode) print('F');
                      data = utf8.encode('F');
                      serverSocket!.send(data, serverAddress, sendPort);
                    },
                    child: Text('Salva Alarme Atual'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (kDebugMode) print('C');
                      data = utf8.encode('C');
                      serverSocket!.send(data, serverAddress, sendPort);
                    },
                    child: Text('Carrega Hora Salva'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (kDebugMode) print('G');
                      data = utf8.encode('G');
                      serverSocket!.send(data, serverAddress, sendPort);
                    },
                    child: Text('Carrega Alarme Salvo'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ButtonStyle(),
                onPressed: () {
                  if (kDebugMode) print('D');
                  data = utf8.encode('D');
                  serverSocket!.send(data, serverAddress, sendPort);
                },
                child: Text('Atualiza para Hora Atual'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
