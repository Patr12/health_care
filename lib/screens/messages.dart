import 'package:flutter/material.dart';
import 'package:health/components/chatCard.dart';
import 'package:health/components/customAppBar.dart';
import 'package:health/models/chat.dart';

import 'package:health/screens/messageScreen.dart';

import '../utils/config.dart';

class Messages extends StatefulWidget {
  const Messages({super.key});

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {

  @override
  Widget build(BuildContext context) {
    Config().init(context);

    return Scaffold(
      appBar: CustomAppBar(
        appTitle: "Chat with Your Doctor",
        icon: const Icon(Icons.menu),
        actions: [
        IconButton(
          icon: const Icon(Icons.search),
          color: Colors.white,
          onPressed: () {},
        ),
      ],
      ),
      body: const Body(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Config.primaryColor,
        child: const Icon(
          Icons.person_add_alt_1,
          color: Colors.white,
        ),
      ),
    );
  }
}

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: chatsData.length,
            itemBuilder: (context, index) => ChatCard(
              chat: chatsData[index],
              press: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MessagesScreen(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
