import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:github/ssutil_flutter.dart';

typedef void OnUserTap(User user);

class Users extends StatelessWidget {
  final Future<List<User>> future;
  final OnUserTap onUserTap;

  Users({@required this.future, this.onUserTap});

  @override
  Widget build(BuildContext context) {
    return new FutBuilder<List<User>>(
        future: future,
        builder: (List<User> users) {
          return new ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              User user = users[index];
              return buildListItem(user);
            },
          );
        });
  }

  Widget buildListItem(User user) {
    return new ListTile(
      leading: new CircleAvatar(child: new Text(user.login[0].toUpperCase())),
      title: new Text('${user.login}'),
      subtitle: new Text('Type: ${user.type}'),
      isThreeLine: true,
      onTap: () {
        if (onUserTap != null) onUserTap(user);
      },
    );
  }
}

class UsersPage extends StatelessWidget {
  final Future<List<User>> future;
  final OnUserTap onUserTap;

  UsersPage({@required this.future, this.onUserTap});

  void _onUserTap(User u) {
    if (onUserTap != null) onUserTap(u);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: Text("Users"),
        ),
        body: new Users(future: future, onUserTap: _onUserTap));
  }
}

class UsersApp extends StatelessWidget {
  final GitHub g = new GitHub();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: "Users",
        home: new UsersPage(
            future: g.fetchUsers(),
            onUserTap: (User user) {
              print(user);
            }));
  }
}
