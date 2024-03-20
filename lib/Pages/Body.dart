import 'package:album/Pages/AddImage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Body extends StatelessWidget {
  const Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder(
          stream:
              FirebaseFirestore.instance.collection('PublicImage').snapshots(),
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
