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
          final todayExpensesUrl = Uri.parse('http://localhost:3000/expenses/$userId/today',);
        final response = await http.get(todayExpensesUrl);

        if (response.statusCode == 200) {
          final jsonResult = json.decode(response.body) as Map<String, dynamic>;

          final expenses = jsonResult['expenses'] as List<dynamic>;
          final total = jsonResult['total'];

          if (expenses.isEmpty) {
            print("No expenses for today.");
          } else {
            for (var exp in expenses) {
              final dt = DateTime.tryParse(exp['date'].toString());
              final dtLocal = dt?.toLocal();
              print(
                "${exp['id']}. ${exp['item']} : ${exp['paid']}฿ @ ${dtLocal ?? exp['date']}",
              );
            }
            print("Total expenses = $total฿");
          }
        } else {
          print("Failed to fetch today's expenses");
        }

        break;
      case '3':
        print("------------- Search expense -------------");
          // Add code here
        break;
      case '4':
        print("------------- Add new expense -------------");
          final addUrl = Uri.parse('http://localhost:3000/expenses/add/$userId',);
        stdout.write("Item: ");
          String? item = stdin.readLineSync()?.trim();
          stdout.write("Paid: ");
          String? paid = stdin.readLineSync()?.trim();
           if (item == null||  item.isEmpty ||  paid == null || paid.isEmpty){
            print("Invalid input\n");
            continue;
          }

          final paidAmount = int.tryParse(paid);
          if (paidAmount == null) {
            print("Please input a number\n");
            continue;
          }

          final addBody = jsonEncode({
            "user_id": userId,
            "item": item,
            "paid": paidAmount,
          });

          final addResponse = await http.post(addUrl,
            headers: {"Content-Type": "application/json"},
            body: addBody,
          );

          if (addResponse.statusCode == 201) {
            print("Inserted!\n");
          } else {
            print("Failed to add expense. Error: ${addResponse.statusCode}\n");
          }

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