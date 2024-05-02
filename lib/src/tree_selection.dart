import 'package:flutter/foundation.dart' show ChangeNotifier, protected;

import 'tree_controller.dart' show ChildrenProvider, ParentProvider;

// ignore_for_file: public_member_api_docs

class TreeSelection<T extends Object> with ChangeNotifier {
  TreeSelection({
    required this.childrenProvider,
    required this.parentProvider,
    this.enablePartialSelection = true,
  });

  final ChildrenProvider<T> childrenProvider;
  final ParentProvider<T> parentProvider;
  final bool enablePartialSelection;

  T? get activeNode => _activeNode;
  T? _activeNode;

  @protected
  late final Map<T, bool?> selection = <T, bool?>{};

  @protected
  void setSelectionState(T node, bool? selected) {
    selection[node] = selected;
  }

  List<T> get selectedNodes {
    return <T>[
      for (final MapEntry<T, bool?> entry in selection.entries)
        if (entry.value ?? false) entry.key,
    ];
  }

  bool? stateOf(T node) {
    return selection.containsKey(node) ? selection[node] : false;
  }

  void toggle(
    T node, {
    bool whenIndeterminate = true,
    bool updateActiveNode = true,
  }) {
    if (updateActiveNode) {
      _activeNode = node;
    }

    final bool newSelectionState = switch (stateOf(node)) {
      null => whenIndeterminate,
      true => false,
      false => true,
    };

    setSelectionState(node, newSelectionState);

    if (enablePartialSelection) {
      _propagateSelectionToDescendants(node, newSelectionState);
      _propagateSelectionToAncestors(parentProvider(node));
    }

    notifyListeners();
  }

  void _propagateSelectionToDescendants(T node, bool selectionState) {
    for (final T child in childrenProvider(node)) {
      setSelectionState(child, selectionState);
      _propagateSelectionToDescendants(child, selectionState);
    }
  }

  void _propagateSelectionToAncestors(T? node) {
    if (node == null) return;

    final bool? oldSelectionState = stateOf(node);
    final bool? newSelectionState = _findNewSelectionStateFromChildren(node);

    if (oldSelectionState != newSelectionState) {
      setSelectionState(node, newSelectionState);
      _propagateSelectionToAncestors(parentProvider(node));
    }
  }

  bool? _findNewSelectionStateFromChildren(T node) {
    bool hasSelectedChildren = false;
    bool hasUnselectedChildren = false;

    for (final T child in childrenProvider(node)) {
      switch (stateOf(child)) {
        // The following clauses check for indeterminate state and returns early
        // when either a child has an indeterminate state or when both selected
        // and unselected states are found among siblings.
        case null:
          return null;
        case true when hasUnselectedChildren:
          return null;
        case false when hasSelectedChildren:
          return null;

        // Update the state among siblings and keep looking.
        case true:
          hasSelectedChildren = true;
        case false:
          hasUnselectedChildren = true;
      }
    }

    return hasSelectedChildren;
  }

  @override
  void dispose() {
    selection.clear();
    super.dispose();
  }
}
