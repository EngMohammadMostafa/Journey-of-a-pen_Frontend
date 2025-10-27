import 'package:book_worm_haven/features/auth/presentation/pages/quote.dart';
import 'package:book_worm_haven/features/auth/presentation/pages/shopping_cart.dart';
import 'package:book_worm_haven/features/auth/presentation/pages/writing_competitions.dart';
import 'package:flutter/material.dart';
import 'package:book_worm_haven/features/auth/presentation/pages/profile_page.dart';
import 'package:book_worm_haven/features/auth/presentation/pages/notifications_page.dart';
import '../widgets/bottom_nav_bar.dart';
import 'package:book_worm_haven/features/books/repository/books_repository.dart';
import 'package:book_worm_haven/features/books/data/models/book_model.dart';

// ============================
// الصفحة الرئيسية
// ============================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const ProfilePage(),
    const NotificationsPage(),
    const ShoppingCartPage(),
    const WritingCompetitionsPage(),
     QuotesPage(),
  ];

  late AnimationController _introController;
  late Animation<double> _introAnimation;
  bool _showIntro = true;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _introAnimation = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeInOut,
    );

    _introController.forward().then((value) {
      setState(() {
        _showIntro = false;
      });
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🎨 الخلفية المتدرجة
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1C597B),
                  Color(0xFF4C869F),
                  Color(0xFF7199AA),
                  Color(0xFFE3F2FD),
                ],
              ),
            ),
          ),

          // 🧩 محتوى الصفحة
          _pages[_selectedIndex],

          // 🌟 شاشة المقدمة المؤقتة
          if (_showIntro && _selectedIndex == 0)
            IgnorePointer(
              ignoring: !_showIntro,
              child: FadeTransition(
                opacity: _introAnimation,
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ),

        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

// ============================
// محتوى الصفحة الرئيسية (مع التصنيفات الجديدة)
// ============================
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final BooksRepository _bookRepo = BooksRepository();
  List<BookModel> _books = [];
  bool _isLoading = true;
  String selectedCategory = "Action";

  final List<String> categories = [
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
    'Historical Fiction',
    'Biography',
    'Autobiography',
    'Poetry',
    'Classic Literature',
    'Crime',
    'Detective',
    'Dystopian',
    'Young Adult',
    'Children’s Books',
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
    'Health & Fitness',
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
    'Satire',
  ];

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    setState(() => _isLoading = true);
    try {
      final books = await _bookRepo.getAllBooks();
      setState(() {
        _books = books;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching books: $e');
      setState(() => _isLoading = false);
    }
  }

  List<BookModel> getBooksByCategory(String category) {
    return _books.where((book) => book.category == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ الصورة التحفيزية
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                "assets/images/motivation.png",
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: "Search for a book...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = category == selectedCategory;
                  return GestureDetector(
                    onTap: () => setState(() => selectedCategory = category),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1C597B) : Colors.grey[300],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 260,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: getBooksByCategory(selectedCategory).length,
                itemBuilder: (context, index) {
                  final book = getBooksByCategory(selectedCategory)[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 160,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                child: Image.network(
                                  book.imageUrl ?? '',
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              if (book.isPaid)
                                const Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Icon(Icons.lock, color: Colors.red),
                                ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(
                                  book.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  book.isPaid ? "Paid" : "Free",
                                  style: TextStyle(
                                    color: book.isPaid ? Colors.red : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
