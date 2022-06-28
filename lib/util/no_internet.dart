import 'package:flutter/material.dart';

class NoINternet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 300,
              child: Image.asset("assets/no_internet.png"),
            ),
            SizedBox(height: 20),
            Text("Please Connect to internet",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
          ],
        ),
      ),
    );
  }
}