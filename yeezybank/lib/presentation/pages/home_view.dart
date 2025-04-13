import 'package:flutter/material.dart';
import '../widgets/action_button.dart';
import '../widgets/balance_section.dart';
import '../widgets/statement_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Green header background
          Positioned(
            top: -69,
            left: -9,
            child: Container(
              width: 411,
              height: 266,
              color: const Color(0xFF6CE1A3),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top app bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.person_outline,
                          color: Colors.black,
                        ),
                        onPressed: () {},
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.help_outline,
                              color: Colors.black,
                            ),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.search, color: Colors.black),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.settings_outlined,
                              color: Colors.black,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.only(left: 29, top: 20),
                  child: Text(
                    'Olá de novo, Luiz!',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),

                const BalanceSection(),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.only(top: 40, left: 28),
                  child: Row(
                    children: [
                      ActionButton(
                        icon: Icons.add,
                        label: 'Depositar',
                        onTap: () {},
                      ),
                      const SizedBox(width: 37),
                      ActionButton(
                        icon: Icons.send,
                        label: 'Transferir',
                        onTap: () {},
                      ),
                      const SizedBox(width: 37),
                      ActionButton(
                        icon: Icons.show_chart,
                        label: 'Investir',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                // Statement section
                const Padding(
                  padding: EdgeInsets.only(left: 20, top: 40),
                  child: Text(
                    'Extrato',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB0B0B0),
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: StatementCard(),
                ),

                const Spacer(),

                // Bottom navigation
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
