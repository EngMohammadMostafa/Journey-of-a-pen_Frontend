import 'package:book_worm_haven/features/quotes/presentation/pages/quote.dart';
import 'package:book_worm_haven/features/books/presentation/pages/shopping_cart.dart';
import 'package:book_worm_haven/features/competitions/presentation/page/writing_competitions.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:book_worm_haven/features/notifications/presentation/pages/notifications_page.dart';
import 'package:provider/provider.dart';
import '../../../../core/api/api_service.dart';
import '../../../books/data/books_service.dart';
import '../../../books/data/models/book_model.dart';
import '../../../books/presentation/pages/book_details_page.dart';
import '../../../books/provider/books_provider.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../data/category_service.dart';
import '../../data/models/category_model.dart';
import '../../provider/home_provider.dart';
import '../../repository/category_repository.dart';
import '../widgets/bottom_nav_bar.dart';

// الصفحة الرئيسية
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const ShoppingCartPage(),
    QuotesPage(),
    const WritingCompetitionsPage(),
    const NotificationsPage(),
    const ProfilePage(),
  ];

  late AnimationController _introController;
  late Animation<double> _introAnimation;
  bool _showIntro = true;

  @override
  void initState() {
    super.initState();

    //  تحميل الكتب من HomeProvider عند فتح الصفحة (موجود ضمن نطاق _HomePageState)
    Future.microtask(() {
      try {
        Provider.of<HomeProvider>(context, listen: false).fetchAllBooks();
      } catch (e) {
        // في حال لم يكن الـ Provider جاهزًا بعد نتجاهل الخطأ بأمان
        print('Error calling fetchAllBooks from initState: $e');
      }
    });

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _introAnimation = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeInOut,
    );

    _introController.forward().then((_) {
      setState(() => _showIntro = false);
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

          _pages[_selectedIndex],

          if (_showIntro && _selectedIndex == 0)
            FadeTransition(
              opacity: _introAnimation,
              child: Container(color: Colors.black.withOpacity(0.6)),
            ),
        ],
      ),

      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) async {
          if (index == 1) {
            final booksProvider = context.read<BooksProvider>();

            // تحديث المشتريات
            if (booksProvider.purchasedBooks.isEmpty) {
              await booksProvider.initializeUserData();
            } else {
              await booksProvider.loadPurchasedBooksFromServer();
            }
          }

          setState(() => _selectedIndex = index);
        },

      ),
    );
  }
}

