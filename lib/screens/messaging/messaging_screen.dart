import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../../services/chat_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'chat_detail_screen.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  int _selectedTab = 0;
  String _selectedJob = 'All jobs';
  String? _activeChat;
  final FocusNode _searchFocus = FocusNode();
  bool _isSearchFocused = false;
  
  bool _isLoading = true;
  List<dynamic> _conversations = [];
  String? _errorMessage;
  bool _showSlowLoadingMessage = false;

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      setState(() => _isSearchFocused = _searchFocus.hasFocus);
    });
    _loadInitialData();
    _startRefreshTimer();
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted && !_isLoading) {
        _fetchConversations(isBackground: true);
      }
    });
  }

  Future<void> _loadInitialData() async {
    // 1. Load from cache first for instant UI
    await _loadFromCache();
    
    // 2. Background fetch from API
    _fetchConversations();
  }

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_conversations');
      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        if (mounted) {
          setState(() {
            _conversations = decoded;
            // If we have cache, we don't show full screen loader, 
            // but we might still be "fetching" in background
            _isLoading = _conversations.isEmpty; 
          });
        }
      }
    } catch (e) {
      print('❌ [Cache] Error loading: $e');
    }
  }

  Future<void> _saveToCache(List<dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_conversations', jsonEncode(data));
    } catch (e) {
      print('❌ [Cache] Error saving: $e');
    }
  }

  Future<void> _preFetchMessages(List<dynamic> topChats) async {
    for (var chat in topChats) {
      final String? chatId = chat['id']?.toString();
      if (chatId != null) {
        try {
          final response = await ChatService.getMessages(chatId);
          if (response['success']) {
            final List<dynamic> messages = response['data']['messages'] ?? [];
            // Save to cache using the same key format as ChatDetailScreen
            final prefs = await SharedPreferences.getInstance();
            // We reverse it here because ChatDetailScreen expects reversed messages for its reverse: true ListView
            final reversedMessages = List.from(messages.reversed);
            await prefs.setString('cached_messages_$chatId', jsonEncode(reversedMessages));
          }
        } catch (_) {}
      }
    }
  }

  Future<void> _fetchConversations({bool isBackground = false}) async {
    if (!mounted) return;
    
    if (!isBackground) {
      setState(() {
        if (_conversations.isEmpty) _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await ChatService.getConversations();
      if (mounted) {
        if (response['success']) {
          final data = response['data'];
          final List<dynamic> newConversations = data['conversations'] ?? [];
          setState(() {
            _conversations = newConversations;
            _isLoading = false;
            _showSlowLoadingMessage = false;
          });
          _saveToCache(newConversations);
          
          // 3. Pre-fetch messages for top conversations for "instant" open feel
          _preFetchMessages(newConversations.take(5).toList());
        } else if (!isBackground) {
          setState(() {
            if (_conversations.isEmpty) _errorMessage = response['message'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted && !isBackground) {
        setState(() {
          if (_conversations.isEmpty) _errorMessage = "Network error occurred";
          _isLoading = false;
        });
      }
    } finally {
      if (mounted && !isBackground) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchFocus.dispose();
    super.dispose();
  }
  
  final List<String> _tabs = ['All Messages', 'Unread', 'Archived'];
  final List<String> _jobOptions = ['All jobs', 'Senior Developer', 'UI/UX Designer'];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          // Chat List Sidebar
          Container(
            width: isDesktop ? 400 : screenWidth,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(right: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1), width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSidebarHeader(),
                _buildSearchAndFilters(),
                _buildTabSwitcher(),
                Expanded(
                  child: _buildMainList(isDesktop),
                ),
              ],
            ),
          ),
          
          // Chat Window (Desktop)
          if (isDesktop)
            Expanded(
              child: _activeChat == null
                  ? _buildEmptyChatState()
                  : ChatDetailScreen(
                      conversationId: _activeChat!,
                      userName: _conversations.firstWhere((c) => c['id'].toString() == _activeChat, orElse: () => {'other_user': {'name': 'Candidate'}})['other_user']?['name'] ?? 'Candidate',
                      isEmbedded: true,
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainList(bool isDesktop) {
    if (_isLoading && _conversations.isEmpty) {
      return _buildSkeletonLoader();
    }

    if (_errorMessage != null && _conversations.isEmpty) {
      return _buildErrorState();
    }

    return Stack(
      children: [
        _buildConversationList(isDesktop),
        if (_showSlowLoadingMessage)
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).cardColor)),
                  const SizedBox(width: 12),
                  Text("Refreshing conversations...", style: TextStyle(color: Theme.of(context).cardColor, fontSize: 12)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      itemCount: 6,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: Theme.of(context).dividerColor.withOpacity(0.1), shape: BoxShape.circle),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 100, height: 14, decoration: BoxDecoration(color: Theme.of(context).dividerColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 8),
                  Container(width: double.infinity, height: 12, decoration: BoxDecoration(color: Theme.of(context).dividerColor.withOpacity(0.05), borderRadius: BorderRadius.circular(4))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.alertCircle, size: 40, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(_errorMessage ?? "Failed to load chats", style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchConversations, child: const Text("Retry")),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Messages',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                '${_conversations.length} Active Conversations',
                style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(LucideIcons.edit3, size: 20, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _isSearchFocused ? Theme.of(context).cardColor : Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isSearchFocused ? AppColors.primary.withOpacity(0.5) : Theme.of(context).dividerColor.withOpacity(0.1),
                width: 1.5,
              ),
              boxShadow: _isSearchFocused ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ] : [],
            ),
            child: TextField(
              focusNode: _searchFocus,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                hintStyle: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), fontWeight: FontWeight.w500),
                prefixIcon: Icon(LucideIcons.search, size: 18, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildJobFilterDropdown(),
        ],
      ),
    );
  }

  Widget _buildJobFilterDropdown() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedJob,
          isExpanded: true,
          icon: Icon(LucideIcons.chevronDown, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
          dropdownColor: Theme.of(context).cardColor,
          style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontWeight: FontWeight.w600),
          items: _jobOptions.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedJob = val!),
        ),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () => setState(() => _selectedTab = index),
              child: Column(
                children: [
                  Text(
                    _tabs[index],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 20,
                    height: 2,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildConversationList(bool isDesktop) {
    if (_conversations.isEmpty) {
      return Center(child: Text("No conversations found", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))));
    }

    return RefreshIndicator(
      onRefresh: _fetchConversations,
      child: ListView.builder(
        itemCount: _conversations.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final chat = _conversations[index];
          final String id = chat['id']?.toString() ?? '';
          if (id.isEmpty) return const SizedBox.shrink();

          final otherUser = chat['other_user'] ?? {};
          final lastMsg = chat['last_message'] ?? {};
          final unreadCount = chat['unread_count'] ?? 0;
          final isActive = _activeChat == id;
          
          String timeStr = '—';
          if (chat['updated_at'] != null) {
            try {
              DateTime dt = DateTime.parse(chat['updated_at']);
              timeStr = _formatDateTime(dt);
            } catch (_) {}
          }
          
          String? avatarUrl = otherUser['profile_image'] ?? 
                             otherUser['profile_picture'] ??
                             otherUser['profile_photo_url'] ?? 
                             otherUser['avatar'] ?? 
                             otherUser['photo'] ?? 
                             otherUser['image'];
          
          return InkWell(
            onTap: () {
              if (isDesktop) {
                setState(() => _activeChat = id);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatDetailScreen(
                      conversationId: id,
                      userName: otherUser['name'] ?? 'Candidate',
                      userAvatar: avatarUrl,
                    ),
                  ),
                ).then((_) => _fetchConversations());
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
                border: Border(
                  left: BorderSide(
                    color: isActive ? AppColors.primary : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Builder(
                        builder: (context) {
                          String? finalUrl = avatarUrl;
                          if (finalUrl != null && finalUrl.isNotEmpty) {
                            if (!finalUrl.startsWith('http')) {
                              finalUrl = 'https://www.mindwareinfotech.com${finalUrl.startsWith('/') ? '' : '/'}$finalUrl';
                            }
                            
                            return CachedNetworkImage(
                              imageUrl: finalUrl,
                              imageBuilder: (context, imageProvider) => CircleAvatar(
                                radius: 24,
                                backgroundImage: imageProvider,
                              ),
                              placeholder: (context, url) => CircleAvatar(
                                radius: 24,
                                backgroundColor: Theme.of(context).dividerColor.withOpacity(0.05),
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary.withOpacity(0.5)),
                              ),
                              errorWidget: (context, url, error) => CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                child: Text(
                                  (otherUser['name'] ?? '?').substring(0, 1).toUpperCase(),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18),
                                ),
                              ),
                            );
                          }
                          
                          return CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Text(
                              (otherUser['name'] ?? '?').substring(0, 1).toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18),
                            ),
                          );
                        }
                      ),
                      if (chat['is_online'] == true)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              shape: BoxShape.circle,
                              border: Border.all(color: Theme.of(context).cardColor, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              otherUser['name'] ?? 'Candidate',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: unreadCount > 0 ? FontWeight.w800 : FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              timeStr,
                              style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                lastMsg['body'] ?? 'No messages yet',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: unreadCount > 0 ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                  fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ),
                            if (unreadCount > 0)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  unreadCount.toString(),
                                  style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return DateFormat('MMM d').format(dt);
  }

  Widget _buildEmptyChatState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
              boxShadow: Theme.of(context).brightness == Brightness.light ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ] : [],
            ),
            child: Icon(LucideIcons.messageSquare, size: 48, color: Theme.of(context).dividerColor.withOpacity(0.2)),
          ),
          const SizedBox(height: 24),
          Text(
            'Select a conversation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a candidate from the left to start chatting',
            style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
}
