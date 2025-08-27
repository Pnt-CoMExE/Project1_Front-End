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
        // ขออนุญาตเขียนไว้อ่านนะครับผม
        Future<void> allExpenses(int userId) async {
          final url = Uri.parse('http://localhost:3000/expenses/$userId');
          try {
            final response = await http.get(url);

            if (response.statusCode == 200) {
              List<dynamic> expenses = json.decode(response.body);

              if (expenses.isEmpty) {
                print("No expenses found.");
              } else {
                double total =
                    0; // ถ้ามีข้อมูลใน expense ในรายการจะประกาศตัวแปร total รวมเงินครับ

                expenses.sort((a, b) {
                  if (a['id'] > b['id']) {
                    return 1; // ถ้า a มากกว่า b จะให้ a อยู่หลัง b ตะได้เรียงจากน้อยไปมากครับ
                  } else if (a['id'] < b['id']) {
                    return -1; // ถ้า a น้อยกว่า b จะให้ a อยู่ก่อน b จะได้เรียงจากน้อยไปมากครับ
                  } else {
                    return 0;
                  }
                }); // sort id เรียงจากน้อยไปมากครับ

                for (var exp in expenses) {
                  String date = exp['date'].toString(); // วนลูปผ่านทุก expense ใน list //ดึงข้อมูลจาก object expense แต่ละอย่างครับ และ ดึงค่า date จาก object
                  String item = exp['item'];
                  String paid = exp['paid'].toString();

                  print("${exp['id']}. $item : $paid ฿ : $date");

                  total +=
                      double.tryParse(paid) ??
                      0; //?? 0 คือ ถ้สแปลงไม่ได้ให้ใช้ค่าเป็น 0 แทนนะครับผม และ ตรง double.tryParse(paid) คือแปลง string เป็น double ครับ
                }

                print("Total expenses = ${total.toStringAsFixed(0)} ฿");
              }
            } else {
              print(
                "Failed to fetch expenses: ${response.body}",
              ); // ถ้าไม่เรียกใช้ 200 จะเรียกไม่สำเร็จค้าบบ
            }
          } catch (err) {
            print("Error connecting to server: $err");
          }
        }

        await allExpenses(userId);
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
            break;
      case '5':
        print("------------- Delete an expense -------------");
          // Add code here
          Future<void> deleteExpense(int userId) async {
          print("Enter expense ID to delete:"); //ฟังก์ชั่นที่เขียนจะทำงานแบบ async และ ไม่คืนค่า
          String? input = stdin.readLineSync()?.trim(); // trim คือ ตัดช่องว่างออกถ้ามันมีช่องว่าง

          if (input == null || input.isEmpty) {
            print("Invalid input"); //ดูว่า input เป็น ว่างเปล่า ถ้าใช่จะ error
            return;
          }

          int? expenseId = int.tryParse(input); //แปลง String เป็น int ครับ และ int? คือ อนุญาตให้เป็นค่าว่างครับ
          if (expenseId == null) {
            print("Please enter a valid number");
            return;
          }

          final url = Uri.parse('http://localhost:3000/expenses/$expenseId');
          try {
            final response = await http.delete(url); //ส่ง HTTP DELETE request ไปยัง URL ที่กำหนดครับ

            if (response.statusCode == 200) {
              final result = json.decode(response.body); //แปลง Json เป็น Dart object ครับ
              print("👍 ${result['message']}");
            } else {
              print("😡 Failed to delete expense: ${response.body}");
            }
          } catch (err) {
            print("😡 Error connecting to server: $err");
          }
        }

        await deleteExpense(userId);
        break;
      case '6':
        print("------ Bye ------");
        return;
      default:
        print("Choose only 1 - 6!!!");
    }
  }
}
