import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class InviteList extends StatefulWidget {
  const InviteList({Key? key, required this.docId}) : super(key: key);
  final String docId;
  @override
  _InviteListState createState() => _InviteListState();
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

class _InviteListState extends State<InviteList> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController phoneNumber = TextEditingController();
  String doc = '';
  @override
  void initState() {
    super.initState();
    doc = widget.docId;
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
                                              })
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
    String title = '';
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xff7252E7),
        automaticallyImplyLeading: true,
        title: Text(
          'Invite your friends to:',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontSize: 22,
          ),
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
        ],
        centerTitle: false,
        elevation: 2,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Align(
                alignment: AlignmentDirectional(0, 0),
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    shape: BoxShape.rectangle,
                  ),
                  child: FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('PrivateEvents')
                          .doc(doc)
                          .get(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot2) {
                        if (!snapshot2.hasData) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        title = snapshot2.data?['Title'];
                        return Stack(
                          children: [
                            Align(
                              alignment: AlignmentDirectional(0, 0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(0),
                                  bottomRight: Radius.circular(0),
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                                child: Image.network(
                                  snapshot2.data?['Event Image'],
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional(-0.93, 0.84),
                              child: Text(
                                snapshot2.data?['Title'],
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Color(0xFFBDBCBF),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                ),
              ),
              SizedBox(height: 12),
              Align(
                alignment: AlignmentDirectional(-0.95, 0),
                child: Text(
                  'Invite your friends:-',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.black,
                    fontSize: 22,
                  ),
                ),
              ),
              Expanded(
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
                      return Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(17, 5, 17, 17),
                        child: ListView.builder(
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
                                builder: (context,
                                    AsyncSnapshot<DocumentSnapshot> snapshot1) {
                                  if (!snapshot1.hasData) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  return ListTile(
                                      contentPadding:
                                          const EdgeInsets.only(right: 10),
                                      title: Text(snapshot1.data?['Name']),
                                      subtitle:
                                          Text(snapshot1.data?['phone Number']),
                                      leading: CircleAvatar(
                                        backgroundImage:
                                            AssetImage("assets/user1.png"),
                                      ),
                                      trailing: TextButton.icon(
                                        onPressed: () async {
                                          try {
                                            await FirebaseFirestore.instance
                                                .collection('PrivateEvents')
                                                .doc(doc)
                                                .collection('Members')
                                                .where('id',
                                                    isEqualTo: snapshot.data
                                                        ?.docs[index]['id'])
                                                .get()
                                                .then((value) async => {
                                                      if (value.docs.isEmpty)
                                                        {
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'PrivateEvents')
                                                              .doc(doc)
                                                              .collection(
                                                                  'Members')
                                                              .add({
                                                            'id': snapshot
                                                                    .data?.docs[
                                                                index]['id'],
                                                            'acceptance': '0'
                                                          })
                                                        }
                                                    })
                                                .whenComplete(() async => {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('Users')
                                                          .doc(snapshot.data
                                                                  ?.docs[index]
                                                              ['id'])
                                                          .collection('Invites')
                                                          .where('id',
                                                              isEqualTo: doc)
                                                          .get()
                                                          .then(
                                                              (value) async => {
                                                                    if (value
                                                                        .docs
                                                                        .isEmpty)
                                                                      {
                                                                        await FirebaseFirestore
                                                                            .instance
                                                                            .collection(
                                                                                'Users')
                                                                            .doc(snapshot.data?.docs[index][
                                                                                'id'])
                                                                            .collection(
                                                                                'Invites')
                                                                            .add({
                                                                          'id':
                                                                              doc
                                                                        }),
                                                                        sendPushMessage(
                                                                            title,
                                                                            'you have invite to',
                                                                            snapshot1.data?['token'])
                                                                      }
                                                                    else
                                                                      {
                                                                        Get.defaultDialog(
                                                                            title:
                                                                                'already Invited',
                                                                            middleText:
                                                                                'Invite already sent')
                                                                      }
                                                                  }),
                                                    });
                                          } catch (e) {}
                                        },
                                        icon: Icon(
                                          Icons.person_add_alt_1_rounded,
                                          color: Color(0xff7252E7),
                                        ),
                                        label: Text(
                                          "Invite",
                                          style: TextStyle(
                                              color: Color(0xff7252E7)),
                                        ),
                                      ));
                                });
                          },
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
