import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lg_connection/components/connection_flag.dart';
import 'package:lg_connection/utils/helper.dart';
import 'package:lg_connection/utils/kml_makers.dart';

import '../components/reusable_card.dart';
import '../connections/ssh.dart';

bool connectionStatus = false;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SSH ssh;
  String location = 'NO Location YET';
  String lat = 'NO Lat YET';
  String long = 'NO Long YET';
  String city = 'NO CITY YET';
  late Position locator;
  bool enabled = false;

  @override
  void initState() {
    super.initState();
    ssh = SSH();
    _connectToLG();
    _determinePosition();
  }

  Future<void> _connectToLG() async {
    bool? result = await ssh.connectToLG();
    setState(() {
      connectionStatus = result!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.deepPurple.shade300,
        /*appBar: AppBar(
          title: const Text('LG Connection'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () async {
                await Navigator.pushNamed(context, '/settings');
                _connectToLG();
              },
            ),
          ],
        ),*/
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.only(top: 10, left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ConnectionFlag(
                      status: connectionStatus,
                      backgroundColor: Colors.deepPurple.shade400,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 20.0, 0.0),
                      child: IconButton(
                          onPressed: () async {
                            await Navigator.pushNamed(context, '/settings');
                            _connectToLG();
                          },
                          icon: const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 45.0,
                          )),
                    )
                  ],
                )),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: GalaxyButton(
                      colour: Colors.deepPurple.shade300,
                      onPress: () async {
                        if (!connectionStatus) showError();
                        await showDialog(
                          useRootNavigator: false,
                            context: context,
                            builder: (BuildContext context) {
                              return
                                AlertDialog(
                                  title: const Row(
                                    children: [
                                      Icon(
                                        Icons.warning,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 0.0),
                                      Text('Warning!'),
                                    ],
                                  ),
                                  content: const Text(
                                      'This will reboot all the machines in the Liquid galaxy Rig.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        'CANCEL',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {

                                        await ssh.rebootLG(context);
                                        print('successfully rebooted');
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        'REBOOT',
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                  ],
                              );
                            });
                      },
                      cardChild: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.reset_tv,
                                color: Colors.white, size: 55.0),
                            SizedBox(width: 25.0),
                            Text(
                              'REBOOT LG',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GalaxyButton(
                      colour: Colors.deepPurple.shade300,
                      onPress: () async {
                        if (!connectionStatus) showError();
                        await _determinePosition();
                        await ssh.flyTo(context, double.parse(lat),
                            double.parse(long), 7934.28515625, 0, 0);
                        print('execution finished');
                      },
                      cardChild: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.home_work,
                                color: Colors.white, size: 55.0),
                            SizedBox(width: 25.0),
                            Text(
                              'HOME-CITY',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            //
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: GalaxyButton(
                      onPress: () async {
                        if (!connectionStatus) showError();
                        /*await _determinePosition();
                          await _getCity(locator.latitude, locator.longitude);
                          await ssh.flyTo(context, double.parse(lat), double.parse(long), 7934.28515625, 0, 0);
                          await ssh.flyToOrbit(context, double.parse(lat), double.parse(long), 7934.28515625, 0, 10);
                          //ssh.startOrbit(context);
                          print("Orbit Succeeded");*/
                        await _determinePosition();
                        String str = KMLMakers.buildTourOrbit(double.parse(lat),
                            double.parse(long), 7934.28515625, 0, 0);
                        File file = await ssh.makeFile('Orbit', str);
                        await ssh.kmlFileUpload(context, file, 'Orbit');
                        print("uploaded successfully");
                        await ssh.runKml(context, 'Orbit');
                        print("KML RAN");
                        await ssh.startOrbit(context);
                        /*if (!mounted) {
                            return;
                          }*/
                        /*for(int i =0; i<=str.length-100;i+=100)
                            {
                              print(str.substring(i,i+100));
                            }*/
                      },
                      cardChild: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.my_location,
                                color: Colors.white, size: 55.0),
                            SizedBox(width: 25.0),
                            Text(
                              'ORBIT-HOME-CITY',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      colour: Colors.deepPurple.shade300,
                    ),
                  ),
                  Expanded(
                    child: GalaxyButton(
                      colour: Colors.deepPurple.shade300,
                      onPress: () async {
                        if (!connectionStatus) showError();
                        await _determinePosition();
                        String imgLink =
                            "https://raw.githubusercontent.com/AritraBiswas9788/QuickAccessFiles/main/GithubAvatar.jpg";
                        String balloonKml = KMLMakers.orbitBalloon(
                            double.parse(lat),
                            double.parse(long),
                            7934.28515625,
                            0,
                            10,
                            "Aritra Biswas",
                            imgLink,
                            city);
                        int rightMostVM = (ssh.sendRigs() ~/ 2) + 1;
                        print("VM: $rightMostVM");
                        await ssh.renderInSlave(
                            context, rightMostVM, balloonKml);
                        //await ssh.setRefresh(context);
                        print("RENDER COMMAND COMPLETED");
                      },
                      cardChild: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.settings_ethernet,
                                color: Colors.white, size: 55.0),
                            SizedBox(width: 25.0),
                            Text(
                              'HTML-BUBBLE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    locator = await Geolocator.getCurrentPosition();
    _getCity(locator.latitude, locator.longitude);
    setState(() {
      lat = locator.latitude.toString();
      long = locator.longitude.toString();
      print("lat: $lat, long: $long");
    });
  }

  Future<void> _getCity(double latitude, double longitude) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    // print(placemarks.toString());
    city =
        placemarks[0].locality != null ? placemarks[0].locality! : "not found";
  }

  void showError() {
    showSnackBar(context: context, message: "LIQUID GALAXY RIG NOT CONNECTED");
  }
}
