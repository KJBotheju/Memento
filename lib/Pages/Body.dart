import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:album/Pages/AddImage.dart';

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

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Card(
                      margin: EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
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

                      FirebaseFirestore.instance
                          .collection('PublicImage')
                          .doc(widget.documentId)
                          .collection('Likes')
                          .add({
                        'timestamp': Timestamp.now(),
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
