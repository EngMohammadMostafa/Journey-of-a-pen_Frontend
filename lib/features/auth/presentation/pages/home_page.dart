import 'package:book_worm_haven/features/quotes/presentation/pages/quote.dart';
import 'package:book_worm_haven/features/auth/presentation/pages/shopping_cart.dart';
import 'package:book_worm_haven/features/auth/presentation/pages/writing_competitions.dart';
import 'package:flutter/material.dart';
import 'package:book_worm_haven/features/auth/presentation/pages/profile_page.dart';
import 'package:book_worm_haven/features/auth/presentation/pages/notifications_page.dart';
import '../../../books/presentation/pages/book_details_page.dart';
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
        description: "رحلة مثيرة لبطل يسعى لإنقاذ العالم وسط مغامرات مشوقة.",
      ),
      BookModel(
        id: 2,
        title: "Love in Paris",
        author: "Emily Rose",
        category: "Romance",
        isPaid: true,
        imageUrl: "https://picsum.photos/200/300?random=2",
        description: "قصة حب دافئة تدور أحداثها في شوارع باريس الجميلة.",
      ),
      BookModel(
        id: 3,
        title: "Galaxy Wars",
        author: "Mark Sky",
        category: "Romance",
        isPaid: false,
        imageUrl: "https://picsum.photos/200/300?random=3",
        description: "ملحمة فضائية بين المجرات، تجمع بين الشجاعة والتكنولوجيا.",
      ),
      BookModel(
        id: 4,
        title: "Haunted Nights",
        author: "Lucy Grey",
        category: "Romance",
        isPaid: true,
        imageUrl: "https://picsum.photos/200/300?random=4",
        description: "ليالٍ مرعبة في قصر قديم يخفي أسرارًا غامضة ومخيفة.",
      ),
      BookModel(
        id: 5,
        title: "Mystic Forest",
        author: "Alan Woods",
        category: "Fantasy",
        isPaid: false,
        imageUrl: "https://picsum.photos/200/300?random=5",
        description: "ليالٍ مرعبة في قصر قديم يخفي أسرارًا غامضة ومخيفة.",
      ),
      BookModel(
        id: 6,
        title: "Comedy Central",
        author: "Tom Hanks",
        category: "Comedy",
        isPaid: false,
        imageUrl: "https://picsum.photos/200/300?random=6",
        description: "ليالٍ مرعبة في قصر قديم يخفي أسرارًا غامضة ومخيفة.",
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

// 📚 عرض الكتب في كروت أنيقة مع وصف متدرج وتأثير حركة ناعم (تصحيح: إزالة `delay`)
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

                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 500 + 100 * index), // ← هنا تم التعديل
                  curve: Curves.easeOut,
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - value)),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookDetailsPage(book: book),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // 🖼️ صورة الكتاب
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                            child: Image.network(
                              book.imageUrl ?? '',
                              width: 100,
                              height: 140,
                              fit: BoxFit.cover,
                            ),
                          ),

                          // 📝 تفاصيل الكتاب
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 🏷️ العنوان
                                  Text(
                                    book.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1C597B),
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  // ✏️ الوصف المتدرج
                                  ShaderMask(
                                    shaderCallback: (bounds) => const LinearGradient(
                                      colors: [Color(0xFF1C597B), Color(0xFF4C869F)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds),
                                    child: Text(
                                      book.description ??
                                          "كتاب رائع يأخذك في رحلة مليئة بالتشويق والإثارة.",
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // 🔒 أو ✅ شارة الحالة
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: book.isPaid
                                          ? Colors.red.withOpacity(0.1)
                                          : Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          book.isPaid ? Icons.lock : Icons.check_circle,
                                          color: book.isPaid ? Colors.red : Colors.green,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
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
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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

