import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../models/card.dart';
import '../../models/project_list.dart';
import '../../models/team_member.dart';
import '../../providers/trello_provider.dart';
import '../../theme/app_theme.dart';
import '../../constants/app_constants.dart';
import '../../services/trello_demo_data_service.dart';
import 'card_detail_screen.dart';
import 'create_card_screen.dart';
import 'team_members_screen.dart';

class TrelloBoardScreen extends StatefulWidget {
  final String projectId;

  const TrelloBoardScreen({
    super.key,
    required this.projectId,
  });

  @override
  State<TrelloBoardScreen> createState() => _TrelloBoardScreenState();
}

class _TrelloBoardScreenState extends State<TrelloBoardScreen> {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadProjectData();
  }

  Future<void> _loadProjectData() async {
    final trelloProvider = Provider.of<TrelloProvider>(context, listen: false);
    await trelloProvider.loadProjectData(widget.projectId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Project Board'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            onPressed: () => _showTeamMembers(),
            tooltip: 'Team Members',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateCardDialog(),
            tooltip: 'Add Card',
          ),
        ],
      ),
      body: Consumer<TrelloProvider>(
        builder: (context, trelloProvider, child) {
          if (trelloProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final lists = trelloProvider.projectLists;
          final cards = trelloProvider.projectCards;

          return AnimationLimiter(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(AppConstants.spacingM),
              itemCount: lists.length,
              itemBuilder: (context, index) {
                final list = lists[index];
                final listCards = cards.where((card) => card.listId == list.id).toList();
                
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildListColumn(list, listCards),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildListColumn(ProjectList list, List<ProjectCard> cards) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: AppConstants.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // List Header
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    list.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingS,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Text(
                    '${cards.length}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingM),
          
          // Cards
          Expanded(
            child: ReorderableListView.builder(
              padding: EdgeInsets.zero,
              itemCount: cards.length + 1, // +1 for add card button
              onReorder: (oldIndex, newIndex) {
                _reorderCards(list.id, cards, oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                if (index == cards.length) {
                  return _buildAddCardButton(list);
                }
                
                final card = cards[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildCard(card),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(ProjectCard card) {
    return Container(
      key: ValueKey(card.id),
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: InkWell(
          onTap: () => _openCardDetail(card),
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Labels
                if (card.labels.isNotEmpty) ...[
                  Wrap(
                    spacing: AppConstants.spacingXS,
                    runSpacing: AppConstants.spacingXS,
                    children: card.labels.map((label) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingXS,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: label.color,
                        borderRadius: BorderRadius.circular(AppConstants.radiusXS),
                      ),
                      child: Text(
                        label.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                ],
                
                // Title
                Text(
                  card.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: AppConstants.spacingS),
                
                // Description
                if (card.description.isNotEmpty) ...[
                  Text(
                    card.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                ],
                
                // Checklist Progress
                if (card.checklist.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.checklist,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: AppConstants.spacingXS),
                      Text(
                        '${card.checklist.where((item) => item.isCompleted).length}/${card.checklist.length}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingS),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: card.checklistProgress,
                          backgroundColor: AppTheme.textTertiary.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            card.checklistProgress == 1.0 
                                ? AppTheme.successColor 
                                : AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                ],
                
                // Due Date
                if (card.dueDate != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: card.isOverdue ? AppTheme.errorColor : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: AppConstants.spacingXS),
                      Text(
                        _formatDate(card.dueDate!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: card.isOverdue ? AppTheme.errorColor : AppTheme.textSecondary,
                          fontWeight: card.isOverdue ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                ],
                
                // Assignees
                if (card.assigneeIds.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: AppConstants.spacingXS),
                      Expanded(
                        child: Text(
                          '${card.assigneeIds.length} member${card.assigneeIds.length > 1 ? 's' : ''}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddCardButton(ProjectList list) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Card(
        elevation: 0,
        color: AppTheme.cardColor.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          side: BorderSide(
            color: AppTheme.primaryColor.withOpacity(0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: InkWell(
          onTap: () => _showCreateCardDialog(listId: list.id),
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: Row(
              children: [
                Icon(
                  Icons.add,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.spacingS),
                Text(
                  'Add a card',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _reorderCards(String listId, List<ProjectCard> cards, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    
    final trelloProvider = Provider.of<TrelloProvider>(context, listen: false);
    trelloProvider.reorderCards(listId, oldIndex, newIndex);
  }

  void _openCardDetail(ProjectCard card) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CardDetailScreen(card: card),
      ),
    );
  }

  void _showCreateCardDialog({String? listId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateCardScreen(
        projectId: widget.projectId,
        listId: listId,
      ),
    );
  }

  void _showTeamMembers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamMembersScreen(projectId: widget.projectId),
      ),
    );
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
