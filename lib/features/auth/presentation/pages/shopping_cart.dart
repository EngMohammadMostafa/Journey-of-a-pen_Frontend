import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../books/presentation/pages/book_details_page.dart';

class ShoppingCartPage extends StatelessWidget {
  const ShoppingCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userPurchases = [
      {
        "purchasing_id": 1,
        "date": DateTime(2025, 11, 4),
        "book": {
          "book_id": 101,
          "title": "The Hero's Journey",
          "author": "John Smith",
          "price": 12.99,
          "discount_rate": 0.0,
          "image": "https://picsum.photos/200/300?random=10",
        }
      },
      {
        "purchasing_id": 2,
        "date": DateTime(2025, 11, 1),
        "book": {
          "book_id": 102,
          "title": "Love in Paris",
          "author": "Emily Rose",
          "price": 15.99,
          "discount_rate": 3.0,
          "image": "https://picsum.photos/200/300?random=11",
        }
      },
      {
        "purchasing_id": 3,
        "date": DateTime(2025, 10, 29),
        "book": {
          "book_id": 103,
          "title": "Haunted Nights",
          "author": "Lucy Grey",
          "price": 10.50,
          "discount_rate": 0.0,
          "image": "https://picsum.photos/200/300?random=12",
        }
      },
    ];

    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "سلة المشتريات",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: userPurchases.length,
                    itemBuilder: (context, index) {
                      final purchase = userPurchases[index];
                      final book = purchase["book"] as Map<String, dynamic>?;

                      if (book == null) return const SizedBox();

                      final price = book["price"] as double? ?? 0.0;
                      final discount = book["discount_rate"] as double? ?? 0.0;
                      final discountedPrice = price - discount;

                      final date = purchase["date"] as DateTime?;
                      final formattedDate = date != null
                          ? DateFormat('yyyy/MM/dd').format(date)
                          : '';

                      final title = book["title"] as String? ?? '';
                      final author = book["author"] as String? ?? '';
                      final imageUrl = book["image"] as String? ??
                          'https://picsum.photos/200/300?random=1';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookDetailsPage(book:book), // تمرير بيانات الكتاب
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  bottomLeft: Radius.circular(18),
                                ),
                                child: Image.network(
                                  imageUrl,
                                  width: 100,
                                  height: 130,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1C597B),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "بواسطة: $author",
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Text(
                                            "${discountedPrice.toStringAsFixed(2)} \$",
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (discount > 0)
                                            Padding(
                                              padding: const EdgeInsets.only(left: 8),
                                              child: Text(
                                                "${price.toStringAsFixed(2)} \$",
                                                style: const TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 14,
                                                  decoration: TextDecoration.lineThrough,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "🗓️ $formattedDate",
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 13,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
