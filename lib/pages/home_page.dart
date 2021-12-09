// ignore_for_file: prefer_const_constructors, unnecessary_new, prefer_const_literals_to_create_immutables, avoid_function_literals_in_foreach_calls

import 'package:bouldr/pages/add_venue.dart';
import 'package:bouldr/pages/area_page.dart';
import 'package:bouldr/pages/settings_page.dart';
import 'package:bouldr/pages/venue_page.dart';
import 'package:bouldr/utils/authentication.dart';
import 'package:bouldr/widgets/home_map.dart';
import 'package:bouldr/widgets/venue_widget.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repository/data_repository.dart';
import '../widgets/home_map.dart';
import 'package:in_app_review/in_app_review.dart';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  HomePage(BuildContext context, {Key? key}) : super(key: key);
  final DataRepository repository = DataRepository();
  String param = "";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SharedPreferences prefs;
  bool dynamic_link = false;

  @override
  void initState() {
    super.initState();
    initDynamicLinks();
    incrementReviewCount();
  }

  void incrementReviewCount() async {
    final InAppReview inAppReview = InAppReview.instance;
    prefs = await SharedPreferences.getInstance();
    try {
      var reviewCount = prefs.getInt('reviewCount');
      var userReviewed = prefs.getBool('userReviewed');

      if (reviewCount == null || userReviewed == null) {
        prefs.setInt('reviewCount', 0);
        prefs.setBool('userReviewed', false);

        reviewCount = prefs.getInt('reviewCount');
        userReviewed = prefs.getBool('userReviewed');
      }

      if (userReviewed == false) {
        if (reviewCount! < 5) {
          prefs.setInt('reviewCount', reviewCount + 1);
        } else {
          prefs.setInt('reviewCount', 0);
          if (await inAppReview.isAvailable()) {
            inAppReview
                .requestReview()
                .whenComplete(() => prefs.setBool('userReviewed', true));
          }
        }
      }
    } catch (e) {
      print('Error: ' + e.toString());
    }
  }

  void handleDeeplink(Uri deepLink) async {
    dynamic_link = true;

    String? venueId;
    String? areaId;
    String? sectionId;
    String? routeId;

    deepLink.queryParameters.forEach((key, value) {
      if (key == "venue") {
        venueId = value;
      } else if (key == "area") {
        areaId = value;
      } else if (key == "section") {
        sectionId = value;
      } else if (key == "route") {
        routeId = value;
      }
    });

    if (venueId != null) {
      /*
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomePage(context)),
          (Route<dynamic> route) => false);
          */

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VenuePage(venueId!),
        ),
      );
    }

    if (areaId != null && sectionId == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AreaPage(venueId!, areaId!),
        ),
      );
    }

    if (areaId != null && sectionId != null && routeId == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AreaPage(venueId!, areaId!, sectionId: sectionId!),
        ),
      );
    }

    if (areaId != null && sectionId != null && routeId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AreaPage(venueId!, areaId!,
              sectionId: sectionId!, routeId: routeId!),
        ),
      );
    }
  }

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData? dynamicLink) async {
      final Uri? deepLink = dynamicLink?.link;

      if (deepLink != null) {
        //Navigator.pushNamed(context, deepLink.path);
        handleDeeplink(deepLink);
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      //Navigator.pushNamed(context, deepLink.path);
      handleDeeplink(deepLink);
    }
  }

  Future<int> getDefaultTab() async {
    prefs = await SharedPreferences.getInstance();
    var defaultHomeTab = prefs.getInt('defaultHomeTab') ?? 1;
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
      case 'Add location':
        if (AuthenticationHelper().user != null) {
          Navigator.push(
                  context, MaterialPageRoute(builder: (context) => AddVenue()))
              .then((value) => {
                    /*
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomePage(context)))*/
                    setState(() {
                      widget.param = "";
                    })
                  });
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
            return DefaultTabController(
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
                              return {'Add location', 'Settings'}
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
                        HomeMapWidget(widget.param, dynamic_link),
                        VenueWidget(),
                      ],
                    ),
                    floatingActionButton: Visibility(
                        visible: true,
                        child: FloatingActionButton.extended(
                            backgroundColor: Colors.green,
                            onPressed: () => {handleActions('Add location')},
                            label: Text('Add location'),
                            icon: Icon(Icons.location_on))));
              }),
            );
          }
        }
      },
    );
  }
}
