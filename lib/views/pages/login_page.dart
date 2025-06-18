import 'package:app/controller/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthLoginService authLoginService = Get.put(AuthLoginService());
  final LoginController loginController = Get.put(LoginController());
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/icons/mbk_icon_login.png',
              ),
              SizedBox(
                height: 30.0,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: TextFormField(
                  controller: _telephoneController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 18.0, // Increase the font size
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person,
                        color: const Color.fromARGB(255, 133, 133, 133)),
                    hintText: 'เบอร์โทรศัพท์',
                    hintStyle: TextStyle(
                      fontSize: 18.0,
                      color: const Color.fromARGB(255, 199, 199, 199),
                    ),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 40,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  obscuringCharacter: '●', // ปิดการแสดงรหัสผ่าน
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.lock,
                      color: const Color.fromARGB(255, 133, 133, 133),
                    ),
                    hintText: 'รหัสผ่าน',
                    hintStyle: TextStyle(
                      fontSize: 18.0,
                      color: const Color.fromARGB(255, 199, 199, 199),
                    ),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 40,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              MaterialButton(
                onPressed: () {
                  loginController.login(
                      _telephoneController.text.trim(), _passwordController.text.trim());
                },
                color: const Color.fromARGB(255, 196, 21, 5),
                textColor: Colors.white,
                minWidth: 353,
                height: 45,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: const Text("เข้าสู่ระบบ",
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                height: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
