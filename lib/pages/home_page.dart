// ignore_for_file: prefer_const_constructors, unnecessary_new, prefer_const_literals_to_create_immutables, avoid_function_literals_in_foreach_calls

import 'package:bouldr/pages/add_venue.dart';
import 'package:bouldr/pages/settings_page.dart';
import 'package:bouldr/utils/authentication.dart';
import 'package:bouldr/widgets/home_map.dart';
import 'package:bouldr/widgets/venue_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repository/data_repository.dart';
import '../widgets/home_map.dart';

class HomePage extends StatefulWidget {
  HomePage(BuildContext context, {Key? key}) : super(key: key);
  final DataRepository repository = DataRepository();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SharedPreferences prefs;

  Future<int> getDefaultTab() async {
    prefs = await SharedPreferences.getInstance();
    var defaultHomeTab = prefs.getInt('defaultHomeTab') ?? 0;
    return Future.value(defaultHomeTab);
  }

  void userAccountPressed() {
    if (AuthenticationHelper().user == null) {
      AuthenticationHelper().loginDialogue(context);
    } else {
      Fluttertoast.showToast(
        msg: AuthenticationHelper().user.uid,
      );
    }
  }

  void handleActions(String value) {
    switch (value) {
      case 'Add venue':
        if (AuthenticationHelper().user != null) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddVenue()));
        } else {
          Fluttertoast.showToast(
            msg: "Must be logged in to perform this action",
          );
          AuthenticationHelper().loginDialogue(context);
        }
        break;
      case 'Settings':
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SettingsPage()));
        break;
    }
  }

  TabBar get _tabBar => TabBar(
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map),
                const SizedBox(width: 8),
                Text('Map'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.list),
                const SizedBox(width: 8),
                Text('List'),
              ],
            ),
          ),
        ],
        labelColor: Colors.grey,
        indicatorColor: Colors.greenAccent,
      );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: getDefaultTab(),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Text('Loading...'));
        } else {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            if (prefs.getString('gradingScale') == null) {
              prefs.setString('gradingScale', "v");
            }
            SystemChrome.setPreferredOrientations(
                [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primarySwatch: Colors.green,
              ),
              home: DefaultTabController(
                initialIndex: snapshot.data!.toInt(),
                length: 2,
                child: Builder(builder: (context) {
                  final tabController = DefaultTabController.of(context)!;
                  tabController.addListener(() {
                    prefs.setInt('defaultHomeTab', tabController.index);
                  });
                  return Scaffold(
                    appBar: AppBar(
                        actions: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                            onPressed: () =>
                                {AuthenticationHelper().loginDialogue(context)},
                          ),
                          PopupMenuButton<String>(
                            onSelected: (handleActions),
                            itemBuilder: (BuildContext context) {
                              return {'Add venue', 'Settings'}
                                  .map((String choice) {
                                return PopupMenuItem<String>(
                                  value: choice,
                                  child: Text(choice),
                                );
                              }).toList();
                            },
                          ),
                        ],
                        centerTitle: false,
                        titleTextStyle: TextStyle(
                            fontSize: 32,
                            fontFamily: 'Accent',
                            fontWeight: FontWeight.w100),
                        bottom: PreferredSize(
                          preferredSize: _tabBar.preferredSize,
                          child: ColoredBox(
                            color: Colors.white,
                            child: _tabBar,
                          ),
                        ),
                        title: Container(
                          padding: EdgeInsets.fromLTRB(0, 6, 0, 0),
                          child: Text('bouldr'),
                        ),
                        backgroundColor: Colors.green),
                    body: TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        HomeMapWidget(),
                        VenueWidget(),
                      ],
                    ),
                  );
                }),
              ),
            );
          }
        }
      },
    );
  }
}
