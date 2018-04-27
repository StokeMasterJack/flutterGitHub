import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:github/bottom.dart';
import 'package:github/drawer.dart';
import 'package:github/github.dart';
import 'package:github/home.dart';
import 'package:github/login.dart';
import 'package:github/repos.dart';
import 'package:github/search.dart';
import 'package:github/ssutil_flutter.dart';
import 'package:github/users.dart';
import 'package:url_launcher/url_launcher.dart';

class GitHubApp extends StatefulWidget {
  @override
  _GitHubAppState createState() {
    return new _GitHubAppState();
  }
}

class _GitHubAppState extends State<GitHubApp> {
  final GitHub gitHub = new GitHub();

  void onSearchRepos(BuildContext context) async {
    SearchReposPage nextPage = new SearchReposPage(
        gitHub: gitHub,
        onSelected: (_, Repo repo) {
          launch('https://github.com/${repo.owner}/${repo.name}');
        });
    final Route route = new MaterialPageRoute(builder: (context) => nextPage);
    Navigator.push(context, route);
  }

  void onRepos(BuildContext context) async {
    ReposPage reposPage = new ReposPage(
        fRepos: gitHub.fetchAllRepos(),
        onSelected: (BuildContext ctx, Repo repo) {
          snack(ctx, "Repo [${repo.name}] Selected");
        });
    final Route route = new MaterialPageRoute(builder: (context) => reposPage);
    Navigator.push(context, route);
  }

  void onUsers(BuildContext context) async {
    UsersPage usersPage = new UsersPage(
        fUsers: gitHub.fetchUsers(),
        onSelected: (BuildContext ctx, User user) {
          var route = new MaterialPageRoute(
              builder: (ctx) =>
                  new ReposPage(title: "Repos for ${user.username}", fRepos: gitHub.fetchReposForUser(user.username)));
          Navigator.push(ctx, route);
        });
    Navigator.push(context, new MaterialPageRoute(builder: (context) => usersPage));
  }

  void onLogin(BuildContext context) async {
    LoginPage nextPage = new LoginPage(
      loginService: gitHub.login,
      cachedLogin: gitHub.cachedLogin,
    );

    final Route<User> route = new MaterialPageRoute<User>(builder: (context) => nextPage);
    final User user = await Navigator.push(context, route);

    setState(() {
      if (user != null) {
        this.gitHub.loginSuccess(user);
      } else {
        this.gitHub.loginFail();
      }
    });
  }

  void onLogout(BuildContext context) {
    setState(() {
      this.gitHub.logout();
    });
  }

  void onSetCachedCreds(BuildContext context) {
    setState(() {
      gitHub.setCachedLoginToDave();
    });
  }

  void onClearCachedCreds(BuildContext context) {
    setState(() {
      gitHub.clearCachedLogin();
    });
  }

  void onMyRepos(BuildContext context) async {
    if (!gitHub.isLoggedIn()) {
      snack(context, "Must be logged in to perform this operation");
    } else {
      ReposPage nextPage = new ReposPage(
          title: "My Repos",
          fRepos: gitHub.fetchMyRepos(),
          onSelected: (_, Repo repo) {
            print(111);
          });
      final Route<User> route = new MaterialPageRoute<User>(builder: (context) => nextPage);
      Navigator.push(context, route);
    }
  }

  GitHubDrawer mkDrawer() {
    return new GitHubDrawer(items: buildItems());
  }

  Widget mkBottom() {
    return new GitHubBottomAppBar(user: gitHub.user, onLogin: this.onLogin);
  }

  @override
  Widget build(BuildContext context) {
    Widget home = new HomePage(user: this.gitHub.user, drawer: mkDrawer(), bottom: mkBottom(), items: buildItems());

    MaterialApp materialApp = new MaterialApp(
        title: "GitHub",
        theme: new ThemeData(
          brightness: Brightness.light,
        ),
        home: home);

    return materialApp;
  }

  List<Item> buildItems() {
    bool loggedIn = gitHub.isLoggedIn();
    List<Item> items = <Item>[
      new Item(title: "Repos", action: this.onRepos),
      new Item(title: "Users", action: this.onUsers),
      new Item(title: "Search Repos", action: this.onSearchRepos),
      new Item(title: "Reset Cached Credentials", action: this.onSetCachedCreds),
      new Item(title: "Clear Cached Credentials", action: this.onClearCachedCreds),
      loggedIn ? new Item(title: "Logout", action: this.onLogout) : new Item(title: "Login", action: this.onLogin),
    ];

    if (gitHub.isLoggedIn()) {
      items.add(new Item(title: "My Repos", action: this.onMyRepos));
    }

    return items;
  }
}

class Item extends StatelessWidget {
  final String title;
  final String subtitle;
  final ContextCallback action;
  final Icon icon;

  Item(
      {@required this.title,
      this.subtitle = "Dave is a very good man",
      @required this.action,
      this.icon: const Icon(Icons.toys)});

  @override
  Widget build(BuildContext context) {
    return new ListTile(
        leading: icon,
        title: new Text(title),
        subtitle: new Text(subtitle),
        onTap: () {
          action(context);
        });
  }
}
