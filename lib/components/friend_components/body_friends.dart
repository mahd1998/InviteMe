import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../Screens/requests_list.dart';
import '../../bloc/app_cubit.dart';
import '../../bloc/app_state.dart';
import '../../constants/const_list.dart';
import '../../util/utils.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BodyFriends extends StatefulWidget {
  const BodyFriends({Key? key}) : super(key: key);

  @override
  _BodyFriendsState createState() => _BodyFriendsState();
}

class _BodyFriendsState extends State<BodyFriends> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth auth = FirebaseAuth.instance;

  int size = 0;
  @override
  void initState() {
    super.initState();
  }

  void sendPushMessage(String body, String title, String token) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAYsWQgbk:APA91bGvIF2HEcTCaEfCc0bMH58zt0ztRdebmgKmO7_3IqM7igJsFMlf5A4X3belonz7goEf4juK9OkR1v-0816pGsZQGwyzWvUA5S2t0zuybkTa1WUG5qejXckBNtB1SrLxm9Fo4S6F',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": token,
          },
        ),
      );
      print('done');
    } catch (e) {
      print("error push notification");
    }
  }

  TextEditingController phoneNumber = TextEditingController();
  Future<void> notiy() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(auth.currentUser?.uid)
        .collection('Friends')
        .where('acceptance', isEqualTo: '0')
        .get()
        .then((value) => {
              if (mounted)
                {
                  setState(() {
                    size = value.size;
                  }),
                }
            });
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            title: Text('Add by phone Number'),
            content: TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {});
              },
              controller: phoneNumber,
              decoration: InputDecoration(hintText: "phoneNumber"),
            ),
            actions: <Widget>[
              FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0))),
                color: Colors.green,
                textColor: Colors.white,
                child: Text('Add'),
                onPressed: () {
                  const snackBar = SnackBar(
                    content: Text('Add has been Sent!'),
                  );
                  FirebaseFirestore.instance
                      .collection('Users')
                      .where('phone Number', isEqualTo: phoneNumber.text)
                      .get()
                      .then((value) => {
                            if (value.docs.first.id != auth.currentUser?.uid)
                              {
                                FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(value.docs.first.id)
                                    .collection('Friends')
                                    .where('id',
                                        isEqualTo: auth.currentUser?.uid)
                                    .get()
                                    .then((exist) => {
                                          if (exist.docs.isEmpty)
                                            {
                                              FirebaseFirestore.instance
                                                  .collection('Users')
                                                  .doc(value.docs.first.id)
                                                  .collection("Friends")
                                                  .add({
                                                'id': auth.currentUser?.uid,
                                                'acceptance': '0',
                                              }),
                                              FirebaseFirestore.instance
                                                  .collection('Users')
                                                  .doc(value.docs.first.id)
                                                  .get()
                                                  .then((friendDoc) => {
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('Users')
                                                            .doc(auth
                                                                .currentUser
                                                                ?.uid)
                                                            .get()
                                                            .then((myDoc) => {
                                                                  sendPushMessage(
                                                                      'You have a friend Request from ${myDoc['Name']}',
                                                                      'Friend request',
                                                                      friendDoc[
                                                                          'token'])
                                                                })
                                                      }),
                                            }
                                          else
                                            {
                                              ScaffoldMessenger.of(this.context)
                                                  .showSnackBar(snackBar),
                                            },
                                        }),
                              }
                            else
                              {
                                Get.snackbar(
                                    'Sorry!', 'You can\'t add your self.')
                              }
                          })
                      .catchError((e) {
                    Get.snackbar('Sorry!', 'Number not found.');
                  });
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    const storiesStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 20);
    notiy();
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
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
                padding: const EdgeInsets.only(left: 15, top: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Friends', style: storiesStyle),
                    bodyChats(),
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
      backgroundColor: backgroundColor,
      flexibleSpace: Padding(
        padding: EdgeInsets.only(top: padding.top / 2, left: 7),
        child: _avatarAndDisplayName(),
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              onPressed: () {
                _displayTextInputDialog(context);
              },
              icon: Icon(Icons.person_add),
            )
          ],
        ),
        Stack(
          children: [
            IconButton(
              onPressed: () {
                Get.to(() => RequestsPage());
              },
              icon: Icon(Icons.notification_add),
            ),
            if (size != 0)
              Positioned(
                right: MediaQuery.of(context).size.width / 15,
                top: MediaQuery.of(context).size.width / 26,
                child: Container(
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                  width: 10,
                  height: 10,
                ),
              )
          ],
        )
      ],
      toolbarHeight: 70,
      elevation: 0,
    );
  }

  Widget bodyChats() {
    return Expanded(
      child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .doc(auth.currentUser?.uid)
              .collection('Friends')
              .where('acceptance', isEqualTo: '1')
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: snapshot.data?.size,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Users')
                        .doc(snapshot.data?.docs[index]['id'])
                        .snapshots(),
                    builder:
                        (context, AsyncSnapshot<DocumentSnapshot> snapshot1) {
                      if (!snapshot1.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return ListTile(
                        contentPadding: const EdgeInsets.only(right: 10),
                        title: Text(snapshot1.data?['Name']),
                        subtitle: Text(snapshot1.data?['phone Number']),
                        leading: CircleAvatar(
                          backgroundImage: AssetImage("assets/user1.png"),
                        ),
                        trailing: IconButton(
                          onPressed: () {
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text('Deleting user:'),
                                content: const Text(
                                    'Are you sure that you want to delete this user?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'Cancel'),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      try {
                                        FirebaseFirestore.instance
                                            .collection('Users')
                                            .doc(auth.currentUser?.uid)
                                            .collection('Friends')
                                            .doc(snapshot
                                                .data?.docs[index].reference.id)
                                            .delete();
                                        FirebaseFirestore.instance
                                            .collection('Users')
                                            .doc(snapshot.data?.docs[index]
                                                ['id'])
                                            .collection('Friends')
                                            .where('id',
                                                isEqualTo:
                                                    auth.currentUser?.uid)
                                            .get()
                                            .then((value) => {
                                                  (value.docs[0].reference)
                                                      .delete(),
                                                });
                                        setState(() {});
                                      } catch (e) {}
                                      Navigator.pop(context, 'Ok');
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const FaIcon(
                            FontAwesomeIcons.trash,
                            size: 20,
                          ),
                        ),
                      );
                    });
              },
            );
          }),
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
        const Text('InviteMe', style: contactNameStyle),
      ],
    );
  }
}
