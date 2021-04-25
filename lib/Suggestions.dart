import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:hello_me/Login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hello_me/AuthRepository.dart';
import 'package:provider/provider.dart';
import 'package:hello_me/Saved.dart';
import 'package:snapping_sheet/snapping_sheet.dart';



class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _biggerFont = const TextStyle(fontSize: 18);
  String? email = '';
  bool isDragged = false;
  final openFactor = 0.2;
  final closeFactor = 0.03;
  var factor = 0.03;
  SnappingSheetController snapSheetController = SnappingSheetController();
  @override
  Widget build(BuildContext context) {
    if(FirebaseAuth.instance.currentUser != null) {
      email = FirebaseAuth.instance.currentUser!.email;
    }
    print('email'); print(email);
    return Consumer(
        builder: (context, AuthRepository user, _) => Scaffold(
            appBar: AppBar(
              title: Text('Startup Name Generator'),
              actions: [
                IconButton(icon: Icon(Icons.favorite), onPressed: _pushSaved),
                user.status == Status.Authenticated
                    ? IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () async {
                    user.signOut();
                    _pushLogin();
                  },
                )
                    : IconButton(
                    icon: Icon(Icons.login), onPressed: _pushLogin),
              ],
            ),
            body: Stack(children:[
              _buildSuggestions(),
              SnappingSheet(
                // Add your content that is placed
                // behind the sheet. (Can be left empty)
                grabbingHeight: 75,
                lockOverflowDrag: true,
                snappingPositions: [
                  SnappingPosition.factor(
                    positionFactor: 0.0,
                    grabbingContentOffset: GrabbingContentOffset.top,
                  ),
                  SnappingPosition.factor(
                    snappingCurve: Curves.elasticOut,
                    snappingDuration: Duration(milliseconds: 1750),
                    positionFactor: 0.5,
                  ),
                  SnappingPosition.factor(positionFactor: 0.9),
                ],
                // Add your grabbing widget here,
                grabbing:user.status==Status.Authenticated ? SizedBox(height: 0,width: 0,) :
                ListTile(
                  tileColor: Colors.grey,
                  leading: Text('Welcome back, ' + email!),
                  trailing: (factor > closeFactor) ? Icon(Icons.arrow_drop_down): Icon(Icons.arrow_drop_up),
                  onTap: (){
                    setState(() {
                      print('factor'); print(factor);
                      factor = (factor == openFactor ) ? (closeFactor) : (openFactor);
                      if(factor > closeFactor){
                        isDragged = true;
                      }else if(factor < openFactor){
                        isDragged = false;
                      }
                    });
                  },
                )
                ,
                controller:snapSheetController,
                sheetBelow: SnappingSheetContent(
                  draggable: true,
                  // Add your sheet content here
                  child:Container(color: Colors.white,
                  child: Text(
                    'trying snapping sheet',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),),
                ),
              )
            ],)
        )
      // )
    );
  }
  // Widget build(BuildContext context) {
  //   if(FirebaseAuth.instance.currentUser != null) {
  //     email = FirebaseAuth.instance.currentUser!.email;
  //   }
  //   print('email'); print(email);
  //   return Consumer(
  //       builder: (context, AuthRepository user, _) => Scaffold(
  //         appBar: AppBar(
  //           title: Text('Startup Name Generator'),
  //           actions: [
  //             IconButton(icon: Icon(Icons.favorite), onPressed: _pushSaved),
  //             user.status == Status.Authenticated
  //                 ? IconButton(
  //               icon: Icon(Icons.exit_to_app),
  //               onPressed: () async {
  //                 user.signOut();
  //                 _pushLogin();
  //               },
  //             )
  //                 : IconButton(
  //                 icon: Icon(Icons.login), onPressed: _pushLogin),
  //           ],
  //         ),
  //         body: Stack(children:[
  //           _buildSuggestions(),
  //           SnappingSheet(
  //             // Add your content that is placed
  //             // behind the sheet. (Can be left empty)
  //             grabbingHeight: 75,
  //             onSheetMoved: (l){
  //               setState(() {
  //                 if(user.status==Status.Authenticated){
  //                   isDragged=true;
  //                 }
  //               });
  //             },
  //             initialSnappingPosition: SnappingPosition.factor(positionFactor: closeFactor),
  //             snappingPositions: [SnappingPosition.factor(positionFactor: closeFactor),
  //               SnappingPosition.factor(positionFactor: openFactor)],
  //             // Add your grabbing widget here,
  //             grabbing:user.status==Status.Authenticated ? SizedBox(height: 0,width: 0,) :
  //             ListTile(
  //               tileColor: Colors.grey,
  //               leading: Text('Welcome back, ' + email!),
  //               trailing: Icon(Icons.arrow_drop_up),
  //               onTap: (){
  //                 setState(() {
  //                   factor = (factor == openFactor ) ? (closeFactor) : (openFactor);
  //                   if(factor > closeFactor){
  //                     isDragged = true;
  //                   }else if(factor < openFactor){
  //                     isDragged = false;
  //                   }
  //                 });
  //               },
  //             )
  //             ,
  //             sheetBelow: SnappingSheetContent(
  //               draggable: true,
  //               // Add your sheet content here
  //               child:Text(
  //                 'trying snapping sheet',
  //                 style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
  //               ),
  //             ),
  //           )
  //         ],)
  //       )
  //   // )
  //   );
  // }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: (BuildContext _context, int i) {
          if (i.isOdd) {
            return Divider();
          }

          final int index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index]);
        });
  }

  Widget _buildRow(WordPair pair) {
    final alreadySaved = savedG.contains(pair);
    return Consumer(builder: (context, AuthRepository user, _) {
      return ListTile(
        title: Text(
          pair.asPascalCase,
          style: _biggerFont,
        ),
        trailing: Icon(
          alreadySaved ? Icons.favorite : Icons.favorite_border,
          color: alreadySaved ? Colors.red : null,
        ),
        onTap: () async {
          final FirebaseFirestore _db = FirebaseFirestore.instance;
          List fav = [];
          if (user.status == Status.Authenticated) {
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .get()
                .then((documentSnapshot) async =>
                    fav = documentSnapshot.data()!['favorites']);
          }
          setState(() {
            if (user.status == Status.Authenticated) {
              if (fav.contains(pair.asPascalCase) == true) {
                _db
                    .collection('Users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .update({
                  'favorites': FieldValue.arrayRemove([pair.asPascalCase])
                });
              } else {
                _db
                    .collection('Users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .update({
                  'favorites': FieldValue.arrayUnion([pair.asPascalCase])
                });
              }
            }
            if (alreadySaved) {
              savedG.remove(pair);
            } else {
              savedG.add(pair);
            }
          });
        },
      );
    });
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          return Saved();
        },
      ),
    );
  }

  void _pushLogin() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          return Login();
        },
      ),
    );
  }
}
