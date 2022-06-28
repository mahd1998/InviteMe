import 'dart:async';
import 'package:assessment_task/Screens/privateEventsInbox.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'maps.dart';
import 'package:path/path.dart';
import 'package:assessment_task/components/globals.dart' as globals;

import 'myPrivateList.dart';

class PrivateForm extends StatefulWidget {
  const PrivateForm({Key? key}) : super(key: key);

  @override
  State<PrivateForm> createState() => _PrivateFormState();
}

class _PrivateFormState extends State<PrivateForm> {
  late StreamSubscription<User?> user;
  @override
  void initState() {
    initState();
    user = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter FormBuilder',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        FormBuilderLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: FormBuilderLocalizations.delegate.supportedLocales,
      home: const PrivateCompleteForm(),
    );
  }
}

class PrivateCompleteForm extends StatefulWidget {
  const PrivateCompleteForm({Key? key}) : super(key: key);

  @override
  PrivateCompleteFormState createState() {
    return PrivateCompleteFormState();
  }
}

class PrivateCompleteFormState extends State<PrivateCompleteForm> {
  FirebaseStorage storage = FirebaseStorage.instance;
  String imageUrl = '';
  final FirebaseAuth auth = FirebaseAuth.instance;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 480,
        maxWidth: 640,
      );
      if (image == null) return;

      final imageTemp = File(image.path);

      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future pickImageC() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxHeight: 480,
        maxWidth: 640,
      );

      if (image == null) return;

      final imageTemp = File(image.path);

      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  File? image;
  bool autoValidate = true;
  bool readOnly = false;
  bool showSegmentedControl = true;
  final _formKey = GlobalKey<FormBuilderState>();
  bool _ageHasError = false;
  bool _genderHasError = false;
  TextEditingController descrptionController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  DateTime date = DateTime.now();
  void _onChanged(dynamic val) => debugPrint(val.toString());

  Future uploadFile() async {
    final _firebaseStorage = FirebaseStorage.instance;
    if (image == null) return;
    final fileName = basename(image!.path);
    final destination = 'files/$fileName';
    try {
      final ref = _firebaseStorage.ref(destination).child('file/');
      await ref.putFile(image!);
      var downloadUrl = await ref.getDownloadURL();
      setState(() {
        imageUrl = downloadUrl;
      });
    } catch (e) {
      print('error occured');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.9),
              spreadRadius: 12,
              blurRadius: 12,
              offset: Offset(9.0, 9.0)),
        ]),
        child: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: 1,
          height: 60.0,
          items: <Widget>[
            Icon(Icons.inbox_rounded, size: 30),
            Icon(Icons.add, size: 30),
            Icon(Icons.person_sharp, size: 30),
          ],
          color: Colors.white,
          buttonBackgroundColor: Colors.white,
          backgroundColor: Color(0xFF4B39EF),
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 200),
          onTap: (index) {
            switch (index) {
              case 0:
                Get.off(() => PrivateList());
                break;
              case 2:
                Get.off(() => MyPrivateList());
                break;
            }
          },
          letIndexChange: (index) => true,
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.off(() => PrivateList()),
        ),
        title: const Text('Create Private Event'),
        backgroundColor: Color(0xFF4B39EF).withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.deepPurple, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                FormBuilder(
                  key: _formKey,
                  // enabled: false,
                  onChanged: () {
                    _formKey.currentState!.save();
                    debugPrint(_formKey.currentState!.value.toString());
                  },
                  autovalidateMode: AutovalidateMode.disabled,
                  skipDisabled: true,
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25.0),
                          child: image != null
                              ? Image.file(
                                  image!,
                                  fit: BoxFit.fill,
                                )
                              : Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      100.0, 140.0, 0.0, 0.0),
                                  child: Text(
                                    "No image selected",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ),
                        ),
                        width: MediaQuery.of(context).size.width / 1,
                        height: 250.0,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          MaterialButton(
                              color: Color(0xff7252E7),
                              child: const Text("Pick from Gallery",
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold)),
                              onPressed: () {
                                pickImage();
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                              }),
                          const SizedBox(
                            width: 20,
                          ),
                          MaterialButton(
                              color: Color(0xff7252E7),
                              child: const Text("     Take Picture   ",
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold)),
                              onPressed: () {
                                pickImageC();
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                              }),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          child: Text(
                            "Title:- ",
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextField(
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1,
                              color: Colors.deepPurple, //this has no effect
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText: "Event Title...",
                        ),
                        controller: titleController,
                        maxLength: 20,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          child: Text(
                            "Descrption:- ",
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextField(
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1,
                              color: Colors.deepPurple, //this has no effect
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText: "Write here...",
                        ),
                        controller: descrptionController,
                        maxLines: 3,
                        maxLength: 240,
                      ),
                      const SizedBox(height: 10),
                      FormBuilderDateTimePicker(
                        name: 'date',
                        initialEntryMode: DatePickerEntryMode.calendar,
                        initialValue: DateTime.now(),
                        inputType: InputType.both,
                        decoration: InputDecoration(
                          labelText: 'Appointment Time:-',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _formKey.currentState!.fields['date']
                                  ?.didChange(null);
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                              date = _formKey.currentState!.value['date'];
                            },
                          ),
                        ),
                        initialTime: const TimeOfDay(hour: 8, minute: 0),
                        // locale: const Locale.fromSubtags(languageCode: 'fr'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 24.0,
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MapSample()));
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Color(0xff7252E7)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Color(0xff7252E7))))),
                  label: const Text(
                    'Location',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!(descrptionController.text.isEmpty ||
                              titleController.text.isEmpty ||
                              globals.location ==
                                  LatLng(0.000000000, 0.000000000) ||
                              image.isNull ||
                              _formKey.currentState!.fields['date'].isNull)) {
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text('loading:'),
                                content: Text('Publishing...'),
                              ),
                            );
                            uploadFile()
                                .whenComplete(() async => {
                                      FirebaseFirestore.instance
                                          .collection('PrivateEvents')
                                          .add({
                                        "Event Owner": auth.currentUser?.uid,
                                        "Event Image": imageUrl,
                                        "Title": titleController.text,
                                        "description":
                                            descrptionController.text,
                                        "Location": GeoPoint(
                                            globals.location.latitude,
                                            globals.location.longitude),
                                        "Date And Time": _formKey
                                            .currentState?.value['date'],
                                      }).then((docRef) {
                                        FirebaseFirestore.instance
                                            .collection('Users')
                                            .doc(auth.currentUser?.uid)
                                            .collection('PrivateEvents')
                                            .add({'EventDocId': docRef.id});
                                        FirebaseFirestore.instance
                                            .collection('PrivateEvents')
                                            .doc(docRef.id)
                                            .collection('Members')
                                            .add({});
                                      }),
                                    })
                                .whenComplete(() => {
                                      Get.off(() => MyPrivateList()),
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: const Text(
                                              "Event has been published"),
                                          duration:
                                              Duration(milliseconds: 1000),
                                        ),
                                      )
                                    });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    const Text("Please fill all informations"),
                                duration: Duration(milliseconds: 1000),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Color(0xff7252E7)),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3.0),
                                    side:
                                        BorderSide(color: Color(0xff7252E7))))),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
