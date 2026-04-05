import 'package:flutter/material.dart';

void main() {
  runApp(const AIChatApp());
}

class AIChatApp extends StatelessWidget {
  const AIChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Chat Interface',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const ChatScreen(),
      },
    );
  }
}

// Model to represent a single chat message
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Session management: tracking the ongoing conversation
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Simulates a text-processing API call
  Future<String> _mockTextProcessingAPI(String query) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Generate a mock response based on the query
    if (query.toLowerCase().contains('hello') || query.toLowerCase().contains('hi')) {
      return "Hello there! How can I assist you today?";
    } else if (query.toLowerCase().contains('help')) {
      return "I can help you with answering questions, brainstorming ideas, or just having a chat. What do you need?";
    } else {
      return "This is a simulated AI response to your query: \"$query\". Once the backend is connected, this will be replaced with a real AI model response.";
    }
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    _textController.clear();
    
    // Add user message to the session
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    
    _scrollToBottom();

    // Fetch AI response
    try {
      final response = await _mockTextProcessingAPI(text);
      
      // Add AI response to the session
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(text: response, isUser: false));
      });
      
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(text: "Error: Unable to reach the AI service.", isUser: false));
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
      ),
      body: Column(
        children: [
          // Display area for AI responses and user queries
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          
          // Typing indicator
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'AI is typing...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
          // Input field for user queries
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: isUser 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser 
                      ? Theme.of(context).colorScheme.onPrimary 
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.grey, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 6,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                textInputAction: TextInputAction.send,
                onSubmitted: _handleSubmitted,
                decoration: InputDecoration(
                  hintText: 'Ask me anything...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
