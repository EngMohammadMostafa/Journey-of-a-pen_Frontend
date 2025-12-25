import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/purchase_model.dart';
import '../../provider/books_provider.dart';

class ShoppingCartPage extends StatelessWidget {
  const ShoppingCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final booksProvider = context.watch<BooksProvider>();
    final List<PurchaseModel> userPurchases = booksProvider.purchasedBooks;

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
              crossAxisAlignment: CrossAxisAlignment.center,
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
                  child: userPurchases.isEmpty
                      ? const Center(
                    child: Text(
                      "لم تشترِ أي كتب بعد.",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  )
                      : ListView.builder(
                    itemCount: userPurchases.length,
                    itemBuilder: (context, index) {
                      final purchase = userPurchases[index];
                      final book = purchase.book;

                      if (book == null) return const SizedBox();

                      final price = book.price;
                      final discount = book.discountRate ?? 0.0;
                      final discountedPrice = price - discount;

                      final purchaseDate = purchase.purchasedAt;
                      final formattedDate = purchaseDate != null
                          ? DateFormat('yyyy/MM/dd').format(purchaseDate)
                          : '';

                      return GestureDetector(
                        onTap: () {
                          showGeneralDialog(
                            context: context,
                            barrierDismissible: true,
                            barrierLabel: "Dialog",
                            transitionDuration:
                            const Duration(milliseconds: 350),
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
                              return Stack(
                                children: [
                                  // الخلفية الضبابية
                                  BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 4, sigmaY: 4),
                                    child: Container(
                                        color:
                                        Colors.black.withOpacity(0.2)),
                                  ),
                                  Center(
                                    child: ScaleTransition(
                                      scale: CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.elasticOut,
                                      ),
                                      child: Container(
                                        width: 300,
                                        padding:
                                        const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(20),
                                          gradient:
                                          const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFF1C597B),
                                              Color(0xFF4C869F),
                                              Color(0xFF77A9C4),
                                            ],
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.info_outline,
                                              size: 50,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(height: 15),
                                            const Text(
                                              "تنبيه",
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight:
                                                FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              "يمكنك قراءة الكتاب من خلال صفحة البروفايل.\n"
                                                  "تاريخ الشراء: $formattedDate",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                height: 1.5,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                style: ElevatedButton
                                                    .styleFrom(
                                                  backgroundColor:
                                                  Colors.white,
                                                  foregroundColor:
                                                  Color(0xFF1C597B),
                                                  elevation: 3,
                                                  padding:
                                                  const EdgeInsets
                                                      .symmetric(
                                                      vertical: 12),
                                                  shape:
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(12),
                                                  ),
                                                ),
                                                onPressed: () =>
                                                    Navigator.pop(
                                                        context),
                                                child: const Text(
                                                  "حسناً",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
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
                                  book.imageUrl ??
                                      'https://picsum.photos/200/300',
                                  width: 100,
                                  height: 130,
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
                                      const SizedBox(height: 4),
                                      Text(
                                        "بواسطة: ${book.author}",
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
                                              padding:
                                              const EdgeInsets.only(
                                                  left: 8),
                                              child: Text(
                                                "${price.toStringAsFixed(2)} \$",
                                                style: const TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 14,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        formattedDate,
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
