import 'package:flutter/material.dart';
import '../services/User_service.dart';
import '../services/login_service.dart';
import '../services/production_task_service.dart';

class ProductionTaskPage extends StatefulWidget {
  @override
  _ProductionTaskPageState createState() => _ProductionTaskPageState();
}

class _ProductionTaskPageState extends State<ProductionTaskPage> {
  String? _username; // 存储工号
  String? _name; // 存储姓名

  final loginService = LoginService(); // 登录服务实例
  final userService = UserService(); // 用户服务实例
  late SearchParams searchParams; // 延迟初始化 searchParams

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
          // 初始化 searchParams，确保 _name 不为 null
          searchParams = SearchParams(
            pageNum: 1,
            pageSize: 10,
            worker: _name ?? '', // 使用 _name 的值，如果为 null，则使用空字符串
          );
        });
      } catch (e) {
        print('Error fetching user details: $e');
      }
    }
  }

  final ticketService = TicketService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('生产任务'),
        backgroundColor: Colors.lightBlueAccent, // 设置顶部导航栏颜色
      ),
      body: FutureBuilder<List<Tickets>>(
        future: _name != null ? ticketService.getTickets(searchParams) : Future.value([]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('未找到任务'));
          } else {
            final tickets = snapshot.data!;
            return ListView.builder(
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
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
                          '工单编号: ${ticket.ticketID}',
                          style: TextStyle(
                            color: Colors.blueGrey[700], // 设置文本颜色
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8), // 设置间距
                        Text(
                          '产品名称: ${ticket.productName}',
                          style: TextStyle(color: Colors.blueGrey[600], fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '车间: ${ticket.workshop}',
                          style: TextStyle(color: Colors.blueGrey[600], fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '班组: ${ticket.team}',
                          style: TextStyle(color: Colors.blueGrey[600], fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '工人: ${ticket.worker}',
                          style: TextStyle(color: Colors.blueGrey[600], fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '等级: ${ticket.grade}',
                          style: TextStyle(color: Colors.blueGrey[600], fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '工序: ${ticket.process}',
                          style: TextStyle(color: Colors.blueGrey[600], fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '数量: ${ticket.number}',
                          style: TextStyle(color: Colors.blueGrey[600], fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '开始日期: ${ticket.startDate}',
                          style: TextStyle(color: Colors.blueGrey[600], fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '结束日期: ${ticket.endDate}',
                          style: TextStyle(color: Colors.blueGrey[600], fontSize: 16),
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