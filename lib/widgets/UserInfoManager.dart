import 'package:flutter/material.dart';
import '../services/login_service.dart';
import '../services/user_service.dart';

class UserInfoManager with ChangeNotifier {
  String? _username; // 存储工号
  String? _name; // 存储姓名
  String? _role; // 存储职位信息
  String? _workshop; //班组
  String? _teamsGroups; //车间

  final loginService = LoginService(); // 登录服务实例
  final userService = UserService(); // 用户服务实例

  // 异步获取用户名及用户详细信息
  Future<void> fetchUsernameAndUserDetails() async {
    final username = await loginService.getUsername();
    _username = username;

    if (_username != null) {
      try {
        final user = await userService.getUserByUsername(_username!);
        _name = user.name;
        _role = user.role;
        _workshop= user.workshop;
        _teamsGroups=user.teamsGroups;
        notifyListeners(); // 通知监听器数据已更新
      } catch (e) {
        print('Error fetching user details: $e');
      }
    }
  }

  // 获取当前用户的姓名
  String? get name => _name;

  // 获取当前用户的工号
  String? get username => _username;

  // 获取当前用户的职位
  String? get role => _role;

  String? get workshop => _workshop;

  String? get teamsGroups => _teamsGroups;

  // 退出登录
  void logout() {
    _username = null;
    _name = null;
    _role = null;
    notifyListeners(); // 通知监听器数据已更新
  }
}