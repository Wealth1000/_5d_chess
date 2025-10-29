import 'package:_5d_chess/ui/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '5D Chess',
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 35,
          ),
        ),
        toolbarHeight: 70,
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          child: ListView(
            shrinkWrap: true,
            children: [
              const SizedBox(height: 16),
              Center(
                child: CustomButton(onPressed: () {}, text: 'New Game'),
              ),
              const SizedBox(height: 16),
              Center(
                child: CustomButton(onPressed: () {}, text: 'Guide'),
              ),
              const SizedBox(height: 16),
              Center(
                child: CustomButton(onPressed: () {}, text: 'Settings'),
              ),
              const SizedBox(height: 16),
              Center(
                child: CustomButton(onPressed: () {}, text: 'Credits'),
              ),
              const SizedBox(height: 16),
              Center(
                child: CustomButton(onPressed: () {}, text: 'Exit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
