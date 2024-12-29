import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/home_page1.dart';
import '../pages/home_page2.dart';
import '../pages/home_page3.dart';
import '../pages/login_page.dart';
import '../widgets/config.dart';

class LoginService {

  // 保存登录状态和用户名
  Future<void> saveLoginStatusAndUsername(bool isLoggedIn, String username,String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
    await prefs.setString('username', username); // 保存用户名
    await prefs.setString('role', role);
  }

  // 检查登录状态
  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // 获取保存的用户名
  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  // 获取保存的用户角色
  Future<String?> getRole() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  // 退出登录
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    // 清除登录状态和用户名
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('username');

    // 显示退出成功的对话框（可选）
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('退出成功'),
          content: Text('您已成功退出！'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
                // 跳转到登录页面或其他适当页面
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()), // 确保LoginPage已定义
                );
              },
              child: Text('确定'),
            ),
          ],
        );
      },
    );
  }

  // 登录方法
  Future<void> login(BuildContext context, String username, String password, String role) async {
    final Dio dio = Dio();

    final String checkUrl = 'http://${AppConfig.baseUrl}/login';

    final Map<String, dynamic> data = {
      "username": username,
      "password": password,
      "role": role,
    };

    try {
      final Response response = await dio.post(checkUrl, data: data);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;

        if (responseData['data']['code'] == '200') {
          // 保存登录状态为 true 并保存用户名
          await saveLoginStatusAndUsername(true, username,role);

          // 根据角色选择对应的主页
          Widget nextPage;
          switch (role) {
            case '工人':
              nextPage = HomePage1();
              break;
            case '车间主任':
              nextPage = HomePage2();
              break;
            case '管理员':
              nextPage = HomePage3();
              break;
            default:
              nextPage = LoginPage(); // 如果角色不匹配，默认回到登录页或处理错误
          }

          // 登录成功，显示成功对话框并跳转到相应的主页
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('登录成功'),
                content: Text('欢迎回来！'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // 关闭对话框
                      // 登录成功后跳转到对应的角色主页
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => nextPage),
                      );
                    },
                    child: Text('确定'),
                  ),
                ],
              );
            },
          );
        } else {
          // 业务逻辑上的失败，显示错误消息
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('登录失败'),
                content: Text('用户密码不正确或角色错误'), // 显示具体的错误信息
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // 关闭对话框
                    },
                    child: Text('确定'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        // HTTP请求失败
        throw Exception('HTTP请求失败，状态码: ${response.statusCode}');
      }
    } catch (e) {
      // 处理异常
      print('发生错误: $e');
      // 显示网络错误或其它错误消息
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('登录失败'),
            content: Text('发生了一个错误，请稍后再试。'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 关闭对话框
                },
                child: Text('确定'),
              ),
            ],
          );
        },
      );
    }
  }
}