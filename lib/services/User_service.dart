import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../widgets/config.dart';

class User {
  final String username;
  final String password;
  final String name;
  final String role;
  final String workshop;
  final String teamsGroups;

  User({
    required this.username,
    required this.password,
    required this.name,
    required this.role,
    required this.workshop,
    required this.teamsGroups
  });

  factory User.fromJson(Map<String, dynamic> json) {
    if (json['username'] == null || json['password'] == null || json['name'] == null || json['role'] == null) {
      throw Exception('Missing required fields in JSON response.');
    }

    return User(
      username: json['username'],
      password: json['password'],
      name: json['name'],
      role: json['role'],
      workshop: json['workshop'] ?? '', // 如果缺失，设置为空字符串
      teamsGroups: json['teamsGroups'] ?? '', // 如果缺失，设置为空字符串
    );
  }
}

class UserService {
  // 获取用户信息的函数
  Future<User> getUserByUsername(String username) async {

    // 确保 AppConfig.baseUrl 包含正确的协议
    final baseUrl = AppConfig.baseUrl;

    // 构建完整的请求URL
    final url = Uri.http(baseUrl, '/selectByUsername', {'username': username});

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json; charset=utf-8', // 指定接受的字符编码
        },
      );


      if (response.statusCode == 200) {
        try {
          final jsonResponse = json.decode(response.body);
          if (jsonResponse.containsKey('data') && jsonResponse['data'] != null) {
            return User.fromJson(jsonResponse['data']);
          } else {
            throw Exception('No data found in the response.');
          }
        } catch (e) {
          // 处理 JSON 解析错误
          throw FormatException('Failed to parse JSON response: $e');
        }
      } else {
        // 提供更具体的错误信息
        throw HttpException('Failed to load user by username: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      // 处理网络请求或JSON解析错误
      throw Exception('Failed to fetch user details: $e');
    }
  }
}