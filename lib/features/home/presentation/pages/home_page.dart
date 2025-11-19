import 'package:flutter/material.dart';
import '../../../../core/api/api_service.dart';
import '../../../books/data/models/book_model.dart';
import '../../data/category_service.dart';
import '../../repository/category_repository.dart';
import '../widgets/books_grid_widget.dart';
import '../../../books/repository/books_repository.dart';
import '../../data/models/category_model.dart';
import '../widgets/categories_widget.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final BooksRepository booksRepository = BooksRepository();
  final CategoryRepository categoryRepository =
  CategoryRepository(CategoryService(ApiService()));


  List<CategoryModel> categories = [];
  List<BookModel> books = [];
  int selectedCategory = 0;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    final fetchedCategories = await categoryRepository.fetchCategories();
    final fetchedBooks = await booksRepository.getAllBooks();

    setState(() {
      categories = fetchedCategories;
      books = fetchedBooks;
      if (categories.isNotEmpty) selectedCategory = categories.first.id;
      loading = false;
    });
  }

  Future<void> filterBooks(int categoryId) async {
    setState(() => loading = true);

    final filteredBooks =
    await booksRepository.getBooksByCategory(categoryId);

    setState(() {
      selectedCategory = categoryId;
      books = filteredBooks;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("المكتبة الرقمية"),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // التصنيفات
          CategoriesWidget(
            categories: categories,
            selectedCategoryId: selectedCategory,
            onCategorySelected: filterBooks,
          ),

          const SizedBox(height: 10),

          // الكتب
          BooksGridWidget(books: books),
        ],
      ),
    );
  }
}
