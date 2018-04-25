import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:github/github.dart';

typedef void OnRepoTap(Repo repo);

class Repos extends StatelessWidget {
  final Future<List<Repo>> fRepos;
  final OnRepoTap onRepoTap;

  Repos({@required this.fRepos, this.onRepoTap});

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<List<Repo>>(
        future: this.fRepos,
        builder: (_, AsyncSnapshot<List<Repo>> snap) {
//          logSnapshot(snap);
          switch (snap.connectionState) {
            case ConnectionState.waiting:
              return renderWait();
            case ConnectionState.done:
              if (snap.hasData) {
                List<Repo> repos = snap.data;
                if (repos == null) {
                  return Text("");
                } else if (repos.length == 0) {
                  return new Center(child: new Text("No records found"));
                } else {
                  return renderData(snap.data);
                }
              } else if (snap.hasError) {
                return renderErr(snap.error);
              } else {
                return Text("");
              }
              break;
            case ConnectionState.active:
              return renderWait();
            case ConnectionState.none:
              return renderWait();
            default:
              throw StateError("Shouldnt be here 2");
          }
        });
  }

  Widget renderData(List<Repo> repos) {
    return new ListView.builder(
        padding: new EdgeInsets.all(4.0),
        itemCount: repos.length,
        itemBuilder: (_, index) {
          return _buildListItem(repos[index]);
        });
  }

  Widget renderErr(Object err) {
    debugPrint("Problem compelting an http call $err");
    return new Text("Error: $err");
  }

  Widget renderWait() {
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }

  Widget _buildListItem(Repo repo) {
    const int maxLength = 100;
    String desc = (repo.description ?? "No description");
    if (desc.length > maxLength) desc = desc.substring(0, maxLength);

    return new ListTile(
        leading: new CircleAvatar(child: new Text(repo.name[0].toUpperCase())),
        title: new Text('${repo.name}'),
        subtitle: new Text(desc),
        trailing: new Text(repo.owner),
        isThreeLine: true,
        onTap: () {
          if (onRepoTap != null) onRepoTap(repo);
        });
  }

  void logSnapshot(AsyncSnapshot<List<Repo>> snap) {
    print("state: ${snap.connectionState}");
    if (snap.hasData) {
      print("hasData: ");
      if (snap.data == null) {
        print("data is null");
      } else {
        print("data.length is ${snap.data.length}");
      }
    } else if (snap.hasError) {
      print("Err: ${snap.error}");
    }
  }
}

class ReposPage extends StatelessWidget {
  final Future<List<Repo>> fRepos;
  final OnRepoTap onRepoTap;

  ReposPage({@required this.fRepos, this.onRepoTap});

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text("Repos"),
      ),
      body: new Repos(fRepos: fRepos, onRepoTap: onRepoTap),
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
            onRepoTap: (Repo repo) {
              print(repo);
            }));
  }
}
