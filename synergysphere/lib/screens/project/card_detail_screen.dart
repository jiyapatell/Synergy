import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/card.dart';
import '../../providers/trello_provider.dart';
import '../../theme/app_theme.dart';
import '../../constants/app_constants.dart';
import '../../services/trello_demo_data_service.dart';

class CardDetailScreen extends StatefulWidget {
  final ProjectCard card;

  const CardDetailScreen({
    super.key,
    required this.card,
  });

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  late ProjectCard _currentCard;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentCard = widget.card;
  }

  @override
  void dispose() {
    _commentController.dispose();
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
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header
            _buildCardHeader(),
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
            
            // Checklist
            if (_currentCard.checklist.isNotEmpty) ...[
              _buildSectionTitle('Checklist'),
              const SizedBox(height: AppConstants.spacingS),
              _buildChecklist(),
              const SizedBox(height: AppConstants.spacingL),
            ],
            
            // Attachments
            if (_currentCard.attachments.isNotEmpty) ...[
              _buildSectionTitle('Attachments'),
              const SizedBox(height: AppConstants.spacingS),
              _buildAttachments(),
              const SizedBox(height: AppConstants.spacingL),
            ],
            
            // Comments
            _buildSectionTitle('Comments'),
            const SizedBox(height: AppConstants.spacingS),
            _buildComments(),
            const SizedBox(height: AppConstants.spacingL),
            
            // Add Comment
            _buildAddComment(),
          ],
        ),
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
            Text(
              'Created by ${_getUserName(_currentCard.createdBy)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  void _editCard() {
    // TODO: Implement edit card functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit card functionality coming soon!'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _toggleChecklistItem(ChecklistItem item, bool isCompleted) {
    final trelloProvider = Provider.of<TrelloProvider>(context, listen: false);
    final updatedItem = item.copyWith(isCompleted: isCompleted);
    trelloProvider.updateChecklistItem(_currentCard.id, item.id, updatedItem);
    
    setState(() {
      _currentCard = trelloProvider.projectCards.firstWhere((c) => c.id == _currentCard.id);
    });
  }

  void _downloadAttachment(CardAttachment attachment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${attachment.name}...'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
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
}
