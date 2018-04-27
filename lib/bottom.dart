import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:github/ssutil_flutter.dart';

class GitHubBottomAppBar extends StatelessWidget {
  GitHubBottomAppBar({this.user, @required this.onLogin});

  final User user;
  final ContextCallback onLogin;

  Widget buildChild(BuildContext context) {
    if (user != null) {
      return new Padding(padding: const EdgeInsets.all(6.0), child: new Text(user.username));
    } else {
      return new Padding(padding: const EdgeInsets.all(6.0), child: new Text("Not logged in"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new BottomAppBar(child: buildChild(context));
  }
}
