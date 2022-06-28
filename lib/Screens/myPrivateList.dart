import 'package:assessment_task/Screens/home_screen.dart';
import 'package:assessment_task/Screens/privateForm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../bloc/app_cubit.dart';
import '../../bloc/app_state.dart';
import '../../constants/const_list.dart';
import '../../util/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'privateEventsInbox.dart';
import 'invite_list.dart';

class MyPrivateList extends StatefulWidget {
  const MyPrivateList({Key? key}) : super(key: key);

  @override
  _MyPrivateListState createState() => _MyPrivateListState();
}

class _MyPrivateListState extends State<MyPrivateList> {
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  final int _page = 2;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  String convertDateTimeDisplay(String date) {
    final DateFormat displayFormater = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
    final DateFormat serverFormater = DateFormat('dd-MM-yyyy   HH:mm');
    final DateTime displayDate = displayFormater.parse(date);
    final String formatted = serverFormater.format(displayDate);
    return formatted;
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
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    const storiesStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 20);

    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.9),
                spreadRadius: 10,
                blurRadius: 10,
                offset: Offset(9.0, 9.0)),
          ]),
          child: CurvedNavigationBar(
            key: _bottomNavigationKey,
            index: _page,
            height: 60.0,
            items: <Widget>[
              Icon(Icons.inbox_rounded, size: 35),
              Icon(Icons.add, size: 35),
              Icon(Icons.person_sharp, size: 35),
            ],
            color: Colors.white,
            buttonBackgroundColor: Colors.white,
            backgroundColor: Color(0xFF4B39EF),
            animationCurve: Curves.easeInOut,
            animationDuration: Duration(milliseconds: 400),
            onTap: (index) {
              switch (index) {
                case 1:
                  Get.off(() => PrivateCompleteForm());
                  break;
                case 0:
                  Get.off(() => PrivateList());
                  break;
              }
            },
            letIndexChange: (index) => true,
          ),
        ),
        backgroundColor: backgroundColor,
        appBar: appBar(padding),
        body: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: size.width,
            height: size.height * .9,
            decoration: ViewUtils.bodyDecoration(),
            child: BlocBuilder<AppCubit, AppState>(builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bodyMyPriEvents(),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  AppBar appBar(EdgeInsets padding) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.off(() => PrivateList()),
      ),
      backgroundColor: backgroundColor,
      flexibleSpace: Padding(
        padding: EdgeInsets.only(top: padding.top / 2, left: 7),
        child: _avatarAndDisplayName(),
      ),
      // actions: const [
      //   Icon(Icons.search, color: white),
      //   Icon(Icons.more_vert, color: white)
      // ],
      toolbarHeight: 70,
      elevation: 0,
    );
  }

  Widget bodyMyPriEvents() {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('PrivateEvents')
                    .where('Event Owner', isEqualTo: auth.currentUser?.uid)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return new ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: snapshot.data!.size,
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(
                        height: 10,
                      );
                    },
                    itemBuilder: (BuildContext context, int index1) {
                      try {
                        return Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 7,
                                color: Color(0x2F1D2429),
                                offset: Offset(0, 3),
                              )
                            ],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(10, 0, 10, 10),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Stack(children: [
                                  Align(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(0),
                                        bottomRight: Radius.circular(0),
                                        topLeft: Radius.circular(11),
                                        topRight: Radius.circular(11),
                                      ),
                                      child: Image.network(
                                        snapshot.data?.docs[index1]
                                            ['Event Image'],
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.1,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional(0.89, 0.84),
                                    child: CircleAvatar(
                                      radius: 20,
                                      backgroundColor:
                                          Colors.grey.withOpacity(0.8),
                                      child: IconButton(
                                        tooltip: 'delete',
                                        iconSize: 20,
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                          size: 23,
                                        ),
                                        onPressed: () {
                                          showDialog<String>(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                AlertDialog(
                                              title:
                                                  const Text('Deleting event:'),
                                              content: const Text(
                                                  'Are you sure that you want to delete this event?'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, 'Cancel'),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    try {
                                                      if ((FirebaseStorage
                                                              .instance
                                                              .refFromURL(snapshot
                                                                          .data
                                                                          ?.docs[
                                                                      index1][
                                                                  'Event Image'])) !=
                                                          null)
                                                        FirebaseStorage.instance
                                                            .refFromURL(snapshot
                                                                    .data
                                                                    ?.docs[index1]
                                                                ['Event Image'])
                                                            .delete();
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'PrivateEvents')
                                                          .doc(snapshot
                                                              .data
                                                              ?.docs[index1]
                                                              .reference
                                                              .id)
                                                          .collection('Members')
                                                          .where('id',
                                                              isNotEqualTo: '')
                                                          .get()
                                                          .then((value) => {
                                                                value.docs.forEach(
                                                                    (element) {
                                                                  FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'Users')
                                                                      .doc(element
                                                                              .data()[
                                                                          'id'])
                                                                      .collection(
                                                                          'Invites')
                                                                      .where(
                                                                          'id',
                                                                          isEqualTo: snapshot
                                                                              .data
                                                                              ?.docs[
                                                                                  index1]
                                                                              .reference
                                                                              .id)
                                                                      .get()
                                                                      .then(
                                                                          (value) =>
                                                                              {
                                                                                (value.docs[0].reference).delete(),
                                                                              });
                                                                }),
                                                              });
                                                      FirebaseFirestore.instance
                                                          .collection('Users')
                                                          .doc(auth
                                                              .currentUser?.uid)
                                                          .collection(
                                                              'PrivateEvents')
                                                          .where('EventDocId',
                                                              isEqualTo: snapshot
                                                                  .data
                                                                  ?.docs[index1]
                                                                  .reference
                                                                  .id)
                                                          .get()
                                                          .then((value) => {
                                                                (value.docs[0]
                                                                        .reference)
                                                                    .delete(),
                                                              });
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'PrivateEvents')
                                                          .doc(snapshot
                                                              .data
                                                              ?.docs[index1]
                                                              .reference
                                                              .id)
                                                          .delete();
                                                    } catch (e) {}
                                                    Navigator.pop(
                                                        context, 'Ok');
                                                  },
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ]),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      19, 8, 16, 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                        snapshot.data?.docs[index1]['Title'],
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          color: Color(0xFF090F13),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      19, 0, 50, 9),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            convertDateTimeDisplay(
                                                (snapshot.data?.docs[index1]
                                                        ['Date And Time'])!
                                                    .toDate()
                                                    .toString()),
                                            style: TextStyle(
                                              fontFamily: 'Lexend Deca',
                                              color: Color(0xFF39D2C0),
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          FutureBuilder(
                                              future: FirebaseFirestore.instance
                                                  .collection("PrivateEvents")
                                                  .doc(snapshot
                                                      .data?.docs[index1].id)
                                                  .collection('Members')
                                                  .where('acceptance',
                                                      isEqualTo: '1')
                                                  .get(),
                                              builder: (context,
                                                  AsyncSnapshot<QuerySnapshot>
                                                      snapshot1) {
                                                if (snapshot1.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return CircularProgressIndicator();
                                                }
                                                if (snapshot1.hasError) {
                                                  return CircularProgressIndicator();
                                                }
                                                return Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      WidgetSpan(
                                                        child: Tooltip(
                                                          message: 'People in',
                                                          child: Icon(
                                                              Icons
                                                                  .people_alt_rounded,
                                                              size: 20,
                                                              shadows: [
                                                                Shadow(
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.2),
                                                                  offset:
                                                                      Offset(
                                                                          1.0,
                                                                          1.0),
                                                                  blurRadius:
                                                                      1.0,
                                                                ),
                                                              ]),
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: (snapshot1
                                                                .data?.size)
                                                            .toString(),
                                                        style:
                                                            TextStyle(shadows: [
                                                          Shadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.5),
                                                            offset: Offset(
                                                                1.9, 1.5),
                                                            blurRadius: 1.0,
                                                          ),
                                                        ]),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      19, 0, 16, 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          snapshot.data?.docs[index1]
                                              ['description'],
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            color: Color(0xFF57636C),
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16, 0, 16, 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      ElevatedButton.icon(
                                        icon: Icon(
                                          Icons.location_pin,
                                          color: Colors.white,
                                          size: 24.0,
                                        ),
                                        label: Text('Event'),
                                        onPressed: () async {
                                          _launchURL(
                                              (snapshot
                                                      .data
                                                      ?.docs[index1]['Location']
                                                      .latitude)
                                                  .toString(),
                                              (snapshot
                                                      .data
                                                      ?.docs[index1]['Location']
                                                      .longitude)
                                                  .toString());
                                        },
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            8, 0, 0, 0),
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.deepPurple,
                                            //onPrimary: Colors.deepPurple,
                                            elevation: 10, // Elevation
                                            shadowColor: Colors
                                                .deepPurple, // Shadow Color
                                          ),
                                          icon: Icon(
                                            Icons.person_add_alt_1_rounded,
                                            color: Colors.white,
                                            size: 24.0,
                                          ),
                                          label: Text('Invite'),
                                          onPressed: () async {
                                            Get.to(() => InviteList(
                                                  docId: (snapshot.data
                                                          ?.docs[index1].id)
                                                      .toString(),
                                                ));
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } catch (e) {}
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );
                }),
          ],
        ),
      ),
    );
  }

  Widget _avatarAndDisplayName() {
    const contactNameStyle =
        TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: white);
    return Row(
      children: [
        Container(
          height: 50,
          width: 50,
          decoration: ViewUtils.displayAvatarDecoration(),
        ),
        const SizedBox(width: 5),
        const Text('your Private Events:', style: contactNameStyle),
      ],
    );
  }
}
