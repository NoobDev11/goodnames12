import 'package:flutter/material.dart';

class CommonButtons {
  static Widget floatingAddButton({required VoidCallback onPressed}) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: const Icon(Icons.add),
    );
  }

  static Widget cancelButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Cancel'),
    );
  }

  static Widget confirmButton({required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      child: const Text('Add Habit'),
    );
  }
}
