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
              print("🖕 Failed to delete expense: ${response.body}");
            }
          } catch (err) {
            print("🖕 Error connecting to server: $err");
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