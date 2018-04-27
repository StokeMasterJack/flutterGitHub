import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:github/repos.dart';
import 'package:github/users.dart';

class TabsPage extends StatelessWidget {
  final Future<List<User>> users;
  final Future<List<Repo>> repos;

  TabsPage({@required this.users, @required this.repos});

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
      length: 2,
      child: new Scaffold(
        appBar: new AppBar(
          bottom: new TabBar(
            tabs: [
              new Tab(text: "Repos"),
              new Tab(text: "Users"),
            ],
          ),
          title: new Text('GitHub'),
        ),
        body: new TabBarView(
          children: [new Repos(fRepos: repos), new Users(fUsers: users)],
        ),
      ),
    );
  }
}


class TabsApp extends StatelessWidget {
  final GitHub g = new GitHub();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(title: "GitHub", home: new TabsPage(users: g.fetchUsers(), repos: g.fetchAllRepos()));
  }

  static void run() {
    runApp(new TabsApp());
  }
}