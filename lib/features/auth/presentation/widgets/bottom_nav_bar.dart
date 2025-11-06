import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> iconPaths = [
      'assets/icons/home_book.png',
      'assets/icons/shopping_cart.png',
      'assets/icons/quote.png',
      'assets/icons/writing_competitions.png',
      'assets/icons/notifications.png',
      'assets/icons/profile.png',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          height: 70,
          child: Row(
            children: List.generate(iconPaths.length, (index) {
              bool isSelected = selectedIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onItemTapped(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1C597B).withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Image.asset(
                        iconPaths[index],
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                        color: null,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
