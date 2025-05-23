import 'package:flutter/material.dart';
import 'package:health/components/chatBody.dart';
import 'package:health/utils/config.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: const Body(),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.blue, 
      iconTheme: IconThemeData(color: Colors.white),
      title: const Row(
        children: [
          Icon(Icons.arrow_back_ios),
          SizedBox(width: 10,),
          CircleAvatar(
            backgroundImage: AssetImage("assets/doctor_4.jpg"),
          ),
          SizedBox(width: Config.defaultPadding * 0.75),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hana Gamage",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              Text(
                "Active 3m ago",
                style: TextStyle(fontSize: 12, color: Colors.white),
              )
            ],
          )
        ],
      ),
    );
  }
}
