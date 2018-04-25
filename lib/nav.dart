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
      home: new NavRoot(),
    );
  }
}

class NavRoot extends StatelessWidget {
  final GitHub g = new GitHub();

  @override
  Widget build(BuildContext context) {
    UsersPage usersPage = new UsersPage(
        future: g.fetchUsers(),
        onUserTap: (User u) {
          Widget nextPage = new ReposPage(fRepos: g.fetchReposForUser(u.login));
          Navigator.push(context, new MaterialPageRoute(builder: (context) => nextPage));
        });

    return usersPage;
  }
}
