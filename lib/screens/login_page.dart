import 'package:fidi_game/screens/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fidi_game/utils/constants.dart' as global;


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email;
  String password;
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void emptytoast() {
    if (_emailController.text.toString() == "" && _emailController.text.toString() != '@') {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Enter a valid Email")));
    } else if (_passwordController.text.toString() == "" && _passwordController.text.length < 3) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Enter a valid Password")));
    }
  }


  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            header(),
            SizedBox(height: 40.0),
            emailField(),
            SizedBox(height: 20.0),
            passwordField(),
            SizedBox(height: 20.0),
            submit(),
            SizedBox(height: 30.0),
            footer(),
          ],
        ),
      ),
    );
  }

  Widget header()
  {
    return Column(
      children: [
        new Container(
          height: 300,
          child: Center(
              child: Text(global.fidiGame,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 32.0,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w600,
                      color: Colors.white))),
        ),
        SizedBox(height: 30.0),
        new Center(
          child: Text(global.login,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.normal,
                  color: Color(0xffFEFEFE))),
        ),
      ],
    );
  }

  Widget emailField()
  {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      width: 330,
      height: 50.0,
      child: new TextFormField(
        style:
        TextStyle(fontFamily: 'Poppins', color: Color(0xffFEFEFE)),
        controller: _emailController,
        onChanged: (value) {
          email = value;
        },
        keyboardType: TextInputType.emailAddress,
        decoration: new InputDecoration(
          hintText: 'Email',
          contentPadding: EdgeInsets.all(10.0),
          hintStyle:
          TextStyle(fontFamily: 'Poppins', color: Colors.white),
          labelStyle: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
              fontStyle: FontStyle.normal,
              color: Color(0xffFEFEFE)),
          filled: true,
          fillColor: Color(0xff292333),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide:
            BorderSide(color: Color(0xff292333), width: 2.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(color: Color(0xff292333)),
          ),
        ),
      ),
    );
  }

   Widget passwordField()
  {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      width: 330,
      height: 50.0,
      child: new TextFormField(
        style:
        TextStyle(fontFamily: 'Poppins', color: Color(0xffFEFEFE)),
        obscureText: true,
        controller: _passwordController,
        onChanged: (value) {
          password = value;
        },
        keyboardType: TextInputType.text,
        decoration: new InputDecoration(
          hintText: 'Password',
          contentPadding: EdgeInsets.all(10.0),
          hintStyle:
          TextStyle(fontFamily: 'Poppins', color: Colors.white),
          labelStyle: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
              fontStyle: FontStyle.normal,
              color: Color(0xffFEFEFE)),
          filled: true,
          fillColor: Color(0xff292333),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide:
            BorderSide(color: Color(0xff292333), width: 2.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(color: Color(0xff292333)),
          ),
        ),
      ),
    );
  }

   Widget submit()
  {
    return Padding(
      padding:
      EdgeInsets.only(top: 37, left: 107, right: 107, bottom: 49),
      child: Container(
        width: 200,
        height: 48,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: BorderSide(color: Color(0xffFCBC3C))),
          color: Color(0xffFCBC3C),
          onPressed: () async {
            emptytoast();
            try {
              final loginUser = await _auth.signInWithEmailAndPassword(email: email, password: password);
              if(loginUser.user != null)
                {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setString( global.id, loginUser?.user.uid);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (Context) => Home()));
                }
              else
                {
                  final newUser =
                  await _auth.createUserWithEmailAndPassword(
                      email: email, password: password);
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setString( global.id, newUser?.user.uid);
                  if (newUser != null) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (Context) => Home()));
                  }
                }

            } catch (e) {
              print(e.toString());
            }

          },
          child: Text(global.signIn,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.black,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.normal)),
        ),
      ),
    );
  }

  Widget footer()
  {
    return Column(
      children: [
        new Center(
          child: Text(global.signInWith,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  color: Color(0xffFEFEFE))),
        ),
        SizedBox(height: 40.0),
        new Center(
          child: Text(global.newUserSignIn,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                  color: Color(0xffFEFEFE))),
        ),
        SizedBox(height: 70.0)
      ],
    );
  }
}
