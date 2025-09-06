import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../constants/app_constants.dart';

class PowerUp {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool isEnabled;
  final String category;

  const PowerUp({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.isEnabled,
    required this.category,
  });

  PowerUp copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    Color? color,
    bool? isEnabled,
    String? category,
  }) {
    return PowerUp(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isEnabled: isEnabled ?? this.isEnabled,
      category: category ?? this.category,
    );
  }
}

class PowerUpsScreen extends StatefulWidget {
  const PowerUpsScreen({super.key});

  @override
  State<PowerUpsScreen> createState() => _PowerUpsScreenState();
}

class _PowerUpsScreenState extends State<PowerUpsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<PowerUp> _powerUps = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializePowerUps();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _initializePowerUps() {
    _powerUps = [
      // Productivity
      PowerUp(
        id: 'keyboard_shortcuts',
        name: 'Keyboard Shortcuts',
        description: 'Navigate and perform actions quickly with keyboard shortcuts',
        icon: Icons.keyboard,
        color: AppTheme.primaryColor,
        isEnabled: true,
        category: 'Productivity',
      ),
      PowerUp(
        id: 'bulk_operations',
        name: 'Bulk Operations',
        description: 'Select and perform actions on multiple cards at once',
        icon: Icons.select_all,
        color: AppTheme.primaryColor,
        isEnabled: false,
        category: 'Productivity',
      ),
      PowerUp(
        id: 'card_templates',
        name: 'Card Templates',
        description: 'Create reusable card templates for common tasks',
        icon: Icons.content_copy,
        color: AppTheme.primaryColor,
        isEnabled: false,
        category: 'Productivity',
      ),
      PowerUp(
        id: 'auto_archive',
        name: 'Auto Archive',
        description: 'Automatically archive completed cards after a specified time',
        icon: Icons.archive,
        color: AppTheme.primaryColor,
        isEnabled: false,
        category: 'Productivity',
      ),

      // Automation
      PowerUp(
        id: 'auto_move',
        name: 'Auto Move Cards',
        description: 'Automatically move cards based on due dates or conditions',
        icon: Icons.autorenew,
        color: const Color(0xFF10B981),
        isEnabled: false,
        category: 'Automation',
      ),
      PowerUp(
        id: 'smart_notifications',
        name: 'Smart Notifications',
        description: 'Get intelligent notifications based on your work patterns',
        icon: Icons.notifications_active,
        color: const Color(0xFF10B981),
        isEnabled: false,
        category: 'Automation',
      ),
      PowerUp(
        id: 'auto_assign',
        name: 'Auto Assignment',
        description: 'Automatically assign cards based on workload and skills',
        icon: Icons.person_add_alt,
        color: const Color(0xFF10B981),
        isEnabled: false,
        category: 'Automation',
      ),
      PowerUp(
        id: 'workflow_rules',
        name: 'Workflow Rules',
        description: 'Create custom rules to automate repetitive tasks',
        icon: Icons.rule,
        color: const Color(0xFF10B981),
        isEnabled: false,
        category: 'Automation',
      ),

      // Analytics
      PowerUp(
        id: 'time_tracking',
        name: 'Time Tracking',
        description: 'Track time spent on cards and generate reports',
        icon: Icons.timer,
        color: const Color(0xFFF59E0B),
        isEnabled: false,
        category: 'Analytics',
      ),
      PowerUp(
        id: 'velocity_charts',
        name: 'Velocity Charts',
        description: 'Visualize team productivity and sprint velocity',
        icon: Icons.show_chart,
        color: const Color(0xFFF59E0B),
        isEnabled: false,
        category: 'Analytics',
      ),
      PowerUp(
        id: 'burndown_charts',
        name: 'Burndown Charts',
        description: 'Track progress with burndown and burnup charts',
        icon: Icons.trending_down,
        color: const Color(0xFFF59E0B),
        isEnabled: false,
        category: 'Analytics',
      ),
      PowerUp(
        id: 'team_insights',
        name: 'Team Insights',
        description: 'Get insights into team performance and collaboration',
        icon: Icons.insights,
        color: const Color(0xFFF59E0B),
        isEnabled: false,
        category: 'Analytics',
      ),

      // Integrations
      PowerUp(
        id: 'calendar_sync',
        name: 'Calendar Sync',
        description: 'Sync due dates with Google Calendar or Outlook',
        icon: Icons.calendar_today,
        color: const Color(0xFF8B5CF6),
        isEnabled: false,
        category: 'Integrations',
      ),
      PowerUp(
        id: 'slack_integration',
        name: 'Slack Integration',
        description: 'Get notifications and updates in Slack channels',
        icon: Icons.chat,
        color: const Color(0xFF8B5CF6),
        isEnabled: false,
        category: 'Integrations',
      ),
      PowerUp(
        id: 'github_integration',
        name: 'GitHub Integration',
        description: 'Link cards to GitHub issues and pull requests',
        icon: Icons.code,
        color: const Color(0xFF8B5CF6),
        isEnabled: false,
        category: 'Integrations',
      ),
      PowerUp(
        id: 'email_integration',
        name: 'Email Integration',
        description: 'Create cards from emails and send updates via email',
        icon: Icons.email,
        color: const Color(0xFF8B5CF6),
        isEnabled: false,
        category: 'Integrations',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Power-Ups'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Productivity'),
            Tab(text: 'Automation'),
            Tab(text: 'Analytics'),
            Tab(text: 'Integrations'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search power-ups...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Power-ups List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPowerUpsList(_getFilteredPowerUps()),
                _buildPowerUpsList(_getFilteredPowerUps('Productivity')),
                _buildPowerUpsList(_getFilteredPowerUps('Automation')),
                _buildPowerUpsList(_getFilteredPowerUps('Analytics')),
                _buildPowerUpsList(_getFilteredPowerUps('Integrations')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerUpsList(List<PowerUp> powerUps) {
    if (powerUps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.extension,
              size: 64,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              'No power-ups found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              'Try adjusting your search or browse different categories',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      itemCount: powerUps.length,
      itemBuilder: (context, index) {
        final powerUp = powerUps[index];
        return _buildPowerUpCard(powerUp);
      },
    );
  }

  Widget _buildPowerUpCard(PowerUp powerUp) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Row(
          children: [
            // Power-up Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: powerUp.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Icon(
                powerUp.icon,
                color: powerUp.color,
                size: 24,
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
            
            // Power-up Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          powerUp.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingS,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: powerUp.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppConstants.radiusS),
                        ),
                        child: Text(
                          powerUp.category,
                          style: TextStyle(
                            fontSize: 10,
                            color: powerUp.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingXS),
                  Text(
                    powerUp.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
            
            // Toggle Switch
            Switch(
              value: powerUp.isEnabled,
              onChanged: (value) => _togglePowerUp(powerUp, value),
              activeColor: powerUp.color,
            ),
          ],
        ),
      ),
    );
  }

  List<PowerUp> _getFilteredPowerUps([String? category]) {
    var filtered = _powerUps;
    
    if (category != null) {
      filtered = filtered.where((powerUp) => powerUp.category == category).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((powerUp) {
        return powerUp.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               powerUp.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    return filtered;
  }

  void _togglePowerUp(PowerUp powerUp, bool enabled) {
    setState(() {
      final index = _powerUps.indexWhere((p) => p.id == powerUp.id);
      if (index != -1) {
        _powerUps[index] = powerUp.copyWith(isEnabled: enabled);
      }
    });

    if (enabled) {
      _showPowerUpDetails(powerUp);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${powerUp.name} disabled'),
          backgroundColor: AppTheme.textSecondary,
        ),
      );
    }
  }

  void _showPowerUpDetails(PowerUp powerUp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: powerUp.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
              ),
              child: Icon(
                powerUp.icon,
                color: powerUp.color,
                size: 18,
              ),
            ),
            const SizedBox(width: AppConstants.spacingS),
            Expanded(child: Text(powerUp.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(powerUp.description),
            const SizedBox(height: AppConstants.spacingM),
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingS),
              decoration: BoxDecoration(
                color: powerUp.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    size: 16,
                    color: powerUp.color,
                  ),
                  const SizedBox(width: AppConstants.spacingXS),
                  Text(
                    'Category: ${powerUp.category}',
                    style: TextStyle(
                      color: powerUp.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (powerUp.id == 'keyboard_shortcuts') ...[
              const SizedBox(height: AppConstants.spacingM),
              const Text(
                'Keyboard Shortcuts:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppConstants.spacingS),
              _buildShortcutItem('Ctrl/Cmd + N', 'Create new card'),
              _buildShortcutItem('Ctrl/Cmd + F', 'Search cards'),
              _buildShortcutItem('Ctrl/Cmd + A', 'Select all cards'),
              _buildShortcutItem('Delete', 'Delete selected cards'),
              _buildShortcutItem('Ctrl/Cmd + Z', 'Undo last action'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (powerUp.id == 'keyboard_shortcuts')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showKeyboardShortcuts();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: powerUp.color,
                foregroundColor: Colors.white,
              ),
              child: const Text('View All Shortcuts'),
            ),
        ],
      ),
    );
  }

  Widget _buildShortcutItem(String shortcut, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingXS),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingXS,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppTheme.textTertiary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusXS),
            ),
            child: Text(
              shortcut,
              style: const TextStyle(
                fontSize: 10,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingS),
          Expanded(
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  void _showKeyboardShortcuts() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keyboard Shortcuts'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShortcutSection('Navigation', [
                _buildShortcutItem('↑↓', 'Navigate between cards'),
                _buildShortcutItem('←→', 'Navigate between lists'),
                _buildShortcutItem('Esc', 'Close dialogs'),
                _buildShortcutItem('Tab', 'Focus next element'),
              ]),
              const SizedBox(height: AppConstants.spacingM),
              _buildShortcutSection('Actions', [
                _buildShortcutItem('Ctrl/Cmd + N', 'Create new card'),
                _buildShortcutItem('Ctrl/Cmd + F', 'Search cards'),
                _buildShortcutItem('Ctrl/Cmd + A', 'Select all cards'),
                _buildShortcutItem('Delete', 'Delete selected cards'),
                _buildShortcutItem('Ctrl/Cmd + Z', 'Undo last action'),
                _buildShortcutItem('Ctrl/Cmd + Y', 'Redo last action'),
              ]),
              const SizedBox(height: AppConstants.spacingM),
              _buildShortcutSection('Card Operations', [
                _buildShortcutItem('Enter', 'Open card details'),
                _buildShortcutItem('Space', 'Toggle card selection'),
                _buildShortcutItem('Ctrl/Cmd + C', 'Copy card'),
                _buildShortcutItem('Ctrl/Cmd + V', 'Paste card'),
                _buildShortcutItem('Ctrl/Cmd + D', 'Duplicate card'),
              ]),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutSection(String title, List<Widget> shortcuts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.spacingS),
        ...shortcuts,
      ],
    );
  }
}
