import 'package:farm_hub/screens/login.dart';
import 'package:flutter/material.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  String selectedLanguage = 'PT-BR';
  double _dragPosition = 0;
  bool _completed = false;

  @override
  Widget build(BuildContext context) {
    double sliderWidth = MediaQuery.of(context).size.width - 60;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/welcome.png'),
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [
                  Colors.white,
                  Colors.white70,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => selectedLanguage = 'PT-BR'),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: selectedLanguage == 'PT-BR'
                                ? Border.all(color: Colors.green, width: 2)
                                : null,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Image(
                            image: AssetImage('images/flags/br.png'),
                            width: 32,
                            height: 32,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      GestureDetector(
                        onTap: () => setState(() => selectedLanguage = 'EN'),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: selectedLanguage == 'EN'
                                ? Border.all(color: Colors.red, width: 2)
                                : null,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Image(
                            image: AssetImage('images/flags/us.png'),
                            width: 32,
                            height: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      height: 1,
                    ),
                    children: const [
                      TextSpan(
                        text: "Farm",
                        style: TextStyle(color: Colors.green),
                      ),
                      TextSpan(text: "HUB"),
                    ],
                  ),
                ),

                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    children: const [
                      TextSpan(text: "Sua Fazenda "),
                      TextSpan(
                        text: "Moderna",
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  "Gerencie sua fazenda com precisão, "
                      "organize estoque e acompanhe o progresso.",
                  style: TextStyle(
                    fontSize: 17,
                    height: 1.3,
                    color: Colors.black54,
                  ),
                ),

                const Spacer(),

                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Arraste para começar",
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                    ),
                    Positioned(
                      left: _dragPosition,
                      child: GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          setState(() {
                            _dragPosition += details.delta.dx;
                            if (_dragPosition < 0) _dragPosition = 0;
                            if (_dragPosition > sliderWidth) _dragPosition = sliderWidth;
                          });
                        },
                        onHorizontalDragEnd: (details) {
                          if (_dragPosition >= sliderWidth) {
                            setState(() => _completed = true);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const Login()),
                            );
                          } else {
                            setState(() => _dragPosition = 0);
                          }
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Icon(Icons.arrow_forward, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}
