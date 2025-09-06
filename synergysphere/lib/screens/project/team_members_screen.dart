import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/team_member.dart';
import '../../providers/trello_provider.dart';
import '../../theme/app_theme.dart';
import '../../constants/app_constants.dart';
import '../../services/trello_demo_data_service.dart';

class TeamMembersScreen extends StatefulWidget {
  final String projectId;

  const TeamMembersScreen({
    super.key,
    required this.projectId,
  });

  @override
  State<TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class _TeamMembersScreenState extends State<TeamMembersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Team Members'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _inviteMember,
            tooltip: 'Invite Member',
          ),
        ],
      ),
      body: Consumer<TrelloProvider>(
        builder: (context, trelloProvider, child) {
          final members = trelloProvider.teamMembers;
          final users = TrelloDemoDataService.getDemoUsers();

          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              final user = users.firstWhere(
                (u) => u.id == member.userId,
                orElse: () => users.first,
              );

              return Card(
                margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.avatarUrl ?? 'https://i.pravatar.cc/150?img=1'),
                    radius: 24,
                  ),
                  title: Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingXS),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spacingS,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getRoleColor(member.role).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppConstants.radiusS),
                              border: Border.all(
                                color: _getRoleColor(member.role).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              member.role.displayName,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _getRoleColor(member.role),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppConstants.spacingS),
                          Text(
                            'Joined ${_formatDate(member.joinedAt)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: member.role != MemberRole.owner
                      ? PopupMenuButton<String>(
                          onSelected: (value) => _handleMemberAction(value, member),
                          itemBuilder: (context) => [
                            if (member.role != MemberRole.owner) ...[
                              const PopupMenuItem(
                                value: 'change_role',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: AppConstants.spacingS),
                                    Text('Change Role'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'remove',
                                child: Row(
                                  children: [
                                    Icon(Icons.person_remove, size: 20, color: AppTheme.errorColor),
                                    SizedBox(width: AppConstants.spacingS),
                                    Text('Remove Member', style: TextStyle(color: AppTheme.errorColor)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingS,
                            vertical: AppConstants.spacingXS,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppConstants.radiusS),
                          ),
                          child: Text(
                            'Owner',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _inviteMember() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _InviteMemberSheet(projectId: widget.projectId),
    );
  }

  void _handleMemberAction(String action, TeamMember member) {
    switch (action) {
      case 'change_role':
        _changeMemberRole(member);
        break;
      case 'remove':
        _removeMember(member);
        break;
    }
  }

  void _changeMemberRole(TeamMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Role for ${_getUserName(member.userId)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: MemberRole.values.map((role) {
            if (role == MemberRole.owner) return const SizedBox.shrink();
            
            return RadioListTile<MemberRole>(
              title: Text(role.displayName),
              subtitle: Text(role.description),
              value: role,
              groupValue: member.role,
              onChanged: (value) {
                if (value != null) {
                  _updateMemberRole(member, value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _updateMemberRole(TeamMember member, MemberRole newRole) {
    final trelloProvider = Provider.of<TrelloProvider>(context, listen: false);
    final updatedMember = member.copyWith(role: newRole);
    trelloProvider.updateTeamMember(updatedMember);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_getUserName(member.userId)} role updated to ${newRole.displayName}'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _removeMember(TeamMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Are you sure you want to remove ${_getUserName(member.userId)} from this project?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final trelloProvider = Provider.of<TrelloProvider>(context, listen: false);
              trelloProvider.removeTeamMember(member.id);
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${_getUserName(member.userId)} removed from project'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  String _getUserName(String userId) {
    final users = TrelloDemoDataService.getDemoUsers();
    final user = users.firstWhere(
      (user) => user.id == userId,
      orElse: () => users.first,
    );
    return user.name;
  }

  Color _getRoleColor(MemberRole role) {
    switch (role) {
      case MemberRole.owner:
        return AppTheme.primaryColor;
      case MemberRole.admin:
        return AppTheme.warningColor;
      case MemberRole.member:
        return AppTheme.successColor;
      case MemberRole.viewer:
        return AppTheme.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'today';
    } else if (difference == 1) {
      return 'yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      final months = (difference / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
  }
}

class _InviteMemberSheet extends StatefulWidget {
  final String projectId;

  const _InviteMemberSheet({required this.projectId});

  @override
  State<_InviteMemberSheet> createState() => _InviteMemberSheetState();
}

class _InviteMemberSheetState extends State<_InviteMemberSheet> {
  final _emailController = TextEditingController();
  MemberRole _selectedRole = MemberRole.member;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
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
                    'Invite Team Member',
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'Enter member email',
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
                  
                  // Role Selection
                  Text(
                    'Role',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  
                  ...MemberRole.values.where((role) => role != MemberRole.owner).map((role) {
                    return RadioListTile<MemberRole>(
                      title: Text(role.displayName),
                      subtitle: Text(role.description),
                      value: role,
                      groupValue: _selectedRole,
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                    );
                  }).toList(),
                  
                  const Spacer(),
                  
                  // Invite Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _inviteMember,
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
                        'Send Invitation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingL),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _inviteMember() {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an email address'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // TODO: Implement actual invitation logic
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invitation sent to ${_emailController.text}'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }
}
