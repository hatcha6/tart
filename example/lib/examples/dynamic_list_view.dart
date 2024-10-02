import 'package:flutter/material.dart';
import 'package:tart_dev/tart.dart';

class DynamicListView extends StatefulWidget {
  const DynamicListView({super.key});

  @override
  State<DynamicListView> createState() => _DynamicListViewState();
}

class _DynamicListViewState extends State<DynamicListView> {
  String search = '';
  // Imagine we got this from a server
  final restaurantWidget = '''
return f:Card(
  child: f:Padding(
    padding: p:EdgeInsetsAll(value: 16),
    child: f:Column(
      children: [
        f:Row(
          children: [
            f:Icon(icon: p:IconsRestaurant()),
            f:SizedBox(width: 8),
            f:Text(text: item.name),
          ],
        ),
        f:SizedBox(height: 8),
        f:Row(
          children: [
            f:Icon(icon: p:IconsStar()),
            f:SizedBox(width: 4),
            f:Text(text: 'Rating: ' + item.rating),
          ],
        ),
        f:SizedBox(height: 8),
        f:Text(text: 'Todays Special: ' + item.todaySpecial),
      ],
    ),
  ),
);
''';

  final shopWidget = '''
return f:Container(
  child: f:Padding(
    padding: p:EdgeInsetsAll(value: 16),
    child: f:Row(
      children: [
        f:Icon(icon: p:IconsShoppingBag()),
        f:SizedBox(width: 16),
        f:Expanded(
          child: f:Column(
            children: [
              f:Text(text: item.name),
              f:SizedBox(height: 4),
              f:Text(text: 'Rating: ' + item.rating),
              f:SizedBox(height: 4),
              f:Text(text: 'Sells: ' + item.sells),
            ],
          ),
        ),
      ],
    ),
  ),
);
''';

  final attractionWidget = '''
return f:Card(
  child: f:Stack(
    children: [
      f:Container(
        height: 200,
        color: p:Color(r: 128, g: 0, b: 128, a: 179),
      ),
      f:Padding(
        padding: p:EdgeInsetsAll(value: 16),
        child: f:Column(
          children: [
            f:Center(child: f:Icon(icon: p:IconsAttractions())),
            f:SizedBox(height: 16),
            f:Text(text: item.name),
            f:SizedBox(height: 8),
            f:Text(text: 'Established: ' + item.established),
            f:SizedBox(height: 8),
            f:Text(text: item.description),
          ],
        ),
      ),
    ],
  ),
);
''';

  final items = [
    {
      'type': 'restaurant',
      'name': 'Le Christine',
      'rating': '4.6',
      'todaySpecial': 'Entrée, Plat et Dessert',
    },
    {
      'type': 'attraction',
      'name': 'Eiffel Tower',
      'established': '1889',
      'description':
          'The Eiffel Tower is a wrought-iron lattice tower on the Champ de Mars in Paris, France. It is named after the engineer Gustave Eiffel, whose company designed and built the tower.',
    },
    {
      'type': 'attraction',
      'name': 'Louvre Museum',
      'established': '1793',
      'description':
          'The Louvre is the world\'s largest art museum and a historic monument in Paris, France. A central landmark of the city, it is located on the Right Bank of the Seine in the city\'s 1st arrondissement.',
    },
    {
      'type': 'shop',
      'name': 'Le Bon Marché',
      'rating': '4.7',
      'sells': 'fashion, accessories, home decor',
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  TartStatefulWidget buildWidget(Map<String, dynamic> item) {
    final widget = switch (item['type']) {
      'restaurant' => restaurantWidget,
      'shop' => shopWidget,
      'attraction' => attractionWidget,
      _ => throw Exception('Unknown type: ${item['type']}'),
    };
    return TartStatefulWidget(
      source: widget,
      environment: {'item': item},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Search View'),
      ),
      body: Column(
        children: [
          TextField(
            onSubmitted: (value) {
              setState(() {
                search = value;
              });
            },
          ),
          Builder(builder: (context) {
            final filteredItems = search.isEmpty
                ? items
                : items
                    .where((item) => item
                        .toString()
                        .toLowerCase()
                        .contains(search.toLowerCase()))
                    .toList();
            return TartBuilder(
              tartWidgets:
                  filteredItems.map((item) => buildWidget(item)).toList(),
              builder: (context, tartWidgets) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      return tartWidgets[index];
                    },
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
