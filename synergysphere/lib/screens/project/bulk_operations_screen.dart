import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/card.dart';
import '../../providers/trello_provider.dart';
import '../../theme/app_theme.dart';
import '../../constants/app_constants.dart';

class BulkOperationsScreen extends StatefulWidget {
  final List<ProjectCard> selectedCards;

  const BulkOperationsScreen({
    super.key,
    required this.selectedCards,
  });

  @override
  State<BulkOperationsScreen> createState() => _BulkOperationsScreenState();
}

class _BulkOperationsScreenState extends State<BulkOperationsScreen> {
  final List<ProjectCard> _selectedCards = [];
  String _selectedAction = '';
  CardStatus? _newStatus;
  List<String> _selectedLabels = [];
  List<String> _selectedAssignees = [];
  DateTime? _newDueDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCards.addAll(widget.selectedCards);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Bulk Operations (${_selectedCards.length})'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearSelection,
            tooltip: 'Clear Selection',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Selected Cards Summary
                _buildSelectedCardsSummary(),
                
                // Action Selection
                _buildActionSelection(),
                
                // Action Configuration
                if (_selectedAction.isNotEmpty) _buildActionConfiguration(),
                
                // Apply Button
                if (_selectedAction.isNotEmpty) _buildApplyButton(),
              ],
            ),
    );
  }

  Widget _buildSelectedCardsSummary() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.spacingM),
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spacingS),
              Text(
                'Selected Cards',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${_selectedCards.length}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            _selectedCards.map((card) => card.title).join(', '),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionSelection() {
    final actions = [
      {
        'id': 'move',
        'title': 'Move to List',
        'description': 'Move selected cards to a different list',
        'icon': Icons.move_to_inbox,
        'color': AppTheme.primaryColor,
      },
      {
        'id': 'assign',
        'title': 'Assign Members',
        'description': 'Assign team members to selected cards',
        'icon': Icons.person_add,
        'color': const Color(0xFF10B981),
      },
      {
        'id': 'label',
        'title': 'Add Labels',
        'description': 'Add labels to selected cards',
        'icon': Icons.label,
        'color': const Color(0xFFF59E0B),
      },
      {
        'id': 'due_date',
        'title': 'Set Due Date',
        'description': 'Set due date for selected cards',
        'icon': Icons.schedule,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'id': 'archive',
        'title': 'Archive Cards',
        'description': 'Archive selected cards',
        'icon': Icons.archive,
        'color': const Color(0xFFEF4444),
      },
      {
        'id': 'delete',
        'title': 'Delete Cards',
        'description': 'Permanently delete selected cards',
        'icon': Icons.delete_forever,
        'color': const Color(0xFFDC2626),
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Action',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingM),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: AppConstants.spacingS,
              mainAxisSpacing: AppConstants.spacingS,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              final isSelected = _selectedAction == action['id'];
              
              return Card(
                elevation: isSelected ? 4 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  side: BorderSide(
                    color: isSelected ? action['color'] as Color : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: InkWell(
                  onTap: () => _selectAction(action['id'] as String),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingM),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          action['icon'] as IconData,
                          color: action['color'] as Color,
                          size: 32,
                        ),
                        const SizedBox(height: AppConstants.spacingS),
                        Text(
                          action['title'] as String,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.spacingXS),
                        Text(
                          action['description'] as String,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionConfiguration() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.spacingM),
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configure Action',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingM),
          _buildActionSpecificConfiguration(),
        ],
      ),
    );
  }

  Widget _buildActionSpecificConfiguration() {
    switch (_selectedAction) {
      case 'move':
        return _buildMoveConfiguration();
      case 'assign':
        return _buildAssignConfiguration();
      case 'label':
        return _buildLabelConfiguration();
      case 'due_date':
        return _buildDueDateConfiguration();
      case 'archive':
        return _buildArchiveConfiguration();
      case 'delete':
        return _buildDeleteConfiguration();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMoveConfiguration() {
    final trelloProvider = Provider.of<TrelloProvider>(context, listen: false);
    final lists = trelloProvider.projectLists;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select destination list:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.spacingS),
        ...lists.map((list) => RadioListTile<CardStatus>(
          title: Text(list.name),
          value: _getStatusFromListName(list.name),
          groupValue: _newStatus,
          onChanged: (value) {
            setState(() {
              _newStatus = value;
            });
          },
        )),
      ],
    );
  }

  Widget _buildAssignConfiguration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select team members to assign:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.spacingS),
        // Demo team members
        ...['John Doe', 'Jane Smith', 'Mike Johnson', 'Sarah Wilson'].map((member) => CheckboxListTile(
          title: Text(member),
          value: _selectedAssignees.contains(member),
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _selectedAssignees.add(member);
              } else {
                _selectedAssignees.remove(member);
              }
            });
          },
        )),
      ],
    );
  }

  Widget _buildLabelConfiguration() {
    final labels = [
      {'name': 'Frontend', 'color': const Color(0xFF3B82F6)},
      {'name': 'Backend', 'color': const Color(0xFF10B981)},
      {'name': 'Design', 'color': const Color(0xFFF59E0B)},
      {'name': 'Bug', 'color': const Color(0xFFEF4444)},
      {'name': 'Feature', 'color': const Color(0xFF8B5CF6)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select labels to add:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.spacingS),
        Wrap(
          spacing: AppConstants.spacingS,
          children: labels.map((label) => FilterChip(
            label: Text(label['name'] as String),
            selected: _selectedLabels.contains(label['name']),
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedLabels.add(label['name'] as String);
                } else {
                  _selectedLabels.remove(label['name']);
                }
              });
            },
            selectedColor: (label['color'] as Color).withOpacity(0.2),
            checkmarkColor: label['color'] as Color,
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildDueDateConfiguration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Set due date:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.spacingS),
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: Text(_newDueDate != null 
              ? 'Due: ${_formatDate(_newDueDate!)}' 
              : 'No due date set'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: _selectDueDate,
        ),
      ],
    );
  }

  Widget _buildArchiveConfiguration() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: const Color(0xFFEF4444).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning,
            color: const Color(0xFFEF4444),
          ),
          const SizedBox(width: AppConstants.spacingS),
          Expanded(
            child: Text(
              'This will archive ${_selectedCards.length} cards. They will be moved to the archive and can be restored later.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteConfiguration() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: const Color(0xFFDC2626).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error,
            color: const Color(0xFFDC2626),
          ),
          const SizedBox(width: AppConstants.spacingS),
          Expanded(
            child: Text(
              'This will permanently delete ${_selectedCards.length} cards. This action cannot be undone.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFDC2626),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton() {
    Color buttonColor;
    String buttonText;
    
    switch (_selectedAction) {
      case 'archive':
        buttonColor = const Color(0xFFEF4444);
        buttonText = 'Archive Cards';
        break;
      case 'delete':
        buttonColor = const Color(0xFFDC2626);
        buttonText = 'Delete Cards';
        break;
      default:
        buttonColor = AppTheme.primaryColor;
        buttonText = 'Apply Changes';
    }

    return Container(
      margin: const EdgeInsets.all(AppConstants.spacingM),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _canApplyAction() ? _applyAction : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  void _selectAction(String action) {
    setState(() {
      _selectedAction = action;
      _newStatus = null;
      _selectedLabels.clear();
      _selectedAssignees.clear();
      _newDueDate = null;
    });
  }

  void _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _newDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _newDueDate = date;
      });
    }
  }

  bool _canApplyAction() {
    switch (_selectedAction) {
      case 'move':
        return _newStatus != null;
      case 'assign':
        return _selectedAssignees.isNotEmpty;
      case 'label':
        return _selectedLabels.isNotEmpty;
      case 'due_date':
        return _newDueDate != null;
      case 'archive':
      case 'delete':
        return true;
      default:
        return false;
    }
  }

  void _applyAction() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final trelloProvider = Provider.of<TrelloProvider>(context, listen: false);
      
      switch (_selectedAction) {
        case 'move':
          await _applyMoveAction(trelloProvider);
          break;
        case 'assign':
          await _applyAssignAction(trelloProvider);
          break;
        case 'label':
          await _applyLabelAction(trelloProvider);
          break;
        case 'due_date':
          await _applyDueDateAction(trelloProvider);
          break;
        case 'archive':
          await _applyArchiveAction(trelloProvider);
          break;
        case 'delete':
          await _applyDeleteAction(trelloProvider);
          break;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully applied ${_selectedAction} to ${_selectedCards.length} cards'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to apply action: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _applyMoveAction(TrelloProvider trelloProvider) async {
    // Find the target list
    final targetList = trelloProvider.projectLists.firstWhere(
      (list) => _getStatusFromListName(list.name) == _newStatus,
    );
    
    for (final card in _selectedCards) {
      await trelloProvider.moveCard(card.id, targetList.id);
    }
  }

  Future<void> _applyAssignAction(TrelloProvider trelloProvider) async {
    for (final card in _selectedCards) {
      final updatedCard = card.copyWith(
        assigneeIds: _selectedAssignees,
        updatedAt: DateTime.now(),
      );
      await trelloProvider.updateCard(updatedCard);
    }
  }

  Future<void> _applyLabelAction(TrelloProvider trelloProvider) async {
    for (final card in _selectedCards) {
      final existingLabels = card.labels.map((l) => l.name).toList();
      final newLabels = [...existingLabels, ..._selectedLabels];
      
      final updatedLabels = newLabels.map((name) => CardLabel(
        id: 'label_$name',
        name: name,
        color: _getLabelColor(name),
      )).toList();
      
      final updatedCard = card.copyWith(
        labels: updatedLabels,
        updatedAt: DateTime.now(),
      );
      await trelloProvider.updateCard(updatedCard);
    }
  }

  Future<void> _applyDueDateAction(TrelloProvider trelloProvider) async {
    for (final card in _selectedCards) {
      final updatedCard = card.copyWith(
        dueDate: _newDueDate,
        updatedAt: DateTime.now(),
      );
      await trelloProvider.updateCard(updatedCard);
    }
  }

  Future<void> _applyArchiveAction(TrelloProvider trelloProvider) async {
    for (final card in _selectedCards) {
      final updatedCard = card.copyWith(
        isArchived: true,
        updatedAt: DateTime.now(),
      );
      await trelloProvider.updateCard(updatedCard);
    }
  }

  Future<void> _applyDeleteAction(TrelloProvider trelloProvider) async {
    for (final card in _selectedCards) {
      await trelloProvider.deleteCard(card.id);
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedCards.clear();
    });
    Navigator.pop(context);
  }

  CardStatus _getStatusFromListName(String listName) {
    switch (listName.toLowerCase()) {
      case 'to do':
        return CardStatus.todo;
      case 'in progress':
        return CardStatus.inProgress;
      case 'review':
        return CardStatus.review;
      case 'done':
        return CardStatus.done;
      default:
        return CardStatus.todo;
    }
  }

  Color _getLabelColor(String labelName) {
    switch (labelName) {
      case 'Frontend':
        return const Color(0xFF3B82F6);
      case 'Backend':
        return const Color(0xFF10B981);
      case 'Design':
        return const Color(0xFFF59E0B);
      case 'Bug':
        return const Color(0xFFEF4444);
      case 'Feature':
        return const Color(0xFF8B5CF6);
      default:
        return AppTheme.primaryColor;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
