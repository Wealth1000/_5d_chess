import 'package:chess_5d/ui/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewGameScreen extends StatelessWidget {
  const NewGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Game',
          style: GoogleFonts.orbitron(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        toolbarHeight: 70,
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          child: ListView(
            shrinkWrap: true,
            children: [
              const SizedBox(height: 16),
              Center(
                child: CustomButton(onPressed: () {}, text: 'Local'),
              ),
              const SizedBox(height: 16),
              Center(
                child: CustomButton(onPressed: () {}, text: 'CPU'),
              ),
              const SizedBox(height: 16),
              Center(
                child: CustomButton(onPressed: () {}, text: 'Public'),
              ),
              const SizedBox(height: 16),
              Center(
                child: CustomButton(onPressed: () {}, text: 'Custom'),
              ),
              const SizedBox(height: 16),
              Center(
                child: CustomButton(onPressed: () {}, text: 'Private'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
