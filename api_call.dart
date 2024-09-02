import 'dart:convert';
import 'package:button_toggle/model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<UserModel> futureUserModel;

  @override
  void initState() {
    super.initState();
    futureUserModel = getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: FutureBuilder<UserModel>(
        future: futureUserModel,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            final userModel = snapshot.data!;
            final products = userModel.products ?? [];

            return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          product.images != null && product.images!.isNotEmpty
                              ? Image.network(
                                  product.images![0],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.error);
                                  },
                                )
                              : Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey,
                                  child: const Icon(Icons.image_not_supported),
                                ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  product.title ?? 'No Title',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${product.price?.toStringAsFixed(2) ?? '0.0'} USD',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        updateProduct(product.id);
                                      },
                                      icon: const Icon(Icons.add),
                                      tooltip: 'Update Product',
                                    ),
                                    // IconButton(
                                    //   onPressed: () {
                                    //     updateProduct(product.id);
                                    //   },
                                    //   icon: const Icon(Icons.add),
                                    //   tooltip: 'Add to Cart',
                                    // ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
          } else {
            return const Center(
              child: Text('No data available'),
            );
          }
        },
      ),
    );
  }

  Future<UserModel> getData() async {
    final response =
        await http.get(Uri.parse("https://dummyjson.com/products"));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body.toString());
      print('Decoded data: $data');
      return UserModel.fromJson(data);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> updateProduct(int? productId) async {
    if (productId == null) return;
    final response = await http.put(
      Uri.parse('https://dummyjson.com/products/$productId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'title': 'Updated Title',
        'price': 99.99,
      }),
    );
    if (response.statusCode == 200) {
      setState(() {
        futureUserModel = getData();
      });
    } else {
      throw Exception('Failed to update product');
    }
  }
}
