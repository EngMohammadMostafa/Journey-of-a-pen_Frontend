import 'package:flutter/material.dart';
import '../../repository/books_repository.dart';
import '../../data/models/book_model.dart';
import '../widgets/book_card.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  final BooksRepository _repo = BooksRepository();
  late Future<List<BookModel>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = _repo.getAllBooks();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BookModel>>(
      future: _booksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        } else if (snapshot.hasError) {
          return Center(child: Text("حدث خطأ أثناء تحميل الكتب", style: TextStyle(color: Colors.red)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("لا توجد كتب حالياً", style: TextStyle(color: Colors.white)));
        }

        final books = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: books.length,
          itemBuilder: (context, index) {
            return BookCard(book: books[index]);
          },
        );
      },
    );
  }
}
