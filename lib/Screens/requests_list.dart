import 'package:flutter/material.dart';
import '../components/friend_components/body_requests.dart';
import '../constants/const_list.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({Key? key}) : super(key: key);

  @override
  _RequestsPageState createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage>
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

  _onTap() async {
    if (result) {
      _controller!.forward();
      await showMenu(
        context: context,
        color: backgroundColor,
        position: const RelativeRect.fromLTRB(80.0, 450.0, 190.0, 120),
        items: [
          PopupMenuItem(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                    title: Text('Chat', style: menuStyle),
                    leading: const Icon(Icons.chat, color: white)),
              ],
            ),
          ),
        ],
      );
    } else {
      _controller!.reverse();
    }
    result = !result;
  }

  final list = [const BodyRequests()];

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
