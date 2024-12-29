import 'dart:convert';
import 'package:http/http.dart' as http;

// 确保 AppConfig 已经定义并且包含 baseUrl
import '../widgets/config.dart';

class WorkReport {
  final int reportID;
  final String productName;
  final String productCode;
  final String workshop;
  final String team;
  final String worker;
  final int completedQuantity;
  final int lossQuantity;
  final String nextProcess;
  final String date;

  WorkReport({
    required this.reportID,
    required this.productName,
    required this.productCode,
    required this.workshop,
    required this.team,
    required this.worker,
    required this.completedQuantity,
    required this.lossQuantity,
    required this.nextProcess,
    required this.date,
  });

  // 从 JSON 对象创建 WorkReport 实例的静态方法
  factory WorkReport.fromJson(Map<String, dynamic> json) {
    return WorkReport(
      reportID: json['reportID'] as int,
      productName: json['productName'] as String,
      productCode: json['productCode'] as String,
      workshop: json['workshop'] as String,
      team: json['team'] as String,
      worker: json['worker'] as String,
      completedQuantity: json['completedQuantity'] as int,
      lossQuantity: json['lossQuantity'] as int,
      nextProcess: json['nextProcess'] as String,
      date: json['date'] as String,
    );
  }
}

class SearchParams {
  final int pageNum;
  final int pageSize;
  final String worker;
  final String productName;

  SearchParams({
    this.pageNum = 1,
    this.pageSize = 10,
    this.worker='',
    this.productName='',
  });
}

class WorkReportService {
  final String baseUrl = AppConfig.baseUrl;

  Future<List<WorkReport>> fetchWorkReports(SearchParams searchParams) async {
    var queryParameters = {
      'pageNum': searchParams.pageNum.toString(),
      'pageSize': searchParams.pageSize.toString(),
      'worker': searchParams.worker,
      'productName': searchParams.productName

    };

    final uri = Uri.http(baseUrl, '/workReport/selectPage', queryParameters);

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
          return jsonList.map((json) => WorkReport.fromJson(json)).toList();
        } else {
          throw Exception('Unexpected data format: expected a list, but got ${jsonList.runtimeType}');
        }
      } else {
        throw Exception('Failed to load work reports: ${response.reasonPhrase}');
      }
    } catch (e) {
      // 处理错误
      print('Error: $e');
      rethrow; // 或者根据需要自定义错误处理
    }
  }
}