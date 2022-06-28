import 'package:country_code_picker/country_code_picker.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:assessment_task/util/hexcolor.dart';
import '../components/background.dart';
import 'login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  void initState() {
    super.initState();
  }

  String country = 'Jordan';
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordController2 = TextEditingController();
  late String fullName = '';
  late String phone = '';
  late String password = '';
  late String email = '';
  late String password1 = '';
  final FirebaseAuth auth = FirebaseAuth.instance;

  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    passwordController2.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    try {
      await auth
          .createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim())
          .then((value) async => {
                FirebaseFirestore.instance
                    .collection('Users')
                    .doc(value.user?.uid)
                    .set({
                  "email": emailController.text,
                  "Name": fullNameController.text,
                  "phone Number": phoneController.text,
                  "country": country
                }),
                FirebaseFirestore.instance
                    .collection('Users')
                    .doc(value.user?.uid)
                    .collection("PublicEvents")
                    .add({}),
                FirebaseFirestore.instance
                    .collection('Users')
                    .doc(value.user?.uid)
                    .collection("PrivateEvents")
                    .add({}),
                FirebaseFirestore.instance
                    .collection('Users')
                    .doc(value.user?.uid)
                    .collection("Invites")
                    .add({}),
                FirebaseFirestore.instance
                    .collection('Users')
                    .doc(value.user?.uid)
                    .collection("Friends")
                    .add({}),
                FirebaseFirestore.instance
                    .collection('Users')
                    .doc(value.user?.uid)
                    .collection("Events")
                    .add({}),
                Get.off(LoginScreen()),
                Get.defaultDialog(
                    title: 'Successfully registered',
                    middleText: 'You can log In now!'),
                dispose(),
              });
    } on FirebaseAuthException catch (e) {
      late String errorMessage = e.toString();
      late String errormsg;
      switch (errorMessage) {
        case "[firebase_auth/unknown] Given String is empty or null":
          {
            errormsg = "please fill all the blanks.";
          }
          break;

        case "[firebase_auth/email-already-in-use] The email address is already in use by another account.":
          {
            errormsg = "The email address is already in use.";
          }
          break;

        case "[firebase_auth/invalid-email] The email address is badly formatted.":
          {
            errormsg = "please write your email correctly";
          }
          break;

        default:
          {
            errormsg = errorMessage;
          }
          break;
      }
      print(e);
      AlertDialog alert = AlertDialog(
        title: Text('Error'),
        content: Text('$errormsg'),
        actions: <Widget>[
          FlatButton(
              child: Text('ok'),
              onPressed: () {
                Navigator.of(context).pop();
              }),
        ],
      );
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          });
    }
  }

  Future<void> validation() async {
    if (!(fullNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        passwordController2.text.isEmpty ||
        phoneController.text.isEmpty)) {
      final bool isValid = EmailValidator.validate(emailController.text);
      if (isValid != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: const Text("Please enter a valid email address"),
            duration: const Duration(milliseconds: 600),
          ),
        );
      } else if ((passwordController.text).length.isLowerThan(8)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enter valid password'),
            duration: const Duration(milliseconds: 600),
          ),
        );
      } else if (passwordController.text != passwordController2.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: const Text("Please write the same password"),
            duration: Duration(milliseconds: 600),
          ),
        );
      } else {
        try {
          signUp();
        } catch (e) {
          late String errorMessage = e.toString();
          print(e);
          AlertDialog alert = AlertDialog(
            title: const Text('Error'),
            content: Text(errorMessage),
            actions: <Widget>[
              FlatButton(
                  child: const Text('ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ],
          );
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return alert;
              });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: const Text("Please fill all the blanks!"),
          duration: Duration(milliseconds: 700),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Background(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(5, 20, 20, 20),
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: Text(
                  "REGISTER",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2661FA),
                      fontSize: 36),
                  textAlign: TextAlign.left,
                ),
              ),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "Name",
                    labelStyle: TextStyle(
                        color: Colors.black87,
                        fontStyle: FontStyle.italic,
                        fontSize: 15),
                  ),
                  onChanged: (value) {
                    fullName = value;
                  },
                  controller: fullNameController,
                  maxLength: 20,
                ),
              ),
              SizedBox(height: size.height * 0.03),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(
                        color: Colors.black87,
                        fontStyle: FontStyle.italic,
                        fontSize: 15),
                  ),
                  onChanged: (value) {
                    email = value;
                  },
                  controller: emailController,
                ),
              ),
              SizedBox(height: size.height * 0.03),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      "           Phone Number:",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 60,
                          child: CountryCodePicker(
                            onChanged: (value) {
                              country = value.name!;
                            },
                            hideMainText: true,
                            showFlagMain: true,
                            showFlag: true,
                            initialSelection: 'JO',
                            hideSearch: false,
                            showCountryOnly: false,
                            showOnlyCountryWhenClosed: true,
                            alignLeft: true,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 15, 5, 5),
                          child: SizedBox(
                            width: 200,
                            height: 60,
                            child: TextField(
                              onChanged: (value) {
                                phone = value;
                              },
                              keyboardType: TextInputType.number,
                              maxLength: 12,
                              controller: phoneController,
                              obscureText: false,
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        width: 2, color: Colors.blue),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  fillColor: const Color(0xfff3f3f4),
                                  filled: true),
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.03),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(
                        color: Colors.black87,
                        fontStyle: FontStyle.italic,
                        fontSize: 15),
                  ),
                  onChanged: (value) {
                    password = value;
                  },
                  controller: passwordController,
                  obscureText: true,
                ),
              ),
              SizedBox(height: size.height * 0.05),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "confirm your password",
                    labelStyle: TextStyle(
                        color: Colors.black87,
                        fontStyle: FontStyle.italic,
                        fontSize: 15),
                  ),
                  onChanged: (value) {
                    password1 = value;
                  },
                  controller: passwordController2,
                  obscureText: true,
                ),
              ),
              SizedBox(height: size.height * 0.05),
              Container(
                alignment: Alignment.centerRight,
                margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: RaisedButton(
                  onPressed: () {
                    validation();
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80.0)),
                  textColor: Colors.white,
                  padding: const EdgeInsets.all(0),
                  child: Container(
                    alignment: Alignment.center,
                    height: 50.0,
                    width: size.width * 0.5,
                    decoration: new BoxDecoration(
                        borderRadius: BorderRadius.circular(80.0),
                        gradient: new LinearGradient(colors: [
                          Color.fromARGB(255, 255, 136, 34),
                          Color.fromARGB(255, 255, 177, 41)
                        ])),
                    padding: const EdgeInsets.all(0),
                    child: Text(
                      "SIGN UP",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: GestureDetector(
                  onTap: () => {
                    Get.off(LoginScreen()),
                  },
                  child: Text(
                    "Already Have an Account? Sign in",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
