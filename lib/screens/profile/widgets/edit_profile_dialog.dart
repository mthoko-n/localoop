import 'package:flutter/material.dart';

class EditProfileDialog extends StatefulWidget {
  final String initialDisplayName;
  final String initialLastName;

  const EditProfileDialog({
    super.key,
    required this.initialDisplayName,
    required this.initialLastName,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late final TextEditingController _displayNameController;
  late final TextEditingController _lastNameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(text: widget.initialDisplayName);
    _lastNameController = TextEditingController(text: widget.initialLastName);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      final displayName = _displayNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      
      // Only return values that have changed
      Map<String, String?> result = {};
      
      if (displayName != widget.initialDisplayName) {
        result['displayName'] = displayName.isEmpty ? null : displayName;
      }
      
      if (lastName != widget.initialLastName) {
        result['lastName'] = lastName.isEmpty ? null : lastName;
      }
      
      // Only proceed if there are changes
      if (result.isNotEmpty) {
        Navigator.of(context).pop(result);
      } else {
        Navigator.of(context).pop(); // No changes
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                hintText: 'Enter your display name',
              ),
              validator: (value) {
                if (value != null && value.trim().isNotEmpty && value.trim().length > 100) {
                  return 'Display name must be 100 characters or less';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                hintText: 'Enter your last name',
              ),
              validator: (value) {
                if (value != null && value.trim().isNotEmpty && value.trim().length > 100) {
                  return 'Last name must be 100 characters or less';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveProfile,
          child: const Text('Save'),
        ),
      ],
    );
  }
}