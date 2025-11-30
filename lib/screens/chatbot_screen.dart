import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:convert';
import 'package:http/http.dart' as http;

// Configure secrets via --dart-define at run/build time to avoid hardcoding keys.
// HuggingFace (optional fallback)
const String kHfApiKey = String.fromEnvironment('HF_API_KEY');
const String kHfModelId = String.fromEnvironment(
  'HF_MODEL_ID',
  defaultValue: 'facebook/blenderbot-400M-distill',
);
String get _hfApiUrl =>
    'https://api-inference.huggingface.co/models/$kHfModelId';

// Groq OpenAI-compatible Chat Completions API
// Read API key from --dart-define only; do not hardcode secrets.
const String kGroqApiKey = String.fromEnvironment('GROQ_API_KEY');
const String kGroqModel = String.fromEnvironment(
  'GROQ_MODEL',
  defaultValue: 'meta-llama/llama-4-scout-17b-16e-instruct',
);
const String _groqChatUrl = 'https://api.groq.com/openai/v1/chat/completions';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      await _speech.initialize();
    } catch (_) {}
  }

  Future<String> _getAIResponse(String userMessage) async {
    // Prefer Groq if key is provided; otherwise fall back to HF if configured.
    if (kGroqApiKey.isNotEmpty) {
      return _getGroqResponse(userMessage);
    }
    if (kHfApiKey.isNotEmpty) {
      return _getHuggingFaceResponse(userMessage);
    }
    return 'Chatbot not configured: pass GROQ_API_KEY or HF_API_KEY via --dart-define.';
  }

  Future<String> _getGroqResponse(String userMessage) async {
    try {
      // Build chat history for better context
      final history = [
        {
          'role': 'system',
          'content':
              'You are a helpful campus assistant for LGS. Answer succinctly.'
        },
        ..._messages.map((m) => {
              'role': m['from'] == 'user' ? 'user' : 'assistant',
              'content': m['text'] ?? ''
            }),
        {
          'role': 'user',
          'content': userMessage,
        },
      ];

      final resp = await http.post(
        Uri.parse(_groqChatUrl),
        headers: {
          'Authorization': 'Bearer $kGroqApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': kGroqModel,
          'messages': history,
          'temperature': 1,
          'top_p': 1,
          'max_tokens': 512,
          'stream': false,
        }),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final choices = data['choices'] as List?;
        final content = choices != null && choices.isNotEmpty
            ? choices[0]['message']['content'] as String?
            : null;
        return content?.trim().isNotEmpty == true
            ? content!
            : 'I received your message but couldn\'t generate a response.';
      }
      return 'Groq error: ${resp.statusCode} ${resp.body}';
    } catch (e) {
      return 'Groq request failed: ${e.toString()}';
    }
  }

  Future<String> _getHuggingFaceResponse(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse(_hfApiUrl),
        headers: {
          'Authorization': 'Bearer $kHfApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'inputs': userMessage,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List &&
            data.isNotEmpty &&
            data[0]['generated_text'] != null) {
          return data[0]['generated_text'];
        }
        return 'I received your message but couldn\'t generate a response.';
      } else {
        return 'HF error: ${response.statusCode}. Please try again.';
      }
    } catch (e) {
      return 'HF request failed: ${e.toString()}';
    }
  }

  Future<void> _groqStreamResponse(
    String userMessage,
    void Function(String chunk) onChunk,
  ) async {
    try {
      final history = [
        {
          'role': 'system',
          'content':
              'You are a helpful campus assistant for LGS. Answer succinctly.'
        },
        ..._messages.map((m) => {
              'role': m['from'] == 'user' ? 'user' : 'assistant',
              'content': m['text'] ?? ''
            }),
        {
          'role': 'user',
          'content': userMessage,
        },
      ];

      final client = http.Client();
      final req = http.Request('POST', Uri.parse(_groqChatUrl));
      req.headers.addAll({
        'Authorization': 'Bearer $kGroqApiKey',
        'Content-Type': 'application/json',
      });
      req.body = jsonEncode({
        'model': kGroqModel,
        'messages': history,
        'temperature': 1,
        'top_p': 1,
        'max_tokens': 512,
        'stream': true,
      });

      final streamed = await client.send(req);
      final decoder = streamed.stream.transform(utf8.decoder);
      await for (final chunk in decoder) {
        for (final line in chunk.split('\n')) {
          final trimmed = line.trim();
          if (!trimmed.startsWith('data:')) continue;
          final dataStr = trimmed.substring(5).trim();
          if (dataStr == '[DONE]') {
            return; // stream finished
          }
          try {
            final jsonObj = jsonDecode(dataStr) as Map<String, dynamic>;
            final choices = jsonObj['choices'] as List?;
            final delta = choices != null && choices.isNotEmpty
                ? choices[0]['delta'] as Map<String, dynamic>?
                : null;
            final content = delta?['content'] as String?;
            if (content != null && content.isNotEmpty) {
              onChunk(content);
            }
          } catch (_) {
            // ignore malformed lines
          }
        }
      }
    } catch (e) {
      onChunk('\n[stream error: ${e.toString()}]');
    }
  }

  void _sendMessage() async {
    // Gate: require signed-in user for chatbot usage
    if (FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in or sign up to use the chatbot.'),
        ),
      );
      return;
    }
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    // Add user message and prepare UI state
    setState(() {
      _messages.add({'from': 'user', 'text': text});
      _controller.clear();
      _isLoading = true;
    });

    // Prefer streaming with Groq if configured
    if (kGroqApiKey.isNotEmpty) {
      int botIndex = -1;
      setState(() {
        _messages.add({'from': 'bot', 'text': ''});
        botIndex = _messages.length - 1;
      });

      await _groqStreamResponse(text, (chunk) {
        setState(() {
          final current = _messages[botIndex]['text'] ?? '';
          _messages[botIndex] = {'from': 'bot', 'text': current + chunk};
        });
      });

      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Fallback to non-streaming response provider
    final botResponse = await _getAIResponse(text);
    setState(() {
      _messages.add({'from': 'bot', 'text': botResponse});
      _isLoading = false;
    });
  }

  void _toggleListening() async {
    if (!_isListening) {
      final available = await _speech.initialize();
      if (!available) return;
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() {
          _controller.text = result.recognizedWords;
        });
      });
    } else {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Chatbot')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == _messages.length && _isLoading) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('AI is thinking...',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  );
                }
                final m = _messages[i];
                final isUser = m['from'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(m['text'] ?? '',
                        style: const TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                    onPressed: _toggleListening,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration:
                          const InputDecoration(hintText: 'Ask the bot...'),
                      onSubmitted: (_) => _sendMessage(),
                      enabled: !_isLoading,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                      onPressed: _isLoading ? null : _sendMessage,
                      child: const Text('Send')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
