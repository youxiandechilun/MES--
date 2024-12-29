import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../widgets/config.dart';

class Tickets {
  int id;                          // 主键 自增
  String ticketID;                 // 工单编号
  String planID;                   // 计划编号
  String productName;              // 产品名称
  String workshop;                 // 车间
  String team;                     // 班组
  String worker;                   // 工人名字
  String grade;                    // 工人工级
  String process;                  // 工序
  String number;                   // 应该完成的数量
  String startDate;                // 开始日期
  String endDate;                  // 结束日期

  // 构造函数
  Tickets({
    required this.id,
    required this.ticketID,
    required this.planID,
    required this.productName,
    required this.workshop,
    required this.team,
    required this.worker,
    required this.grade,
    required this.process,
    required this.number,
    required this.startDate,
    required this.endDate,
  });

  // 从 JSON 对象创建 Tickets 实例的静态方法
  factory Tickets.fromJson(Map<String, dynamic> json) {
    return Tickets(
      id: json['id'] as int,
      ticketID: json['ticketID'] as String,
      planID: json['planID'] as String,
      productName: json['productName'] as String,
      workshop: json['workshop'] as String,
      team: json['team'] as String,
      worker: json['worker'] as String,
      grade: json['grade'] as String,
      process: json['process'] as String,
      number: json['number'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
    );
  }
}

class SearchParams {
  int pageNum = 1;
  int pageSize = 10;
  String ticketID;
  String worker;

  SearchParams({
    required this.pageNum,
    required this.pageSize,
    this.ticketID = '',
    this.worker = '',
  });
}

class TicketService {
  final baseUrl = AppConfig.baseUrl;

  // 获取生产任务
  Future<List<Tickets>> getTickets(SearchParams searchParams) async {
    var queryParameters = {
      'pageNum': searchParams.pageNum.toString(),
      'pageSize': searchParams.pageSize.toString(),
      'ticketID': searchParams.ticketID,
      'worker': searchParams.worker,
    };

    final uri = Uri.http(baseUrl, '/ticket/selectPage', queryParameters);

    try {
      print("即将发送HTTP GET请求");
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json; charset=utf-8'},
      );

      print("响应体: ${response.body}"); // 打印响应体

      if (response.statusCode == 200) { // 检查是否成功
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // 从jsonResponse中获取list
        final List<dynamic> jsonList = jsonResponse['data']['list'] ?? [];

        // 确保jsonList是列表
        if (jsonList is List) {
          return jsonList.map((json) => Tickets.fromJson(json)).toList();
        } else {
          throw Exception('Unexpected data format: expected a list, but got ${jsonList.runtimeType}');
        }
      } else {
        throw Exception('Failed to load tickets: ${response.reasonPhrase}');
      }
    } catch (e) {
      // 处理错误
      print('Error: $e');
      rethrow; // 或者根据需要自定义错误处理
    }
  }
}