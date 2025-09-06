import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/card.dart';
import '../../providers/trello_provider.dart';
import '../../theme/app_theme.dart';
import '../../constants/app_constants.dart';

class CreateCardScreen extends StatefulWidget {
  final String projectId;
  final String? listId;

  const CreateCardScreen({
    super.key,
    required this.projectId,
    this.listId,
  });

  @override
  State<CreateCardScreen> createState() => _CreateCardScreenState();
}

class _CreateCardScreenState extends State<CreateCardScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  CardStatus _selectedStatus = CardStatus.todo;
  DateTime? _selectedDueDate;
  List<String> _selectedAssigneeIds = [];
  List<CardLabel> _selectedLabels = [];

  final List<CardLabel> _availableLabels = [
    CardLabel(id: 'label_1', name: 'Frontend', color: const Color(0xFF3B82F6)),
    CardLabel(id: 'label_2', name: 'Backend', color: const Color(0xFF10B981)),
    CardLabel(id: 'label_3', name: 'Design', color: const Color(0xFFF59E0B)),
    CardLabel(id: 'label_4', name: 'Bug', color: const Color(0xFFEF4444)),
    CardLabel(id: 'label_5', name: 'Feature', color: const Color(0xFF8B5CF6)),
    CardLabel(id: 'label_6', name: 'Urgent', color: const Color(0xFFDC2626)),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.95,
              decoration: const BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppConstants.radiusL),
                ),
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: AppConstants.spacingM),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.textTertiary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingM),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Create New Card',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  
                  // Form
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingM,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            TextFormField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                labelText: 'Card Title',
                                hintText: 'Enter card title',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                  borderSide: BorderSide(color: AppTheme.primaryColor),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a card title';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppConstants.spacingL),
                            
                            // Description
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: 'Description',
                                hintText: 'Enter card description (optional)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                  borderSide: BorderSide(color: AppTheme.primaryColor),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingL),
                            
                            // Status
                            Text(
                              'Status',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingS),
                            Wrap(
                              spacing: AppConstants.spacingS,
                              children: CardStatus.values.map((status) {
                                final isSelected = _selectedStatus == status;
                                return FilterChip(
                                  label: Text(status.displayName),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedStatus = status;
                                    });
                                  },
                                  selectedColor: status.color.withOpacity(0.2),
                                  checkmarkColor: status.color,
                                  side: BorderSide(
                                    color: isSelected ? status.color : AppTheme.textTertiary,
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: AppConstants.spacingL),
                            
                            // Labels
                            Text(
                              'Labels',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingS),
                            Wrap(
                              spacing: AppConstants.spacingS,
                              children: _availableLabels.map((label) {
                                final isSelected = _selectedLabels.any((l) => l.id == label.id);
                                return FilterChip(
                                  label: Text(label.name),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedLabels.add(label);
                                      } else {
                                        _selectedLabels.removeWhere((l) => l.id == label.id);
                                      }
                                    });
                                  },
                                  selectedColor: label.color.withOpacity(0.2),
                                  checkmarkColor: label.color,
                                  side: BorderSide(
                                    color: isSelected ? label.color : AppTheme.textTertiary,
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: AppConstants.spacingL),
                            
                            // Due Date
                            Text(
                              'Due Date',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingS),
                            InkWell(
                              onTap: _selectDueDate,
                              child: Container(
                                padding: const EdgeInsets.all(AppConstants.spacingM),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppTheme.textTertiary),
                                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: AppTheme.textSecondary,
                                    ),
                                    const SizedBox(width: AppConstants.spacingS),
                                    Text(
                                      _selectedDueDate != null
                                          ? _formatDate(_selectedDueDate!)
                                          : 'Select due date (optional)',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: _selectedDueDate != null
                                            ? AppTheme.textPrimary
                                            : AppTheme.textSecondary,
                                      ),
                                    ),
                                    if (_selectedDueDate != null) ...[
                                      const Spacer(),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _selectedDueDate = null;
                                          });
                                        },
                                        icon: const Icon(Icons.clear),
                                        iconSize: 20,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingL),
                  
                            // Create Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _createCard,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppConstants.spacingM,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                  ),
                                ),
                                child: const Text(
                                  'Create Card',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingL),
                            const SizedBox(height: AppConstants.spacingXL), // Extra padding for bottom
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDueDate = date;
      });
    }
  }

  void _createCard() async {
    if (!_formKey.currentState!.validate()) return;

    final trelloProvider = Provider.of<TrelloProvider>(context, listen: false);
    
    // Find the appropriate list ID
    String listId = widget.listId ?? '';
    if (listId.isEmpty) {
      final lists = trelloProvider.projectLists;
      if (lists.isNotEmpty) {
        listId = lists.first.id;
      }
    }

    final card = ProjectCard(
      id: 'card_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      projectId: widget.projectId,
      listId: listId,
      status: _selectedStatus,
      assigneeIds: _selectedAssigneeIds,
      labels: _selectedLabels,
      checklist: [],
      attachments: [],
      comments: [],
      dueDate: _selectedDueDate,
      position: 0,
      createdBy: 'user_1', // Current user
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await trelloProvider.createCard(card);
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Card created successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
