import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:github/ssutil.dart' as ss;
import 'package:http/http.dart';
//import 'package:http/http.dart';

class User {
  final int id;
  final String username;
  final String type;

  String password;

  User({this.id, this.username, this.type});

  @override
  String toString() => username;

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
      username: json['login'],
      type: json['type'],
    );
  }

  static Map<String, dynamic> decode(String jsonText) {
    return json.decode(jsonText);
  }

  static User parse(String jsonText) {
    Map<String, dynamic> map = json.decode(jsonText);
    return fromJson(map);
  }

  static List<User> parseUsers(String json) => ss.decodeJsonList<User>(json, fromJson);

  Credentials credentials() {
    return new Credentials(username, password);
  }
}

class Repo {
  final int id;
  final String name;
  final String description;
  final String owner;

  Repo({this.id, this.name, this.description, this.owner});

  @override
  String toString() {
    return 'Repo{name: $name}';
  }

  factory Repo.fromJson1(Map<String, dynamic> json) {
    return fromJson(json);
  }

  static Repo fromJson(Map<String, dynamic> json) =>
      new Repo(id: json['id'], name: json['name'], description: json['description'], owner: json['owner']["login"]);

  static List<Repo> parseRepos(String json) => ss.decodeJsonList<Repo>(json, fromJson);

  static QueryResponse<Repo> parseQueryResponse(String json) {
    return QueryResponse.parse<Repo>(json, Repo.fromJson);
  }
}

class GitHub {
  static const String baseUrl = "https://api.github.com";
  ss.Api api = new ss.Api();

  /*
  var encoded = UTF8.encode("Îñţérñåţîöñåļîžåţîờñ");
  var encoded = BASE64.encode([0x62, 0x6c, 0xc3, 0xa5, 0x62, 0xc3, 0xa6,
                               0x72, 0x67, 0x72, 0xc3, 0xb8, 0x64]);
   */

  Credentials _credentials = Credentials.dave();
  User _user;

  set logging(bool value) {
    api.logging = value;
  }

  void loginDave() {
    login(Credentials.dave());
  }

  bool isLoggedIn() {
    return _user != null;
  }

  User get user {
    return _user;
  }

  void logout() {
    this._user = null;
  }

  void loginSuccess(User user) {
    this._user = user;
    this._credentials = user.credentials();
  }

  void loginFail() {
    this._user = null;
    this._credentials = null;
  }

  void setCachedLoginToDave() {
    _credentials = Credentials.dave();
  }

  void clearCachedLogin() {
    _credentials = null;
  }

  Credentials get cachedLogin {
    return _credentials;
  }

  Future<User> login1(String username, String password) async {
    return login(new Credentials(username, password));
  }

  Future<Response> httpGet(String url, {Map<String, String> headers}) async {
    Map<String, String> h = headers ?? {};
    if (_user != null) {
      h[HttpHeaders.AUTHORIZATION] = _user.credentials().createBasicAuthToken();
    }
    return api.get(url, headers: h);
  }

  Future<User> login(Credentials login) async {
    String auth = login.createBasicAuthToken();
    String url = "$baseUrl/user";
    try {
      Response response = await api.get(url, headers: {HttpHeaders.AUTHORIZATION: auth});
      return await compute(User.parse, response.body);
    } on ss.HttpException catch (e) {
      if (e.statusCode == 401) {
        return null;
      } else {
        throw e;
      }
    }
  }

//  https://api.github.com/users
  Future<List<User>> fetchUsers() async {
    Response response = await httpGet("$baseUrl/users");
    return compute(User.parseUsers, response.body);
  }

//  https://api.github.com/search/repositories?q=configurator
  Future<QueryResponse<Repo>> fetchRepos(String query) async {
    if (query == null) throw ArgumentError.notNull("query");
    Response response = await httpGet("$baseUrl/search/repositories?q=$query");
    return Repo.parseQueryResponse(response.body);
  }

  Future<List<Repo>> fetchMyRepos() async {
    Response response = await httpGet("$baseUrl/user/repos");
    return compute(Repo.parseRepos, response.body);
  }

//  https://api.github.com/repositories
  Future<List<Repo>> fetchAllRepos() async {
    Response response = await httpGet("$baseUrl/repositories");
    return compute(Repo.parseRepos, response.body);
  }

  List<Repo> parseReposFails(String responseBody) {
    final parsed = json.decode(responseBody);
    return parsed.map((json) => Repo.fromJson(json)).toList(); //cause a cast error
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
  Future<List<Repo>> fetchReposForUser(String username) async {
    final response = await httpGet("$baseUrl/users/$username/repos");
    return compute(Repo.parseRepos, response.body);
  }

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

  static QueryResponse<T> parse<T>(String jsonText, ss.FromJsonFactory<T> fromJsonFactory) {
    Map<String, dynamic> map = json.decode(jsonText);
    return fromJson<T>(map, fromJsonFactory);
  }
}

class Credentials {
  final String username;
  final String password;

  const Credentials(this.username, this.password)
      : assert(username != null),
        assert(password != null);

  @override
  String toString() {
    return 'Login{username: $username, password: $password}';
  }

  String createBasicAuthToken() {
    String authRaw = "$username:$password";
    Uint8List u = utf8.encode(authRaw);
    String b = base64.encode(u);
    return "Basic $b";
  }

  static Credentials dave() {
    return const Credentials("StokeMasterJack", "6425kr"); //todo
  }
}
