import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/pub_events_profile.dart';
import 'friend_list.dart';
import 'home_screen.dart';
import 'dart:async';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:get/get.dart';
import 'login_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //-------------------------
  List<EventData> eventData = [];
  String name = 'unknown';
  String email = 'Loading';
  String phone = 'Loading';
  bool isLoading = false;
  final FirebaseAuth auth = FirebaseAuth.instance;
  String convertDateTimeDisplay(String date) {
    final DateFormat displayFormater = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
    final DateFormat serverFormater = DateFormat('dd-MM-yyyy (HH:mm)');
    final DateTime displayDate = displayFormater.parse(date);
    final String formatted = serverFormater.format(displayDate);
    return formatted;
  }

  Future docsGetter() async {
    eventData.clear();
    FirebaseFirestore.instance
        .collection('PublicEvents')
        .where('Event Owner', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      //print(value.size);
      value.docs.forEach((element) {
        eventData.add(EventData(
            title: '${element.data()['Title']}',
            time: element.data()['Date And Time'],
            picture: "${element.data()['Event Image']}",
            location: element.data()['Location']));
        //docsId?.add(element.id);
      });
    });
  }

  Future<void> getUserData() async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(auth.currentUser?.uid)
        .snapshots()
        .listen((event) {
      setState(() {
        name = event.get("Name");
        email = event.get('email');
        phone = event.get('phone Number');
      });
    });
  }

  _launchURL(String lat, String long) async {
    if (await canLaunch(
        'https://www.google.com/maps/dir/?api=1&destination=${lat},${long}&travelmode=driving&dir_action=navigate')) {
      await launch(
          'https://www.google.com/maps/dir/?api=1&destination=${lat},${long}&travelmode=driving&dir_action=navigate');
    } else {
      throw 'Could not launch https://www.google.com/maps/dir/?api=1&destination=${lat},${long}&travelmode=driving&dir_action=navigate';
    }
  }

  @override
  void initState() {
    super.initState();
    docsGetter();
    getUserData();
    setState(() {});
  }
  //________________________________________

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          const Duration(milliseconds: 1000);
        });
      }
    });
    //__________________________________
    return Scaffold(
      backgroundColor: Color(0xff7252E7),
      appBar: AppBar(
        title: Text("InviteMe"),
        elevation: 0,
        backgroundColor: Color(0xff7252E7),
        actions: <Widget>[],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/user1.png"), fit: BoxFit.cover),
                  gradient: LinearGradient(
                      colors: [Color(0xff6D0E85), Color(0xff4059f1)],
                      begin: Alignment.bottomRight,
                      end: Alignment.centerLeft)),
              child: Text(''),
            ),
            ListTile(
              title: const Text('Home',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              onTap: () {
                Get.off(HomePage());
              },
            ),
            ListTile(
              title: const Text('Friends',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              onTap: () {
                Get.off(FriendsPage());
              },
            ),
            ListTile(
              title: const Text('LogOut',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                setState(() {});
                Get.off(LoginScreen());
              },
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 17.0, top: 5),
                child: Container(
                  width: 100,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    image: DecorationImage(
                        image: AssetImage("assets/user1.png"),
                        fit: BoxFit.cover),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Padding(
                  padding: const EdgeInsets.only(left: 38.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        name,
                        textWidthBasis: TextWidthBasis.longestLine,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.phone, color: Colors.white, size: 15),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(phone,
                                  style: TextStyle(
                                    color: Colors.white,
                                    wordSpacing: 2,
                                    letterSpacing: 4,
                                  )),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
                right: 20.0, left: 20.0, top: 15, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Your Email:',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        )),
                    Text(email,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        )),
                  ],
                ),
                Container(
                  color: Colors.white,
                  width: 0.2,
                  height: 22,
                ),
                Container(
                  padding:
                      EdgeInsets.only(left: 10, right: 10, top: 1, bottom: 1),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(33)),
                      gradient: LinearGradient(
                          colors: [Color(0xff4059f1), Color(0xff4059f1)],
                          begin: Alignment.bottomRight,
                          end: Alignment.centerLeft)),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                    onPressed: () async {
                      Get.to(FriendsPage());
                    },
                    child: const Text('Friends',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                    color: Color(0xffEFEFEF),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(34))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 10, right: 10, left: 20, bottom: 5),
                      child: GradientText(
                        'Your public Events:',
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                        colors: [
                          Color(0xff6D0E85),
                          Color(0xff4059f1),
                        ],
                      ),
                    ),
                    FutureBuilder(builder: (context, AsyncSnapshot snapshot) {
                      return Expanded(
                          child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topCenter,
                            child: isLoading
                                ? CircularProgressIndicator()
                                : Container(
                                    height: MediaQuery.of(context).size.height,
                                    width: 345,
                                    child: ListView.builder(
                                      itemCount: eventData.length,
                                      itemBuilder: (context, index) {
                                        try {
                                          return Container(
                                            decoration: BoxDecoration(
                                              //                    <-- BoxDecoration
                                              border: Border(
                                                  bottom:
                                                      BorderSide(width: 0.1)),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    new Text(
                                                        (index + 1).toString() +
                                                            '- ${eventData[index].title}',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        )),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          width: 90,
                                                          height: 40,
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 1,
                                                                  right: 1,
                                                                  top: 1,
                                                                  bottom: 1),
                                                          decoration: BoxDecoration(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10)),
                                                              gradient: LinearGradient(
                                                                  colors: [
                                                                    Color(
                                                                        0xff6D0E85),
                                                                    Color(
                                                                        0xff4059f1)
                                                                  ],
                                                                  begin: Alignment
                                                                      .bottomRight,
                                                                  end: Alignment
                                                                      .centerLeft)),
                                                          child: TextButton(
                                                            style: TextButton
                                                                .styleFrom(
                                                              textStyle:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          15),
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              _launchURL(
                                                                  (eventData[index]
                                                                          .location
                                                                          .latitude)
                                                                      .toString(),
                                                                  (eventData[index]
                                                                          .location
                                                                          .longitude)
                                                                      .toString());
                                                            },
                                                            child: const Text(
                                                                'location',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                          ),
                                                        ),
                                                        Container(
                                                          child: IconButton(
                                                            color: Colors.grey,
                                                            icon: const Icon(
                                                                Icons.delete),
                                                            tooltip: 'Delete',
                                                            onPressed: () {
                                                              showDialog<
                                                                  String>(
                                                                context:
                                                                    context,
                                                                builder: (BuildContext
                                                                        context) =>
                                                                    AlertDialog(
                                                                  title: const Text(
                                                                      'Deleting event:'),
                                                                  content:
                                                                      const Text(
                                                                          'Are you sure that you want to delete this event?'),
                                                                  actions: <
                                                                      Widget>[
                                                                    TextButton(
                                                                      onPressed: () => Navigator.pop(
                                                                          context,
                                                                          'Cancel'),
                                                                      child: const Text(
                                                                          'Cancel'),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed:
                                                                          () async {
                                                                        isLoading =
                                                                            true;
                                                                        try {
                                                                          FirebaseFirestore
                                                                              .instance
                                                                              .collection('PublicEvents')
                                                                              .where('Event Owner', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                                                                              .get()
                                                                              .then((value) async {
                                                                            if ((FirebaseStorage.instance.refFromURL(value.docs[index]['Event Image'])) !=
                                                                                null)
                                                                              FirebaseStorage.instance.refFromURL(value.docs[index]['Event Image']).delete();

                                                                            value.docs[index].reference.delete();
                                                                            docsGetter();
                                                                            setState(() {
                                                                              isLoading = false;
                                                                            });
                                                                          });
                                                                        } catch (e) {
                                                                          setState(
                                                                              () {
                                                                            isLoading =
                                                                                false;
                                                                          });
                                                                        }

                                                                        Navigator.pop(
                                                                            context,
                                                                            'Ok');
                                                                      },
                                                                      child: const Text(
                                                                          'OK'),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        Text(
                                                          "date:",
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 4,
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        Text(
                                                          convertDateTimeDisplay(
                                                              (eventData[index]
                                                                      .time)
                                                                  .toDate()
                                                                  .toString()),
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color: Color(
                                                                  0xFF39D2C0)),
                                                        )
                                                      ],
                                                    ),
                                                    Divider(),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        bottomLeft:
                                                            Radius.circular(9),
                                                        bottomRight:
                                                            Radius.circular(9),
                                                        topLeft:
                                                            Radius.circular(9),
                                                        topRight:
                                                            Radius.circular(9),
                                                      ),
                                                      child: Image.network(
                                                        eventData[index]
                                                            .picture,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            3,
                                                        height: 80,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        } catch (e) {}
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                    ),
                                  ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.only(right: 12, left: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(33)),
                            ),
                            height: 5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                // Icon(Icons.home, color: Color(0xff434BE6),),
                                // Icon(Icons.notifications_active,
                                // color: Colors.grey.withOpacity(0.6)),
                                SizedBox(
                                  width: 33,
                                ),
                                // Icon(Icons.person,
                                //     color: Colors.grey.withOpacity(0.6)),
                              ],
                            ),
                          ),
                        ],
                      ));
                    })
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
