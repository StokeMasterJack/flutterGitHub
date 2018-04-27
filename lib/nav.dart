import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:github/repos.dart';
import 'package:github/users.dart';

const title = "GitHub";

class NavApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "NavApp",
      home: new NavPage(),
    );
  }
}

class NavPage extends StatelessWidget {
  final GitHub g = new GitHub();

  @override
  Widget build(BuildContext context) {
    UsersPage usersPage = new UsersPage(
        fUsers: g.fetchUsers(),
        onSelected: (BuildContext ctx,User u) {
          Widget nextPage = new ReposPage(fRepos: g.fetchReposForUser(u.username));
          Navigator.push(ctx, new MaterialPageRoute(builder: (ctx) => nextPage));
        });

    return usersPage;
  }
}
