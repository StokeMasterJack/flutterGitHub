import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:github/ssutil_flutter.dart';

class Repos extends StatelessWidget {
  final Future<List<Repo>> fRepos;
  final OnSelected<Repo> onSelected;

  Repos({@required this.fRepos, this.onSelected});

  @override
  Widget build(BuildContext context) {
    return new FutBuilder<List<Repo>>(
        future: this.fRepos,
        dataBuilder: (BuildContext context, List<Repo> repos) {
          if (repos == null) {
            return Text("");
          } else if (repos.length == 0) {
            return new Center(child: new Text("No records found"));
          } else {
            return renderData(context, repos);
          }
        });
  }

  Widget renderData(BuildContext context, List<Repo> repos) {
    return new ListView.builder(
        padding: new EdgeInsets.all(4.0),
        itemCount: repos.length,
        itemBuilder: (_, index) {
          return _buildListItem(context, repos[index]);
        });
  }

  Widget _buildListItem(BuildContext context, Repo repo) {
    const int maxLength = 100;
    String desc = (repo.description ?? "No description");
    if (desc.length > maxLength) desc = desc.substring(0, maxLength);

    return new ListTile(
      leading: new CircleAvatar(child: new Text(repo.name[0].toUpperCase())),
      title: new Text('${repo.name}'),
      subtitle: new Text(desc),
      trailing: new Text(repo.owner),
      onTap: onSelected == null
          ? null
          : () {
              onSelected(context, repo);
            },
      onLongPress: () {
        print("Long Press");
      },
    );
  }

  Widget buildPopupMenu(BuildContext context){
    return new PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                initialValue: "a",
                onSelected: (String selectedValue){
                    snack(context, selectedValue);
                } ,
                child: new ListTile(
                  title: const Text('An item with a simple menu'),
                  subtitle: new Text("aaa")
                ),
                itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                  new PopupMenuItem<String>(
                    value: "a",
                    child: new Text("aaaa")
                  ),
                  new PopupMenuItem<String>(
                    value: "b",
                    child: new Text("bbbb")
                  ),
                  new PopupMenuItem<String>(
                    value: "c",
                    child: new Text("cccc")
                  )
                ]
              );
  }

}

class ReposPage extends StatelessWidget {
  final Future<List<Repo>> fRepos;
  final OnSelected<Repo> onSelected;
  final String title;

  ReposPage({@required this.fRepos, this.onSelected, this.title});

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text(this.title ?? "Repos"),
      ),
      body: new Repos(fRepos: fRepos, onSelected: onSelected),
    );
  }
}

class ReposApp extends StatelessWidget {
  final GitHub g = new GitHub();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: "Repos",
        home: new ReposPage(
            fRepos: g.fetchAllRepos(),
            onSelected: (_, Repo repo) {
              print(repo);
            }));
  }
}
