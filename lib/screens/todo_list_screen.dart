import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../services/todo_storage.dart';
import '../services/theme_service.dart';
import '../widgets/todo_item_widget.dart';
import '../widgets/add_todo_dialog.dart';
import '../widgets/delete_task_tutorial.dart';
import '../services/tutorial_service.dart';
import 'settings_screen.dart';

enum SortOption {
  createdDate,
  dueDate,
  priority;

  String get displayName {
    switch (this) {
      case SortOption.createdDate:
        return 'Created Date';
      case SortOption.dueDate:
        return 'Due Date';
      case SortOption.priority:
        return 'Priority';
    }
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TodoStorage _storage = TodoStorage();
  List<Todo> _todos = [];
  List<Todo> _filteredTodos = [];
  String _searchQuery = '';
  SortOption _sortOption = SortOption.createdDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    setState(() => _isLoading = true);
    final todos = await _storage.loadTodos();
    setState(() {
      _todos = todos;
      _applyFiltersAndSort();
      _isLoading = false;
    });
  }

  void _applyFiltersAndSort() {
    // Filter by search query
    _filteredTodos = _todos.where((todo) {
      final query = _searchQuery.toLowerCase();
      return todo.title.toLowerCase().contains(query) ||
          todo.description.toLowerCase().contains(query);
    }).toList();

    // Sort
    switch (_sortOption) {
      case SortOption.createdDate:
        _filteredTodos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.dueDate:
        _filteredTodos.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case SortOption.priority:
        _filteredTodos.sort(
          (a, b) => a.priority.sortOrder.compareTo(b.priority.sortOrder),
        );
        break;
    }
  }

  Future<void> _saveTodos() async {
    await _storage.saveTodos(_todos);
    setState(() {
      _applyFiltersAndSort();
    });
  }

  void _addTodo() async {
    final result = await showDialog<Todo>(
      context: context,
      builder: (context) => const AddTodoDialog(),
    );

    if (result != null) {
      setState(() {
        _todos.add(result);
      });
      await _saveTodos();
    }
  }

  void _editTodo(Todo todo) async {
    final result = await showDialog<Todo>(
      context: context,
      builder: (context) => AddTodoDialog(todo: todo),
    );

    if (result != null) {
      setState(() {
        final index = _todos.indexWhere((t) => t.id == todo.id);
        if (index != -1) {
          _todos[index] = result;
        }
      });
      await _saveTodos();
    }
  }

  void _toggleTodo(Todo todo) {
    setState(() {
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = todo.copyWith(isCompleted: !todo.isCompleted);
      }
    });
    _saveTodos();
  }

  void _deleteTodo(Todo todo) {
    setState(() {
      _todos.removeWhere((t) => t.id == todo.id);
    });
    _saveTodos();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFiltersAndSort();
    });
  }

  void _changeSortOption() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Sort By',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...SortOption.values.map((option) {
                return ListTile(
                  leading: Radio<SortOption>(
                    value: option,
                    groupValue: _sortOption,
                    onChanged: (SortOption? value) {
                      if (value != null) {
                        setState(() {
                          _sortOption = value;
                          _applyFiltersAndSort();
                        });
                        Navigator.pop(context);
                      }
                    },
                  ),
                  title: Text(option.displayName),
                  onTap: () {
                    setState(() {
                      _sortOption = option;
                      _applyFiltersAndSort();
                    });
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _todos.where((t) => t.isCompleted).length;
    final totalCount = _todos.length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Todos'),
            Text(
              '$completedCount of $totalCount completed',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _changeSortOption,
            tooltip: 'Sort',
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  onChanged: _onSearchChanged,
                  style: Theme.of(context).brightness == Brightness.dark
                      ? const TextStyle(color: Color(0xFFFFFFFF))
                      : null,
                  decoration: InputDecoration(
                    hintText: 'Search todos...',
                    hintStyle: Theme.of(context).brightness == Brightness.dark
                        ? TextStyle(
                            color: const Color(0xFFFFFFFF).withOpacity(0.5),
                          )
                        : null,
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFFFFFFFF)
                          : null,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(0xFFFFFFFF)
                                  : null,
                            ),
                            onPressed: () => _onSearchChanged(''),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          Theme.of(context).brightness == Brightness.dark
                          ? const BorderSide(
                              color: Color(0xFF5457CC),
                              width: 1.5,
                            )
                          : BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          Theme.of(context).brightness == Brightness.dark
                          ? const BorderSide(
                              color: Color(0xFF5457CC),
                              width: 1.5,
                            )
                          : BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          Theme.of(context).brightness == Brightness.dark
                          ? const BorderSide(
                              color: Color(0xFF5457CC),
                              width: 2.0,
                            )
                          : BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1C1C2E)
                        : Colors.grey[100],
                  ),
                ),
              ),

              // Todo list
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredTodos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isEmpty
                                  ? Icons.check_circle_outline
                                  : Icons.search_off,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No todos yet!\nTap + to add one'
                                  : 'No todos found',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredTodos.length,
                        padding: const EdgeInsets.only(bottom: 80),
                        itemBuilder: (context, index) {
                          final todo = _filteredTodos[index];
                          return TodoItemWidget(
                            todo: todo,
                            onToggle: () => _toggleTodo(todo),
                            onEdit: () => _editTodo(todo),
                            onDelete: () => _deleteTodo(todo),
                          );
                        },
                      ),
              ),
            ],
          ),
          // Tutorial Overlay
          Consumer<TutorialService>(
            builder: (context, tutorialService, child) {
              if (tutorialService.isInitialized &&
                  !tutorialService.hasSeenDeleteTutorial &&
                  _todos.isNotEmpty) {
                return DeleteTaskTutorialOverlay(
                  onDismiss: () => tutorialService.markDeleteTutorialAsSeen(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTodo,
        icon: const Icon(Icons.add),
        label: const Text('Add Todo'),
      ),
    );
  }
}
