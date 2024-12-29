import 'package:flutter/material.dart';
import '../services/collect_material_service.dart';
import '../widgets/UserInfoManager.dart';

class MaterialIssuancePage extends StatefulWidget {
  @override
  _MaterialIssuancePageState createState() => _MaterialIssuancePageState();
}

class _MaterialIssuancePageState extends State<MaterialIssuancePage> {
  final _formKey = GlobalKey<FormState>();

  String? _materialId, _materialName, _quantityIssued, _purpose;
  final ProductionTaskService _service = ProductionTaskService();
  final UserInfoManager _userInfoManager = UserInfoManager();  // 实例化 UserInfoManager
  TextEditingController _workerController = TextEditingController();
  TextEditingController _issuanceDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserDetailsAndSetDate();
  }

  Future<void> _fetchUserDetailsAndSetDate() async {
    await _userInfoManager.fetchUsernameAndUserDetails();  // 获取用户信息
    setState(() {
      _workerController.text = _userInfoManager.name ?? '';  // 设置工人姓名
      _issuanceDateController.text = DateTime.now().toString().substring(0, 10);  // 设置当前日期
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final materialRecord = MaterialRecords(
        materialId: int.parse(_materialId!),
        materialName: _materialName,
        worker: _workerController.text,
        issuanceDate: _issuanceDateController.text,
        quantityIssued: int.parse(_quantityIssued!),
        purpose: _purpose,
      );

      try {
        await _service.addMaterialRecord(materialRecord);
        // 提交成功后显示提示
        _showSuccessDialog(context);
      } catch (e) {
        // 如果提交失败，显示错误提示
        _showErrorDialog(context, e.toString());
      }
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('领取成功'),
          content: Text('物料领取记录已成功添加！'),
          actions: <Widget>[
            TextButton(
              child: Text('确定'),
              onPressed: () {
                Navigator.of(context).pop();  // 关闭对话框
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
          title: Text('领取失败'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: Text('确定'),
              onPressed: () {
                Navigator.of(context).pop();  // 关闭对话框
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
        title: Text('物料领取'),
        backgroundColor: Colors.lightBlueAccent,  // 与之前页面统一的颜色
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  labelText: '物料编号',
                  labelStyle: TextStyle(color: Colors.blueGrey[700]),  // 与之前页面统一的文本颜色
                ),
                onSaved: (value) => _materialId = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入物料编号';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8),  // 间距与之前页面一致
              TextFormField(
                decoration: InputDecoration(
                  labelText: '物料名称',
                  labelStyle: TextStyle(color: Colors.blueGrey[700]),
                ),
                onSaved: (value) => _materialName = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入物料名称';
                  }
                  return null;
                },
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
                controller: _issuanceDateController,
                enabled: false,
                decoration: InputDecoration(
                  labelText: '领取日期',
                  labelStyle: TextStyle(color: Colors.blueGrey[700]),
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '领取数量',
                  labelStyle: TextStyle(color: Colors.blueGrey[700]),
                ),
                onSaved: (value) => _quantityIssued = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入领取数量';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  labelText: '领取目的',
                  labelStyle: TextStyle(color: Colors.blueGrey[700]),
                ),
                onSaved: (value) => _purpose = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入领取目的';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.lightBlueAccent),  // 按钮颜色与AppBar一致
                ),
                onPressed: _submitForm,
                child: Text('领取', style: TextStyle(color: Colors.white)),  // 按钮文字颜色
              ),
            ],
          ),
        ),
      ),
    );
  }
}