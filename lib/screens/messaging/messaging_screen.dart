import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
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
  
  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      setState(() => _isSearchFocused = _searchFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }
  
  final List<String> _tabs = ['All Messages', 'Unread', 'Archived'];
  final List<String> _jobOptions = ['All jobs', 'Senior Developer', 'UI/UX Designer'];

  final List<Map<String, dynamic>> _conversations = [
    {
      'id': '1',
      'name': 'Alex Thompson',
      'lastMessage': 'I have sent the updated resume. Please check.',
      'time': '2m ago',
      'unread': 2,
      'isOnline': true,
      'job': 'Senior Flutter Developer'
    },
    {
      'id': '2',
      'name': 'Sarah Jenkins',
      'lastMessage': 'When can we schedule the interview?',
      'time': '1h ago',
      'unread': 0,
      'isOnline': false,
      'job': 'UI/UX Designer'
    },
    {
      'id': '3',
      'name': 'Michael Chen',
      'lastMessage': 'Thanks for the opportunity!',
      'time': 'Yesterday',
      'unread': 0,
      'isOnline': true,
      'job': 'Senior Flutter Developer'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Chat List Sidebar
          Container(
            width: isDesktop ? 400 : screenWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: Colors.grey.shade200, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSidebarHeader(),
                _buildSearchAndFilters(),
                _buildTabSwitcher(),
                Expanded(
                  child: _buildConversationList(isDesktop),
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
                      userName: _conversations.firstWhere((c) => c['id'] == _activeChat)['name'],
                      isEmbedded: true,
                    ),
            ),
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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Messages',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
              ),
              SizedBox(height: 4),
              Text(
                '3 Active Conversations',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(LucideIcons.edit3, size: 20, color: Color(0xFF475569)),
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
              color: _isSearchFocused ? Colors.white : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isSearchFocused ? AppColors.primary.withOpacity(0.5) : const Color(0xFFF1F5F9),
                width: 1.5,
              ),
              boxShadow: _isSearchFocused ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ] : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              focusNode: _searchFocus,
              decoration: const InputDecoration(
                hintText: 'Search conversations...',
                hintStyle: TextStyle(fontSize: 14, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                prefixIcon: Icon(LucideIcons.search, size: 18, color: Color(0xFF64748B)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedJob,
          isExpanded: true,
          icon: const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF94A3B8)),
          style: const TextStyle(fontSize: 13, color: Color(0xFF475569), fontWeight: FontWeight.w600),
          items: _jobOptions.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val),
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
                      color: isSelected ? AppColors.primary : const Color(0xFF64748B),
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
    return ListView.builder(
      itemCount: _conversations.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final chat = _conversations[index];
        final isActive = _activeChat == chat['id'];
        
        return InkWell(
          onTap: () {
            if (isDesktop) {
              setState(() => _activeChat = chat['id']);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(userName: chat['name']),
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFEEF2FF) : Colors.transparent,
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
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFFF1F5F9),
                      child: Text(
                        chat['name'].substring(0, 1),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                      ),
                    ),
                    if (chat['isOnline'])
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
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
                            chat['name'],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: chat['unread'] > 0 ? FontWeight.w800 : FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            chat['time'],
                            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat['lastMessage'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: chat['unread'] > 0 ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                                fontWeight: chat['unread'] > 0 ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ),
                          if (chat['unread'] > 0)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                chat['unread'].toString(),
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
    );
  }

  Widget _buildEmptyChatState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(LucideIcons.messageSquare, size: 48, color: Color(0xFFCBD5E1)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Select a conversation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose a candidate from the left to start chatting',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
