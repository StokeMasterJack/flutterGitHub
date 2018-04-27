import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:github/app.dart';
import 'package:github/bottom.dart';
import 'package:github/drawer.dart';
import 'package:github/github.dart';

class HomePage extends StatefulWidget {
  final User user;
  final List<Item> items;
  final GitHubDrawer drawer;
  final GitHubBottomAppBar bottom;

  HomePage({this.user, this.items, this.drawer, this.bottom});

  @override
  State createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = <Widget>[];

    for (Item item in widget.items) {
      widgets.add(item);
    }

    Column col = new Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );

    Container container = new Container(
      padding: const EdgeInsets.all(16.0),
      child: col,
    );

    return new Scaffold(
        appBar: AppBar(
          title: Text("GitHub"),
        ),
        drawer: widget.drawer,
        bottomNavigationBar: widget.bottom,
        body: new SingleChildScrollView(child: container));
  }
}