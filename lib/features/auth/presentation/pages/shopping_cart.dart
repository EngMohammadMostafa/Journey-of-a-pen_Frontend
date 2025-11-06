import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // لتنسيق التاريخ

class ShoppingCartPage extends StatelessWidget {
  const ShoppingCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    // بيانات وهمية لعمليات الشراء
    final List<Map<String, dynamic>> purchases = [
      {
        "title": "The Hero's Journey",
        "author": "John Smith",
        "price": 12.99,
        "discount": 0.0,
        "date": DateTime(2025, 11, 4),
        "address": "شارع الجامعة - مبنى A",
        "image": "https://picsum.photos/200/300?random=10",
      },
      {
        "title": "Love in Paris",
        "author": "Emily Rose",
        "price": 15.99,
        "discount": 3.0,
        "date": DateTime(2025, 11, 1),
        "address": "المدينة الجامعية - بوابة 2",
        "image": "https://picsum.photos/200/300?random=11",
      },
      {
        "title": "Haunted Nights",
        "author": "Lucy Grey",
        "price": 10.50,
        "discount": 0.0,
        "date": DateTime(2025, 10, 29),
        "address": "حي المستقبل - عمارة 5",
        "image": "https://picsum.photos/200/300?random=12",
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
                // 🛒 عنوان الصفحة
                const Text(
                  "سلة المشتريات",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // 🧾 قائمة المشتريات
                Expanded(
                  child: ListView.builder(
                    itemCount: purchases.length,
                    itemBuilder: (context, index) {
                      final item = purchases[index];
                      final discountedPrice = item["price"] - item["discount"];
                      final formattedDate =
                      DateFormat('yyyy/MM/dd').format(item["date"]);

                      return Container(
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
                            // 📘 صورة الكتاب
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(18),
                                bottomLeft: Radius.circular(18),
                              ),
                              child: Image.network(
                                item["image"],
                                width: 100,
                                height: 130,
                                fit: BoxFit.cover,
                              ),
                            ),

                            // 🧾 تفاصيل الشراء
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["title"],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1C597B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "بواسطة: ${item["author"]}",
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 6),

                                    // 💰 السعر والخصم
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
                                        if (item["discount"] > 0)
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(left: 8),
                                            child: Text(
                                              "${item["price"]} \$",
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 14,
                                                decoration:
                                                TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),

                                    // 🏠 العنوان
                                    Text(
                                      "📍 ${item["address"]}",
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 13,
                                      ),
                                    ),

                                    // 📅 التاريخ
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
