import 'package:flutter/material.dart';
import '../components/friend_components/body_friends.dart';
import '../constants/const_list.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage>
    with TickerProviderStateMixin {
  var _currentIndex = 0;
  bool result = true;
  Animation<double>? _myAnimation;
  AnimationController? _controller;
  PageController? controller;
  final menuStyle = const TextStyle(color: white);
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    controller = PageController(initialPage: 0);

    _myAnimation = CurvedAnimation(curve: Curves.linear, parent: _controller!);
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  final list = [const BodyFriends()];

  void _changeIndex(int value) => setState(() => _currentIndex = value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
          onPageChanged: (value) => _changeIndex(value),
          children: [list.elementAt(_currentIndex)]),
    );
  }
}
