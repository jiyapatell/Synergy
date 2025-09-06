import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/card.dart';
import '../../providers/trello_provider.dart';
import '../../theme/app_theme.dart';
import '../../constants/app_constants.dart';
import '../../services/trello_demo_data_service.dart';

class EnhancedCardDetailScreen extends StatefulWidget {
  final ProjectCard card;

  const EnhancedCardDetailScreen({
    super.key,
    required this.card,
  });

  @override
  State<EnhancedCardDetailScreen> createState() => _EnhancedCardDetailScreenState();
}

class _EnhancedCardDetailScreenState extends State<EnhancedCardDetailScreen>
    with TickerProviderStateMixin {
  late ProjectCard _currentCard;
  final TextEditingController _commentController = TextEditingController();
  late TabController _tabController;
  final Random _random = Random();
  int _votes = 0;
  bool _hasVoted = false;
  Duration _timeSpent = Duration.zero;
  bool _isTrackingTime = false;
  DateTime? _timeTrackingStart;

  @override
  void initState() {
    super.initState();
    _currentCard = widget.card;
    _tabController = TabController(length: 3, vsync: this);
    _votes = _random.nextInt(10) + 1; // Demo votes
  }

  @override
  void dispose() {
    _commentController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_currentCard.title),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editCard,
            tooltip: 'Edit Card',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'archive',
                child: Row(
                  children: [
                    Icon(Icons.archive),
                    SizedBox(width: 8),
                    Text('Archive'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(Icons.copy),
                    SizedBox(width: 8),
                    Text('Copy'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'move',
                child: Row(
                  children: [
                    Icon(Icons.move_to_inbox),
                    SizedBox(width: 8),
                    Text('Move'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: 'Details'),
            Tab(icon: Icon(Icons.attach_file), text: 'Attachments'),
            Tab(icon: Icon(Icons.comment), text: 'Activity'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailsTab(),
          _buildAttachmentsTab(),
          _buildActivityTab(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header with voting
          _buildCardHeader(),
          const SizedBox(height: AppConstants.spacingL),
          
          // Quick Actions
          _buildQuickActions(),
          const SizedBox(height: AppConstants.spacingL),
          
          // Labels
          if (_currentCard.labels.isNotEmpty) ...[
            _buildSectionTitle('Labels'),
            const SizedBox(height: AppConstants.spacingS),
            _buildLabels(),
            const SizedBox(height: AppConstants.spacingL),
          ],
          
          // Description
          _buildSectionTitle('Description'),
          const SizedBox(height: AppConstants.spacingS),
          _buildDescription(),
          const SizedBox(height: AppConstants.spacingL),
          
          // Assignees
          if (_currentCard.assigneeIds.isNotEmpty) ...[
            _buildSectionTitle('Assignees'),
            const SizedBox(height: AppConstants.spacingS),
            _buildAssignees(),
            const SizedBox(height: AppConstants.spacingL),
          ],
          
          // Due Date
          if (_currentCard.dueDate != null) ...[
            _buildSectionTitle('Due Date'),
            const SizedBox(height: AppConstants.spacingS),
            _buildDueDate(),
            const SizedBox(height: AppConstants.spacingL),
          ],
          
          // Time Tracking
          _buildSectionTitle('Time Tracking'),
          const SizedBox(height: AppConstants.spacingS),
          _buildTimeTracking(),
          const SizedBox(height: AppConstants.spacingL),
          
          // Checklist
          if (_currentCard.checklist.isNotEmpty) ...[
            _buildSectionTitle('Checklist'),
            const SizedBox(height: AppConstants.spacingS),
            _buildChecklist(),
            const SizedBox(height: AppConstants.spacingL),
          ],
        ],
      ),
    );
  }

  Widget _buildAttachmentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Attachments'),
          const SizedBox(height: AppConstants.spacingS),
          if (_currentCard.attachments.isEmpty)
            _buildEmptyAttachments()
          else
            _buildAttachments(),
        ],
      ),
    );
  }

  Widget _buildActivityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Comments'),
          const SizedBox(height: AppConstants.spacingS),
          _buildComments(),
          const SizedBox(height: AppConstants.spacingL),
          _buildAddComment(),
        ],
      ),
    );
  }

  Widget _buildCardHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _currentCard.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingS,
                    vertical: AppConstants.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: _currentCard.status.color,
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Text(
                    _currentCard.status.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingS),
            Row(
              children: [
                Text(
                  'Created by ${_getUserName(_currentCard.createdBy)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                // Voting section
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _hasVoted ? Icons.thumb_up : Icons.thumb_up_outlined,
                        color: _hasVoted ? AppTheme.primaryColor : AppTheme.textSecondary,
                      ),
                      onPressed: _toggleVote,
                    ),
                    Text(
                      '$_votes',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            Wrap(
              spacing: AppConstants.spacingS,
              runSpacing: AppConstants.spacingS,
              children: [
                _buildActionChip(
                  icon: Icons.schedule,
                  label: 'Set Due Date',
                  onTap: _setDueDate,
                ),
                _buildActionChip(
                  icon: Icons.person_add,
                  label: 'Add Member',
                  onTap: _addMember,
                ),
                _buildActionChip(
                  icon: Icons.label,
                  label: 'Add Label',
                  onTap: _addLabel,
                ),
                _buildActionChip(
                  icon: Icons.checklist,
                  label: 'Add Checklist',
                  onTap: _addChecklist,
                ),
                _buildActionChip(
                  icon: Icons.attach_file,
                  label: 'Add Attachment',
                  onTap: _addAttachment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingS,
        ),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: AppConstants.spacingXS),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeTracking() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.timer,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.spacingS),
                Text(
                  'Time Spent',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDuration(_timeSpent),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isTrackingTime ? _stopTimeTracking : _startTimeTracking,
                    icon: Icon(_isTrackingTime ? Icons.stop : Icons.play_arrow),
                    label: Text(_isTrackingTime ? 'Stop Timer' : 'Start Timer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isTrackingTime ? AppTheme.errorColor : AppTheme.successColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingS),
                OutlinedButton.icon(
                  onPressed: _resetTimeTracking,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAttachments() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          children: [
            Icon(
              Icons.attach_file,
              size: 48,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              'No attachments yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              'Add files, images, or links to this card',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textTertiary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            ElevatedButton.icon(
              onPressed: _addAttachment,
              icon: const Icon(Icons.add),
              label: const Text('Add Attachment'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: "add_comment",
          onPressed: () {
            _tabController.animateTo(2); // Switch to activity tab
            Future.delayed(const Duration(milliseconds: 300), () {
              FocusScope.of(context).requestFocus(FocusNode());
            });
          },
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.comment, color: Colors.white),
        ),
        const SizedBox(height: AppConstants.spacingS),
        FloatingActionButton(
          heroTag: "add_attachment",
          onPressed: _addAttachment,
          backgroundColor: AppTheme.successColor,
          child: const Icon(Icons.attach_file, color: Colors.white),
        ),
      ],
    );
  }

  // Helper methods
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildLabels() {
    return Wrap(
      spacing: AppConstants.spacingS,
      runSpacing: AppConstants.spacingS,
      children: _currentCard.labels.map((label) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingS,
          vertical: AppConstants.spacingXS,
        ),
        decoration: BoxDecoration(
          color: label.color,
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
        ),
        child: Text(
          label.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildDescription() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Text(
          _currentCard.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildAssignees() {
    final users = TrelloDemoDataService.getDemoUsers();
    return Wrap(
      spacing: AppConstants.spacingS,
      runSpacing: AppConstants.spacingS,
      children: _currentCard.assigneeIds.map((userId) {
        final user = users.firstWhere((u) => u.id == userId);
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingS,
            vertical: AppConstants.spacingXS,
          ),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusS),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundImage: NetworkImage(user.avatarUrl ?? 'https://i.pravatar.cc/150?img=1'),
              ),
              const SizedBox(width: AppConstants.spacingXS),
              Text(
                user.name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDueDate() {
    final isOverdue = _currentCard.isOverdue;
    return Card(
      color: isOverdue ? AppTheme.errorColor.withOpacity(0.1) : null,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Row(
          children: [
            Icon(
              Icons.schedule,
              color: isOverdue ? AppTheme.errorColor : AppTheme.textSecondary,
            ),
            const SizedBox(width: AppConstants.spacingS),
            Text(
              _formatDate(_currentCard.dueDate!),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isOverdue ? AppTheme.errorColor : AppTheme.textPrimary,
                fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isOverdue) ...[
              const SizedBox(width: AppConstants.spacingS),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingXS,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor,
                  borderRadius: BorderRadius.circular(AppConstants.radiusXS),
                ),
                child: const Text(
                  'OVERDUE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChecklist() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          children: [
            // Progress Bar
            Row(
              children: [
                Icon(
                  Icons.checklist,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.spacingS),
                Text(
                  '${_currentCard.checklist.where((item) => item.isCompleted).length}/${_currentCard.checklist.length}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(_currentCard.checklistProgress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingS),
            LinearProgressIndicator(
              value: _currentCard.checklistProgress,
              backgroundColor: AppTheme.textTertiary.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                _currentCard.checklistProgress == 1.0 
                    ? AppTheme.successColor 
                    : AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            
            // Checklist Items
            ..._currentCard.checklist.map((item) => _buildChecklistItem(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem(ChecklistItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingS),
      child: Row(
        children: [
          Checkbox(
            value: item.isCompleted,
            onChanged: (value) => _toggleChecklistItem(item, value ?? false),
            activeColor: AppTheme.primaryColor,
          ),
          Expanded(
            child: Text(
              item.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: item.isCompleted ? AppTheme.textSecondary : AppTheme.textPrimary,
                decoration: item.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachments() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          children: _currentCard.attachments.map((attachment) => Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.spacingS),
            child: Row(
              children: [
                Icon(
                  _getAttachmentIcon(attachment.type),
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: AppConstants.spacingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attachment.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Added by ${_getUserName(attachment.uploadedBy)} • ${_formatDate(attachment.uploadedAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () => _downloadAttachment(attachment),
                ),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildComments() {
    if (_currentCard.comments.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: Text(
            'No comments yet. Be the first to comment!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          children: _currentCard.comments.map((comment) => Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(_getUserAvatar(comment.authorId)),
                ),
                const SizedBox(width: AppConstants.spacingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            comment.authorName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(width: AppConstants.spacingS),
                          Text(
                            _formatDate(comment.createdAt),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacingXS),
                      Text(
                        comment.text,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildAddComment() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add a comment',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _commentController.clear(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: AppConstants.spacingS),
                ElevatedButton(
                  onPressed: _addComment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Comment'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Action methods
  void _handleMenuAction(String action) {
    switch (action) {
      case 'archive':
        _archiveCard();
        break;
      case 'copy':
        _copyCard();
        break;
      case 'move':
        _moveCard();
        break;
    }
  }

  void _toggleVote() {
    setState(() {
      if (_hasVoted) {
        _votes--;
        _hasVoted = false;
      } else {
        _votes++;
        _hasVoted = true;
      }
    });
  }

  void _startTimeTracking() {
    setState(() {
      _isTrackingTime = true;
      _timeTrackingStart = DateTime.now();
    });
    
    // Start a timer to update the display
    _updateTimeTracking();
  }

  void _stopTimeTracking() {
    if (_timeTrackingStart != null) {
      setState(() {
        _isTrackingTime = false;
        _timeSpent += DateTime.now().difference(_timeTrackingStart!);
        _timeTrackingStart = null;
      });
    }
  }

  void _resetTimeTracking() {
    setState(() {
      _timeSpent = Duration.zero;
      _isTrackingTime = false;
      _timeTrackingStart = null;
    });
  }

  void _updateTimeTracking() {
    if (_isTrackingTime && _timeTrackingStart != null) {
      setState(() {
        // This will trigger a rebuild to show updated time
      });
      Future.delayed(const Duration(seconds: 1), _updateTimeTracking);
    }
  }

  void _editCard() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit card functionality coming soon!'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _archiveCard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Card'),
        content: const Text('Are you sure you want to archive this card?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Card archived successfully!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }

  void _copyCard() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Card copied to clipboard!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _moveCard() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Move card functionality coming soon!'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _setDueDate() {
    showDatePicker(
      context: context,
      initialDate: _currentCard.dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((date) {
      if (date != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Due date set to ${_formatDate(date)}'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    });
  }

  void _addMember() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add member functionality coming soon!'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _addLabel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add label functionality coming soon!'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _addChecklist() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add checklist functionality coming soon!'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _addAttachment() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        final file = result.files.first;
        final attachment = CardAttachment(
          id: 'attachment_${DateTime.now().millisecondsSinceEpoch}',
          name: file.name,
          url: file.path ?? '',
          type: _getFileType(file.extension ?? ''),
          uploadedAt: DateTime.now(),
          uploadedBy: 'user_1', // Current user
        );

        final trelloProvider = Provider.of<TrelloProvider>(context, listen: false);
        trelloProvider.addAttachment(_currentCard.id, attachment);
        
        setState(() {
          _currentCard = trelloProvider.projectCards.firstWhere((c) => c.id == _currentCard.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${file.name} attached successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to attach file: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _toggleChecklistItem(ChecklistItem item, bool isCompleted) {
    final trelloProvider = Provider.of<TrelloProvider>(context, listen: false);
    final updatedItem = item.copyWith(isCompleted: isCompleted);
    trelloProvider.updateChecklistItem(_currentCard.id, item.id, updatedItem);
    
    setState(() {
      _currentCard = trelloProvider.projectCards.firstWhere((c) => c.id == _currentCard.id);
    });
  }

  void _downloadAttachment(CardAttachment attachment) async {
    if (attachment.type == 'link') {
      final uri = Uri.parse(attachment.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open link'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloading ${attachment.name}...'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    }
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    final trelloProvider = Provider.of<TrelloProvider>(context, listen: false);
    final comment = CardComment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      text: _commentController.text.trim(),
      authorId: 'user_1', // Current user
      authorName: 'John Doe', // Current user name
      createdAt: DateTime.now(),
    );

    trelloProvider.addComment(_currentCard.id, comment);
    _commentController.clear();
    
    setState(() {
      _currentCard = trelloProvider.projectCards.firstWhere((c) => c.id == _currentCard.id);
    });
  }

  // Helper methods
  String _getUserName(String userId) {
    final users = TrelloDemoDataService.getDemoUsers();
    final user = users.firstWhere(
      (user) => user.id == userId,
      orElse: () => users.first,
    );
    return user.name;
  }

  String _getUserAvatar(String userId) {
    final users = TrelloDemoDataService.getDemoUsers();
    final user = users.firstWhere(
      (user) => user.id == userId,
      orElse: () => users.first,
    );
    return user.avatarUrl ?? 'https://i.pravatar.cc/150?img=1';
  }

  IconData _getAttachmentIcon(String type) {
    switch (type) {
      case 'image':
        return Icons.image;
      case 'document':
        return Icons.description;
      case 'link':
        return Icons.link;
      default:
        return Icons.attach_file;
    }
  }

  String _getFileType(String extension) {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    final docExtensions = ['pdf', 'doc', 'docx', 'txt', 'rtf'];
    
    if (imageExtensions.contains(extension.toLowerCase())) {
      return 'image';
    } else if (docExtensions.contains(extension.toLowerCase())) {
      return 'document';
    } else {
      return 'file';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 0) {
      return 'In $difference days';
    } else {
      return '${-difference} days ago';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
