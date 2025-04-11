import 'package:dialife/api/api.dart';
import 'package:dialife/api/entities.dart';
import 'package:flutter/material.dart';

class DoctorChat extends StatefulWidget {
  final APIDoctor doctor;

  const DoctorChat({
    super.key,
    required this.doctor,
  });

  @override
  State<DoctorChat> createState() => _DoctorChatState();
}

class _DoctorChatState extends State<DoctorChat> {
  int? fromMessageId;
  final _scrollController = ScrollController();
  final _messageController = TextEditingController();
  int _previousMessageCount = 0;

  Stream<List<APIChatMessage>> _getMessageStream() async* {
    while (true) {
      try {
        final messages = await MonitoringAPI.getChatBatch(
          widget.doctor.id,
          fromMessageId: fromMessageId,
        );

        // Detect if new messages arrived
        if (messages.length > _previousMessageCount &&
            _previousMessageCount > 0) {
          // Schedule scroll after UI updates
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
        _previousMessageCount = messages.length;

        yield messages;

        // Wait a bit before fetching the next batch
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        yield []; // Yield empty list when there's an error
        await Future.delayed(const Duration(seconds: 5));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Consultation'),
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<APIChatMessage>>(
              stream: _getMessageStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    snapshot.data == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Unable to load messages. Please try again later.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isUserMessage = message.isFromPatient;

                    // Get previous message to check if it's also from the doctor
                    final bool isPreviousFromDoctor =
                        index < messages.length - 1 &&
                            !messages[index + 1].isFromPatient;

                    // Only show doctor profile if this is the first message or previous was from patient
                    final bool showDoctorProfile =
                        !isUserMessage && !isPreviousFromDoctor;

                    return AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 400),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutQuad,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(
                              isUserMessage
                                  ? (1 - value) * 20
                                  : (value - 1) * 20,
                              0,
                            ),
                            child: child,
                          );
                        },
                        child: Align(
                          alignment: isUserMessage
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: isUserMessage
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              if (showDoctorProfile)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, bottom: 4.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: _getAvatar(),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        widget.doctor
                                            .name, // Replace with actual doctor name
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 6.0),
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  gradient: isUserMessage
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF64B5F6), // Lighter blue
                                            Color(0xFF42A5F5) // Lighter blue
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : const LinearGradient(
                                          colors: [
                                            Color(0xFFF5F5F5), // Lighter gray
                                            Color(0xFFEEEEEE) // Lighter gray
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(18.0),
                                    topRight: const Radius.circular(18.0),
                                    bottomLeft: isUserMessage
                                        ? const Radius.circular(18.0)
                                        : const Radius.circular(4.0),
                                    bottomRight: isUserMessage
                                        ? const Radius.circular(4.0)
                                        : const Radius.circular(18.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isUserMessage
                                          ? Colors.blue.withOpacity(0.3)
                                          : Colors.grey.withOpacity(0.15),
                                      blurRadius: 10,
                                      spreadRadius: 0.5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: isUserMessage
                                        ? Colors.blue.withOpacity(0.3)
                                        : Colors.grey.withOpacity(0.2),
                                    width: 0.5,
                                  ),
                                ),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.75,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildMessageContent(
                                        message, isUserMessage),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTimestamp(message.createdAt),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isUserMessage
                                            ? Colors.white70
                                            : Colors.black45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () async {
                    final message = _messageController.text.trim();
                    if (message.isNotEmpty) {
                      try {
                        // Clear the text field immediately for better UX
                        _messageController.clear();

                        // Send the message
                        await MonitoringAPI.sendMessage(
                          doctorId: widget.doctor.id,
                          messageType: 'text',
                          textMessage: message,
                        );

                        // Optional: scroll to the top of the list to see the new message
                        if (_scrollController.hasClients) {
                          _scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      } catch (e) {
                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Failed to send message: ${e.toString()}'),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  CircleAvatar _getAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: Colors.blue.shade50,
      backgroundImage: widget.doctor.profileImage != null
          ? NetworkImage(
              '${MonitoringAPI.baseUrl}/storage/${widget.doctor.profileImage!}')
          : null,
      child: widget.doctor.profileImage == null
          ? Text(
              widget.doctor.name.isNotEmpty
                  ? widget.doctor.name[0].toUpperCase()
                  : "D",
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            )
          : null,
    );
  }

  Widget _buildMessageContent(APIChatMessage message, bool isUserMessage) {
    // Handle different message types (text, image, etc.)
    switch (message.messageType) {
      case 'image':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.message?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  message.message!,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: isUserMessage ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                "${MonitoringAPI.baseUrl}/storage/attachments/${message.path}",
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  padding: const EdgeInsets.all(8.0),
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
          ],
        );
      case 'pdf':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.message?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  message.message!,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: isUserMessage ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            InkWell(
              onTap: () {
                // Open PDF viewer or launch URL
                final pdfUrl =
                    "${MonitoringAPI.baseUrl}/storage/attachments/${message.path}";
                // Implement PDF viewing functionality here
              },
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: isUserMessage ? Colors.white24 : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      color: isUserMessage ? Colors.white : Colors.red,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.path?.split('/').last ?? 'Document.pdf',
                            style: TextStyle(
                              color:
                                  isUserMessage ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tap to view PDF',
                            style: TextStyle(
                              fontSize: 12,
                              color: isUserMessage
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      case 'text':
      default:
        return Text(
          message.message ?? 'Empty message',
          style: TextStyle(
            fontSize: 16.0,
            color: isUserMessage ? Colors.white : Colors.black87,
          ),
        );
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    // For future dates (unlikely in chat, but handling anyway)
    if (difference.isNegative) {
      final duration = timestamp.difference(now);
      if (duration.inSeconds < 60) return 'just now';
      if (duration.inMinutes < 60) {
        return 'in ${duration.inMinutes} ${duration.inMinutes == 1 ? 'minute' : 'minutes'}';
      }
      if (duration.inHours < 24) {
        return 'in ${duration.inHours} ${duration.inHours == 1 ? 'hour' : 'hours'}';
      }
      if (duration.inDays < 7) {
        return 'in ${duration.inDays} ${duration.inDays == 1 ? 'day' : 'days'}';
      }
      if (duration.inDays < 30) {
        return 'in ${(duration.inDays / 7).floor()} ${(duration.inDays / 7).floor() == 1 ? 'week' : 'weeks'}';
      }
      if (duration.inDays < 365) {
        return 'in ${(duration.inDays / 30).floor()} ${(duration.inDays / 30).floor() == 1 ? 'month' : 'months'}';
      }
      return 'in ${(duration.inDays / 365).floor()} ${(duration.inDays / 365).floor() == 1 ? 'year' : 'years'}';
    }

    // For past dates
    if (difference.inSeconds < 60) return 'just now';
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    }
    if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} ${(difference.inDays / 7).floor() == 1 ? 'week' : 'weeks'} ago';
    }
    if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() == 1 ? 'month' : 'months'} ago';
    }
    return '${(difference.inDays / 365).floor()} ${(difference.inDays / 365).floor() == 1 ? 'year' : 'years'} ago';
  }
}
