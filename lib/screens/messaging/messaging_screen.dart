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
  
  final List<String> _tabs = ['Inbox (0)', 'Unread (0)'];
  final List<String> _jobOptions = ['All jobs', 'Senior Developer', 'UI/UX Designer'];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Chat List Section
          Expanded(
            flex: isDesktop ? 1 : 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(right: BorderSide(color: Colors.grey.shade100, width: 1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildTabs(),
                  _buildJobFilter(),
                  Expanded(
                    child: _buildEmptyState(),
                  ),
                ],
              ),
            ),
          ),
          
          // Chat Detail Section (Desktop only)
          if (isDesktop)
            Expanded(
              flex: 2,
              child: Container(
                color: const Color(0xFFF8FAFC),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.messageSquare, size: 64, color: Color(0xFFCBD5E1)),
                      SizedBox(height: 16),
                      Text(
                        'Select a conversation to start chatting',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Messages',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text('Online status: ', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              Text(
                'On',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 1)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final isSelected = _selectedTab == index;
            return Padding(
              padding: const EdgeInsets.only(right: 24),
              child: InkWell(
                onTap: () => setState(() => _selectedTab = index),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    _tabs[index],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppColors.primary : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildJobFilter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedJob,
            isExpanded: true,
            icon: const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF94A3B8)),
            items: _jobOptions.map((String val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Text('Filter by job: $val', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedJob = val!),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.messageCircle, size: 48, color: Color(0xFFCBD5E1)),
          const SizedBox(height: 16),
          const Text(
            'No conversations',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start a conversation with a candidate.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
