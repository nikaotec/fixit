import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;

  bool get isListening => _speech.isListening;

  Future<bool> ensureInitialized() async {
    if (_initialized) return true;
    try {
      _initialized = await _speech.initialize(
        debugLogging: true,
        onError: (error) => print('Speech error: $error'),
      );
    } on PlatformException catch (e) {
      print('Speech initialization failed: $e');
      _initialized = false;
    }
    return _initialized;
  }

  Future<void> start({
    required void Function(String words, bool isFinal) onResult,
    String? localeId,
  }) async {
    final available = await ensureInitialized();
    if (!available) {
      print('Speech not available');
      return;
    }
    try {
      await _speech.listen(
        localeId: localeId,
        partialResults: true,
        onResult: (result) {
          print(
            'Speech result: ${result.recognizedWords} (final: ${result.finalResult})',
          );
          onResult(result.recognizedWords, result.finalResult);
        },
      );
    } on PlatformException catch (e) {
      print('Speech listen failed: $e');
    }
  }

  Future<void> stop() async {
    await _speech.stop();
  }
}
