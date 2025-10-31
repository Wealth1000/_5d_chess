import 'package:_5d_chess/ui/widgets/custom_dialog_box.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: CustomDialogBox(
          children: [
            const ListTile(
              title: Text('Enable Sound'),
              trailing: Switch(value: true, onChanged: null),
            ),
            const ListTile(
              title: Text('Enable Notifications'),
              trailing: Switch(value: false, onChanged: null),
            ),            
            ListTile(
              title: Text('Color palette'),
              trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                onTap: () {
                  // Add color picker logic here for first box
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                  color: Colors.blue, // Default color
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                  ),
                ),
                ),
                const SizedBox(width: 12),
                InkWell(
                onTap: () {
                  // Add color picker logic here for second box
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                  color: Colors.red, // Default color
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                  ),
                ),
                ),
              ],
              ),
            ),
            const ListTile(
              title: Text('Dummy Setting'),
              trailing: Switch(value: true, onChanged: null),
            ),
          ]
        ),
      ),
    );
  }
}