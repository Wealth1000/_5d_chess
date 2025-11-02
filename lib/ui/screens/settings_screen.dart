import 'package:chess_5d/ui/widgets/custom_dialog_box.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.orbitron(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        toolbarHeight: 50,
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Center(
        child: CustomDialogBox(
          width: 350,
          children: [
            ListTile(
              title: const Text('Enable Sound'),
              trailing: Switch(
                value: true,
                onChanged: null,
                thumbColor: Theme.of(context).switchTheme.thumbColor,
                trackColor: Theme.of(context).switchTheme.trackColor,
              ),
            ),
            ListTile(
              title: const Text('Enable Notifications'),
              trailing: Switch(
                value: false,
                onChanged: null,
                thumbColor: Theme.of(context).switchTheme.thumbColor,
                trackColor: Theme.of(context).switchTheme.trackColor,
              ),
            ),
            ListTile(
              title: const Text('Theme'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Primary'),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () {
                      // Add color picker logic here for first box
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary, // Default color
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('Secondary'),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () {
                      // Add color picker logic here for second box
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surface, // Default color
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Dummy Setting'),
              trailing: Switch(
                value: true,
                onChanged: null,
                thumbColor: Theme.of(context).switchTheme.thumbColor,
                trackColor: Theme.of(context).switchTheme.trackColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
