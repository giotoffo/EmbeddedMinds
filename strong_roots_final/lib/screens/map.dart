import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  // ValueNotifier to track which shop's description is expanded
  final ValueNotifier<int?> expandedIndexNotifier = ValueNotifier(null);

  // List of shops with their details
  final List<Map<String, String>> shops = const [
    {
      'label': 'A', // Identifier label for the shop
      'name': 'NaturaSì - Via Volturno', // Shop name
      'address': 'Via Volturno 1, 35138 Padova', // Shop address
      'description':
          'Organic supermarket offering over 4000 biodynamic, natural, and organic products.', // Shop description
    },
    {
      'label': 'B',
      'name': 'Fragranze Mondo Bio',
      'address': 'Corso Milano, Padova',
      'description':
          'Organic herbal and perfume shop offering natural cosmetics and wellness products.',
    },
    {
      'label': 'C',
      'name': 'SOBON - Sotto il Salone',
      'address': 'Via Sotto il Salone 39, Padova',
      'description':
          'Organic store with local, bulk, and sustainable products.',
    },
    {
      'label': 'D',
      'name': 'Fattoria alle Origini',
      'address': 'Via Sotto il Salone 26, Padova',
      'description':
          'Farm products at zero kilometers, directly from producer to consumer.',
    },
    {
      'label': 'E',
      'name': 'Lo Stizzeri',
      'address': 'Via Cesare Battisti, Padova',
      'description':
          'Small artisanal shop with local specialties and natural products.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,

      // App bar with the title
      appBar: AppBar(
        toolbarHeight: 70,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        centerTitle: true,
        title: const Text(
          'Organic Shops in Padua',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 36, 84, 44),
      ),

      // Body of the Scaffold wrapped in a SingleChildScrollView for scrolling
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 250, 239, 221),
              Color.fromARGB(255, 246, 229, 201),
              Color.fromARGB(255, 254, 221, 169),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),

                // Displaying the logo image
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color.fromARGB(255, 0, 0, 0),
                        width: 2.0,
                      ),
                    ),
                    child: Image.asset('immagini/mapPD.png', scale: 2),
                  ),
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ValueListenableBuilder<int?>(
                    valueListenable: expandedIndexNotifier,
                    builder: (context, expandedIndex, _) {
                      return Column(
                        // Generating a list of widgets for each shop
                        children: List.generate(shops.length, (index) {
                          final shop = shops[index];
                          final isExpanded =
                              expandedIndex ==
                              index; // Check if this shop's description is expanded

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ListTile representing the shop
                              ListTile(
                                leading: const Icon(
                                  Icons.location_on,
                                  color: Color.fromARGB(255, 36, 84, 44),
                                ),
                                title: RichText(
                                  text: TextSpan(
                                    style: DefaultTextStyle.of(context).style,
                                    children: [
                                      TextSpan(
                                        text: '${shop['label']}: ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color.fromARGB(
                                            255,
                                            36,
                                            84,
                                            44,
                                          ),
                                          decoration: TextDecoration.none,
                                        ),
                                      ),

                                      TextSpan(
                                        text: shop['name']!, // Shop name
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color.fromARGB(
                                            255,
                                            36,
                                            84,
                                            44,
                                          ),
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Subtitle displaying the address
                                subtitle: Text(
                                  shop['address']!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),

                                // On tap, toggle the expansion of the description
                                onTap: () {
                                  expandedIndexNotifier.value =
                                      isExpanded ? null : index;
                                },
                              ),

                              // AnimatedCrossFade to show/hide the description
                              AnimatedCrossFade(
                                firstChild: const SizedBox.shrink(),
                                secondChild: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 56.0,
                                    right: 8.0,
                                    bottom: 12.0,
                                  ),
                                  child: Text(
                                    shop['description']!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                crossFadeState:
                                    isExpanded
                                        ? CrossFadeState.showSecond
                                        : CrossFadeState.showFirst,
                                duration: const Duration(milliseconds: 300),
                              ),
                              if (index < shops.length)
                                const Divider(
                                  thickness: 1,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                            ],
                          );
                        }),
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
