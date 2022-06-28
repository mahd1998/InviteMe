import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../bloc/app_cubit.dart';
import '../../bloc/app_state.dart';
import '../../constants/const_list.dart';
import '../../util/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BodyRequests extends StatefulWidget {
  const BodyRequests({Key? key}) : super(key: key);

  @override
  _BodyRequestsState createState() => _BodyRequestsState();
}

class _BodyRequestsState extends State<BodyRequests> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  final FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController phoneNumber = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    const storiesStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 20);

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
                    const Text('Friend Requests', style: storiesStyle),
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
              .where('acceptance', isEqualTo: '0')
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FlatButton(
                                color: Colors.red,
                                textColor: Colors.white,
                                child: Text(
                                  'Decline',
                                ),
                                onPressed: () {
                                  try {
                                    FirebaseFirestore.instance
                                        .collection('Users')
                                        .doc(auth.currentUser?.uid)
                                        .collection('Friends')
                                        .doc(snapshot
                                            .data?.docs[index].reference.id)
                                        .delete();
                                    setState(() {});
                                  } catch (e) {}
                                }),
                            FlatButton(
                                color: Colors.green,
                                textColor: Colors.white,
                                child: Text(
                                  'Accept',
                                ),
                                onPressed: () async {
                                  try {
                                    FirebaseFirestore.instance
                                        .collection('Users')
                                        .doc(auth.currentUser?.uid)
                                        .collection('Friends')
                                        .doc(snapshot
                                            .data?.docs[index].reference.id)
                                        .update({'acceptance': '1'});
                                    FirebaseFirestore.instance
                                        .collection('Users')
                                        .doc(snapshot.data?.docs[index]['id'])
                                        .collection('Friends')
                                        .add({
                                      'id': auth.currentUser?.uid,
                                      'acceptance': '1',
                                    });
                                    setState(() {});
                                  } catch (e) {}
                                }),
                          ],
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
