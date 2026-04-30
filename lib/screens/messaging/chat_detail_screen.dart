import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';

class ChatDetailScreen extends StatelessWidget {
  final String userName;
  final bool isEmbedded;

  const ChatDetailScreen({
    super.key,
    required this.userName,
    this.isEmbedded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: isEmbedded ? null : _buildAppBar(context),
      body: Container(
        decoration: isEmbedded ? BoxDecoration(
          border: Border(left: BorderSide(color: Colors.grey.shade200, width: 1)),
        ) : null,
        child: Column(
          children: [
            if (isEmbedded) _buildEmbeddedHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                children: [
                  _buildDateDivider('October 24, 2026'),
                  _buildMessageBubble(
                    'Hi there! I am interested in the Senior Flutter Developer position.',
                    false,
                    '10:30 AM',
                  ),
                  _buildMessageBubble(
                    'Hello Alex! Thanks for reaching out. We would love to discuss further. Are you available for a quick call tomorrow?',
                    true,
                    '10:35 AM',
                  ),
                  _buildMessageBubble(
                    'Yes, tomorrow at 2 PM works for me. Should I prepare anything?',
                    false,
                    '10:36 AM',
                  ),
                  _buildMessageBubble(
                    'Just your portfolio and recent project details. Looking forward!',
                    true,
                    '10:40 AM',
                  ),
                ],
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(LucideIcons.chevronLeft, color: Color(0xFF1E293B)),
        onPressed: () => Navigator.pop(context),
      ),
      title: _buildUserHeader(),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(LucideIcons.phone, size: 20, color: Color(0xFF64748B))),
        IconButton(onPressed: () {}, icon: const Icon(LucideIcons.moreVertical, size: 20, color: Color(0xFF64748B))),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: Colors.grey.shade100, height: 1),
      ),
    );
  }

  Widget _buildEmbeddedHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
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
    return Row(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                userName.substring(0, 1),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              userName,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
            ),
            const Text(
              'Online',
              style: TextStyle(fontSize: 11, color: Color(0xFF22C55E), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: const Color(0xFF64748B)),
    );
  }

  Widget _buildDateDivider(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              date,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
            ),
          ),
          const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFFF1F5F9),
                child: Text(userName.substring(0, 1), style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isMe ? AppColors.primary.withOpacity(0.2) : Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 14,
                        color: isMe ? Colors.white : const Color(0xFF1E293B),
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 10,
                        color: isMe ? Colors.white.withOpacity(0.8) : const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
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
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100, width: 1)),
      ),
      child: Row(
        children: [
          _buildInputButton(LucideIcons.plusCircle),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildInputButton(LucideIcons.smile),
          const SizedBox(width: 12),
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(LucideIcons.send, size: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildInputButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20, color: const Color(0xFF64748B)),
    );
  }
}
