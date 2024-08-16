import 'package:flutter/material.dart';

class ListPoint extends StatefulWidget {
  final List<dynamic> point;

  const ListPoint({
    Key? key,
    required this.point,
  }) : super(key: key);

  @override
  State<ListPoint> createState() => _ListPointState();
}

class _ListPointState extends State<ListPoint> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'List',
              style: TextStyle(fontSize: 11),
            ),
            Text(
              'Nearest Sana',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: widget.point.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(
                top: 3, bottom: 3), // Sesuaikan jarak sesuai kebutuhan
            child: Column(
              children: [
                SizedBox(
                    height: MediaQuery.of(context).size.width,
                    child: Text(
                      widget.point[index]['title'],
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    )),
                // Padding(
                //   padding: const EdgeInsets.only(bottom: 3.0),
                //   child: Text(
                //     'Teks di bawah gambar ${index + 1}', // Ganti dengan teks yang sesuai
                //     style: const TextStyle(fontSize: 16),
                //     textAlign: TextAlign.left,
                //   ),
                // ),
              ],
            ),
          );
        },
      ),
    );
  }
}
