import 'package:github/github.dart';

void main1() async {
  GitHub g = new GitHub();
  g.logging = true;
  g.login("StokeMasterJack", "6425kr");
  User user = await g.fetchUser();
  print(user);
}


void main() async {
  GitHub g = new GitHub();
  g.logging = true;
  List<Repo> repos = await g.fetchAllRepos();
  print(repos.length);
}

void main2() async {
  GitHub g = new GitHub();
  g.logging = true;
  List<User> users = await g.fetchUsers();
  print(users.length);
}
