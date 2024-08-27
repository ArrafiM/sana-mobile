import 'package:flutter/material.dart';

class DetailPoint extends StatefulWidget {
  final Map<String, dynamic> point;

  const DetailPoint({
    Key? key,
    required this.point,
  }) : super(key: key);

  @override
  State<DetailPoint> createState() => _DetailPointState();
}

class _DetailPointState extends State<DetailPoint> {
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
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Detail',
                style: TextStyle(fontSize: 12),
              ),
              Text(
                widget.point['merchant']['name'],
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: const SizedBox(
          child: Text('Here this detail info'),
        )
        // ListView.builder(
        //   controller: _scrollController,
        //   itemCount: widget.point.length,
        //   itemBuilder: (context, index) {
        //     return Padding(
        //       padding: const EdgeInsets.only(
        //           top: 3, bottom: 3), // Sesuaikan jarak sesuai kebutuhan
        //       child: Column(
        //         children: [
        //           SizedBox(
        //               height: MediaQuery.of(context).size.width,
        //               child: Text(widget.point[index]['title'])),
        //           // Padding(
        //           //   padding: const EdgeInsets.only(bottom: 3.0),
        //           //   child: Text(
        //           //     'Teks di bawah gambar ${index + 1}', // Ganti dengan teks yang sesuai
        //           //     style: const TextStyle(fontSize: 16),
        //           //     textAlign: TextAlign.left,
        //           //   ),
        //           // ),
        //         ],
        //       ),
        //     );
        //   },
        // ),
        );
  }
}
