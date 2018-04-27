import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:github/repos.dart';
import 'package:github/ssutil.dart' as ss;
import 'package:github/ssutil_flutter.dart';


class SearchReposApp extends StatelessWidget {
  final GitHub gitHub = new GitHub();


  @override
  Widget build(BuildContext context) {
    MaterialApp app =
        new MaterialApp(title: "GitHub", home: new SearchReposPage(gitHub: gitHub));
    return app;
  }
}

class SearchReposPage extends StatefulWidget {
  final GitHub gitHub;
  final Future<List<Repo>> fRepos;
  final OnSelected<Repo> onSelected;

  SearchReposPage({@required this.gitHub, this.fRepos, this.onSelected}) : assert(gitHub != null);

  @override
  State createState() => new _SearchReposPageState2();
}

class _SearchReposPageState2 extends State<SearchReposPage> {
  Future<List<Repo>> fRepos;
  TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = new TextEditingController();
    if (widget.fRepos != null) {
      this.fRepos = widget.fRepos;
    } else {
      this.fRepos = Future.value(null);
    }

    controller.addListener(() {
      setState(() {
        this.fRepos = fetchRepos();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Search Repos"),
        bottom: new AppBar(
          automaticallyImplyLeading: false,
          title: mkSearchTextField(),
        ),
      ),
      body: new Repos(fRepos: fRepos, onSelected: widget.onSelected),
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

  Future<List<Repo>> fetchRepos() {
    if (isTextFieldEmpty()) return Future.value(null);
    return widget.gitHub.fetchReposList(this.controller.text);
  }

  TextField mkSearchTextField() {
    return new TextField(
        controller: this.controller,
        autofocus: true,
        decoration: new InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.all(5.0).copyWith(right: 0.0),
            suffixIcon: mkCancelIcon(),
            filled: true,
            fillColor: Colors.white,
            border: InputBorder.none,
            hintText: 'Search Repos'));
  }

  static const String baseTitle = "Repos";

  Widget mkCancelIcon() {
    IconButton x = new IconButton(
        icon: new Icon(
          Icons.cancel,
          color: Colors.grey,
          size: 18.0,
        ),
        onPressed: () {
          setState(() {
            controller.clear();
          });
        },
        color: Colors.blue,
        alignment: Alignment.centerRight);

    return x;
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    controller.dispose();
    super.dispose();
  }
}
