import 'package:health/utils/config.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, this.appTitle, this.route, this.icon, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  final String? appTitle;
  final String? route;
  final Icon? icon;
  final List<Widget>? actions;

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true, 
      backgroundColor: Colors.blue, // background color is white in this app
      elevation: 0,
      title: Center(
        child: Text(
          widget.appTitle!,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      //if icon is not set, return null
      centerTitle: true,
      leading: widget.icon != null ? Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 10, 
          vertical: 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Config.primaryColor,
        ),
        child: IconButton(
          onPressed: () {
            //if route is given, then this icon button will navigate to that route
            if (widget.route != null) {
              Navigator.of(context).pushNamed(widget.route!);
            } else {
              //else, just simply pop back to previous page
              Navigator.of(context).pop();
            }
          },
          icon: widget.icon!,
          iconSize: 16,
          color: Colors.white,
        ),
      )
      : null,
      //if action is not set, return null
      actions: widget.actions,
    );
  }
}
