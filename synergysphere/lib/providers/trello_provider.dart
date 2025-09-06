import 'package:flutter/foundation.dart';
import '../models/card.dart';
import '../models/project_list.dart';
import '../models/team_member.dart';
import '../services/trello_demo_data_service.dart';

class TrelloProvider with ChangeNotifier {
  List<ProjectList> _projectLists = [];
  List<ProjectCard> _projectCards = [];
  List<TeamMember> _teamMembers = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<ProjectList> get projectLists => _projectLists;
  List<ProjectCard> get projectCards => _projectCards;
  List<TeamMember> get teamMembers => _teamMembers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadProjectData(String projectId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load demo data
      _projectLists = TrelloDemoDataService.getDemoProjectLists(projectId);
      _projectCards = [];
      
      // Load cards for each list
      for (final list in _projectLists) {
        final listCards = TrelloDemoDataService.getDemoCards(projectId, list.id);
        _projectCards.addAll(listCards);
      }
      
      _teamMembers = TrelloDemoDataService.getDemoTeamMembers(projectId);
    } catch (e) {
      _errorMessage = 'Failed to load project data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createCard(ProjectCard card) async {
    try {
      _projectCards.add(card);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to create card: $e';
      notifyListeners();
    }
  }

  Future<void> updateCard(ProjectCard card) async {
    try {
      final index = _projectCards.indexWhere((c) => c.id == card.id);
      if (index != -1) {
        _projectCards[index] = card;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to update card: $e';
      notifyListeners();
    }
  }

  Future<void> deleteCard(String cardId) async {
    try {
      _projectCards.removeWhere((card) => card.id == cardId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete card: $e';
      notifyListeners();
    }
  }

  Future<void> moveCard(String cardId, String newListId) async {
    try {
      final cardIndex = _projectCards.indexWhere((card) => card.id == cardId);
      if (cardIndex != -1) {
        final card = _projectCards[cardIndex];
        final newCard = card.copyWith(
          listId: newListId,
          updatedAt: DateTime.now(),
        );
        _projectCards[cardIndex] = newCard;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to move card: $e';
      notifyListeners();
    }
  }

  void reorderCards(String listId, int oldIndex, int newIndex) {
    try {
      final listCards = _projectCards.where((card) => card.listId == listId).toList();
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      
      final card = listCards.removeAt(oldIndex);
      listCards.insert(newIndex, card);
      
      // Update positions
      for (int i = 0; i < listCards.length; i++) {
        final cardIndex = _projectCards.indexWhere((c) => c.id == listCards[i].id);
        if (cardIndex != -1) {
          _projectCards[cardIndex] = listCards[i].copyWith(
            position: i,
            updatedAt: DateTime.now(),
          );
        }
      }
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to reorder cards: $e';
      notifyListeners();
    }
  }

  Future<void> addTeamMember(TeamMember member) async {
    try {
      _teamMembers.add(member);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add team member: $e';
      notifyListeners();
    }
  }

  Future<void> updateTeamMember(TeamMember member) async {
    try {
      final index = _teamMembers.indexWhere((m) => m.id == member.id);
      if (index != -1) {
        _teamMembers[index] = member;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to update team member: $e';
      notifyListeners();
    }
  }

  Future<void> removeTeamMember(String memberId) async {
    try {
      _teamMembers.removeWhere((member) => member.id == memberId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to remove team member: $e';
      notifyListeners();
    }
  }

  Future<void> addChecklistItem(String cardId, ChecklistItem item) async {
    try {
      final cardIndex = _projectCards.indexWhere((card) => card.id == cardId);
      if (cardIndex != -1) {
        final card = _projectCards[cardIndex];
        final updatedChecklist = List<ChecklistItem>.from(card.checklist)..add(item);
        _projectCards[cardIndex] = card.copyWith(
          checklist: updatedChecklist,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to add checklist item: $e';
      notifyListeners();
    }
  }

  Future<void> updateChecklistItem(String cardId, String itemId, ChecklistItem item) async {
    try {
      final cardIndex = _projectCards.indexWhere((card) => card.id == cardId);
      if (cardIndex != -1) {
        final card = _projectCards[cardIndex];
        final updatedChecklist = card.checklist.map((i) => i.id == itemId ? item : i).toList();
        _projectCards[cardIndex] = card.copyWith(
          checklist: updatedChecklist,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to update checklist item: $e';
      notifyListeners();
    }
  }

  Future<void> deleteChecklistItem(String cardId, String itemId) async {
    try {
      final cardIndex = _projectCards.indexWhere((card) => card.id == cardId);
      if (cardIndex != -1) {
        final card = _projectCards[cardIndex];
        final updatedChecklist = card.checklist.where((i) => i.id != itemId).toList();
        _projectCards[cardIndex] = card.copyWith(
          checklist: updatedChecklist,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to delete checklist item: $e';
      notifyListeners();
    }
  }

  Future<void> addComment(String cardId, CardComment comment) async {
    try {
      final cardIndex = _projectCards.indexWhere((card) => card.id == cardId);
      if (cardIndex != -1) {
        final card = _projectCards[cardIndex];
        final updatedComments = List<CardComment>.from(card.comments)..add(comment);
        _projectCards[cardIndex] = card.copyWith(
          comments: updatedComments,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to add comment: $e';
      notifyListeners();
    }
  }

  Future<void> addAttachment(String cardId, CardAttachment attachment) async {
    try {
      final cardIndex = _projectCards.indexWhere((card) => card.id == cardId);
      if (cardIndex != -1) {
        final card = _projectCards[cardIndex];
        final updatedAttachments = List<CardAttachment>.from(card.attachments)..add(attachment);
        _projectCards[cardIndex] = card.copyWith(
          attachments: updatedAttachments,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to add attachment: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
