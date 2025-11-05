import 'package:book_worm_haven/features/quotes/presentation/pages/quote.dart';
import 'package:book_worm_haven/features/auth/presentation/pages/shopping_cart.dart';
import 'package:book_worm_haven/features/auth/presentation/pages/writing_competitions.dart';
import 'package:flutter/material.dart';
import 'package:book_worm_haven/features/auth/presentation/pages/profile_page.dart';
import 'package:book_worm_haven/features/auth/presentation/pages/notifications_page.dart';
import '../../../books/presentation/widgets/book_card.dart';
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
  List<BookModel> _books = [];
  bool _isLoading = true;
  String selectedCategory = "Action";

  final List<String> categories = [
    'Action', 'Romance', 'Science Fiction', 'Horror', 'Fantasy',
    'Mystery', 'Drama', 'Comedy', 'Adventure', 'Thriller',
  ];

  @override
  void initState() {
    super.initState();
    _loadDummyBooks();
  }

  void _loadDummyBooks() {
    _books = [
      BookModel(
        id: 1,
        title: "The Hero's Journey",
        author: "John Smith",
        category: "Action",
        isPaid: false,
        imageUrl: "https://picsum.photos/200/300?random=1",
      ),
      BookModel(
        id: 2,
        title: "Love in Paris",
        author: "Emily Rose",
        category: "Romance",
        isPaid: true,
        imageUrl: "https://picsum.photos/200/300?random=2",
      ),
      BookModel(
        id: 3,
        title: "Galaxy Wars",
        author: "Mark Sky",
        category: "Science Fiction",
        isPaid: false,
        imageUrl: "https://picsum.photos/200/300?random=3",
      ),
      BookModel(
        id: 4,
        title: "Haunted Nights",
        author: "Lucy Grey",
        category: "Horror",
        isPaid: true,
        imageUrl: "https://picsum.photos/200/300?random=4",
      ),
      BookModel(
        id: 5,
        title: "Mystic Forest",
        author: "Alan Woods",
        category: "Fantasy",
        isPaid: false,
        imageUrl: "https://picsum.photos/200/300?random=5",
      ),
      BookModel(
        id: 6,
        title: "Comedy Central",
        author: "Tom Hanks",
        category: "Comedy",
        isPaid: false,
        imageUrl: "https://picsum.photos/200/300?random=6",
      ),
    ];

    // لتأخير العرض لمحاكاة التحميل
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isLoading = false;
      });
    });
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📸 صورة تحفيزية
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

            // 🔍 شريط البحث
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

            // 🏷️ قائمة التصنيفات
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

            // 📚 قائمة الكتب باستخدام BookCard
            getBooksByCategory(selectedCategory).isEmpty
                ? Center(
              child: Text(
                "لا توجد كتب في هذا التصنيف",
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
              ),
            )
                : ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: getBooksByCategory(selectedCategory).length,
              itemBuilder: (context, index) {
                final book = getBooksByCategory(selectedCategory)[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        book.imageUrl ?? '',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      book.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("المؤلف: ${book.author}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (book.isPaid)
                          const Icon(Icons.lock, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          book.isPaid ? "مدفوع" : "مجاني",
                          style: TextStyle(
                            color: book.isPaid ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          ],
        ),
      ),
    );
  }
}

