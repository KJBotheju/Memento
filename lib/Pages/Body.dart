import 'package:album/Pages/AddImage.dart';
import 'package:flutter/material.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Center(
          child: Text("my album"),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AddImage()),
              );
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.black,
            child: Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
