import 'package:dome2/pages/home_page1.dart';
import 'package:dome2/pages/home_page2.dart'; // 确保你已经导入了 HomePage2
import 'package:dome2/pages/home_page3.dart'; // 确保你已经导入了 HomePage3
import 'package:dome2/pages/login_page.dart';
import 'package:dome2/widgets/UserInfoManager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/login_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final LoginService loginService = LoginService();
  final bool isLoggedIn = await loginService.checkLoginStatus();
  final String? role = await loginService.getRole(); // 获取用户角色

  runApp(MyApp(
    isLoggedIn: isLoggedIn,
    role: role,
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? role;

  const MyApp({Key? key, required this.isLoggedIn, this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget initialPage;
    if (isLoggedIn) {
      switch (role) {
        case '工人':
          initialPage = HomePage1();
          break;
        case '车间主任':
          initialPage = HomePage2();
          break;
        case '管理员':
          initialPage = HomePage3();
          break;
        default:
          initialPage = LoginPage(); // 如果没有匹配的角色或者未登录
      }
    } else {
      initialPage = LoginPage();
    }

    return ChangeNotifierProvider(  // 使用 ChangeNotifierProvider 包裹 MaterialApp
      create: (context) => UserInfoManager(),  // 创建 UserInfoManager 实例
      child: MaterialApp(
        title: 'My App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: initialPage,
      ),
    );
  }
}