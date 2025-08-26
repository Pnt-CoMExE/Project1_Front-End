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
                double total = 0; // ถ้ามีข้อมูลใน expense ในรายการจะประกาศตัวแปร total รวมเงินครับ

                for (var exp in expenses) {
                  String date = exp['date'].toString(); // วนลูปผ่านทุก expense ใน list //ดึงข้อมูลจาก object expense แต่ละอย่างครับ และ ดึงค่า date จาก object
                  String item = exp['item']; 
                  String paid = exp['paid'].toString();

                  print("${exp['id']}. $item : $paid ฿ : $date");

                  total += double.tryParse(paid) ?? 0; //?? 0 คือ ถ้สแปลงไม่ได้ให้ใช้ค่าเป็น 0 แทนนะครับผม และ ตรง double.tryParse(paid) คือแปลง string เป็น double ครับ
                }

                print("Total expenses = ${total.toStringAsFixed(0)} ฿");
              }
            } else {
              print("Failed to fetch expenses: ${response.body}"); // ถ้าไม่เรียกใช้ 200 จะเรียกไม่สำเร็จค้าบบ
            }
          } catch (err) {
            print("Error connecting to server: $err");
          }
        }

        await allExpenses(userId);
        break;
      case '2':
        print("------------- Today's expense -------------");
        // Add code here
        break;
      case '3':
        print("------------- Search expense -------------");
        // Add code here
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
