import 'package:flutter/material.dart';

class TriageChatbot extends StatefulWidget {
  const TriageChatbot({Key? key}) : super(key: key);

  @override
  State<TriageChatbot> createState() => _TriageChatbotState();
}

class _TriageChatbotState extends State<TriageChatbot> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<dynamic> _messages = []; // Changed to dynamic to accept different message types
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addBotMessage(
      'Hello! I\'m HeaLyri\'s AI Health Assistant. I can help assess your symptoms and provide guidance on what to do next. Please note that I\'m not a replacement for professional medical advice.\n\nHow can I help you today?',
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addMessage(String text, bool isUser) {
    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: isUser,
          timestamp: DateTime.now(),
        ),
      );
    });
    _scrollToBottom();
  }

  void _addBotMessage(String text) {
    _addMessage(text, false);
  }

  void _addUserMessage(String text) {
    _addMessage(text, true);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSubmitted(String text) {
    _messageController.clear();
    if (text.trim().isEmpty) return;

    _addUserMessage(text);
    setState(() {
      _isTyping = true;
    });

    // Simulate AI response
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
      });

      if (text.toLowerCase().contains('headache')) {
        _addBotMessage(
          'I understand you\'re experiencing a headache. To help me better assess your situation, could you please tell me:\n\n1. How long have you had this headache?\n2. How would you rate the pain on a scale of 1-10?\n3. Do you have any other symptoms like nausea, sensitivity to light, or fever?',
        );
      } else if (text.toLowerCase().contains('fever')) {
        _addBotMessage(
          'I see you\'re experiencing a fever. This could be due to various causes. To help me better understand:\n\n1. What\'s your temperature reading?\n2. How long have you had the fever?\n3. Do you have any other symptoms like cough, sore throat, or body aches?',
        );
      } else if (text.toLowerCase().contains('cough')) {
        _addBotMessage(
          'I understand you\'re experiencing a cough. To help me better assess your situation:\n\n1. Is it a dry cough or are you coughing up phlegm?\n2. How long have you been coughing?\n3. Do you have any other symptoms like fever, shortness of breath, or chest pain?',
        );
      } else if (text.toLowerCase().contains('emergency') ||
          text.toLowerCase().contains('urgent') ||
          text.toLowerCase().contains('severe')) {
        _addBotMessage(
          '⚠️ Based on what you\'ve described, you may need immediate medical attention. Please contact emergency services or go to your nearest emergency room right away.\n\nWould you like me to show you the nearest emergency facilities?',
        );
        _showEmergencyOptions();
      } else {
        _addBotMessage(
          'Thank you for sharing that information. To provide better guidance, I need to ask a few more questions about your symptoms.\n\n1. When did your symptoms start?\n2. Have you tried any medications or remedies?\n3. Do you have any pre-existing medical conditions?',
        );
      }
    });
  }

  void _showEmergencyOptions() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _messages.add(
          EmergencyOptionsMessage(
            timestamp: DateTime.now(),
            onEmergencyCallTap: () {
              // TODO: Implement emergency call
              _addBotMessage('Connecting you to emergency services...');
            },
            onFindHospitalTap: () {
              // TODO: Implement find hospital
              _addBotMessage(
                  'Here are the nearest emergency facilities to your location:');
              _addBotMessage(
                  '1. Lusaka General Hospital - 2.5 km away\n2. University Teaching Hospital - 3.7 km away\n3. Kanyama Clinic - 1.2 km away');
            },
          ),
        );
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Health Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showInfoDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return const TypingIndicator();
                }
                final message = _messages[index];
                if (message is ChatMessage) {
                  return MessageBubble(message: message);
                } else if (message is EmergencyOptionsMessage) {
                  return EmergencyOptions(
                    message: message,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.mic),
              onPressed: () {
                // TODO: Implement voice input
              },
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Type your symptoms or questions...',
                  border: InputBorder.none,
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: _handleSubmitted,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => _handleSubmitted(_messageController.text),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('About AI Health Assistant'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This AI Health Assistant can help assess your symptoms and provide guidance on what to do next.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Important Limitations:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• This is not a replacement for professional medical advice',
              ),
              Text(
                '• In case of emergency, contact emergency services immediately',
              ),
              Text(
                '• Your conversation is private and secure',
              ),
              SizedBox(height: 16),
              Text(
                'The AI will ask questions to understand your symptoms better and suggest appropriate next steps based on your responses.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class EmergencyOptionsMessage {
  final DateTime timestamp;
  final VoidCallback onEmergencyCallTap;
  final VoidCallback onFindHospitalTap;

  EmergencyOptionsMessage({
    required this.timestamp,
    required this.onEmergencyCallTap,
    required this.onFindHospitalTap,
  });
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser)
            CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: const Icon(
                Icons.health_and_safety,
                color: Colors.blue,
              ),
            ),
          if (!message.isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: message.isUser
                          ? Colors.white.withOpacity(0.7)
                          : Colors.black.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
          if (message.isUser)
            const CircleAvatar(
              child: Icon(Icons.person),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class EmergencyOptions extends StatelessWidget {
  final EmergencyOptionsMessage message;

  const EmergencyOptions({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue[100],
            child: const Icon(
              Icons.health_and_safety,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Emergency Options',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Based on your symptoms, you may need immediate medical attention.',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: message.onEmergencyCallTap,
                              icon: const Icon(Icons.call),
                              label: const Text('Call Emergency'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: message.onFindHospitalTap,
                              icon: const Icon(Icons.local_hospital),
                              label: const Text('Find Nearest Hospital'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: BorderSide(color: Colors.red.shade300),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                  child: Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue[100],
            child: const Icon(
              Icons.health_and_safety,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(1),
                _buildDot(2),
                _buildDot(3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
