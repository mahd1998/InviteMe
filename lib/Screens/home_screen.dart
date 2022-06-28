import 'dart:async';
import 'dart:ui';
import 'package:assessment_task/Screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:assessment_task/util/hexcolor.dart';
import 'package:flutter/services.dart';
import '../components/friend_components/body_friends.dart';
import 'privateEventsInbox.dart';
import 'publicEventsList.dart';
import 'friend_list.dart';
import 'login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late StreamSubscription<User?> user;
  int _selectedIndex = 0;

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      FirebaseFirestore.instance
          .collection('Users')
          .doc(auth.currentUser?.uid)
          .update({'token': token});
    });
  }

  _onTap(int tabIndex) {
    switch (tabIndex) {
      case 0:
        Get.to(() => ProfilePage());
        break;
      case 1:
        Get.to(() => BodyFriends());
        break;
    }
    setState(() {
      _selectedIndex = tabIndex;
    });
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    getToken();
  }

  @override
  Widget build(BuildContext context) {
    double _sigmaX = 0.0; // from 0-10
    double _sigmaY = 0.0; // from 0-10

    return Container(
        child: Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: Text('HomePage'),
        elevation: 0,
        backgroundColor: Color(0xff7252E7).withOpacity(0.8),
        actions: <Widget>[],
      ),
      drawer: Drawer(
        width: 240,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xff6D0E85), Color(0xff4059f1)],
                      begin: Alignment.bottomRight,
                      end: Alignment.centerLeft)),
              child: Text(''),
            ),
            ListTile(
              title: const Text('Friends',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              onTap: () {
                Get.to(FriendsPage());
              },
            ),
            ListTile(
              title: const Text('LogOut',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              onTap: () async {
                auth.signOut();
                Get.off(LoginScreen());
                if (!mounted) {
                  return;
                } else {}
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          gradient: LinearGradient(colors: [
            Color(0xffF2F2F2).withOpacity(0.8),
            Color(0xffF2F2F2).withOpacity(0.8)
          ], begin: Alignment.bottomRight, end: Alignment.centerLeft),
        ),
        child: BottomNavigationBar(
          backgroundColor: Color(0xff7252E7),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.person_pin),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.contact_mail),
              label: 'Friends',
            ),
          ],
          currentIndex: _selectedIndex,
          unselectedItemColor: Color(0xffF2F2F2),
          selectedItemColor: Color(0xffF2F2F2),
          onTap: _onTap,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          // color: Colors.white,
          image: DecorationImage(
            image: AssetImage("assets/Inkedbackground1.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width / 2.4,
                    height: MediaQuery.of(context).size.height / 1.7,
                    child: BackdropFilter(
                      filter:
                          ImageFilter.blur(sigmaX: _sigmaX, sigmaY: _sigmaY),
                      child: new Material(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(5),
                            bottomRight: Radius.circular(220),
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(220)),
                        child: InkWell(
                          onTap: () {
                            Get.to(() => PrivateList());
                          },
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(5),
                              bottomRight: Radius.circular(220),
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(220)),
                          splashColor: Colors.black.withOpacity(0.4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(5),
                                bottomRight: Radius.circular(220),
                                topLeft: Radius.circular(5),
                                topRight: Radius.circular(220)),
                            child: Container(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [
                                    Color(0xff7252E7),
                                    Color(0xff7252E7).withOpacity(0.9)
                                  ],
                                      begin: Alignment.bottomRight,
                                      end: Alignment.centerLeft)),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'Private',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'OleoScriptSwashCaps',
                                    fontSize: 35,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ) // This trailing comma makes auto-formatting nicer for build methods.
                    ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width / 2.3,
                    height: MediaQuery.of(context).size.height / 1.7,
                    child: BackdropFilter(
                      filter:
                          ImageFilter.blur(sigmaX: _sigmaX, sigmaY: _sigmaY),
                      child: new Material(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(220),
                            bottomRight: Radius.circular(5),
                            topLeft: Radius.circular(220),
                            topRight: Radius.circular(5)),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PublicList()));
                          },
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(220),
                              bottomRight: Radius.circular(5),
                              topLeft: Radius.circular(220),
                              topRight: Radius.circular(5)),
                          splashColor: Colors.black.withOpacity(0.4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(220),
                                bottomRight: Radius.circular(5),
                                topLeft: Radius.circular(220),
                                topRight: Radius.circular(5)),
                            child: Container(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [
                                    Color(0xff7252E7),
                                    Color(0xff7252E7).withOpacity(0.9)
                                  ],
                                      begin: Alignment.bottomRight,
                                      end: Alignment.centerLeft)),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'Public',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'OleoScriptSwashCaps',
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ) // This trailing comma makes auto-formatting nicer for build methods.
                    ),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
