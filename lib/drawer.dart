import 'package:flutter/material.dart';
import 'package:github/app.dart';

class GitHubDrawer extends StatelessWidget {
  final List<Item> items;

  GitHubDrawer({this.items});

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[
      new DrawerHeader(
          child: new Text('Drawer Header'),
          decoration: new BoxDecoration(
            color: Colors.blue,
          ))
    ];

    for (Item item in items) {
      ListTile tile = new ListTile(
        title: new Text(item.title),
        onTap: () {
          Navigator.pop(context);
          item.action(context);
        },
      );
      children.add(tile);
    }

    final d = new Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the Drawer if there isn't enough vertical
      // space to fit everything.
      child: new ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: children),
    );

    return d;
  }
}
