import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fidi_game/model/data_model.dart';
import 'package:fidi_game/screens/add_game.dart';
import 'package:fidi_game/screens/login_page.dart';
import 'package:fidi_game/utils/fire_store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fidi_game/utils/constants.dart' as global;

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  int counter = 0;
  FireStoreService fireServ = new FireStoreService();
  StreamSubscription<QuerySnapshot> gameData;
  final _auth = FirebaseAuth.instance;
  bool isLiked = false;
  String _dropDownValue;
  final gameCollection = FirebaseFirestore.instance.collection('fidigame');
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  pressed() {
    setState(() {
      isLiked = !isLiked;
    });
  }

  logOut() async {
    try {
      await _auth.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.clear();
      return Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              fullscreenDialog: true, builder: (Context) => LoginPage()));
    } catch (e) {
      print(e.toString());
    }
  }


  @override
  void initState() {
     super.initState();
  }

  @override
  void dispose() {
   super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0.0,
        title: Text(
          global.fidiGame,
          style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20.0,
              color: Color(0xffFEFEFE),
              fontWeight: FontWeight.w600),
        ),
        actions: [
          Row(
            children: [
              new IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: new Text(global.logout, style: TextStyle(color: Colors.black,
                          fontFamily: 'Poppins',)),
                        content: new Text("Are you sure want to Exit?",
                            style: TextStyle(color: Colors.black,
                              fontFamily: 'Poppins',)),
                        actions: <Widget>[
                          new FlatButton(
                            child: new Text(global.yes, style: TextStyle(color: Colors.black,
                              fontFamily: 'Poppins',),),
                            onPressed: () {
                              logOut();
                            },
                          ),
                          new FlatButton(
                            child: new Text(global.no, style: TextStyle(color: Colors.black,
                              fontFamily: 'Poppins',),),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      );
                    },
                  );
                  print("Logout is done");
                },
                icon: Icon(Icons.logout),
              ),
              Padding(
                padding: EdgeInsets.only(right: 5.0),
                child: new Text(
                  "Logout",
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                ),
              )
            ],
          )
        ],
      ),
      body:
            Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 20.0),
                      Row(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10.0),
                            height: 48.0,
                            decoration: new BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(30.0)),
                              border: Border.all( color: Colors.white),
                            ),
                            child: DropdownButton(
                              icon: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  margin: EdgeInsets.all(10.0),
                                  width: 12.0,
                                  height: 6.0,
                                  child: ClipRRect(
                                    child: Image.asset("images/vector_5.png"),
                                  ),
                                ),
                              ),
                              hint: _dropDownValue == null
                                  ? Padding(
                                padding: EdgeInsets.only(
                                    left: 16.0, top: 13.0, bottom: 10.0),
                                child: Text(global.category,
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        color: Color(0xffFEFEFE),
                                        fontSize: 14.0,
                                        fontStyle: FontStyle.normal,
                                        fontWeight: FontWeight.w400)),
                              )
                                  : Padding(
                                padding: EdgeInsets.only(
                                    left: 16.0, top: 13.0, bottom: 10.0),
                                child: Text(_dropDownValue,
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        color: Color(0xffFEFEFE),
                                        fontSize: 14.0,
                                        fontStyle: FontStyle.normal,
                                        fontWeight: FontWeight.w400)),
                              ),
                              iconEnabledColor: Colors.white,
                              iconDisabledColor: Colors.white,
                              style: TextStyle(color: Colors.white),
                              items: ['Among Us', 'Mini Militia', 'Skribble.io',
                                   "Category"].map(
                                    (val) {
                                  return DropdownMenuItem<String>(
                                    value: val,
                                    child: Text(val,
                                        style: TextStyle(
                                            fontFamily: 'Poppins', color: Colors.black)),
                                  );
                                },
                              ).toList(),
                              onChanged: (val) {
                                setState(
                                      () {
                                    _dropDownValue = val;
                                  },
                                );
                              },
                              underline: Container(
                                  height: 1.0,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.transparent, width: 0.0)))),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0,),
                      StreamBuilder<QuerySnapshot>(
                          stream: _dropDownValue == null || _dropDownValue == "Category"?
                          gameCollection.orderBy('time',descending: true).snapshots():
                            gameCollection.where('category',isEqualTo: _dropDownValue).withConverter<FidiData>(
                              fromFirestore: (snapshots, _) => FidiData.fromMap(snapshots.data()),
                              toFirestore: (userModel, _) => FidiData().toMap(),
                            ).snapshots(),
                          builder: (context, snapshot) {
                            if(!snapshot.hasData)
                              {
                                print("No data availabel");
                                return Container();
                              }
                            else if(snapshot.hasError)
                              {
                                return Container(
                                  child: Center(
                                    child: Text("No Data Available",
                                      style: TextStyle(fontFamily: 'Poppins', color: Colors.white),),
                                  ),
                                );
                              }
                            else {
                              print(snapshot.data?.size);
                              return gameListView(snapshot);
                            }
                          }
                        ),
                      SizedBox(height: 70.0,)
                    ],
                  ),
                ),
               Align(
                 alignment: Alignment.bottomCenter,
                 child: Container(
                    width: 200,
                    height: 48,
                    margin: EdgeInsets.only(bottom: 20.0,),
                    child: MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          side: BorderSide(color: Color(0xffFCBC3C))),
                      color: Color(0xffFCBC3C),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (context) =>
                                    AddGame(FidiData(
                                        url: "",
                                        name: "",
                                        minicount: "",
                                        maxcount: "",
                                        image: "",
                                        desc: ""
                                    ))));
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 14, bottom: 13.0,),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            new Text(
                              "+",
                              style: new TextStyle(color: Colors.black),
                            ),
                            SizedBox(
                              width: 4.0,
                            ),
                            Text(global.addGame,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Color(0xff000000),
                                  fontSize: 14.0,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
               ),
              ],
            ),
    );
  }

  Widget gameListView(AsyncSnapshot<QuerySnapshot<Object>> snapshot)
  {
    return Column(
      children: snapshot.data.docs.asMap().map((index, value) =>
      MapEntry(index, Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            width: double.maxFinite,
            height: 148,
            decoration: new BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16.0),
                  topRight: const Radius.circular(16.0),
                  bottomLeft: const Radius.circular(16.0),
                  bottomRight: const Radius.circular(16.0)),
              boxShadow: [
                new BoxShadow(
                  blurRadius: 1.0,
                  color: Color(0xff292333),
                )
              ],
              border: Border.all(
                  width: 2.5, color: Color(0xff292333)),
              shape: BoxShape.rectangle,
            ),
            child: Column(
              children: [
                Column(
                  children: [
                    SafeArea(
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: 5.0),
                          child: Container(
                            margin:
                            EdgeInsets.symmetric(
                                vertical: 8.0),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius:
                                new BorderRadius.circular(
                                    10.0),
                                child: Image(
                                  fit: BoxFit.cover,
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width *
                                      0.18,
                                  height: MediaQuery
                                      .of(context)
                                      .size
                                      .height *
                                      0.28,
                                  image: NetworkImage(
                                      snapshot.data
                                          .docs[index].get(
                                          "image")),
                                ),
                              ),
                              title: Padding(
                                padding: EdgeInsets.only(
                                    left: 5.0,
                                    bottom: 15.0),
                                child: Text(
                                    snapshot.data?.docs[index]?.get('name'),
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight
                                            .w600,
                                        fontStyle: FontStyle
                                            .normal,
                                        fontSize: 18.0,
                                        color: Color(
                                            0xffFFFFFF))),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets
                                    .only(
                                  left: 10.0,
                                ),
                                child: Text(
                                  snapshot.data?.docs[index]?.get('Desc'),
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 10.0,
                                      color: Color(
                                          0xffFFFFFF),
                                      fontWeight: FontWeight
                                          .w300,
                                      fontStyle: FontStyle
                                          .normal),
                                  maxLines: 2,
                                ),
                              ),
                            ),
                          ),
                        )),
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                pressed();
                                setState(() {
                                  isLiked = !isLiked;
                                });
                              },
                              child: Container(
                                  width: 11.08,
                                  height: 10.09,
                                  child: isLiked
                                      ? Image.asset(
                                      "images/likes.png")
                                      : Image.asset(
                                      "images/like.png")),
                            ),
                            SizedBox(
                              width: 2.0,
                            ),
                            Padding(
                              padding: EdgeInsets.all(2.0),
                              child: new Text(snapshot.data.docs[index].get('likes'),
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.white,
                                      fontWeight:
                                      FontWeight.w300,
                                      fontStyle:
                                      FontStyle.normal,
                                      fontSize: 12.0)),
                            )
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            _scaffoldKey.currentState.showSnackBar(
                              SnackBar(content: Text("Can't Play Now"))
                            );
                          },
                          child: new Container(
                            width: 88,
                            height: 32.0,
                            decoration: new BoxDecoration(
                              borderRadius: BorderRadius
                                  .only(
                                  topLeft:
                                  const Radius.circular(
                                      16.0),
                                  topRight:
                                  const Radius.circular(
                                      16.0),
                                  bottomLeft:
                                  const Radius.circular(
                                      16.0),
                                  bottomRight:
                                  const Radius.circular(
                                      16.0)),
                              boxShadow: [
                                new BoxShadow(
                                  //blurRadius: 1.0,
                                  color: Colors.black,
                                )
                              ],
                              border: Border.all(
                                  color: Color(0xffFCBC3D)),
                              shape: BoxShape.rectangle,
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: 10.0),
                                Icon(
                                  Icons.play_arrow,
                                  color: Color(0xffFFFFFF),
                                ),
                                SizedBox(width: 5.0),
                                Text(
                                  global.play,
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Color(
                                          0xffFFFFFF),
                                      fontStyle:
                                      FontStyle.normal,
                                      fontSize: 12.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                        new Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              child: Image(
                                fit: BoxFit.fill,
                                image: AssetImage(
                                    'images/user.png'),
                              ),
                            ),
                            SizedBox(width: 2.0),
                            new Text(" "+
                                snapshot.data?.docs[index]?.get('Minicount').toString()+"-",
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                    fontSize: 12.0,
                                    fontStyle: FontStyle
                                        .normal,
                                    fontWeight:
                                    FontWeight.w300)),
                            SizedBox(height: 5.0),
                            new Text(
                                snapshot.data?.docs[index]?.get('Maxcount')+" Players",
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                    fontSize: 12.0,
                                    fontStyle: FontStyle
                                        .normal,
                                    fontWeight:
                                    FontWeight.w300)),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10.0,),
        ],
      ))).values.toList(),
    );
  }
}