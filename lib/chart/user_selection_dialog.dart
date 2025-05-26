import 'package:flutter/material.dart';

class UserSelectionDialog extends StatefulWidget {
  final List<Map<String, dynamic>> users;
  final String currentUserId;

  const UserSelectionDialog({
    required this.users,
    required this.currentUserId,
    super.key,
  });

  @override
  _UserSelectionDialogState createState() => _UserSelectionDialogState();
}

class _UserSelectionDialogState extends State<UserSelectionDialog> {
  String? selectedUserId;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select User to Message'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.users.length,
          itemBuilder: (context, index) {
            final user = widget.users[index];
            return ListTile(
              leading: CircleAvatar(
                child: Text(user['name'][0]),
              ),
              title: Text(user['name']),
              subtitle: Text(user['role']),
              trailing: user['id'] == selectedUserId
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                setState(() {
                  selectedUserId = user['id'];
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: selectedUserId == null
              ? null
              : () {
                  Navigator.pop(context, selectedUserId);
                },
          child: const Text('Select'),
        ),
      ],
    );
  }
}