// محتوى الصفحة الرئيسية

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  // متغيرات الحالة
  String searchQuery = "";
  List<BookModel> _books = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = true;
  bool _isLoadingCategories = true;
  CategoryModel? selectedCategory;

  String _getCategoryImage(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'kids':
        return "assets/images/kids.png";
      case 'crime':
        return "assets/images/crime.png";
      case 'romance':
        return "assets/images/romantic.png";
      default:
        return "assets/images/default.png";
    }
  }

  late CategoryRepository categoryRepository;
  late BooksService booksService;

  @override
  void initState() {
    super.initState();

    final apiService = ApiService();
    categoryRepository = CategoryRepository(CategoryService(apiService));
    booksService = BooksService(apiService);

    _loadBooks();
    _loadCategories();
  }

  // تحميل الكتب
  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    try {
      final booksFromApi = await booksService.fetchBooks();
      print("Books fetched: ${booksFromApi.map((b) => b.title).toList()}");
      setState(() => _books = booksFromApi);
    } catch (e) {
      print("Error loading books: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // تحميل التصنيفات
  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      await categoryRepository.fetchCategories();
      setState(() {
        _categories = categoryRepository.categories;
        if (_categories.isNotEmpty) selectedCategory = _categories.first;
      });
    } catch (e) {
      print("Error loading categories: $e");
    } finally {
      setState(() => _isLoadingCategories = false);
    }
  }

  // فلترة الكتب
  List<BookModel> getFilteredBooks() {
    List<BookModel> list = _books;

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      return list.where((book) {
        return book.title.toLowerCase().contains(query) ||
            book.author.toLowerCase().contains(query) ||
            (book.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    if (selectedCategory != null) {
      list = list
          .where((book) => book.categoryName == selectedCategory!.name)
          .toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final books = getFilteredBooks();

    return SafeArea(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة العنوان
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

            // مربع البحث
            TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: "ابحث عن كتاب...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // التصنيفات
            SizedBox(
              height: 50,
              child: _isLoadingCategories
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected =
                      category.id == selectedCategory?.id;

                  return GestureDetector(
                    onTap: () =>
                        setState(() => selectedCategory = category),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1C597B)
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          category.name,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.black87,
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

            // عرض الكتب
            books.isEmpty
                ? Center(
              child: Text(
                "لا توجد كتب في هذا التصنيف",
                style: TextStyle(
                    color: Colors.grey[700], fontSize: 16),
              ),
            )
                : ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];

                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookDetailsPage(book: book),
                    ),
                  ),
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
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                          child: Image.asset(
                            _getCategoryImage(book.categoryName),
                            width: 100,
                            height: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1C597B),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  book.description ??
                                      "كتاب رائع يأخذك في رحلة مليئة بالتشويق والإثارة.",
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // حالة الكتاب (مجاني / مدفوع) و الإعجاب
                                Container(
                                  padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6),
                                  decoration: BoxDecoration(
                                    color: book.isPaid
                                        ? Colors.red.withOpacity(0.1)
                                        : Colors.green
                                        .withOpacity(0.1),
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      // حالة الكتاب
                                      Container(
                                        padding: const EdgeInsets
                                            .symmetric(
                                            horizontal: 10,
                                            vertical: 6),
                                        decoration: BoxDecoration(
                                          color: book.isPaid
                                              ? Colors.red
                                              .withOpacity(0.1)
                                              : Colors.green
                                              .withOpacity(
                                              0.1),
                                          borderRadius:
                                          BorderRadius.circular(
                                              12),
                                        ),
                                        child: Row(
                                          mainAxisSize:
                                          MainAxisSize.min,
                                          children: [
                                            Icon(
                                              book.isPaid
                                                  ? Icons.lock
                                                  : Icons
                                                  .check_circle,
                                              color: book.isPaid
                                                  ? Colors.red
                                                  : Colors.green,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              book.isPaid
                                                  ? "مدفوع"
                                                  : "مجاني",
                                              style: TextStyle(
                                                color: book.isPaid
                                                    ? Colors.red
                                                    : Colors
                                                    .green,
                                                fontWeight:
                                                FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // أيقونة الإعجاب التفاعلية
                                      GestureDetector(
                                        onTap: () async {
                                          if (book.isLiking) return;

                                          setState(() =>
                                          book.isLiking = true);

                                          try {
                                            final result = await booksService
                                                .toggleLike(book.id);
                                            setState(() {
                                              book.isLikedByUser =
                                              result['liked'] as bool;
                                              book.numberOfLikes =
                                              result['likes_count']
                                              as int;
                                            });
                                          } catch (e) {
                                            print(
                                                "Error toggling like: $e");
                                          } finally {
                                            setState(() =>
                                            book.isLiking = false);
                                          }
                                        },
                                        child: Container(
                                          padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6),
                                          decoration: BoxDecoration(
                                            color: book.isLikedByUser
                                                ? Colors.blueGrey
                                                .withOpacity(0.2)
                                                : Colors.blueGrey
                                                .withOpacity(0.1),
                                            borderRadius:
                                            BorderRadius.circular(
                                                12),
                                          ),
                                          child: Row(
                                            mainAxisSize:
                                            MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.thumb_up,
                                                color: book.isLikedByUser
                                                    ? const Color(
                                                    0xFF1C597B)
                                                    : Colors.blueGrey,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                "${book.numberOfLikes}",
                                                style: TextStyle(
                                                  color: book.isLikedByUser
                                                      ? const Color(
                                                      0xFF1C597B)
                                                      : Colors.blueGrey,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
