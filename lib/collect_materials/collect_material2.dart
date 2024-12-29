import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/collect_material_service2.dart';

class MaterialIssuancePage2 extends StatefulWidget {
  @override
  _MaterialIssuancePage2State createState() => _MaterialIssuancePage2State();
}

class _MaterialIssuancePage2State extends State<MaterialIssuancePage2> {
  final workReportService = WorkReportService(); // 工作报告服务实例
  late SearchParams searchParams; // 延迟初始化 searchParams

  @override
  void initState() {
    super.initState();
    // 初始化 searchParams
    searchParams = SearchParams(
      pageNum: 1,
      pageSize: 10,
    );
  }

  void _showAcceptDialog(BuildContext context, WorkReport report) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('接受工序交接单'),
          content: Text('您确定接受工序交接单吗？'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () {
                // 这里可以添加接受逻辑
                _showSnackbar(context, '已接受');
                Navigator.of(context).pop();
              },
              child: Text('确定'),
            ),
          ],
        );
      },
    );
  }

  void _showRejectDialog(BuildContext context, WorkReport report) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('拒绝工序交接单'),
          content: Text('您确定拒绝工序交接单吗？'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () {
                // 这里可以添加拒绝逻辑
                _showSnackbar(context, '已拒绝');
                Navigator.of(context).pop();
              },
              child: Text('确定'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2), // 设置SnackBar持续时间
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('物料发放'),
        backgroundColor: Colors.lightBlueAccent, // 设置顶部导航栏颜色
      ),
      body: FutureBuilder<List<WorkReport>>(
        future: workReportService.fetchWorkReports(searchParams),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('未找到工作报表'));
          } else {
            final reports = snapshot.data!;
            return ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return Card(
                  elevation: 5, // 设置卡片的阴影
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // 设置卡片的圆角
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '报告编号: ${report.reportID}',
                          style: TextStyle(
                            color: Colors.blueGrey[700], // 设置文本颜色
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8), // 设置间距
                        Text(
                          '产品名称: ${report.productName}',
                          style: TextStyle(color: Colors.blueGrey[600], fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '产品编码: ${report.productCode}',
                          style: TextStyle(color: Colors.blueGrey[600], fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '车间: ${report.workshop}',
                          style: TextStyle(color: Colors.blueGrey[600], fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '班组: ${report.team}',
                          style: TextStyle(color: Colors.blueGrey[600], fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '工人: ${report.worker}',
                          style: TextStyle(color: Colors.blueGrey[600], fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '完成数量: ${report.completedQuantity}',
                          style: TextStyle(color: Colors.blueGrey[600], fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '损失数量: ${report.lossQuantity}',
                          style: TextStyle(color: Colors.blueGrey[600], fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '下一工序: ${report.nextProcess}',
                          style: TextStyle(color: Colors.blueGrey[600], fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '日期: ${report.date}',
                          style: TextStyle(color: Colors.blueGrey[600], fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () => _showAcceptDialog(context, report),
                              child: Text('接受'),
                            ),
                            ElevatedButton(
                              onPressed: () => _showRejectDialog(context, report),
                              child: Text('拒绝'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}