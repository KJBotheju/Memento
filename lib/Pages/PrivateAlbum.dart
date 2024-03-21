import 'package:album/Pages/HomePage.dart';
import 'package:album/Pages/PrivateImage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PrivateAlbum extends StatefulWidget {
  const PrivateAlbum({Key? key});

  @override
  State<PrivateAlbum> createState() => _PrivateAlbumState();
}

class _PrivateAlbumState extends State<PrivateAlbum> {
  late String userId;

  @override
  void initState() {
    super.initState();
    fetchUserId();
  }

  void fetchUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
    } else {
      userId = '';
    }
  }

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
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('PrivateImage')
                .where('userId', isEqualTo: userId)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                return ListView.builder(
                  padding: EdgeInsets.all(4),
                  itemCount: snapshot.data!.docs.length,
                  reverse: true, // Reverse the order
                  itemBuilder: (context, index) {
                    var imageUrl = snapshot.data!.docs[index]['image_url'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                );
              } else {
                return Center(child: Text('No images available'));
              }
            },
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
