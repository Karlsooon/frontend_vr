import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page_camera.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.1, 0.6],
            colors: [
              Color(0xFF8058FA).withOpacity(0.88),
              Color.fromARGB(255, 90, 48, 214),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // big logo
              Padding(
                padding: const EdgeInsets.only(
                  left: 100.0,
                  right: 100.0,
                  top: 120,
                  bottom: 20,
                ),
                child: Image.asset('lib/images/vr_logo.png'),
              ),

              // we deliver groceries at your doorstep
              Padding(
                padding: const EdgeInsets.only(
                  left: 100.0,
                  right: 100.0,
                  top: 1,
                  bottom: 10,
                ),
                child: Text(
                  'VR Lense',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              // groceree gives you fresh vegetables and fruits
              Text(
                'Get to know the world',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: const Color.fromARGB(255, 206, 189, 189),
                ),
              ),

              const SizedBox(height: 24),

              const Spacer(),

              // get started button
              GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return GalleryAccess();
                    },
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.only(
                  left: 50.0,
                  right: 50.0,
                  top: 15,
                  bottom: 15,
                ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  child: const Text(
                    "Get Started",
                    style: TextStyle(
                      color: Color(0xFF8058FA),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
