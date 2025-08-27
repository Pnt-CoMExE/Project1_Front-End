import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

void main() async {
  Map<String, dynamic>? loginResult = await login();
  if (loginResult != null) {
    await menu(loginResult['userId'], loginResult['username']);
  }
}

Future<Map<String, dynamic>?> login() async {
  print("===== Login =====");
  stdout.write("Username: ");
  String? username = stdin.readLineSync()?.trim();
  stdout.write("Password: ");
  String? password = stdin.readLineSync()?.trim();

  if (username == null ||
      password == null ||
      username.isEmpty ||
      password.isEmpty) {
    print("Incomplete input");
    return null;
  }

  final body = {"username": username, "password": password};
  final url = Uri.parse('http://localhost:3000/login');
  final response = await http.post(url, body: body);

  if (response.statusCode == 200) {
    final result = json.decode(response.body);
    // Return both userId and username
    return {'userId': result['userId'], 'username': username};
  } else {
    print(response.body);
    return null;
  }
}

Future<void> menu(int userId, String username) async {
  while (true) {
    print("\n========== Expense Tracking App ==========");
    print('Welcome $username');
    print("1. All expenses");
    print("2. Today's expense");
    print("3. Search expense");
    print("4. Add new expense");
    print("5. Delete an expense");
    print("6. Exit");

    stdout.write('Choose...');
    String? choice = stdin.readLineSync()?.trim();

    switch (choice) {
      case '1':
        print("------------- All expenses -------------");
          // Add code here
        break;
      case '2':
        print("------------- Today's expense -------------");
          // Add code here
        break;
      case '3':
        print("------------- Search expense -------------");
           stdout.write("Item to search: ");
  String? keyword = stdin.readLineSync()?.trim();

  if (keyword == null || keyword.isEmpty) {
    print("No keyword entered.");
    break;
  }

  final searchUrl = Uri.parse(
    'http://localhost:3000/expenses/$userId/search?query=${Uri.encodeComponent(keyword)}',
  );

  final response = await http.get(searchUrl);

  if (response.statusCode == 200) {
    final jsonResult = json.decode(response.body) as List<dynamic>;
    if (jsonResult.isEmpty) {
      print("No expenses matched your search '$keyword'.");
    } else {
      for (var exp in jsonResult) {
        final dt = DateTime.tryParse(exp['date'].toString());
        final dtLocal = dt?.toLocal().toString().split(".")[0]; // remove milliseconds
        print("${exp['id']}. ${exp['item']} : ${exp['paid']}฿ : ${dtLocal ?? exp['date']}");
      }
    }
  } else {
    print("Search failed (${response.statusCode})");
  }
        break;
      case '4':
        print("------------- Add new expense -------------");
          // Add code here
        break;
      case '5':
        print("------------- Delete an expense -------------");
          // Add code here
          //test
        break;
      case '6':
        print("------ Bye ------");
        return;
      default:
        print("Choose only 1 - 6!!!");
    }
  }
}