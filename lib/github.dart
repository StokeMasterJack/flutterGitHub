import 'dart:async';
import 'dart:convert';

import 'package:github/ssutil.dart' as ss;

class User {
  final int id;
  final String login;
  final String type;

  User({this.id, this.login, this.type});

  @override
  String toString() => 'User{login: $login}';

  //  factory User.fromJson(Map<String, dynamic> json) {
//    return new User(
//      id: json['id'],
//      login: json['login'],
//      type: json['type'],
//    );
//  }

  //we use this kind of construct because it can be used as a tear-off
  static User fromJson(Map<String, dynamic> json) {
    return new User(
      id: json['id'],
      login: json['login'],
      type: json['type'],
    );
  }
}

class Repo {
  int id;
  String name;
  String description;
  String owner;

  Repo({this.id, this.name, this.description, this.owner});

  @override
  String toString() {
    return 'Repo{name: $name}';
  }

  static Repo fromJson(Map<String, dynamic> json) =>
      new Repo(id: json['id'], name: json['name'], description: json['description'], owner: json['owner']["login"]);
}

class GitHub {
  static const String baseUrl = "https://api.github.com";
  ss.Api api = new ss.Api();

  /*
  var encoded = UTF8.encode("Îñţérñåţîöñåļîžåţîờñ");
  var encoded = BASE64.encode([0x62, 0x6c, 0xc3, 0xa5, 0x62, 0xc3, 0xa6,
                               0x72, 0x67, 0x72, 0xc3, 0xb8, 0x64]);
   */

  bool _log;

  set logging(bool value) {
    api.logging = value;
  }

  void loginDave() {
    login("StokeMasterJack", "6425kr");
  }

  void login(String userName, String password) {
    String authToken = ss.createBasicAuthToken(userName, password);
    api.setAuth(authToken);
  }

  Future<User> fetchUser() async {
    String url = "$baseUrl/user";
    return api.getObject(url, User.fromJson);
  }

  //  https://api.github.com/users
  Future<List<User>> fetchUsers() async => api.getList('$baseUrl/users', User.fromJson);

  //  https://api.github.com/search/repositories?q=configurator
  Future<QueryResponse<Repo>> fetchRepos(String query) async {
    if (query == null) throw ArgumentError.notNull("query");
    return api.getObject("$baseUrl/search/repositories?q=$query", (Map<String, dynamic> json) {
      return QueryResponse.fromJson(json, Repo.fromJson);
    });
  }

  //  https://api.github.com/repositories
  Future<List<Repo>> fetchAllRepos() async {
    return api.getList("$baseUrl/repositories", Repo.fromJson);
  }

  Future<List<Repo>> fetchReposList(String query) async {
    String q = ss.nullNormalize(query);
    if (q == null) {
      return fetchAllRepos();
    } else {
      QueryResponse<Repo> r = await fetchRepos(q);
      return r.items;
    }
  }

  //  https://api.github.com/users/StokeMasterJack/repos
  Future<List<Repo>> fetchReposForUser(String username) async =>
      api.getList("$baseUrl/users/$username/repos", Repo.fromJson);

  QueryResponse<T> _decodeQueryResponseJson<T>(
      String jsonQueryResponseUnparsed, ss.FromJsonFactory<T> fromJsonFactory) {
    final Map<String, dynamic> parsed = json.decode(jsonQueryResponseUnparsed);
    return QueryResponse.fromJson<T>(parsed, fromJsonFactory);
  }
}

class QueryResponse<T> {
  final int totalCount;
  final bool incompleteResults;
  final List<T> items;

  QueryResponse({this.totalCount, this.incompleteResults, this.items});

  static QueryResponse<T> fromJson<T>(Map<String, dynamic> json, ss.FromJsonFactory<T> fromJsonFactory) {
    return new QueryResponse<T>(
        totalCount: json['totalCount'],
        incompleteResults: json['incompleteResults'],
        items: ss.convertJsonList(json['items'], fromJsonFactory));
  }
}
