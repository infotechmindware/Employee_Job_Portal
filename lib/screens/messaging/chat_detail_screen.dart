import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_colors.dart';
import '../../services/chat_service.dart';
import '../../services/auth_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final String conversationId;
  final String userName;
  final String? userAvatar;
  final bool isEmbedded;

  const ChatDetailScreen({
    super.key,
    required this.conversationId,
    required this.userName,
    this.userAvatar,
    this.isEmbedded = false,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();
  
  bool _isLoading = true;
  List<dynamic> _messages = [];
  String? _errorMessage;
  int? _myId;
  bool _isSending = false;
  bool _showSlowLoadingMessage = false;
  bool _showEmoji = false;
  
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _startRefreshTimer();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() => _showEmoji = false);
      } else {
        setState(() {}); // Ensure border updates when focus is lost
      }
    });
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && !_isLoading && !_isSending && !_showEmoji) {
        _fetchMessages(isBackground: true);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    // 1. Load myId (Try cache first)
    _loadMyProfile();
    
    // 2. Load messages from cache (Instant)
    await _loadFromCache();
    
    // 3. Fetch fresh messages from API (Background)
    _fetchMessages();
  }

  Future<void> _loadMyProfile() async {
    final auth = AuthService();
    final response = await auth.getProfile();
    if (response['success'] && response['data'] != null) {
      if (mounted) {
        setState(() {
          _myId = response['data']['id'];
        });
      }
    }
  }

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_messages_${widget.conversationId}');
      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        if (mounted) {
          setState(() {
            _messages = decoded;
            _isLoading = _messages.isEmpty;
          });
          _scrollToBottom(instant: true);
        }
      }
    } catch (e) {
      print('❌ [Cache] Error: $e');
    }
  }

  Future<void> _saveToCache(List<dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_messages_${widget.conversationId}', jsonEncode(data));
    } catch (e) {
      print('❌ [Cache] Save error: $e');
    }
  }

  Future<void> _fetchMessages({bool isBackground = false}) async {
    if (!mounted) return;
    
    if (!isBackground && _messages.isEmpty) {
      setState(() => _isLoading = true);
    }

    try {
      final response = await ChatService.getMessages(widget.conversationId);
      if (mounted) {
        if (response['success']) {
          List<dynamic> newMessages = response['data']['messages'] ?? [];
          
          // Reverse for reverse: true ListView (Newest first)
          newMessages = List.from(newMessages.reversed);
          
          bool hasChanges = newMessages.length != _messages.length;
          
          if (hasChanges || !isBackground) {
            setState(() {
              _messages = newMessages;
              _isLoading = false;
              _showSlowLoadingMessage = false;
            });
            _saveToCache(newMessages);
          }
        } else if (!isBackground) {
          setState(() {
            if (_messages.isEmpty) _errorMessage = response['message'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted && !isBackground) {
        setState(() {
          if (_messages.isEmpty) _errorMessage = "Failed to load messages";
          _isLoading = false;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom({bool instant = false}) {
    // With reverse: true, we scroll to 0.0 to go to the bottom of the UI (start of list)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (instant) {
          _scrollController.jumpTo(0.0);
        } else {
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );
    if (image != null) {
      _sendImage(image.path);
    }
  }

  Future<void> _sendImage(String path) async {
    setState(() => _isSending = true);
    try {
      final response = await ChatService.sendImageMessage(widget.conversationId, path);
      if (mounted) {
        if (response['success']) {
          _fetchMessages();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? "Failed to send image")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Network error during upload")));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    final String tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final Map<String, dynamic> optimisticMsg = {
      'id': tempId,
      'body': text,
      'sender_id': _myId,
      'created_at': DateTime.now().toIso8601String(),
      'is_optimistic': true,
    };

    setState(() {
      _messages.insert(0, optimisticMsg); // Insert at 0 because of reverse: true
      _isSending = true;
      _messageController.clear();
    });
    _scrollToBottom();

    try {
      final response = await ChatService.sendMessage(widget.conversationId, text);
      if (mounted) {
        if (response['success']) {
          await _fetchMessages();
        } else {
          setState(() => _messages.removeWhere((m) => m['id'] == tempId));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? "Failed to send message")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _messages.removeWhere((m) => m['id'] == tempId));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Network error")));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Theme.of(context).dividerColor.withOpacity(0.1), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text('Send Attachment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionItem(LucideIcons.image, 'Gallery', const Color(0xFF3B82F6), () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                }),
                _buildOptionItem(LucideIcons.camera, 'Camera', const Color(0xFFF59E0B), () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                }),
                _buildOptionItem(LucideIcons.fileText, 'File', const Color(0xFFA855F7), () {}),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: widget.isEmbedded ? null : _buildAppBar(context),
      body: WillPopScope(
        onWillPop: () {
          if (_showEmoji) {
            setState(() => _showEmoji = false);
            return Future.value(false);
          }
          return Future.value(true);
        },
        child: Column(
          children: [
            if (widget.isEmbedded) _buildEmbeddedHeader(),
            Expanded(child: _buildMainChat()),
            _buildMessageInput(),
            if (_showEmoji) _buildEmojiPicker(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return SizedBox(
      height: 250,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          _messageController.text += emoji.emoji;
        },
        config: Config(
          height: 250,
          checkPlatformCompatibility: true,
          emojiViewConfig: EmojiViewConfig(
            columns: 7,
            emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
            verticalSpacing: 0,
            horizontalSpacing: 0,
            gridPadding: EdgeInsets.zero,
            replaceEmojiOnLimitExceed: false,
          ),
          categoryViewConfig: CategoryViewConfig(
            initCategory: Category.SMILEYS,
            indicatorColor: AppColors.primary,
            iconColor: Colors.grey,
            iconColorSelected: AppColors.primary,
            backspaceColor: AppColors.primary,
          ),
          skinToneConfig: SkinToneConfig(
            enabled: true,
            dialogBackgroundColor: Theme.of(context).cardColor,
            indicatorColor: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildMainChat() {
    if (_isLoading && _messages.isEmpty) return _buildChatSkeleton();
    if (_errorMessage != null && _messages.isEmpty) return _buildErrorState();

    return Stack(
      children: [
        _buildMessageList(),
        if (_showSlowLoadingMessage)
          Positioned(
            top: 20, left: 20, right: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                child: Text("Syncing messages...", style: TextStyle(color: Theme.of(context).cardColor, fontSize: 11)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChatSkeleton() {
    return ListView.builder(
      itemCount: 4,
      padding: const EdgeInsets.all(24),
      itemBuilder: (context, index) {
        final isLeft = index % 2 == 0;
        return Align(
          alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.only(bottom: 24),
            width: 200, height: 60,
            decoration: BoxDecoration(color: Theme.of(context).dividerColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.alertCircle, size: 40, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text(_errorMessage ?? "Something went wrong", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          TextButton(onPressed: _fetchMessages, child: const Text("Retry")),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_messages.isEmpty) return Center(child: Text("No messages in this conversation", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))));
    
    return ListView.builder(
      controller: _scrollController,
      reverse: true, // Key for chat: Newest at bottom
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final bool isMe = msg['sender_id'] == _myId;
        
        bool showDateDivider = false;
        String dateStr = '';
        
        // Date divider logic for reversed list
        if (index == _messages.length - 1) {
          showDateDivider = true;
          dateStr = _formatDate(msg['created_at']);
        } else {
          final nextMsg = _messages[index + 1]; // next in UI is prev in time
          try {
            final currentDt = DateTime.parse(msg['created_at']);
            final nextDt = DateTime.parse(nextMsg['created_at']);
            if (currentDt.day != nextDt.day || currentDt.month != nextDt.month || currentDt.year != nextDt.year) {
              showDateDivider = true;
              dateStr = _formatDate(msg['created_at']);
            }
          } catch (_) {}
        }

        return Column(
          children: [
            if (showDateDivider) _buildDateDivider(dateStr),
            _buildMessageBubble(msg, isMe),
          ],
        );
      },
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('MMMM d, yyyy').format(dt.toLocal());
    } catch (_) { return dateStr; }
  }

  String _formatTime(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('hh:mm a').format(dt.toLocal());
    } catch (_) { return ''; }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).cardColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(LucideIcons.chevronLeft, color: Theme.of(context).colorScheme.onSurface),
        onPressed: () => Navigator.pop(context),
      ),
      title: _buildUserHeader(),
      actions: [
        IconButton(onPressed: () {}, icon: Icon(LucideIcons.phone, size: 20, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
        IconButton(onPressed: () {}, icon: Icon(LucideIcons.moreVertical, size: 20, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: Theme.of(context).dividerColor.withOpacity(0.1), height: 1),
      ),
    );
  }

  Widget _buildEmbeddedHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildUserHeader(),
          Row(
            children: [
              _buildHeaderIcon(LucideIcons.phone),
              const SizedBox(width: 8),
              _buildHeaderIcon(LucideIcons.video),
              const SizedBox(width: 8),
              _buildHeaderIcon(LucideIcons.moreVertical),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    String? avatarUrl = widget.userAvatar;
    if (avatarUrl != null && avatarUrl.isNotEmpty && !avatarUrl.startsWith('http')) {
      avatarUrl = 'https://www.mindwareinfotech.com${avatarUrl.startsWith('/') ? '' : '/'}$avatarUrl';
    }

    return Row(
      children: [
        avatarUrl != null && avatarUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: avatarUrl,
              imageBuilder: (context, imageProvider) => CircleAvatar(radius: 18, backgroundImage: imageProvider),
              placeholder: (context, url) => CircleAvatar(radius: 18, backgroundColor: AppColors.primary.withOpacity(0.1), child: const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2))),
              errorWidget: (context, url, error) => CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(widget.userName.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
            )
          : CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(widget.userName.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.userName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface)),
            const Text('Online', style: TextStyle(fontSize: 11, color: Color(0xFF22C55E), fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Theme.of(context).dividerColor.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
    );
  }

  Widget _buildDateDivider(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          Expanded(child: Divider(color: Theme.of(context).dividerColor.withOpacity(0.1))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(date, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4))),
          ),
          Expanded(child: Divider(color: Theme.of(context).dividerColor.withOpacity(0.1))),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe) {
    // 1. IMPROVED IMAGE DETECTION (All possible backend fields)
    String? rawImageUrl = msg['image_url'] ?? 
                          msg['image'] ?? 
                          msg['attachment'] ?? 
                          msg['file'] ?? 
                          msg['media'] ??
                          msg['media_url'] ??
                          msg['attachment_url'] ??
                          msg['file_url'] ??
                          msg['file_path'];
                          
    // Check in attachments array if present
    if (rawImageUrl == null && msg['attachments'] != null && (msg['attachments'] as List).isNotEmpty) {
      final firstAttachment = (msg['attachments'] as List).first;
      rawImageUrl = firstAttachment['url'] ?? 
                    firstAttachment['file_url'] ?? 
                    firstAttachment['file_path'] ?? 
                    firstAttachment['path'] ??
                    firstAttachment['attachment_url'];
    }
                             
    String? imageUrl;
    if (rawImageUrl != null && rawImageUrl.toString().isNotEmpty) {
      imageUrl = rawImageUrl.toString();
      // Handle relative URLs (Prepend base domain if needed)
      if (!imageUrl.startsWith('http')) {
        imageUrl = 'https://www.mindwareinfotech.com${imageUrl.startsWith('/') ? '' : '/'}$imageUrl';
      }
    }
    
    if (imageUrl != null) {
      print("DEBUG: IMAGE URL DETECTED => $imageUrl");
    }
    
    final bool hasImage = imageUrl != null;
    final String time = _formatTime(msg['created_at']);
    final bool isSending = msg['is_optimistic'] == true;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              Builder(
                builder: (context) {
                  String? avatarUrl = widget.userAvatar;
                  if (avatarUrl != null && avatarUrl.isNotEmpty && !avatarUrl.startsWith('http')) {
                    avatarUrl = 'https://www.mindwareinfotech.com${avatarUrl.startsWith('/') ? '' : '/'}$avatarUrl';
                  }
                  
                  if (avatarUrl != null && avatarUrl.isNotEmpty) {
                    return CachedNetworkImage(
                      imageUrl: avatarUrl,
                      imageBuilder: (context, imageProvider) => CircleAvatar(radius: 14, backgroundImage: imageProvider),
                      placeholder: (context, url) => CircleAvatar(radius: 14, backgroundColor: Theme.of(context).dividerColor.withOpacity(0.1), child: const SizedBox(width: 8, height: 8, child: CircularProgressIndicator(strokeWidth: 1.5))),
                      errorWidget: (context, url, error) => CircleAvatar(
                        radius: 14,
                        backgroundColor: Theme.of(context).dividerColor.withOpacity(0.1),
                        child: Text(widget.userName.substring(0, 1).toUpperCase(), style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                      ),
                    );
                  }

                  return CircleAvatar(
                    radius: 14,
                    backgroundColor: Theme.of(context).dividerColor.withOpacity(0.1),
                    child: Text(widget.userName.substring(0, 1).toUpperCase(), style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                  );
                }
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: EdgeInsets.all(hasImage ? 6 : 14),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.primary : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isMe ? 20 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (hasImage) 
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minHeight: 150,
                            minWidth: 150,
                            maxHeight: 400,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl!,
                            placeholder: (context, url) => Container(
                              width: 200, 
                              height: 150, 
                              color: Theme.of(context).dividerColor.withOpacity(0.05), 
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary.withOpacity(0.5)))
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 200,
                              height: 150,
                              color: Theme.of(context).dividerColor.withOpacity(0.05),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
                                  const SizedBox(height: 4),
                                  Text(imageUrl!.split('/').last, style: TextStyle(fontSize: 8, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    if ((msg['body'] != null && msg['body'].toString().isNotEmpty && msg['body'] != 'Sent an image') ||
                        (msg['content'] != null && msg['content'].toString().isNotEmpty && msg['content'] != 'Sent an image'))
                      Padding(
                        padding: EdgeInsets.only(top: hasImage ? 8.0 : 0, left: 8, right: 8, bottom: 4),
                        child: Text(
                          msg['body'] ?? msg['content'] ?? '',
                          style: TextStyle(fontSize: 15, color: isMe ? Colors.white : Theme.of(context).colorScheme.onSurface, height: 1.5, fontWeight: FontWeight.w500),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(time, style: TextStyle(fontSize: 10, color: isMe ? Colors.white.withOpacity(0.7) : Theme.of(context).colorScheme.onSurface.withOpacity(0.4), fontWeight: FontWeight.w600)),
                          if (isSending) ...[const SizedBox(width: 4), const Icon(LucideIcons.clock, size: 10, color: Colors.white70)],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Unified Input Pill (Containing Attachment, Emoji, and Text)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: _focusNode.hasFocus ? AppColors.primary : Theme.of(context).dividerColor.withOpacity(0.1), 
                      width: _focusNode.hasFocus ? 1.5 : 0.8
                    ),
                    boxShadow: _focusNode.hasFocus ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.08),
                        blurRadius: 12,
                        spreadRadius: 1,
                      )
                    ] : null,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Attachment Button (Inside the pill)
                      GestureDetector(
                        onTap: _showAttachmentOptions,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: Icon(LucideIcons.plusCircle, color: theme.colorScheme.onSurface.withOpacity(0.4), size: 22),
                        ),
                      ),
                      
                      // Emoji Button
                      IconButton(
                        onPressed: () {
                          if (_showEmoji) {
                            _focusNode.requestFocus();
                          } else {
                            FocusScope.of(context).unfocus();
                          }
                          setState(() => _showEmoji = !_showEmoji);
                        },
                        icon: Icon(
                          _showEmoji ? LucideIcons.keyboard : LucideIcons.smile,
                          size: 22, 
                          color: _showEmoji ? AppColors.primary : const Color(0xFF64748B)
                        ),
                      ),
                      
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          focusNode: _focusNode,
                          maxLines: 5,
                          minLines: 1,
                          textCapitalization: TextCapitalization.sentences,
                          style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                            filled: false,
                          ),
                          onChanged: (val) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              
              // Send Button
              GestureDetector(
                onTap: _sendMessage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _messageController.text.trim().isEmpty && !_isSending
                        ? [const Color(0xFF94A3B8), const Color(0xFF64748B)]
                        : [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_messageController.text.trim().isEmpty ? Colors.grey : AppColors.primary).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _isSending 
                    ? const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                    : const Center(child: Icon(LucideIcons.send, size: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
