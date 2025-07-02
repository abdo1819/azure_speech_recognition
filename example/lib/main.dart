import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:azure_speech_recognition/azure_speech_recognition.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _centerText = 'Unknown';
  late AzureSpeechRecognition _speechAzure;
  String subKey = "your_key";
  String region = "your_server_region";
  String baseUrl = "https://mycontainer:5000"; // optional when using container
  String lang = "it-IT";
  bool isRecording = false;

void activateSpeechRecognizer(){
    // MANDATORY INITIALIZATION
  // Use region for the cloud API or baseUrl for the Speech container
  AzureSpeechRecognition.initializeWithEndpoint(subKey, baseUrl, lang: lang);
  
  _speechAzure.setFinalTranscription((text) {
    // do what you want with your final transcription
    setState(() {
      _centerText = text;
      isRecording = false;
    });

  });

  _speechAzure.setRecognitionStartedHandler(() {
   // called at the start of recognition (it could also not be used)
    isRecording = true;
  });

}
  @override
  void initState() {
    
    _speechAzure = AzureSpeechRecognition();

    activateSpeechRecognizer();

    super.initState();
  }

Future<void> _recognizeVoice() async {
    try {
      AzureSpeechRecognition.simpleVoiceRecognition();//await platform.invokeMethod('azureVoice');
     
    } on PlatformException catch (e) {
      print("Failed to get text '${e.message}'.");
    }
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Text("TEXT RECOGNIZED : $_centerText\n"),
              FloatingActionButton(
                onPressed: () {
                  if (!isRecording) _recognizeVoice();
                },
                child: const Icon(Icons.mic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
