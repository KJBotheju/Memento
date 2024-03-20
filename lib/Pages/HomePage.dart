import 'package:album/Pages/AppDrawer.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Memento',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Stack(
        children: [
          const Center(
            child: Text("my album"),
          ),
          Positioned(
            bottom: 16, // Adjust the position as needed
            right: 16, // Adjust the position as needed
            child: FloatingActionButton(
              onPressed: () {
                // Add functionality to handle adding images
              },
              backgroundColor: Colors.blue,
              foregroundColor: Colors.black,
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
    );
  }
}
