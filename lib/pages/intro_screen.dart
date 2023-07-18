import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page_camera.dart';


class IntroScreen extends StatelessWidget {
  const IntroScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]); // Hide the status bar

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/your_background_image.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // big logo
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 100.0,
                      right: 100.0,
                      top: 100,
                      bottom: 20,
                    ),
                    child: SizedBox(
                      width: 354,
                      height: 282,
                      child: Image.asset('lib/images/vr_logo.png'),
                    ),
                  ),

                  // we deliver groceries at your doorstep
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 100.0,
                      right: 100.0,
                      top: 1,
                      bottom: 1,
                    ),
                    child: Text(
                      'AR Lense',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 100.0,
                      right: 100.0,
                      top: 1,
                      bottom: 50,
                    ),
                    child: Text(
                      'Get to know the world',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color.fromARGB(255, 206, 189, 189),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Spacer(),
                ],
              ),
              Positioned(
                left: 76,
                top: 630,
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return CameraPage();
                      },
                    ),
                  ),
                  child: Container(
                    width: 240,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xFFD9D9D9),
                    ),
                    child: Center(
                      child: Text(
                        "Get Started",
                        style: TextStyle(
                          color: Color(0xFF462B9C),
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
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