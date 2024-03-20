// ignore_for_file: prefer_const_constructors

import 'package:album/Pages/HomePage.dart';
import 'package:album/Pages/PrivateImage.dart';
import 'package:flutter/material.dart';

class PrivateAlbum extends StatefulWidget {
  const PrivateAlbum({super.key});

  @override
  State<PrivateAlbum> createState() => _PrivateAlbumState();
}

class _PrivateAlbumState extends State<PrivateAlbum> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Gallery',
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
      ),
      body: Stack(
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
                  MaterialPageRoute(builder: (context) => PrivateImage()),
                );
              },
              backgroundColor: Colors.blue,
              foregroundColor: Colors.black,
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
