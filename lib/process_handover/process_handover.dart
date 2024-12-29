import 'package:flutter/material.dart';

import '../services/process_handover_service.dart';
import '../widgets/UserInfoManager.dart';

class WorkReportPage extends StatefulWidget {
  @override
  _WorkReportPageState createState() => _WorkReportPageState();
}

class _WorkReportPageState extends State<WorkReportPage> {
  final _formKey = GlobalKey<FormState>();

  String? productName, productCode, workshop, team, worker, nextProcess, date;
  int? completedQuantity, lossQuantity;

  final WorkReportService _service = WorkReportService();
  final UserInfoManager _userInfoManager = UserInfoManager();
  TextEditingController _workerController = TextEditingController();
  TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserDetailsAndSetDate();
  }

  Future<void> _fetchUserDetailsAndSetDate() async {
    await _userInfoManager.fetchUsernameAndUserDetails();
    setState(() {
      _workerController.text = _userInfoManager.name ?? '';
      _dateController.text = DateTime.now().toString().substring(0, 10);
      workshop = _userInfoManager.workshop;
      team = _userInfoManager.teamsGroups;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final workReport = WorkReport(
        reportID: 0, // 假设服务器端会自动生成报告ID
        productName: productName!,
        productCode: productCode!,
        workshop: workshop!,
        team: team!,
        worker: _workerController.text,
        completedQuantity: completedQuantity!,
        lossQuantity: lossQuantity!,
        nextProcess: nextProcess!,
        date: _dateController.text,
      );

      try {
        await _service.addWorkReport(workReport);
        _showSuccessDialog(context);
      } catch (e) {
        _showErrorDialog(context, e.toString());
      }
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('成功'),
          content: Text('工作报告已成功添加！'),
          actions: <Widget>[
            TextButton(
              child: Text('确定'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('失败'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: Text('确定'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('报工'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  labelText: '产品名称',
                  labelStyle: TextStyle(color: Colors.blueGrey[700]),
                ),
                onSaved: (value) => productName = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入产品名称';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  labelText: '产品编号',
                  labelStyle: TextStyle(color: Colors.blueGrey[700]),
                ),
                onSaved: (value) => productCode = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入产品编号';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: TextEditingController(text: workshop),
                enabled: false,
                decoration: InputDecoration(
                  labelText: '车间',
                  labelStyle: TextStyle(color: Colors.blueGrey[700]),
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: TextEditingController(text: team),
                enabled: false,
                decoration: InputDecoration(
                  labelText: '班组',
                  labelStyle: TextStyle(color: Colors.blueGrey[700]),
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _workerController,
                enabled: false,
                decoration: InputDecoration(
                  labelText: '工人姓名',
                  labelStyle: TextStyle(color: Colors.blueGrey[700]),
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '完成数量',
                  labelStyle: TextStyle(color: Colors.blueGrey[700]),
                ),
                onSaved: (value) => completedQuantity = int.parse(value!),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入完成数量';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '损失数量',
                  labelStyle: TextStyle(color: Colors.blueGrey[700]),
                ),
                onSaved: (value) => lossQuantity = int.parse(value!),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入损失数量';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  labelText: '下一步工序',
                  labelStyle: TextStyle(color: Colors.blueGrey[700]),
                ),
                onSaved: (value) => nextProcess = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入下一步工序';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _dateController,
                enabled: false,
                decoration: InputDecoration(
                  labelText: '日期',
                  labelStyle: TextStyle(color: Colors.blueGrey[700]),
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.lightBlueAccent),
                ),
                onPressed: _submitForm,
                child: Text('提交', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}