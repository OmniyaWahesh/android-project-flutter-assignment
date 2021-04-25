import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


Set<WordPair> savedG = new Set<WordPair>();
Set<WordPair> _allPairs = new Set<WordPair>();

class Saved extends StatefulWidget {
  @override
  _SavedState createState() => _SavedState();
}

class _SavedState extends State<Saved> {
  List<WordPair> _cloudSaved = [];
  @override
    Widget build(BuildContext context){
    _getCloudSaved();
    final tiles = _allPairs.map(
          (WordPair pair) {
        // WordPair _currPair = pair;
        return ListTile(
          title: Text(
            pair.asPascalCase,
            style: const TextStyle(fontSize: 18),
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () async {
              setState(() {
                if (FirebaseAuth.instance.currentUser != null) {
                  FirebaseFirestore.instance
                      .collection('Users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .update({
                    'favorites':
                    FieldValue.arrayRemove([pair.asPascalCase])
                  });
                }
                savedG.remove(pair);
              });
            }, //may add ,
          ),
        );
      },
    );
    print('tiles**********************************'); print(tiles);
    final divided = ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList();
    print('divided******************************************'); print(divided);
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Suggestions'),
      ),
      body: divided.isNotEmpty
          ? ListView(children: divided)
          : Center(child: Text('No Saved Suggestions')),
    );
  }

  void _getCloudSaved() async{
    _cloudSaved = [];
    List temp = [];
    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((documentSnapshot)  =>
      temp = documentSnapshot.data()!['favorites']);
      for (var i = 0; i < temp.length; i++) {
        final beforeCapitalLetter = RegExp(r"(?=[A-Z])");
        var parts = temp[i].split(beforeCapitalLetter);
        if (parts.isNotEmpty && parts[0].isEmpty) parts = parts.sublist(1);
        _cloudSaved.add(WordPair(parts[0].toLowerCase(), parts[1].toLowerCase()));
      }
    }
     if(FirebaseAuth.instance.currentUser != null){
       _allPairs = savedG.union(_cloudSaved.toSet());
     }else{
       _allPairs = savedG;
     }
  }
}

