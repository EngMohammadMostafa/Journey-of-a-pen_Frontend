import 'package:flutter/material.dart';
import 'package:book_worm_haven/core/utils/prefs_helper.dart';

class ChooseInterestsPage extends StatefulWidget {
  static const routeName = '/choose-interests';

  const ChooseInterestsPage({super.key});

  @override
  State<ChooseInterestsPage> createState() => _ChooseInterestsPageState();
}

class _ChooseInterestsPageState extends State<ChooseInterestsPage> {
  final List<String> allInterests = [
    'Action',
    'Romance',
    'Science Fiction',
    'Horror',
    'Fantasy',
    'Mystery',
    'Drama',
    'Comedy',
    'Adventure',
    'Thriller',
    'Biography',
    'Autobiography',
    'Poetry',
    'Crime',
    'Detective',
    'Dystopian',
    'Young Adult',
    'Philosophy',
    'Psychology',
    'Self-Help',
    'Religion',
    'Spirituality',
    'History',
    'Politics',
    'Sociology',
    'Art',
    'Music',
    'Science',
    'Technology',
    'Education',
    'Business',
    'Economics',
    'Travel',
    'Cooking',
    'Parenting',
    'Environment',
    'Essays',
    'Short Stories',
    'Memoir',
    'True Crime',
    'War',
    'Western',
    'Paranormal',
    'Superhero',
    'Fairy Tales',
    'Mythology',
    'LGBTQ+',
    'Graphic Novel',
    'Satire'
  ];

  final List<String> selected = [];

  void toggleSelect(String item) {
    setState(() {
      if (selected.contains(item)) {
        selected.remove(item);
      } else {
        if (selected.length < 3) {
          selected.add(item);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("You can select up to 3 categories only."),
            ),
          );
        }
      }
    });
  }

  void onNext() async {
    await PrefsHelper.setHasChosenInterests(true);
    Navigator.pushReplacementNamed(context, '/success');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF000000),
              Color(0xFF7199AA),
              Color(0xFF4C869F),
              Color(0xFF1C597B),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            //  الدوائر الزخرفية
            Positioned(
              right: -20,
              bottom: 20,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.10),
                ),
              ),
            ),
            Positioned(
              right: 60,
              bottom: 60,
              child: Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),
            Positioned(
              right: 80,
              bottom: 30,
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              left: 40,
              top: 60,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),
            Positioned(
              left: 20,
              top: 90,
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    const Text(
                      "What do you like to read:",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontFamily: 'Papyrus',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Choose 3 of those",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        fontFamily: 'Papyrus',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.3,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: allInterests.map((interest) {
                        final isSelected = selected.contains(interest);
                        return GestureDetector(
                          onTap: () => toggleSelect(interest),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF1C597B)
                                  : Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF1C597B)
                                    : Colors.grey.shade400,
                                width: 1.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              interest,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontSize: 14,
                                fontFamily: 'Papyrus',
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 25),

                    // أزرار "Skip" و "Next"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await PrefsHelper.setHasChosenInterests(true);
                            Navigator.pushReplacementNamed(context, '/success');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.black54,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 35, vertical: 10),
                          ),
                          child: const Text(
                            "Skip",
                            style: TextStyle(
                              fontFamily: 'Papyrus',
                              fontSize: 18,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: selected.isEmpty ? null : onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1C597B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 35, vertical: 10),
                          ),
                          child: const Text(
                            "Next",
                            style: TextStyle(
                              fontFamily: 'Papyrus',
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
