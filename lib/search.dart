import 'dart:async';

import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:github/repos.dart';
import 'package:github/ssutil.dart' as ss;

class SearchReposApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(title: "GitHub", home: new SearchReposPage());
  }
}

class SearchReposPage extends StatefulWidget {
  final GitHub g = new GitHub();

  SearchReposPage() {
    g.logging = false;
    g.loginDave();
  }

  @override
  State createState() => new _SearchReposPageState();
}

class _SearchReposPageState extends State<SearchReposPage> {
  Future<List<Repo>> fRepos;
  bool searchMode = false;
  TextEditingController controller;
  String query;

  @override
  void initState() {
    super.initState();
    controller = new TextEditingController();
    fRepos = widget.g.fetchAllRepos();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      drawer: mkDrawer(),
      appBar: mkAppBar(),
      body: new Repos(fRepos: fRepos),
    );
  }

  bool isTextFieldEmpty() {
    if (controller.text == null) {
      return true;
    } else if (ss.isMissing(controller.text)) {
      return true;
    } else
      return false;
  }

  TextField mkSearchTextField() {
    return new TextField(
        controller: this.controller,
        onChanged: (String q) {
          setState(() {});
        },
        autofocus: true,
        onSubmitted: (String q) {
          setState(() {
            this.query = ss.nullNormalize(q);
            this.fRepos = widget.g.fetchReposList(q);
            searchMode = false;
            this.controller.clear();
          });
        },
        decoration: new InputDecoration(
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
            border: InputBorder.none,
            hintText: 'Search Repos'));
  }

  static const String baseTitle = "Repos";

  String computeTitle() {
    String qq = ss.nullNormalize(this.query);
    if (qq == null) {
      return baseTitle;
    } else {
      return "$baseTitle [$qq]";
    }
  }

  Widget mkAppBar() {
    if (!searchMode) {
      return new AppBar(
        title: new Text(computeTitle()),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.search),
            onPressed: () {
              setState(() {
                controller.clear();
                searchMode = true;
              });
            },
          )
        ],
      );
    } else {
      return new AppBar(
          leading: new IconButton(
              icon: const BackButtonIcon(),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () {
                setState(() {
                  searchMode = false;
                });
              }),
          title: mkSearchTextField(),
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          actions: isTextFieldEmpty()
              ? []
              : [
                  new IconButton(
                    icon: new Icon(
                      Icons.cancel,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        controller.clear();
                      });
                    },
                  )
                ]);
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    controller.dispose();
    super.dispose();
  }
}

Drawer mkDrawer() {
  return new Drawer(
    // Add a ListView to the drawer. This ensures the user can scroll
    // through the options in the Drawer if there isn't enough vertical
    // space to fit everything.
    child: new ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: <Widget>[
        new DrawerHeader(
          child: new Text('Drawer Header'),
          decoration: new BoxDecoration(
            color: Colors.blue,
          ),
        ),
        new ListTile(
          title: new Text('Item 1'),
          onTap: () {
            // Update the state of the app
            // ...
          },
        ),
        new ListTile(
          title: new Text('Item 2'),
          onTap: () {
            // Update the state of the app
            // ...
          },
        ),
      ],
    ),
  );
}
