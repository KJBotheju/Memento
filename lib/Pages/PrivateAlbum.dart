import 'package:album/Pages/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:album/Pages/PrivateImage.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
                  reverse: false,
                  itemBuilder: (context, index) {
                    var imageUrl = snapshot.data!.docs[index]['image_url'];
                    var documentId = snapshot.data!.docs[index].id;
                    return Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              _deleteImage(context, documentId);
                            },
                          ),
                        ),
                      ],
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

  Future<void> _deleteImage(BuildContext context, String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('PrivateImage')
          .doc(documentId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image deleted successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
