import 'package:http/http.dart' as http;
import 'dart:convert';

// 假设 AppConfig 已经定义在其他地方
import '../widgets/config.dart';

class WorkReport {
  int reportID; // 报告ID
  String productName; // 产品名称
  String productCode; // 产品编号
  String workshop; // 车间
  String team; // 班组
  String worker; // 工人
  int completedQuantity; // 完成数量
  int lossQuantity; // 损失数量
  String nextProcess; // 下一步工序
  String date; // 日期

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

  // 将 WorkReport 对象转换为 Map，以便可以编码为 JSON
  Map<String, dynamic> toJson() => {
        'reportID': reportID,
        'productName': productName,
        'productCode': productCode,
        'workshop': workshop,
        'team': team,
        'worker': worker,
        'completedQuantity': completedQuantity,
        'lossQuantity': lossQuantity,
        'nextProcess': nextProcess,
        'date': date,
      };
}

class WorkReportService {

  final baseUrl = AppConfig.baseUrl;

  Future<void> addWorkReport(WorkReport workReport) async {


    final uri = Uri.http(baseUrl, '/workReport/add');

    try {
      final response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(workReport.toJson()),
      );

      print('Response status code: ${response.statusCode}');

      final responseBody = utf8.decode(response.bodyBytes);
      print('Response body: $responseBody');

      if (response.statusCode == 200) {
        print('Work report added successfully');
      } else {
        print('Failed to add work report: $responseBody');
      }
    } catch (e) {
      print('Error while adding work report: $e');
    }

  }
}
