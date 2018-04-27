import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:github/ssutil_flutter.dart';

class Users extends StatelessWidget {
  final Future<List<User>> fUsers;
  final OnSelected<User> onSelected;

  Users({@required this.fUsers, this.onSelected});

  @override
  Widget build(BuildContext context) {
    return new FutBuilder<List<User>>(
        future: fUsers,
        dataBuilder: (_, List<User> users) {
          return new ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              User user = users[index];
              return buildListItem(context, user);
            },
          );
        });
  }

  Widget buildListItem(BuildContext context, User user) {
    return new ListTile(
        leading: new CircleAvatar(child: new Text(user.username[0].toUpperCase())),
        title: new Text('${user.username}'),
        subtitle: new Text('Type: ${user.type}'),
        onTap: onSelected != null ? () => onSelected(context, user) : null);
  }
}

class UsersPage extends StatelessWidget {
  final Future<List<User>> fUsers;
  final OnSelected<User> onSelected;

  UsersPage({this.fUsers, this.onSelected}); //  final Future<List<User>> future;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: Text("Users"),
        ),
        body: new Users(fUsers: fUsers, onSelected: onSelected));
  }
}

class UsersApp extends StatelessWidget {
  final GitHub gitHub = new GitHub();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: "Users",
        home: new UsersPage(
            fUsers: gitHub.fetchUsers(),
            onSelected: (BuildContext context, User user) {
              print(user);
            }));
  }
}
