import "package:circles_app/presentation/calendar/calendar_screen.dart";
import "package:circles_app/presentation/home/channel_list/channel_list.dart";
import "package:circles_app/presentation/home/group_list/group_list.dart";
import "package:circles_app/theme.dart";
import "package:flutter/material.dart";

enum DrawerState { CALENDAR, CHANNEL }

class CirclesDrawer extends StatefulWidget {
  @override
  _CirclesDrawerState createState() => _CirclesDrawerState();
}

class _CirclesDrawerState extends State<CirclesDrawer> {
  DrawerState _drawerState = DrawerState.CHANNEL;

  _drawerStateChange(DrawerState state) {
    setState(() {
      _drawerState = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Container(
      decoration: BoxDecoration(
        color: Color(0xff00a368),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GroupList(_drawerStateChange),
          _drawerState == DrawerState.CALENDAR
              ? CalendarScreen()
              : ChannelsList()
        ],
      ),
    ));
  }
}
