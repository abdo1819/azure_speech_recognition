import Flutter
import UIKit
import MicrosoftCognitiveServicesSpeech

public class SwiftAzureSpeechRecognitionPlugin: NSObject, FlutterPlugin {
  var transcriber: SPXConversationTranscriber?
  var channel: FlutterMethodChannel?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "azure_speech_recognition", binaryMessenger: registrar.messenger())
    let instance = SwiftAzureSpeechRecognitionPlugin()
    instance.channel = channel
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "transcribeWithDiarization" {
      guard let args = call.arguments as? [String: Any],
            let key = args["subscriptionKey"] as? String,
            let region = args["region"] as? String,
            let language = args["language"] as? String else {
        result(FlutterError(code: "bad_args", message: nil, details: nil))
        return
      }
      startTranscriber(key: key, region: region, language: language)
      result(true)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }

  private func startTranscriber(key: String, region: String, language: String) {
    do {
      let config = try SPXSpeechConfiguration(subscription: key, region: region)
      config.speechRecognitionLanguage = language
      config.setProperty("SpeechServiceResponse_DiarizeIntermediateResults", value: "true")
      let audio = SPXAudioConfiguration()
      transcriber = try SPXConversationTranscriber(speechConfiguration: config, audioConfiguration: audio)

      try transcriber?.addTranscribingEventHandler({ [weak self] _, evt in
        if let text = evt.result.text {
          let speaker = evt.result.speakerId ?? ""
          self?.channel?.invokeMethod("speech.onSpeech", arguments: "\(speaker):\(text)")
        }
      })

      try transcriber?.startTranscribing()
    } catch {
      channel?.invokeMethod("speech.onException", arguments: error.localizedDescription)
    }
  }
}
