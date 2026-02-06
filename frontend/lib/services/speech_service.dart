import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;

  bool get isListening => _speech.isListening;

  Future<bool> ensureInitialized() async {
    if (_initialized) return true;
    _initialized = await _speech.initialize();
    return _initialized;
  }

  Future<void> start({
    required void Function(String words, bool isFinal) onResult,
    String? localeId,
  }) async {
    await _speech.listen(
      localeId: localeId,
      listenMode: ListenMode.dictation,
      partialResults: true,
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
      },
    );
  }

  Future<void> stop() async {
    await _speech.stop();
  }
}
