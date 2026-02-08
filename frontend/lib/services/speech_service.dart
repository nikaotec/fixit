import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;

  bool get isListening => _speech.isListening;

  Future<bool> ensureInitialized() async {
    if (_initialized) return true;
    try {
      _initialized = await _speech.initialize();
    } on PlatformException {
      _initialized = false;
    }
    return _initialized;
  }

  Future<void> start({
    required void Function(String words, bool isFinal) onResult,
    String? localeId,
  }) async {
    final available = await ensureInitialized();
    if (!available) return;
    try {
      await _speech.listen(
        localeId: localeId,
        listenMode: ListenMode.dictation,
        partialResults: true,
        onResult: (result) {
          onResult(result.recognizedWords, result.finalResult);
        },
      );
    } on PlatformException {
      // Ignore recognizer-not-available errors to avoid crashing the UI.
    }
  }

  Future<void> stop() async {
    await _speech.stop();
  }
}
