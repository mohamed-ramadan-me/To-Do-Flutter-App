import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';

class TodoItemWidget extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TodoItemWidget({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = Color(todo.priority.colorValue);
    final isOverdue = todo.isOverdue;

    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Todo'),
              content: const Text('Are you sure you want to delete this todo?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) => onDelete(),
      child: ColorFiltered(
        colorFilter: todo.isCompleted
            ? const ColorFilter.matrix(<double>[
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0,
                0,
                0,
                1,
                0,
              ])
            : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: priorityColor, width: 3),
          ),
          child: InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox
                  Checkbox(
                    value: todo.isCompleted,
                    onChanged: (value) => onToggle(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          todo.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                decoration: todo.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: todo.isCompleted ? Colors.grey : null,
                              ),
                        ),

                        // Description
                        if (todo.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            todo.description,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[600],
                                  decoration: todo.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        // Due date and priority
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            // Priority chip
                            Chip(
                              label: Text(
                                todo.priority.displayName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: priorityColor,
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),

                            // Due date chip
                            if (todo.dueDate != null)
                              Chip(
                                avatar: Icon(
                                  isOverdue
                                      ? Icons.warning_rounded
                                      : Icons.calendar_today,
                                  size: 16,
                                  color: isOverdue
                                      ? Colors.white
                                      : (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? const Color(0xFFFFFFFF)
                                            : null),
                                ),
                                label: Text(
                                  DateFormat('MMM dd').format(todo.dueDate!),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isOverdue
                                        ? Colors.white
                                        : (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? const Color(0xFFFFFFFF)
                                              : null),
                                  ),
                                ),
                                backgroundColor: isOverdue
                                    ? Colors.red[400]
                                    : (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? const Color(0xFF1C1C2E)
                                          : Colors.grey[200]),
                                side: isOverdue
                                    ? null
                                    : (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? const BorderSide(
                                              color: Color(0xFF5457CC),
                                              width: 1.5,
                                            )
                                          : null),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
