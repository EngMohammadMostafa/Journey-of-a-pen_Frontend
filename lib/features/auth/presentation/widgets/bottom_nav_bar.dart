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
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1C597B).withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 🔹 الأيقونة (بدون color حتى تبقى ملونة)
                        Image.asset(
                          iconPaths[index],
                          width: isSelected ? 34 : 30,
                          height: isSelected ? 34 : 30,
                          fit: BoxFit.contain,
                        ),

                        const SizedBox(height: 4),

                        // 🔹 النقطة الصغيرة أسفل الأيقونة عند التحديد
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          height: 5,
                          width: isSelected ? 20 : 0,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C597B),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
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
