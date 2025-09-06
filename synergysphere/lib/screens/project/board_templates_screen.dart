import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/card.dart';
import '../../models/project_list.dart';
import '../../providers/trello_provider.dart';
import '../../theme/app_theme.dart';
import '../../constants/app_constants.dart';
import '../../services/trello_demo_data_service.dart';

class BoardTemplate {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> listNames;
  final List<Map<String, dynamic>> sampleCards;

  const BoardTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.listNames,
    required this.sampleCards,
  });
}

class BoardTemplatesScreen extends StatefulWidget {
  final String projectId;

  const BoardTemplatesScreen({
    super.key,
    required this.projectId,
  });

  @override
  State<BoardTemplatesScreen> createState() => _BoardTemplatesScreenState();
}

class _BoardTemplatesScreenState extends State<BoardTemplatesScreen> {
  final List<BoardTemplate> _templates = [
    BoardTemplate(
      id: 'kanban',
      name: 'Kanban Board',
      description: 'Classic Kanban workflow with To Do, In Progress, and Done columns',
      icon: Icons.view_kanban,
      color: AppTheme.primaryColor,
      listNames: ['To Do', 'In Progress', 'Done'],
      sampleCards: [
        {'title': 'Design user interface', 'description': 'Create wireframes and mockups'},
        {'title': 'Implement features', 'description': 'Develop core functionality'},
        {'title': 'Test application', 'description': 'Perform quality assurance testing'},
      ],
    ),
    BoardTemplate(
      id: 'scrum',
      name: 'Scrum Board',
      description: 'Agile development workflow with Sprint Backlog, In Progress, Review, and Done',
      icon: Icons.speed,
      color: const Color(0xFF10B981),
      listNames: ['Sprint Backlog', 'In Progress', 'Review', 'Done'],
      sampleCards: [
        {'title': 'User story: Login feature', 'description': 'Implement secure user authentication'},
        {'title': 'Bug fix: Payment processing', 'description': 'Resolve payment gateway issues'},
        {'title': 'Feature: Dark mode', 'description': 'Add dark theme support'},
      ],
    ),
    BoardTemplate(
      id: 'marketing',
      name: 'Marketing Campaign',
      description: 'Marketing workflow from Ideas to Published campaigns',
      icon: Icons.campaign,
      color: const Color(0xFFF59E0B),
      listNames: ['Ideas', 'Planning', 'In Progress', 'Review', 'Published'],
      sampleCards: [
        {'title': 'Social media campaign', 'description': 'Create engaging social media content'},
        {'title': 'Email newsletter', 'description': 'Design and send monthly newsletter'},
        {'title': 'Blog post series', 'description': 'Write informative blog articles'},
      ],
    ),
    BoardTemplate(
      id: 'product',
      name: 'Product Development',
      description: 'Product lifecycle from Research to Launch',
      icon: Icons.inventory,
      color: const Color(0xFF8B5CF6),
      listNames: ['Research', 'Design', 'Development', 'Testing', 'Launch'],
      sampleCards: [
        {'title': 'Market research', 'description': 'Analyze target market and competitors'},
        {'title': 'Product design', 'description': 'Create product specifications and designs'},
        {'title': 'Beta testing', 'description': 'Conduct user testing and feedback collection'},
      ],
    ),
    BoardTemplate(
      id: 'support',
      name: 'Customer Support',
      description: 'Support ticket workflow from New to Resolved',
      icon: Icons.support_agent,
      color: const Color(0xFFEF4444),
      listNames: ['New', 'In Progress', 'Waiting for Customer', 'Resolved'],
      sampleCards: [
        {'title': 'Login issues', 'description': 'Customer cannot access their account'},
        {'title': 'Feature request', 'description': 'Customer wants new functionality'},
        {'title': 'Bug report', 'description': 'Application crashes on mobile devices'},
      ],
    ),
    BoardTemplate(
      id: 'event',
      name: 'Event Planning',
      description: 'Event organization from Planning to Completed',
      icon: Icons.event,
      color: const Color(0xFF06B6D4),
      listNames: ['Planning', 'Preparation', 'In Progress', 'Completed'],
      sampleCards: [
        {'title': 'Venue booking', 'description': 'Reserve event location and facilities'},
        {'title': 'Catering arrangements', 'description': 'Organize food and beverages'},
        {'title': 'Guest invitations', 'description': 'Send out event invitations'},
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Board Templates'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose a Template',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingS),
                Text(
                  'Start with a pre-built board template or create a custom board from scratch',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Templates Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: AppConstants.spacingM,
                mainAxisSpacing: AppConstants.spacingM,
              ),
              itemCount: _templates.length + 1, // +1 for custom template
              itemBuilder: (context, index) {
                if (index == _templates.length) {
                  return _buildCustomTemplateCard();
                }
                return _buildTemplateCard(_templates[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(BoardTemplate template) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: InkWell(
        onTap: () => _createBoardFromTemplate(template),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Template Icon and Color
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: template.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Center(
                  child: Icon(
                    template.icon,
                    size: 32,
                    color: template.color,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingM),
              
              // Template Name
              Text(
                template.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppConstants.spacingS),
              
              // Template Description
              Expanded(
                child: Text(
                  template.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: AppConstants.spacingS),
              
              // List Names Preview
              Wrap(
                spacing: AppConstants.spacingXS,
                runSpacing: AppConstants.spacingXS,
                children: template.listNames.take(3).map((listName) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingXS,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: template.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusXS),
                  ),
                  child: Text(
                    listName,
                    style: TextStyle(
                      fontSize: 10,
                      color: template.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
              if (template.listNames.length > 3) ...[
                const SizedBox(height: AppConstants.spacingXS),
                Text(
                  '+${template.listNames.length - 3} more',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textTertiary,
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTemplateCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        side: BorderSide(
          color: AppTheme.primaryColor.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: InkWell(
        onTap: _createCustomBoard,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Icon(
                  Icons.add,
                  size: 32,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: AppConstants.spacingM),
              Text(
                'Custom Board',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: AppConstants.spacingS),
              Text(
                'Create a board from scratch with your own lists and structure',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createBoardFromTemplate(BoardTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create ${template.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This will create a new board with the following structure:'),
            const SizedBox(height: AppConstants.spacingM),
            ...template.listNames.map((listName) => Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spacingXS),
              child: Row(
                children: [
                  Icon(
                    Icons.list,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: AppConstants.spacingXS),
                  Text(listName),
                ],
              ),
            )),
            if (template.sampleCards.isNotEmpty) ...[
              const SizedBox(height: AppConstants.spacingM),
              Text(
                'Sample cards will be included:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.spacingS),
              ...template.sampleCards.take(2).map((card) => Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spacingXS),
                child: Row(
                  children: [
                    Icon(
                      Icons.credit_card,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: AppConstants.spacingXS),
                    Expanded(
                      child: Text(
                        card['title'],
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _applyTemplate(template);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: template.color,
              foregroundColor: Colors.white,
            ),
            child: const Text('Create Board'),
          ),
        ],
      ),
    );
  }

  void _createCustomBoard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Custom Board'),
        content: const Text('This will create an empty board where you can add your own lists and cards.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _applyCustomTemplate();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Create Board'),
          ),
        ],
      ),
    );
  }

  void _applyTemplate(BoardTemplate template) {
    final trelloProvider = Provider.of<TrelloProvider>(context, listen: false);
    
    // Create lists from template
    final lists = template.listNames.asMap().entries.map((entry) {
      return ProjectList(
        id: 'list_${widget.projectId}_${template.id}_${entry.key}',
        name: entry.value,
        projectId: widget.projectId,
        position: entry.key,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }).toList();

    // Create sample cards
    final cards = <ProjectCard>[];
    for (int i = 0; i < template.sampleCards.length && i < lists.length; i++) {
      final cardData = template.sampleCards[i];
      final list = lists[i];
      
      cards.add(ProjectCard(
        id: 'card_${widget.projectId}_${template.id}_${i}',
        title: cardData['title'],
        description: cardData['description'],
        projectId: widget.projectId,
        listId: list.id,
        status: _getStatusFromListName(list.name),
        position: 0,
        createdBy: 'user_1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }

    // Apply the template
    _applyBoardStructure(lists, cards);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${template.name} board created successfully!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _applyCustomTemplate() {
    final trelloProvider = Provider.of<TrelloProvider>(context, listen: false);
    
    // Create basic lists
    final lists = [
      ProjectList(
        id: 'list_${widget.projectId}_custom_0',
        name: 'To Do',
        projectId: widget.projectId,
        position: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ProjectList(
        id: 'list_${widget.projectId}_custom_1',
        name: 'In Progress',
        projectId: widget.projectId,
        position: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ProjectList(
        id: 'list_${widget.projectId}_custom_2',
        name: 'Done',
        projectId: widget.projectId,
        position: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    _applyBoardStructure(lists, []);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Custom board created successfully!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _applyBoardStructure(List<ProjectList> lists, List<ProjectCard> cards) {
    final trelloProvider = Provider.of<TrelloProvider>(context, listen: false);
    
    // Clear existing data
    trelloProvider.projectLists.clear();
    trelloProvider.projectCards.clear();
    
    // Add new lists and cards
    trelloProvider.projectLists.addAll(lists);
    trelloProvider.projectCards.addAll(cards);
    
    // Notify listeners
    trelloProvider.notifyListeners();
    
    // Navigate back
    Navigator.pop(context);
  }

  CardStatus _getStatusFromListName(String listName) {
    switch (listName.toLowerCase()) {
      case 'to do':
      case 'sprint backlog':
      case 'ideas':
      case 'research':
      case 'planning':
      case 'new':
        return CardStatus.todo;
      case 'in progress':
      case 'development':
      case 'preparation':
        return CardStatus.inProgress;
      case 'review':
      case 'testing':
      case 'waiting for customer':
        return CardStatus.review;
      case 'done':
      case 'published':
      case 'launch':
      case 'resolved':
      case 'completed':
        return CardStatus.done;
      default:
        return CardStatus.todo;
    }
  }
}
