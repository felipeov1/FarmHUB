import 'package:farm_hub/screens/products.dart';
import 'package:flutter/material.dart';
import '../screens/home.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int idx = 0;

  void navigateTo(int i) {
    setState(() => idx = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Farm",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: "HUB",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),

      body: _screens(),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        selectedItemColor: Colors.green,
        onTap: navigateTo,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: "Produtos",
          ),
        ],
      ),
    );
  }

  Widget _screens() {
    switch (idx) {
      case 0:
        return Home(onNavigate: navigateTo);
      case 1:
        return Products(onNavigate: navigateTo);
      default:
        return Home(onNavigate: navigateTo);
    }
  }
}
