import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page_camera.dart';
import 'assistant_page.dart';


class IntroScreen extends StatelessWidget {
  const IntroScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    // Get the screen width and height
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        child: FractionallySizedBox(
          widthFactor: 1.0, // Cover the entire width of the screen
          heightFactor: 1.0, // Cover the entire height of the screen
          child: DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/your_background_image.png'),
                fit: BoxFit.cover,
                alignment:
                    Alignment.topCenter, // Align the image to the top center
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      // big logo
                      Padding(
                        padding: EdgeInsets.only(
                          left: 0.1 *
                              screenWidth, // 10% of screen width from the left
                          right: 0.1 *
                              screenWidth, // 10% of screen width from the right
                          top: 0.12 *
                              screenHeight, // 12% of screen height from the top (moved up by 3%)
                          bottom: 0.02 *
                              screenHeight, // 2% of screen height from the bottom
                        ),
                        child: SizedBox(
                          width: 0.8 * screenWidth, // 80% of screen width
                          height: 0.3 * screenHeight, // 30% of screen height
                          child: Image.asset('lib/images/vr_logo.png'),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'AR Lense',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.08, // 8% of screen width
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Get to know the world',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04, // 4% of screen width
                          color: const Color.fromARGB(255, 206, 189, 189),
                        ),
                      ),

                      const Spacer(),
                    ],
                  ),
                  Positioned(
                    left: screenWidth *
                        0.28, // Move the button 28% of screen width to the left
                    top: screenHeight *
                        0.759, // 75.9% of screen height from the top
                    child: GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            // return ARKitExample(func: print);
                            return VideoPlayerApp();
                          },
                        ),
                      ),
                      child: Container(
                        width: screenWidth * 0.45, // 50% of screen width
                        height: screenHeight * 0.07, // 7% of screen height
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
