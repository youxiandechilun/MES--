import 'package:flutter/material.dart';
import '../collect_materials/collect_material.dart';
import '../collect_materials/collect_material2.dart';
import '../pages/login_page.dart';
import '../process_handover/process_handover.dart';
import '../production_tasks/production_task.dart';
import '../services/login_service.dart';
import '../services/user_service.dart';


// HomePage1 是一个有状态的 StatefulWidget，用于展示应用的主页面。
class HomePage1 extends StatefulWidget {
  const HomePage1({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage1> {

  String? _username; // 存储工号
  String? _name; // 存储姓名
  String? _role; // 存储职位信息

  final loginService = LoginService(); // 登录服务实例
  final userService = UserService(); // 用户服务实例

  @override
  void initState() {
    super.initState();
    _fetchUsernameAndUserDetails(); // 初始化时获取用户名及用户详细信息
  }

  // 异步获取用户名及用户详细信息
  Future<void> _fetchUsernameAndUserDetails() async {
    final username = await loginService.getUsername();
    setState(() {
      _username = username;
    });

    if (_username != null) {
      try {
        final user = await userService.getUserByUsername(_username!);
        setState(() {
          _name = user.name;
          _role = user.role;
        });
      } catch (e) {
        print('Error fetching user details: $e');
      }
    }
  }

  // 退出登录并返回登录页面
  void _logout() async {
    await loginService.logout(context);
    setState(() {
      _username = null;
      _name = null;
      _role = null;
    });
    Navigator.pop(context); // 如果是抽屉页面，关闭抽屉
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false, // 移除所有之前的页面
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: LayoutBuilder(builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth * 0.6,
          child: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: Text(_name ?? '未登录'),
                  accountEmail: _username != null ? Text(_username!) : null,
                  currentAccountPicture: null,
                  decoration: BoxDecoration(
                    color: Colors.blue[200],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('职位：$_role'),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text('退出登录'),
                  onTap: () => _logout(),
                ),
              ],
            ),
          ),
        );
      }),
      appBar: AppBar(
        title: Text('主页'),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildStatisticsSection(), // 构建统计信息部分
                  _buildFunctionIconsSection(), // 构建功能图标部分
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建统计信息部分
  Widget _buildStatisticsSection() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '12',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              Text(
                '0',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('报工数'),
              Text('不良品'),
            ],
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '8719.52',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              Text(
                '0',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              Text(
                '459',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('月计件'),
              Text('月计时'),
              Text('月提成'),
            ],
          ),
        ],
      ),
    );
  }

  // 构建功能图标部分
  // 构建功能图标部分
  Widget _buildFunctionIconsSection() {
    return Container(
      height: 400, // 设置固定高度
      padding: EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 3.0, // 添加垂直间距
        crossAxisSpacing: 8.0, // 添加水平间距
        children: List.generate(7, (index) {
          IconData icon;
          String label;
          VoidCallback? onTap;

          switch (index) {
            case 0:
              icon = Icons.assignment;
              label = '生产任务';
              onTap = () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProductionTaskPage()));
              };
              break;
            case 1:
              icon = Icons.assignment_late;
              label = '领取物料';
              onTap = () {
                _selectMaterialType(context);
              };
              break;
            case 2:
              icon = Icons.timer;
              label = '生产报工';
              onTap = () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => WorkReportPage()));
              };
              break;
            case 3:
              icon = Icons.assignment_ind;
              label = '报工详情';
              break;
            case 4:
              icon = Icons.error;
              label = '不良品处理';
              break;
            case 5:
              icon = Icons.error_outline;
              label = '不良品记录';
              break;
            case 6:
              icon = Icons.check_circle;
              label = '设备巡检';
              break;
            default:
              icon = Icons.assignment;
              label = '未知';
          }

          return _buildFunctionIcon(icon, label, onTap);
        }),
      ),
    );
  }

// 新增方法：显示选择对话框让用户选择领取哪种类型的物料
  void _selectMaterialType(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('请选择领取类型'),
        children: <Widget>[
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop('原材料');
            },
            child: const Text('领取原材料'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop('工序材料');
            },
            child: const Text('领取工序材料'),
          ),
        ],
      ),
    );

    if (result == '原材料') {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => MaterialIssuancePage()));
    } else if (result == '工序材料') {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => MaterialIssuancePage2()));
    }
  }

  // 构建单个功能图标，并添加点击事件
  Widget _buildFunctionIcon(IconData icon, String label, VoidCallback? onTap) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onTap, // 添加点击事件
        child: Column(
          children: [
            Icon(
              icon,
              size: 48.0,
              color: Colors.blue[500],
            ),
            SizedBox(height: 8.0),
            Text(
              label,
              style: TextStyle(fontSize: 14.0),
            ),
          ],
        ),
      ),
    );
  }
}