import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/config.dart';

class MaterialRecords {

  int? materialId; // 物料ID
  String? materialName; // 物料名称
  String? worker; // 工人姓名
  String? issuanceDate; // 领取日期，字符串类型
  int? quantityIssued; // 领取数量
  String? purpose; // 领取目的

  MaterialRecords({
    this.materialId,
    this.materialName,
    this.worker,
    this.issuanceDate,
    this.quantityIssued,
    this.purpose,
  });

  Map<String, dynamic> toJson() {
    return {
      'materialId': materialId,
      'materialName': materialName,
      'worker': worker,
      'issuanceDate': issuanceDate,
      'quantityIssued': quantityIssued,
      'purpose': purpose,
    };
  }
}

class ProductionTaskService {
  final baseUrl = AppConfig.baseUrl;

  Future<void> addMaterialRecord(MaterialRecords materialRecord) async {
    final uri = Uri.http(baseUrl, '/materialrecords/add');

    try {
      final response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: jsonEncode(materialRecord.toJson()),
      );

      print('Response status code: ${response.statusCode}');

      // 解析响应体并打印
      final responseBody = utf8.decode(response.bodyBytes);
      print('Response body: $responseBody');

      if (response.statusCode == 200) {
        // 处理成功的响应
        print('Material record added successfully');
      } else {
        // 处理错误情况
        print('Failed to add material record: $responseBody');
      }
    } catch (e) {
      // 捕获并打印异常
      print('Error while adding material record: $e');
    }
  }
}