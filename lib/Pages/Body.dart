import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:album/Pages/AddImage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Body extends StatelessWidget {
  const Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('PublicImage')
              .orderBy('timestamp', descending: true)
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
                itemBuilder: (context, index) {
                  var imageUrl = snapshot.data!.docs[index]['image_url'];
                  var documentId = snapshot.data!.docs[index].id;
                  var userId = snapshot.data!.docs[index]['userId'];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Card(
                      margin: EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                              ),
                              if (_isCurrentUser(
                                  userId)) // Check if current user is the owner of the image
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    icon: Icon(Icons.close),
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.red),
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.white),
                                    ),
                                    onPressed: () {
                                      _deleteImage(context, documentId);
                                    },
                                  ),
                                ),
                            ],
                          ),
                          ButtonBar(
                            alignment: MainAxisAlignment.center,
                            children: [
                              LikeButton(documentId: documentId),
                            ],
                          ),
                        ],
                      ),
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

  bool _isCurrentUser(String userId) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    return currentUser != null && currentUser.uid == userId;
  }

  Future<void> _deleteImage(BuildContext context, String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('PublicImage')
          .doc(documentId)
          .delete();
      // Also delete related data
      await FirebaseFirestore.instance
          .collection('PublicImage')
          .doc(documentId)
          .collection('Likes')
          .get()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });
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

class LikeButton extends StatefulWidget {
  final String documentId;

  const LikeButton({required this.documentId});

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  int likeCount = 0;
  bool liked = false;
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    fetchCurrentUserId();
  }

  void fetchCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid;
    } else {
      currentUserId = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('PublicImage')
          .doc(widget.documentId)
          .get(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData && snapshot.data!.exists) {
          likeCount = snapshot.data!['likes'] ?? 0;

          return Row(
            children: [
              IconButton(
                onPressed: () {
                  if (!liked) {
                    setState(() {
                      likeCount++;
                      liked = true;
                      FirebaseFirestore.instance
                          .collection('PublicImage')
                          .doc(widget.documentId)
                          .update({'likes': likeCount});

                      // Check if the user has already liked this image
                      FirebaseFirestore.instance
                          .collection('PublicImage')
                          .doc(widget.documentId)
                          .collection('Likes')
                          .where('userId', isEqualTo: currentUserId)
                          .get()
                          .then((QuerySnapshot querySnapshot) {
                        if (querySnapshot.size == 0) {
                          // User has not liked this image yet, so add the like
                          FirebaseFirestore.instance
                              .collection('PublicImage')
                              .doc(widget.documentId)
                              .collection('Likes')
                              .add({
                            'userId': currentUserId,
                            'timestamp': Timestamp.now(),
                          });
                        }
                      });
                    });
                  }
                },
                icon: Icon(Icons.favorite),
                color: liked ? Colors.red : Colors.grey,
              ),
              Text('$likeCount'),
            ],
          );
        } else {
          return Text('Error: Image not found');
        }
      },
    );
  }
}
