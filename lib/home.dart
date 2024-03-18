import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' show Geolocator, LocationAccuracy, LocationSettings, LocationPermission, Position;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);


  @override
  State<HomeTab> createState() => _HomeTabState();
}
// TODO: where to put logo
// TODO: Make function that returns current lat and long to database
// TODO: make splash screen with 3 consent
// TODO: step counter like notification
// TODO: change to time until, current time based on location and 12-hour instead
// TODO: solar eclipse graphic
// TODO: after making observation, after totality done, cant delete anymore
// TODO: get location loading

// TODO: Swiping gets user to empty screen (center)
// TODO: Test by adding solar eclipse date as today

// TODO: update app logo/icon
// TODO: make location work for when approx, test locations
class _HomeTabState extends State<HomeTab> {

  bool locationRetrieved = false;
  late SharedPreferences _prefs;

  DateTime timeEclipseBegins = DateTime(1970);
  DateTime timeEclipseEnds = DateTime(1970);
  DateTime timeMaxEclipse = DateTime(1970);
  DateTime timeTotalityBegins = DateTime(1970);
  DateTime timeTotalityEnds = DateTime(1970);

  late String _lat;
  late String _long;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed){
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
      else{
        AwesomeNotifications().initialize(
          'resource://drawable/out_logo_draw2',
          [
            NotificationChannel(
              channelKey: 'scheduled',
              channelName: 'Basic Notifications',
              channelDescription: 'Notif channel for basic tests',
            ),
          ],
          debug: true,
        );
      }
    });

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed){
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
      else {
        AwesomeNotifications().initialize(
          'resource://drawable/out_logo_draw2',
          [
            NotificationChannel(
              channelKey: 'scheduled',
              channelName: 'Basic Notifications',
              channelDescription: 'Notif channel for basic tests',
            ),
          ],
          debug: true,
        );
      }
    });

    initTimer();
    _loadData();
  }

  Timer? timer;

  void initTimer() {
    if (timer != null && timer!.isActive) return;

    timer = Timer.periodic(const Duration(seconds: 1), (timer) { // TODO: test optimal seconds val, CHANGE to 15-30 seconds
      //job
      setState(() {
        moonPosition = calculateMoonPosition();
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
    mapController.dispose();
  }

  double moonPosition = -20000; // TODO: will have to have it in sharedPref


  // Function to load data from SharedPreferences
  Future<void> _loadData() async {
    _prefs = await SharedPreferences.getInstance();
    if (this.mounted){
      setState(() {
        // Initialize variables with data from SharedPreferences or default values
        _lat = _prefs.getString('lat') ?? '';
        _long = _prefs.getString('long') ?? '';
      });}
  }
  // Function to save data to SharedPreferences
  Future<void> _saveData() async {
    _prefs.setString('lat', _lat ?? "");
    _prefs.setString('long', _long ?? "");
  }

  Future<void> showScheduledNotification(int id, String channelKey,
      String title, String body, DateTime interval) async {
    String localTZ = await AwesomeNotifications().getLocalTimeZoneIdentifier();

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: channelKey,
        title: title,
        body: body,
        locked: true,
        criticalAlert: true,
        category: NotificationCategory.Alarm,

      ),
      schedule: NotificationCalendar.fromDate(date: interval),
      actionButtons: <NotificationActionButton>[
        NotificationActionButton(key: 'remove', label: 'Stop'),

      ],
    );}

  void _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      setState(() {
        locationRetrieved = false;
      });
    } else {
      setState(() async {
        _getCurrentLocation().then((value) {
          lat = '${value.latitude}';
          long = '${value.longitude}';
          altitude = '${value.altitude}';
          setState(() {
            _lat = lat;
            _long = long;
            print("DATA SAVED");
            online_color = Colors.green;
            locationMessage = 'Lat: $lat, Long: $long, Alt: $altitude';
            getLocationInfo();
            locationRetrieved = true;
            _setMap();
          });
        });
        await _saveData();
        _liveLocation();
        locationRetrieved = true;
      });
    }}
  final JavascriptRuntime jsRuntime = getJavascriptRuntime();

  String locationMessage = "";
  late String lat;
  late String long;
  late String altitude;

  bool loading = false;

  GoogleMap? map;
  late GoogleMapController mapController;

  String online = "●";
  Color online_color = Colors.red;

  late String timeUntilEclipseBegins = '';
  late String timeUntilTotalityBegins = '';
  late String timeUntilMaxEclipse = '';
  late String expectedObscuration = '';
  late String expectedMagnitude = '';

  late Column text_col = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Eclipse begins: ${timeUntilEclipseBegins}',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      Text(
        'Totality begins: ${timeUntilTotalityBegins}',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      Text(
        'Max Eclipse: ${timeUntilMaxEclipse}',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      Text(
        '',
        style: TextStyle(fontSize: 18),
      ),
      Text(
        'Max Coverage: ${expectedMagnitude}',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    ],
  );

  // TODO: test

  // Calculate the left position of the moon container based on current time
  double calculateMoonPosition() {
    DateTime currentTime = DateTime.now();
    double progress = 0.0;

    if (currentTime.isBefore(timeEclipseBegins)) {
      progress = 0.0;
    } else if (currentTime.isAfter(timeEclipseEnds)) {
      progress = 1.0;
    } else {
      progress = (currentTime.difference(timeEclipseBegins).inSeconds /
          timeEclipseEnds.difference(timeEclipseBegins).inSeconds)
          .clamp(0.0, 1.0);
    }
    // Adjust the left position of the moon container based on the progress
    return MediaQuery.of(context).size.width * (0.424) - 62.5 + 125 * progress;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ThemeData.dark(useMaterial3: true),
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text(
                "●",
                style: TextStyle(
                  color: online_color, // Change this to the desired color for "online"
                ),
              ),
              Text(
                " My Location",
                style: TextStyle(
                  // Default text color or any other styles you want to apply
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: Size.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 0), // Add some spacing between the title and location message
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft, // Align to the left
                    child: Text(
                      locationMessage,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (locationRetrieved)
              Expanded(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    // Your map widget here
                    Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: map,
                    ),
                    SizedBox(height: 20), // Add some spacing

                  Container(
                  width: double.infinity,
                    child:
                    Stack(

                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 65, // Adjust the size as needed
                          height: 65, // Adjust the size as needed
                          decoration: BoxDecoration(
                            color: Color(0xFFF69A06), // Desired color
                            shape: BoxShape.circle,
                          ),
                        ),

                        // IF MOON OVERLAPPING STAR,
                        // MAKE THE COLOR OF MOON DARKER
                        Positioned(
                          left: moonPosition, // Adjust the left position as needed
                          child: Container(
                            width: 60, // Adjust the size as needed
                            height: 60, // Adjust the size as needed
                            decoration: BoxDecoration(
                              color: Color(0xFF000000), // Black color
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),),

                SizedBox(height: 20),

                    // Text section for time until different eclipse events
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      padding: EdgeInsets.all(10), // Add padding for better appearance
                      decoration: BoxDecoration(
                        color: Color(0xFF25232A),
                        borderRadius: BorderRadius.circular(10), // Set border radius for rounded edges
                      ),
                      child: text_col,
                    ),
                  ],
                ),
              ),
            if (!locationRetrieved)
              Column(
                children: [
                  Text(
                    "Looks like you have location turned off",
                    style: TextStyle(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() { loading = true; });
                        _getCurrentLocation().then((value) async {
                          lat = '${value.latitude}';
                          long = '${value.longitude}';
                          altitude = '${value.altitude}';
                          setState(() {
                            online_color = Colors.green;
                            locationMessage = 'Lat: $lat, Long: $long, Alt: $altitude';
                            getLocationInfo();
                            locationRetrieved = true;
                            loading = false;
                            _setMap();
                            _lat = lat;
                            _long = long;
                            print("DATA SAVED");
                          });

                          await _saveData();
                          _liveLocation();
                        }).catchError((error) { setState(() {
                          loading = false;
                        });});

                      },
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Color(0xFFF69A06), // Set the foreground color (text color) of the button
                      ),

                      child: Text("Get Location"),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            if (loading)
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF69A06)), // Change the color here
              ), // Loading circle
          ],
        ),
      ),
    );
  }
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled){
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied){
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          "location permissions are permanently denied, we cannot request permission.");
    }
    return await Geolocator.getCurrentPosition();
  }

  void _liveLocation(){
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) async {
      lat = position.latitude.toString();
      long = position.longitude.toString();

      setState(() {
        _lat = lat;
        _long = long;
        print("DATA SAVED");
        _saveData();
        //locationMessage = 'Lat: $lat, Long: $long, Alt: $altitude';

        getLocationInfo();
        mapController.animateCamera(CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)));
        _setMap();
      });


    });

    }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
      _setMapStyle();
    });
  }

  void _setMapStyle() async {
    String style = '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#212121"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#212121"
      }
    ]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "administrative.country",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#181818"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#1b1b1b"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#2c2c2c"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#8a8a8a"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#373737"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#3c3c3c"
      }
    ]
  },
  {
    "featureType": "road.highway.controlled_access",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#4e4e4e"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#000000"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#3d3d3d"
      }
    ]
  }
]''';

    await mapController.setMapStyle(style);
  }

  Future<void> _setMap() async {
    map = GoogleMap(
      onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(double.parse(lat), double.parse(long)),
          zoom: 5.0,
        ),
        polylines: {
          Polyline(
          polylineId: PolylineId('line'),
          color: Colors.red,
          width: 4,
          points: [
            LatLng(-7.628757, -157.165504),
            LatLng(-7.540839, -156.582333),
            LatLng(-7.471794, -156.140206),
            LatLng(-7.412382, -155.770035),
            LatLng(-7.359089, -155.445562),
            LatLng(-7.310127, -155.153432),
            LatLng(-7.264442, -154.885754),
            LatLng(-7.221348, -154.637401),
            LatLng(-7.180368, -154.404824),
            LatLng(-7.141158, -154.185441),
            LatLng(-7.103457, -153.977306),
            LatLng(-7.067064, -153.77891),
            LatLng(-7.031816, -153.589053),
            LatLng(-6.997585, -153.406763),
            LatLng(-6.964263, -153.231239),
            LatLng(-6.93176, -153.061813),
            LatLng(-6.900001, -152.89792),
            LatLng(-6.868921, -152.739078),
            LatLng(-6.838465, -152.584868),
            LatLng(-6.808583, -152.434929),
            LatLng(-6.779233, -152.288945),
            LatLng(-6.750378, -152.146633),
            LatLng(-6.721984, -152.007748),
            LatLng(-6.694022, -151.872065),
            LatLng(-6.666465, -151.739388),
            LatLng(-6.639289, -151.609537),
            LatLng(-6.612473, -151.48235),
            LatLng(-6.585996, -151.357681),
            LatLng(-6.559841, -151.235394),
            LatLng(-6.53399, -151.115368),
            LatLng(-6.50843, -150.997491),
            LatLng(-6.483147, -150.881658),
            LatLng(-6.458126, -150.767775),
            LatLng(-6.433358, -150.655754),
            LatLng(-6.40883, -150.545512),
            LatLng(-6.384532, -150.436974),
            LatLng(-6.360456, -150.33007),
            LatLng(-6.336592, -150.224733),
            LatLng(-6.312932, -150.120901),
            LatLng(-6.289467, -150.018518),
            LatLng(-6.266192, -149.917529),
            LatLng(-6.243099, -149.817883),
            LatLng(-6.220181, -149.719533),
            LatLng(-6.197434, -149.622432),
            LatLng(-6.17485, -149.52654),
            LatLng(-6.152424, -149.431816),
            LatLng(-6.130152, -149.338222),
            LatLng(-6.108028, -149.245721),
            LatLng(-6.086049, -149.154281),
            LatLng(-6.064209, -149.063868),
            LatLng(-6.042505, -148.974452),
            LatLng(-6.020932, -148.886003),
            LatLng(-5.999487, -148.798494),
            LatLng(-5.978167, -148.711898),
            LatLng(-5.956967, -148.62619),
            LatLng(-5.935885, -148.541346),
            LatLng(-5.914917, -148.457343),
            LatLng(-5.894061, -148.374158),
            LatLng(-5.873314, -148.291771),
            LatLng(-5.852673, -148.21016),
            LatLng(-5.832135, -148.129308),
            LatLng(-5.811698, -148.049195),
            LatLng(-5.791359, -147.969803),
            LatLng(-5.771117, -147.891116),
            LatLng(-5.750969, -147.813116),
            LatLng(-5.730912, -147.735788),
            LatLng(-5.710945, -147.659117),
            LatLng(-5.691066, -147.583088),
            LatLng(-5.671273, -147.507687),
            LatLng(-5.651564, -147.432899),
            LatLng(-5.631937, -147.358713),
            LatLng(-5.612391, -147.285116),
            LatLng(-5.592923, -147.212094),
            LatLng(-5.573533, -147.139637),
            LatLng(-5.554219, -147.067732),
            LatLng(-5.534979, -146.99637),
            LatLng(-5.515812, -146.925538),
            LatLng(-5.496716, -146.855228),
            LatLng(-5.477691, -146.785428),
            LatLng(-5.458734, -146.716129),
            LatLng(-5.439845, -146.647322),
            LatLng(-5.421022, -146.578997),
            LatLng(-5.402264, -146.511147),
            LatLng(-5.38357, -146.443761),
            LatLng(-5.364939, -146.376832),
            LatLng(-5.34637, -146.310352),
            LatLng(-5.327861, -146.244314),
            LatLng(-5.309412, -146.178708),
            LatLng(-5.291022, -146.113529),
            LatLng(-5.272689, -146.048768),
            LatLng(-5.254413, -145.984419),
            LatLng(-5.236193, -145.920476),
            LatLng(-5.218028, -145.856931),
            LatLng(-5.199917, -145.793777),
            LatLng(-5.18186, -145.73101),
            LatLng(-5.163854, -145.668622),
            LatLng(-5.145901, -145.606608),
            LatLng(-5.127998, -145.544962),
            LatLng(-5.110145, -145.483678),
            LatLng(-5.092341, -145.422751),
            LatLng(-5.074586, -145.362175),
            LatLng(-5.056879, -145.301946),
            LatLng(-5.03922, -145.242058),
            LatLng(-5.021606, -145.182505),
            LatLng(-5.004039, -145.123285),
            LatLng(-4.986517, -145.06439),
            LatLng(-4.969039, -145.005818),
            LatLng(-4.951606, -144.947563),
            LatLng(-4.934215, -144.889621),
            LatLng(-4.916868, -144.831988),
            LatLng(-4.899563, -144.774659),
            LatLng(-4.882299, -144.717631),
            LatLng(-4.865077, -144.660898),
            LatLng(-4.847895, -144.604459),
            LatLng(-4.830754, -144.548307),
            LatLng(-4.813652, -144.492441),
            LatLng(-4.796589, -144.436855),
            LatLng(-4.779564, -144.381547),
            LatLng(-4.762578, -144.326513),
            LatLng(-4.745629, -144.271749),
            LatLng(-4.728718, -144.217252),
            LatLng(-4.711843, -144.16302),
            LatLng(-4.695004, -144.109047),
            LatLng(-4.678202, -144.055332),
            LatLng(-4.661435, -144.001871),
            LatLng(-4.644702, -143.948661),
            LatLng(-4.628005, -143.895699),
            LatLng(-4.611341, -143.842983),
            LatLng(-4.594712, -143.790508),
            LatLng(-4.578116, -143.738273),
            LatLng(-4.561553, -143.686275),
            LatLng(-4.545022, -143.634511),
            LatLng(-4.528524, -143.582978),
            LatLng(-4.512058, -143.531674),
            LatLng(-4.495624, -143.480596),
            LatLng(-4.479221, -143.429742),
            LatLng(-4.462849, -143.379108),
            LatLng(-4.446507, -143.328694),
            LatLng(-4.430196, -143.278495),
            LatLng(-4.413914, -143.228511),
            LatLng(-4.397663, -143.178738),
            LatLng(-4.381441, -143.129175),
            LatLng(-4.365247, -143.079819),
            LatLng(-4.349083, -143.030668),
            LatLng(-4.332947, -142.981719),
            LatLng(-4.316839, -142.932972),
            LatLng(-4.300759, -142.884423),
            LatLng(-4.284707, -142.836071),
            LatLng(-4.268682, -142.787913),
            LatLng(-4.252684, -142.739948),
            LatLng(-4.236713, -142.692174),
            LatLng(-4.220769, -142.644589),
            LatLng(-4.20485, -142.59719),
            LatLng(-4.188958, -142.549977),
            LatLng(-4.173092, -142.502947),
            LatLng(-4.157251, -142.456099),
            LatLng(-4.141436, -142.40943),
            LatLng(-4.125646, -142.362939),
            LatLng(-4.10988, -142.316625),
            LatLng(-4.094139, -142.270485),
            LatLng(-4.078423, -142.224519),
            LatLng(-4.062731, -142.178723),
            LatLng(-4.047063, -142.133098),
            LatLng(-4.031418, -142.087641),
            LatLng(-4.015797, -142.04235),
            LatLng(-4.0002, -141.997225),
            LatLng(-3.984625, -141.952263),
            LatLng(-3.969074, -141.907464),
            LatLng(-3.953545, -141.862825),
            LatLng(-3.938039, -141.818345),
            LatLng(-3.922555, -141.774024),
            LatLng(-3.907093, -141.729858),
            LatLng(-3.891653, -141.685848),
            LatLng(-3.876236, -141.641992),
            LatLng(-3.860839, -141.598288),
            LatLng(-3.845464, -141.554735),
            LatLng(-3.830111, -141.511332),
            LatLng(-3.814778, -141.468078),
            LatLng(-3.799466, -141.42497),
            LatLng(-3.784175, -141.382009),
            LatLng(-3.768905, -141.339193),
            LatLng(-3.753655, -141.29652),
            LatLng(-3.738425, -141.253989),
            LatLng(-3.723216, -141.2116),
            LatLng(-3.708026, -141.169351),
            LatLng(-3.692856, -141.127241),
            LatLng(-3.677705, -141.085268),
            LatLng(-3.662575, -141.043433),
            LatLng(-3.647463, -141.001732),
            LatLng(-3.632371, -140.960167),
            LatLng(-3.617297, -140.918734),
            LatLng(-3.602243, -140.877434),
            LatLng(-3.587207, -140.836266),
            LatLng(-3.572189, -140.795227),
            LatLng(-3.557191, -140.754318),
            LatLng(-3.54221, -140.713538),
            LatLng(-3.527248, -140.672884),
            LatLng(-3.512304, -140.632357),
            LatLng(-3.497377, -140.591955),
            LatLng(-3.482469, -140.551677),
            LatLng(-3.467578, -140.511523),
            LatLng(-3.452704, -140.471492),
            LatLng(-3.437848, -140.431582),
            LatLng(-3.42301, -140.391793),
            LatLng(-3.408188, -140.352123),
            LatLng(-3.393383, -140.312573),
            LatLng(-3.378596, -140.27314),
            LatLng(-3.363825, -140.233825),
            LatLng(-3.349071, -140.194626),
            LatLng(-3.334333, -140.155542),
            LatLng(-3.319612, -140.116574),
            LatLng(-3.304907, -140.077719),
            LatLng(-3.290219, -140.038977),
            LatLng(-3.275546, -140.000347),
            LatLng(-3.26089, -139.961828),
            LatLng(-3.246249, -139.92342),
            LatLng(-3.231624, -139.885122),
            LatLng(-3.217015, -139.846934),
            LatLng(-3.202422, -139.808853),
            LatLng(-3.187844, -139.77088),
            LatLng(-3.173281, -139.733014),
            LatLng(-3.158733, -139.695254),
            LatLng(-3.144201, -139.657599),
            LatLng(-3.129684, -139.620049),
            LatLng(-3.115182, -139.582603),
            LatLng(-3.100695, -139.54526),
            LatLng(-3.086222, -139.50802),
            LatLng(-3.071764, -139.470881),
            LatLng(-3.057321, -139.433844),
            LatLng(-3.042893, -139.396908),
            LatLng(-3.028478, -139.360071),
            LatLng(-3.014078, -139.323333),
            LatLng(-2.999693, -139.286694),
            LatLng(-2.985321, -139.250153),
            LatLng(-2.970964, -139.213709),
            LatLng(-2.95662, -139.177362),
            LatLng(-2.942291, -139.14111),
            LatLng(-2.927975, -139.104955),
            LatLng(-2.913673, -139.068894),
            LatLng(-2.899384, -139.032927),
            LatLng(-2.88511, -138.997053),
            LatLng(-2.870848, -138.961273),
            LatLng(-2.8566, -138.925585),
            LatLng(-2.842366, -138.88999),
            LatLng(-2.828144, -138.854485),
            LatLng(-2.813936, -138.819071),
            LatLng(-2.799741, -138.783747),
            LatLng(-2.785559, -138.748513),
            LatLng(-2.77139, -138.713368),
            LatLng(-2.757233, -138.678311),
            LatLng(-2.74309, -138.643343),
            LatLng(-2.728959, -138.608461),
            LatLng(-2.714841, -138.573667),
            LatLng(-2.700735, -138.538959),
            LatLng(-2.686642, -138.504337),
            LatLng(-2.672561, -138.4698),
            LatLng(-2.658493, -138.435348),
            LatLng(-2.644437, -138.400981),
            LatLng(-2.630393, -138.366697),
            LatLng(-2.616361, -138.332497),
            LatLng(-2.602342, -138.298379),
            LatLng(-1.982989, -136.841759),
            LatLng(-1.383131, -135.516895),
            LatLng(-0.799268, -134.298587),
            LatLng(-0.228859, -133.168632),
            LatLng(0.330015, -132.113365),
            LatLng(0.878848, -131.122215),
            LatLng(1.41883, -130.186803),
            LatLng(1.950931, -129.300353),
            LatLng(2.475952, -128.457287),
            LatLng(2.994567, -127.652948),
            LatLng(3.507348, -126.8834),
            LatLng(4.01479, -126.145276),
            LatLng(4.517319, -125.435671),
            LatLng(5.015311, -124.752054),
            LatLng(5.509095, -124.092202),
            LatLng(5.998967, -123.454152),
            LatLng(6.485188, -122.836155),
            LatLng(6.967995, -122.236649),
            LatLng(7.447603, -121.654224),
            LatLng(7.924204, -121.087607),
            LatLng(8.397976, -120.535641),
            LatLng(8.869082, -119.997268),
            LatLng(9.33767, -119.471519),
            LatLng(9.803878, -118.957504),
            LatLng(10.267833, -118.454397),
            LatLng(10.729654, -117.961434),
            LatLng(11.189451, -117.477906),
            LatLng(11.647327, -117.003148),
            LatLng(12.103376, -116.536538),
            LatLng(12.557691, -116.077493),
            LatLng(13.010355, -115.625464),
            LatLng(13.461448, -115.179929),
            LatLng(13.911046, -114.740397),
            LatLng(14.359219, -114.306399),
            LatLng(14.806035, -113.877489),
            LatLng(15.251558, -113.45324),
            LatLng(15.695847, -113.033245),
            LatLng(16.138961, -112.617111),
            LatLng(16.580954, -112.204459),
            LatLng(17.021879, -111.794925),
            LatLng(17.461785, -111.388155),
            LatLng(17.90072, -110.983806),
            LatLng(18.338728, -110.581545),
            LatLng(18.775854, -110.181045),
            LatLng(19.212138, -109.781988),
            LatLng(19.64762, -109.384063),
            LatLng(20.082338, -108.986962),
            LatLng(20.516328, -108.590383),
            LatLng(20.949625, -108.194027),
            LatLng(21.382261, -107.7976),
            LatLng(21.814269, -107.400808),
            LatLng(22.245679, -107.00336),
            LatLng(22.67652, -106.604965),
            LatLng(23.106819, -106.205334),
            LatLng(23.536602, -105.804176),
            LatLng(23.965895, -105.401199),
            LatLng(24.394721, -104.996111),
            LatLng(24.823102, -104.588616),
            LatLng(25.251061, -104.178417),
            LatLng(25.678616, -103.765211),
            LatLng(26.105786, -103.348693),
            LatLng(26.532588, -102.928553),
            LatLng(26.959039, -102.504475),
            LatLng(27.385154, -102.076136),
            LatLng(27.810945, -101.643207),
            LatLng(28.236424, -101.205352),
            LatLng(28.661602, -100.762225),
            LatLng(29.086488, -100.313472),
            LatLng(29.511088, -99.858728),
            LatLng(29.935409, -99.397616),
            LatLng(30.359455, -98.92975),
            LatLng(30.783227, -98.454728),
            LatLng(31.206725, -97.972134),
            LatLng(31.629947, -97.481539),
            LatLng(32.052889, -96.982493),
            LatLng(32.475545, -96.474533),
            LatLng(32.897904, -95.957172),
            LatLng(33.319956, -95.429905),
            LatLng(33.741685, -94.892202),
            LatLng(34.163073, -94.343508),
            LatLng(34.584098, -93.783244),
            LatLng(35.004736, -93.210798),
            LatLng(35.424956, -92.62553),
            LatLng(35.844725, -92.026762),
            LatLng(36.264005, -91.413781),
            LatLng(36.68275, -90.785833),
            LatLng(37.100912, -90.142119),
            LatLng(37.518434, -89.481792),
            LatLng(37.935253, -88.803951),
            LatLng(38.351298, -88.107637),
            LatLng(38.766488, -87.391829),
            LatLng(39.180734, -86.655431),
            LatLng(39.593936, -85.897273),
            LatLng(40.005982, -85.116098),
            LatLng(40.416746, -84.310551),
            LatLng(40.826088, -83.479172),
            LatLng(41.233849, -82.62038),
            LatLng(41.639853, -81.732461),
            LatLng(42.0439, -80.813547),
            LatLng(42.445768, -79.861602),
            LatLng(42.845203, -78.874389),
            LatLng(43.241919, -77.849452),
            LatLng(43.635595, -76.784074),
            LatLng(44.02586, -75.675239),
            LatLng(44.412296, -74.519581),
            LatLng(44.79442, -73.313322),
            LatLng(45.171678, -72.052194),
            LatLng(45.543425, -70.731341),
            LatLng(45.908912, -69.345191),
            LatLng(46.267257, -67.887294),
            LatLng(46.617413, -66.350105),
            LatLng(46.958127, -64.724685),
            LatLng(47.287878, -63.000294),
            LatLng(47.604794, -61.163812),
            LatLng(47.906525, -59.198886),
            LatLng(48.190061, -57.08463),
            LatLng(48.451434, -54.793553),
            LatLng(48.685223, -52.28807),
            LatLng(48.883663, -49.51417),
            LatLng(48.887591, -49.44892),
            LatLng(48.891496, -49.383498),
            LatLng(48.895377, -49.317902),
            LatLng(48.899236, -49.252131),
            LatLng(48.90307, -49.186184),
            LatLng(48.906881, -49.12006),
            LatLng(48.910667, -49.053757),
            LatLng(48.91443, -48.987276),
            LatLng(48.918168, -48.920613),
            LatLng(48.921881, -48.853768),
            LatLng(48.92557, -48.78674),
            LatLng(48.929234, -48.719528),
            LatLng(48.932873, -48.652129),
            LatLng(48.936487, -48.584544),
            LatLng(48.940075, -48.51677),
            LatLng(48.943638, -48.448807),
            LatLng(48.947175, -48.380652),
            LatLng(48.950685, -48.312306),
            LatLng(48.95417, -48.243765),
            LatLng(48.957628, -48.175029),
            LatLng(48.96106, -48.106097),
            LatLng(48.964465, -48.036967),
            LatLng(48.967842, -47.967637),
            LatLng(48.971193, -47.898106),
            LatLng(48.974516, -47.828373),
            LatLng(48.977812, -47.758436),
            LatLng(48.981079, -47.688294),
            LatLng(48.984319, -47.617945),
            LatLng(48.98753, -47.547387),
            LatLng(48.990713, -47.476619),
            LatLng(48.993867, -47.40564),
            LatLng(48.996992, -47.334448),
            LatLng(49.000088, -47.26304),
            LatLng(49.003154, -47.191416),
            LatLng(49.006191, -47.119574),
            LatLng(49.009198, -47.047511),
            LatLng(49.012174, -46.975227),
            LatLng(49.015121, -46.90272),
            LatLng(49.018036, -46.829987),
            LatLng(49.020921, -46.757028),
            LatLng(49.023774, -46.683839),
            LatLng(49.026596, -46.61042),
            LatLng(49.029387, -46.536768),
            LatLng(49.032145, -46.462882),
            LatLng(49.034871, -46.388759),
            LatLng(49.037565, -46.314398),
            LatLng(49.040225, -46.239797),
            LatLng(49.042853, -46.164953),
            LatLng(49.045447, -46.089865),
            LatLng(49.048008, -46.01453),
            LatLng(49.050534, -45.938947),
            LatLng(49.053027, -45.863113),
            LatLng(49.055485, -45.787026),
            LatLng(49.057907, -45.710684),
            LatLng(49.060295, -45.634085),
            LatLng(49.062647, -45.557226),
            LatLng(49.064963, -45.480105),
            LatLng(49.067244, -45.402719),
            LatLng(49.069487, -45.325068),
            LatLng(49.071694, -45.247147),
            LatLng(49.073863, -45.168954),
            LatLng(49.075995, -45.090488),
            LatLng(49.078089, -45.011745),
            LatLng(49.080145, -44.932723),
            LatLng(49.082162, -44.85342),
            LatLng(49.08414, -44.773832),
            LatLng(49.086079, -44.693957),
            LatLng(49.087978, -44.613792),
            LatLng(49.089836, -44.533335),
            LatLng(49.091655, -44.452582),
            LatLng(49.093432, -44.371531),
            LatLng(49.095167, -44.290179),
            LatLng(49.096861, -44.208522),
            LatLng(49.098513, -44.126559),
            LatLng(49.100122, -44.044285),
            LatLng(49.101688, -43.961698),
            LatLng(49.103211, -43.878794),
            LatLng(49.104689, -43.79557),
            LatLng(49.106123, -43.712024),
            LatLng(49.107512, -43.62815),
            LatLng(49.108855, -43.543947),
            LatLng(49.110153, -43.45941),
            LatLng(49.111404, -43.374537),
            LatLng(49.112608, -43.289323),
            LatLng(49.113765, -43.203764),
            LatLng(49.114874, -43.117858),
            LatLng(49.115935, -43.0316),
            LatLng(49.116946, -42.944986),
            LatLng(49.117908, -42.858012),
            LatLng(49.118819, -42.770675),
            LatLng(49.11968, -42.68297),
            LatLng(49.12049, -42.594893),
            LatLng(49.121247, -42.50644),
            LatLng(49.121952, -42.417606),
            LatLng(49.122604, -42.328387),
            LatLng(49.123202, -42.238778),
            LatLng(49.123746, -42.148775),
            LatLng(49.124234, -42.058374),
            LatLng(49.124667, -41.967568),
            LatLng(49.125043, -41.876353),
            LatLng(49.125362, -41.784725),
            LatLng(49.125624, -41.692678),
            LatLng(49.125826, -41.600206),
            LatLng(49.125969, -41.507305),
            LatLng(49.126053, -41.413969),
            LatLng(49.126075, -41.320193),
            LatLng(49.126035, -41.22597),
            LatLng(49.125933, -41.131294),
            LatLng(49.125768, -41.036161),
            LatLng(49.125538, -40.940563),
            LatLng(49.125243, -40.844495),
            LatLng(49.124882, -40.74795),
            LatLng(49.124455, -40.650921),
            LatLng(49.123959, -40.553402),
            LatLng(49.123395, -40.455386),
            LatLng(49.122761, -40.356866),
            LatLng(49.122056, -40.257834),
            LatLng(49.121279, -40.158284),
            LatLng(49.120429, -40.058207),
            LatLng(49.119506, -39.957596),
            LatLng(49.118507, -39.856443),
            LatLng(49.117433, -39.75474),
            LatLng(49.116281, -39.652479),
            LatLng(49.11505, -39.54965),
            LatLng(49.11374, -39.446245),
            LatLng(49.112348, -39.342255),
            LatLng(49.110875, -39.237671),
            LatLng(49.109317, -39.132483),
            LatLng(49.107675, -39.026681),
            LatLng(49.105946, -38.920256),
            LatLng(49.104129, -38.813196),
            LatLng(49.102224, -38.705491),
            LatLng(49.100227, -38.597131),
            LatLng(49.098138, -38.488103),
            LatLng(49.095954, -38.378397),
            LatLng(49.093676, -38.268),
            LatLng(49.091299, -38.156899),
            LatLng(49.088824, -38.045083),
            LatLng(49.086247, -37.932538),
            LatLng(49.083568, -37.81925),
            LatLng(49.080784, -37.705206),
            LatLng(49.077893, -37.590391),
            LatLng(49.074893, -37.47479),
            LatLng(49.071783, -37.358387),
            LatLng(49.068559, -37.241168),
            LatLng(49.06522, -37.123115),
            LatLng(49.061763, -37.004211),
            LatLng(49.058185, -36.88444),
            LatLng(49.054485, -36.763781),
            LatLng(49.05066, -36.642218),
            LatLng(49.046707, -36.519729),
            LatLng(49.042622, -36.396295),
            LatLng(49.038404, -36.271895),
            LatLng(49.03405, -36.146506),
            LatLng(49.029555, -36.020107),
            LatLng(49.024917, -35.892672),
            LatLng(49.020132, -35.764179),
            LatLng(49.015198, -35.6346),
            LatLng(49.010109, -35.50391),
            LatLng(49.004863, -35.372081),
            LatLng(48.999456, -35.239083),
            LatLng(48.993883, -35.104887),
            LatLng(48.988139, -34.969461),
            LatLng(48.982221, -34.832772),
            LatLng(48.976124, -34.694784),
            LatLng(48.969842, -34.555463),
            LatLng(48.963371, -34.41477),
            LatLng(48.956704, -34.272666),
            LatLng(48.949837, -34.129108),
            LatLng(48.942764, -33.984053),
            LatLng(48.935477, -33.837455),
            LatLng(48.92797, -33.689265),
            LatLng(48.920236, -33.539433),
            LatLng(48.912269, -33.387903),
            LatLng(48.904059, -33.234618),
            LatLng(48.895599, -33.07952),
            LatLng(48.88688, -32.922542),
            LatLng(48.877892, -32.763619),
            LatLng(48.868626, -32.602677),
            LatLng(48.859072, -32.439639),
            LatLng(48.849217, -32.274425),
            LatLng(48.839051, -32.106947),
            LatLng(48.82856, -31.937111),
            LatLng(48.81773, -31.764818),
            LatLng(48.806548, -31.589961),
            LatLng(48.794997, -31.412424),
            LatLng(48.78306, -31.232082),
            LatLng(48.770719, -31.048803),
            LatLng(48.757955, -30.86244),
            LatLng(48.744744, -30.672836),
            LatLng(48.731065, -30.479818),
            LatLng(48.716892, -30.2832),
            LatLng(48.702195, -30.082774),
            LatLng(48.686945, -29.878316),
            LatLng(48.671108, -29.669576),
            LatLng(48.654645, -29.456276),
            LatLng(48.637515, -29.23811),
            LatLng(48.619671, -29.014732),
            LatLng(48.60106, -28.785757),
            LatLng(48.581622, -28.550745),
            LatLng(48.56129, -28.309199),
            LatLng(48.539986, -28.060548),
            LatLng(48.51762, -27.804132),
            LatLng(48.494087, -27.539182),
            LatLng(48.469265, -27.264793),
            LatLng(48.443005, -26.979886),
            LatLng(48.415133, -26.68316),
            LatLng(48.38543, -26.373021),
            LatLng(48.353626, -26.047479),
            LatLng(48.319377, -25.703994),
            LatLng(48.28223, -25.339243),
            LatLng(48.241575, -24.948724),
            LatLng(48.196547, -24.526079),
            LatLng(48.145856, -24.061799),
            LatLng(48.087412, -23.54048),
            LatLng(48.017388, -22.933925),
            LatLng(47.927108, -22.178172),
            LatLng(47.782917, -21.025046),
          ],),
          Polyline(
          polylineId: PolylineId('line'),
          color: Colors.orangeAccent,
          width: 4,
          points: [
            LatLng(-8.333957, -157.468246),
            LatLng(-8.206773, -156.573633),
            LatLng(-8.126292, -156.034976),
            LatLng(-8.060984, -155.612045),
            LatLng(-8.004029, -155.252825),
            LatLng(-7.952562, -154.935456),
            LatLng(-7.905058, -154.648291),
            LatLng(-7.860587, -154.38425),
            LatLng(-7.818537, -154.138652),
            LatLng(-7.778476, -153.908208),
            LatLng(-7.740088, -153.690504),
            LatLng(-7.703133, -153.483706),
            LatLng(-7.667422, -153.286381),
            LatLng(-7.632807, -153.097387),
            LatLng(-7.599164, -152.915791),
            LatLng(-7.566393, -152.740825),
            LatLng(-7.534409, -152.571844),
            LatLng(-7.503141, -152.408302),
            LatLng(-7.472528, -152.24973),
            LatLng(-7.442515, -152.095725),
            LatLng(-7.413058, -151.945932),
            LatLng(-7.384115, -151.800044),
            LatLng(-7.355651, -151.657786),
            LatLng(-7.327634, -151.518917),
            LatLng(-7.300035, -151.383218),
            LatLng(-7.272828, -151.250496),
            LatLng(-7.245991, -151.120574),
            LatLng(-7.219503, -150.993294),
            LatLng(-7.193345, -150.868511),
            LatLng(-7.1675, -150.746094),
            LatLng(-7.141951, -150.625922),
            LatLng(-7.116684, -150.507884),
            LatLng(-7.091686, -150.391878),
            LatLng(-7.066944, -150.277811),
            LatLng(-7.042448, -150.165594),
            LatLng(-7.018185, -150.055149),
            LatLng(-6.994148, -149.946399),
            LatLng(-6.970326, -149.839275),
            LatLng(-6.94671, -149.733712),
            LatLng(-6.923293, -149.629648),
            LatLng(-6.900068, -149.527027),
            LatLng(-6.877027, -149.425795),
            LatLng(-6.854164, -149.325901),
            LatLng(-6.831472, -149.227299),
            LatLng(-6.808945, -149.129944),
            LatLng(-6.786579, -149.033794),
            LatLng(-6.764367, -148.938808),
            LatLng(-6.742305, -148.84495),
            LatLng(-6.720388, -148.752183),
            LatLng(-6.698612, -148.660474),
            LatLng(-6.676973, -148.56979),
            LatLng(-6.655466, -148.480102),
            LatLng(-6.634087, -148.391379),
            LatLng(-6.612834, -148.303595),
            LatLng(-6.591702, -148.216722),
            LatLng(-6.570688, -148.130737),
            LatLng(-6.549789, -148.045614),
            LatLng(-6.529002, -147.961332),
            LatLng(-6.508325, -147.877867),
            LatLng(-6.487753, -147.795199),
            LatLng(-6.467286, -147.713308),
            LatLng(-6.446919, -147.632174),
            LatLng(-6.426651, -147.551779),
            LatLng(-6.40648, -147.472105),
            LatLng(-6.386403, -147.393135),
            LatLng(-6.366417, -147.314853),
            LatLng(-6.346522, -147.237243),
            LatLng(-6.326715, -147.16029),
            LatLng(-6.306993, -147.083978),
            LatLng(-6.287356, -147.008295),
            LatLng(-6.2678, -146.933225),
            LatLng(-6.248326, -146.858758),
            LatLng(-6.22893, -146.784878),
            LatLng(-6.209612, -146.711576),
            LatLng(-6.190369, -146.638837),
            LatLng(-6.171201, -146.566652),
            LatLng(-6.152105, -146.49501),
            LatLng(-6.133081, -146.423898),
            LatLng(-6.114127, -146.353308),
            LatLng(-6.095241, -146.28323),
            LatLng(-6.076423, -146.213652),
            LatLng(-6.057671, -146.144567),
            LatLng(-6.038984, -146.075965),
            LatLng(-6.020361, -146.007838),
            LatLng(-6.0018, -145.940176),
            LatLng(-5.983302, -145.872972),
            LatLng(-5.964863, -145.806217),
            LatLng(-5.946485, -145.739903),
            LatLng(-5.928164, -145.674024),
            LatLng(-5.909901, -145.608571),
            LatLng(-5.891695, -145.543538),
            LatLng(-5.873545, -145.478917),
            LatLng(-5.855449, -145.414702),
            LatLng(-5.837407, -145.350886),
            LatLng(-5.819418, -145.287462),
            LatLng(-5.801482, -145.224426),
            LatLng(-5.783596, -145.161769),
            LatLng(-5.765762, -145.099487),
            LatLng(-5.747977, -145.037573),
            LatLng(-5.730241, -144.976023),
            LatLng(-5.712554, -144.914829),
            LatLng(-5.694914, -144.853988),
            LatLng(-5.677322, -144.793494),
            LatLng(-5.659776, -144.733342),
            LatLng(-5.642275, -144.673527),
            LatLng(-5.624819, -144.614043),
            LatLng(-5.607408, -144.554887),
            LatLng(-5.590041, -144.496054),
            LatLng(-5.572716, -144.437538),
            LatLng(-5.555435, -144.379337),
            LatLng(-5.538195, -144.321444),
            LatLng(-5.520997, -144.263857),
            LatLng(-5.503839, -144.206571),
            LatLng(-5.486722, -144.149582),
            LatLng(-5.469645, -144.092886),
            LatLng(-5.452608, -144.036479),
            LatLng(-5.435609, -143.980358),
            LatLng(-5.418648, -143.924518),
            LatLng(-5.401726, -143.868957),
            LatLng(-5.38484, -143.81367),
            LatLng(-5.367992, -143.758654),
            LatLng(-5.35118, -143.703906),
            LatLng(-5.334405, -143.649422),
            LatLng(-5.317665, -143.5952),
            LatLng(-5.30096, -143.541236),
            LatLng(-5.28429, -143.487526),
            LatLng(-5.267654, -143.434068),
            LatLng(-5.251052, -143.380859),
            LatLng(-5.234484, -143.327896),
            LatLng(-5.217949, -143.275176),
            LatLng(-5.201447, -143.222696),
            LatLng(-5.184977, -143.170454),
            LatLng(-5.16854, -143.118446),
            LatLng(-5.152134, -143.06667),
            LatLng(-5.13576, -143.015124),
            LatLng(-5.119417, -142.963804),
            LatLng(-5.103104, -142.912708),
            LatLng(-5.086822, -142.861835),
            LatLng(-5.07057, -142.81118),
            LatLng(-5.054348, -142.760743),
            LatLng(-5.038155, -142.71052),
            LatLng(-5.021991, -142.66051),
            LatLng(-5.005857, -142.61071),
            LatLng(-4.98975, -142.561117),
            LatLng(-4.973672, -142.51173),
            LatLng(-4.957622, -142.462547),
            LatLng(-4.9416, -142.413565),
            LatLng(-4.925605, -142.364782),
            LatLng(-4.909637, -142.316197),
            LatLng(-4.893696, -142.267807),
            LatLng(-4.877782, -142.21961),
            LatLng(-4.861894, -142.171605),
            LatLng(-4.846032, -142.123789),
            LatLng(-4.830196, -142.07616),
            LatLng(-4.814386, -142.028718),
            LatLng(-4.798601, -141.981459),
            LatLng(-4.782841, -141.934382),
            LatLng(-4.767106, -141.887486),
            LatLng(-4.751396, -141.840768),
            LatLng(-4.73571, -141.794228),
            LatLng(-4.720048, -141.747862),
            LatLng(-4.70441, -141.701671),
            LatLng(-4.688797, -141.655651),
            LatLng(-4.673206, -141.609802),
            LatLng(-4.657639, -141.564121),
            LatLng(-4.642095, -141.518608),
            LatLng(-4.626575, -141.47326),
            LatLng(-4.611077, -141.428077),
            LatLng(-4.595601, -141.383057),
            LatLng(-4.580148, -141.338197),
            LatLng(-4.564717, -141.293498),
            LatLng(-4.549308, -141.248957),
            LatLng(-4.53392, -141.204573),
            LatLng(-4.518555, -141.160345),
            LatLng(-4.50321, -141.116271),
            LatLng(-4.487887, -141.07235),
            LatLng(-4.472586, -141.028581),
            LatLng(-4.457305, -140.984962),
            LatLng(-4.442044, -140.941493),
            LatLng(-4.426804, -140.898171),
            LatLng(-4.411585, -140.854995),
            LatLng(-4.396386, -140.811965),
            LatLng(-4.381207, -140.769079),
            LatLng(-4.366048, -140.726336),
            LatLng(-4.350908, -140.683735),
            LatLng(-4.335789, -140.641275),
            LatLng(-4.320688, -140.598953),
            LatLng(-4.305607, -140.556771),
            LatLng(-4.290545, -140.514725),
            LatLng(-4.275502, -140.472815),
            LatLng(-4.260478, -140.431041),
            LatLng(-4.245473, -140.3894),
            LatLng(-4.230486, -140.347893),
            LatLng(-4.215517, -140.306517),
            LatLng(-4.200567, -140.265272),
            LatLng(-4.185635, -140.224157),
            LatLng(-4.170721, -140.18317),
            LatLng(-4.155825, -140.142311),
            LatLng(-4.140947, -140.10158),
            LatLng(-4.126086, -140.060974),
            LatLng(-4.111243, -140.020493),
            LatLng(-4.096417, -139.980135),
            LatLng(-4.081608, -139.939901),
            LatLng(-4.066817, -139.899789),
            LatLng(-4.052042, -139.859798),
            LatLng(-4.037285, -139.819928),
            LatLng(-4.022544, -139.780176),
            LatLng(-4.00782, -139.740544),
            LatLng(-3.993112, -139.701029),
            LatLng(-3.978421, -139.661631),
            LatLng(-3.963746, -139.622348),
            LatLng(-3.949087, -139.583181),
            LatLng(-3.934444, -139.544128),
            LatLng(-3.919818, -139.505189),
            LatLng(-3.905207, -139.466362),
            LatLng(-3.890611, -139.427648),
            LatLng(-3.876032, -139.389044),
            LatLng(-3.861468, -139.35055),
            LatLng(-3.846919, -139.312167),
            LatLng(-3.832386, -139.273892),
            LatLng(-3.817868, -139.235724),
            LatLng(-3.803366, -139.197665),
            LatLng(-3.788878, -139.159712),
            LatLng(-3.774405, -139.121864),
            LatLng(-3.759947, -139.084122),
            LatLng(-3.745504, -139.046484),
            LatLng(-3.731075, -139.00895),
            LatLng(-3.716661, -138.971519),
            LatLng(-3.702262, -138.93419),
            LatLng(-3.687876, -138.896963),
            LatLng(-3.673505, -138.859836),
            LatLng(-3.659149, -138.82281),
            LatLng(-3.644806, -138.785884),
            LatLng(-3.630478, -138.749057),
            LatLng(-3.616163, -138.712328),
            LatLng(-3.601862, -138.675697),
            LatLng(-3.587575, -138.639162),
            LatLng(-3.573302, -138.602725),
            LatLng(-3.559042, -138.566383),
            LatLng(-3.544796, -138.530136),
            LatLng(-3.530563, -138.493984),
            LatLng(-3.516344, -138.457926),
            LatLng(-3.502137, -138.421961),
            LatLng(-3.487945, -138.386089),
            LatLng(-3.473765, -138.35031),
            LatLng(-3.459598, -138.314622),
            LatLng(-3.445444, -138.279025),
            LatLng(-3.431303, -138.243519),
            LatLng(-3.417175, -138.208103),
            LatLng(-3.40306, -138.172776),
            LatLng(-3.388957, -138.137538),
            LatLng(-3.374867, -138.102389),
            LatLng(-3.360789, -138.067327),
            LatLng(-3.346724, -138.032353),
            LatLng(-3.332671, -137.997466),
            LatLng(-3.318631, -137.962664),
            LatLng(-3.304602, -137.927949),
            LatLng(-3.290586, -137.893319),
            LatLng(-3.276582, -137.858773),
            LatLng(-3.262591, -137.824312),
            LatLng(-3.248611, -137.789934),
            LatLng(-3.234643, -137.75564),
            LatLng(-3.220686, -137.721428),
            LatLng(-3.206742, -137.687299),
            LatLng(-3.192809, -137.653252),
            LatLng(-3.178888, -137.619286),
            LatLng(-3.164979, -137.5854),
            LatLng(-3.151081, -137.551596),
            LatLng(-3.137194, -137.517871),
            LatLng(-3.123319, -137.484225),
            LatLng(-3.109456, -137.450659),
            LatLng(-3.095603, -137.417171),
            LatLng(-3.081762, -137.383762),
            LatLng(-3.067932, -137.35043),
            LatLng(-3.054113, -137.317175),
            LatLng(-2.442892, -135.894383),
            LatLng(-1.849775, -134.595768),
            LatLng(-1.271644, -133.398408),
            LatLng(-0.706204, -132.285538),
            LatLng(-0.151707, -131.24445),
            LatLng(0.393218, -130.265241),
            LatLng(0.929671, -129.340008),
            LatLng(1.458552, -128.462325),
            LatLng(1.980609, -127.62688),
            LatLng(2.496473, -126.829222),
            LatLng(3.006682, -126.065573),
            LatLng(3.5117, -125.332694),
            LatLng(4.011931, -124.627781),
            LatLng(4.50773, -123.948387),
            LatLng(4.999411, -123.292357),
            LatLng(5.487253, -122.657785),
            LatLng(5.971505, -122.04297),
            LatLng(6.452393, -121.446389),
            LatLng(6.930121, -120.866667),
            LatLng(7.404875, -120.302561),
            LatLng(7.876823, -119.752939),
            LatLng(8.34612, -119.216764),
            LatLng(8.812911, -118.693088),
            LatLng(9.277325, -118.181035),
            LatLng(9.739487, -117.679797),
            LatLng(10.199509, -117.188623),
            LatLng(10.657496, -116.706813),
            LatLng(11.113548, -116.233715),
            LatLng(11.567757, -115.768717),
            LatLng(12.02021, -115.311244),
            LatLng(12.470987, -114.860754),
            LatLng(12.920167, -114.416734),
            LatLng(13.367821, -113.978699),
            LatLng(13.814018, -113.546187),
            LatLng(14.258822, -113.118758),
            LatLng(14.702296, -112.695992),
            LatLng(15.144497, -112.277484),
            LatLng(15.585482, -111.862848),
            LatLng(16.025302, -111.451712),
            LatLng(16.464009, -111.043714),
            LatLng(16.90165, -110.638506),
            LatLng(17.338271, -110.235749),
            LatLng(17.773916, -109.835115),
            LatLng(18.208627, -109.436283),
            LatLng(18.642444, -109.038938),
            LatLng(19.075405, -108.642774),
            LatLng(19.507547, -108.247487),
            LatLng(19.938906, -107.852781),
            LatLng(20.369514, -107.458362),
            LatLng(20.799404, -107.063939),
            LatLng(21.228607, -106.669224),
            LatLng(21.657152, -106.273932),
            LatLng(22.085068, -105.877776),
            LatLng(22.512381, -105.480473),
            LatLng(22.939117, -105.081738),
            LatLng(23.3653, -104.681285),
            LatLng(23.790955, -104.278827),
            LatLng(24.216102, -103.874075),
            LatLng(24.640763, -103.466739),
            LatLng(25.064958, -103.056523),
            LatLng(25.488704, -102.643129),
            LatLng(25.91202, -102.226255),
            LatLng(26.334921, -101.805591),
            LatLng(26.757422, -101.380824),
            LatLng(27.179536, -100.951635),
            LatLng(27.601277, -100.517694),
            LatLng(28.022654, -100.078668),
            LatLng(28.443677, -99.63421),
            LatLng(28.864353, -99.183967),
            LatLng(29.28469, -98.727575),
            LatLng(29.704692, -98.264658),
            LatLng(30.124361, -97.794827),
            LatLng(30.5437, -97.31768),
            LatLng(30.962707, -96.8328),
            LatLng(31.381379, -96.339755),
            LatLng(31.799711, -95.838095),
            LatLng(32.217697, -95.327352),
            LatLng(32.635325, -94.807038),
            LatLng(33.052583, -94.276641),
            LatLng(33.469456, -93.735628),
            LatLng(33.885925, -93.18344),
            LatLng(34.301967, -92.61949),
            LatLng(34.717556, -92.043159),
            LatLng(35.132663, -91.453798),
            LatLng(35.547252, -90.850722),
            LatLng(35.961283, -90.233206),
            LatLng(36.374712, -89.600483),
            LatLng(36.787488, -88.951741),
            LatLng(37.199554, -88.286117),
            LatLng(37.610844, -87.602692),
            LatLng(38.021286, -86.900487),
            LatLng(38.430798, -86.178455),
            LatLng(38.83929, -85.435476),
            LatLng(39.246657, -84.670349),
            LatLng(39.652787, -83.881778),
            LatLng(40.057549, -83.068371),
            LatLng(40.460801, -82.228619),
            LatLng(40.862378, -81.360887),
            LatLng(41.262101, -80.463396),
            LatLng(41.659763, -79.534206),
            LatLng(42.055134, -78.57119),
            LatLng(42.447953, -77.572012),
            LatLng(42.837923, -76.534091),
            LatLng(43.224709, -75.454566),
            LatLng(43.607926, -74.330246),
            LatLng(43.987136, -73.157555),
            LatLng(44.361831, -71.932457),
            LatLng(44.731426, -70.65037),
            LatLng(45.09524, -69.306043),
            LatLng(45.452471, -67.893415),
            LatLng(45.802173, -66.405409),
            LatLng(46.143215, -64.833668),
            LatLng(46.474226, -63.168193),
            LatLng(46.793527, -61.396816),
            LatLng(47.099025, -59.50446),
            LatLng(47.388051, -57.471999),
            LatLng(47.657115, -55.274482),
            LatLng(47.901501, -52.878191),
            LatLng(48.114552, -50.235416),
            LatLng(48.118862, -50.173402),
            LatLng(48.123153, -50.111231),
            LatLng(48.127423, -50.048902),
            LatLng(48.131672, -49.986416),
            LatLng(48.135901, -49.923769),
            LatLng(48.140109, -49.860963),
            LatLng(48.144296, -49.797995),
            LatLng(48.148462, -49.734865),
            LatLng(48.152607, -49.671572),
            LatLng(48.15673, -49.608113),
            LatLng(48.160831, -49.54449),
            LatLng(48.164911, -49.4807),
            LatLng(48.168969, -49.416742),
            LatLng(48.173005, -49.352615),
            LatLng(48.177019, -49.288319),
            LatLng(48.181011, -49.223851),
            LatLng(48.18498, -49.159212),
            LatLng(48.188926, -49.094399),
            LatLng(48.19285, -49.029411),
            LatLng(48.196751, -48.964248),
            LatLng(48.200628, -48.898909),
            LatLng(48.204482, -48.833391),
            LatLng(48.208313, -48.767694),
            LatLng(48.21212, -48.701816),
            LatLng(48.215904, -48.635757),
            LatLng(48.219663, -48.569515),
            LatLng(48.223399, -48.503089),
            LatLng(48.22711, -48.436477),
            LatLng(48.230796, -48.369678),
            LatLng(48.234458, -48.302692),
            LatLng(48.238095, -48.235515),
            LatLng(48.241706, -48.168148),
            LatLng(48.245293, -48.100589),
            LatLng(48.248854, -48.032836),
            LatLng(48.25239, -47.964888),
            LatLng(48.255899, -47.896744),
            LatLng(48.259383, -47.828402),
            LatLng(48.26284, -47.75986),
            LatLng(48.266271, -47.691118),
            LatLng(48.269676, -47.622173),
            LatLng(48.273053, -47.553025),
            LatLng(48.276404, -47.483671),
            LatLng(48.279727, -47.41411),
            LatLng(48.283023, -47.344341),
            LatLng(48.286291, -47.274362),
            LatLng(48.289531, -47.204171),
            LatLng(48.292742, -47.133767),
            LatLng(48.295926, -47.063148),
            LatLng(48.299081, -46.992312),
            LatLng(48.302207, -46.921258),
            LatLng(48.305304, -46.849984),
            LatLng(48.308371, -46.778487),
            LatLng(48.311409, -46.706768),
            LatLng(48.314417, -46.634822),
            LatLng(48.317396, -46.56265),
            LatLng(48.320343, -46.490248),
            LatLng(48.323261, -46.417615),
            LatLng(48.326147, -46.34475),
            LatLng(48.329002, -46.271649),
            LatLng(48.331826, -46.198312),
            LatLng(48.334618, -46.124736),
            LatLng(48.337378, -46.050919),
            LatLng(48.340106, -45.97686),
            LatLng(48.342802, -45.902555),
            LatLng(48.345464, -45.828003),
            LatLng(48.348094, -45.753203),
            LatLng(48.35069, -45.67815),
            LatLng(48.353253, -45.602845),
            LatLng(48.355781, -45.527283),
            LatLng(48.358276, -45.451464),
            LatLng(48.360735, -45.375384),
            LatLng(48.36316, -45.299041),
            LatLng(48.365549, -45.222433),
            LatLng(48.367903, -45.145558),
            LatLng(48.370221, -45.068413),
            LatLng(48.372503, -44.990995),
            LatLng(48.374748, -44.913302),
            LatLng(48.376956, -44.835332),
            LatLng(48.379127, -44.757081),
            LatLng(48.38126, -44.678548),
            LatLng(48.383354, -44.599729),
            LatLng(48.385411, -44.520622),
            LatLng(48.387429, -44.441224),
            LatLng(48.389407, -44.361532),
            LatLng(48.391346, -44.281543),
            LatLng(48.393245, -44.201254),
            LatLng(48.395103, -44.120663),
            LatLng(48.396921, -44.039766),
            LatLng(48.398697, -43.95856),
            LatLng(48.400432, -43.877042),
            LatLng(48.402124, -43.795209),
            LatLng(48.403774, -43.713057),
            LatLng(48.405381, -43.630584),
            LatLng(48.406945, -43.547785),
            LatLng(48.408465, -43.464658),
            LatLng(48.40994, -43.381199),
            LatLng(48.41137, -43.297404),
            LatLng(48.412755, -43.21327),
            LatLng(48.414094, -43.128794),
            LatLng(48.415386, -43.04397),
            LatLng(48.416632, -42.958796),
            LatLng(48.41783, -42.873268),
            LatLng(48.418981, -42.787381),
            LatLng(48.420082, -42.701131),
            LatLng(48.421135, -42.614515),
            LatLng(48.422137, -42.527529),
            LatLng(48.42309, -42.440167),
            LatLng(48.423992, -42.352425),
            LatLng(48.424842, -42.2643),
            LatLng(48.42564, -42.175786),
            LatLng(48.426385, -42.086879),
            LatLng(48.427077, -41.997574),
            LatLng(48.427715, -41.907866),
            LatLng(48.428298, -41.81775),
            LatLng(48.428826, -41.727221),
            LatLng(48.429298, -41.636275),
            LatLng(48.429713, -41.544905),
            LatLng(48.43007, -41.453106),
            LatLng(48.430369, -41.360873),
            LatLng(48.430609, -41.268201),
            LatLng(48.430789, -41.175082),
            LatLng(48.430908, -41.081513),
            LatLng(48.430966, -40.987485),
            LatLng(48.430962, -40.892994),
            LatLng(48.430895, -40.798033),
            LatLng(48.430763, -40.702596),
            LatLng(48.430567, -40.606675),
            LatLng(48.430304, -40.510265),
            LatLng(48.429975, -40.413357),
            LatLng(48.429579, -40.315946),
            LatLng(48.429113, -40.218024),
            LatLng(48.428578, -40.119583),
            LatLng(48.427972, -40.020616),
            LatLng(48.427294, -39.921115),
            LatLng(48.426543, -39.821071),
            LatLng(48.425719, -39.720478),
            LatLng(48.424819, -39.619325),
            LatLng(48.423843, -39.517605),
            LatLng(48.422789, -39.415309),
            LatLng(48.421656, -39.312427),
            LatLng(48.420444, -39.20895),
            LatLng(48.41915, -39.104869),
            LatLng(48.417773, -39.000173),
            LatLng(48.416313, -38.894852),
            LatLng(48.414767, -38.788896),
            LatLng(48.413134, -38.682294),
            LatLng(48.411412, -38.575035),
            LatLng(48.409601, -38.467107),
            LatLng(48.407698, -38.358499),
            LatLng(48.405702, -38.249198),
            LatLng(48.403611, -38.139193),
            LatLng(48.401423, -38.028469),
            LatLng(48.399137, -37.917014),
            LatLng(48.396751, -37.804814),
            LatLng(48.394262, -37.691854),
            LatLng(48.39167, -37.578121),
            LatLng(48.388971, -37.463599),
            LatLng(48.386164, -37.348272),
            LatLng(48.383247, -37.232125),
            LatLng(48.380217, -37.11514),
            LatLng(48.377072, -36.9973),
            LatLng(48.373809, -36.878588),
            LatLng(48.370427, -36.758984),
            LatLng(48.366922, -36.63847),
            LatLng(48.363292, -36.517025),
            LatLng(48.359534, -36.39463),
            LatLng(48.355646, -36.271261),
            LatLng(48.351623, -36.146898),
            LatLng(48.347464, -36.021516),
            LatLng(48.343164, -35.895092),
            LatLng(48.338721, -35.767601),
            LatLng(48.334131, -35.639016),
            LatLng(48.329391, -35.50931),
            LatLng(48.324495, -35.378455),
            LatLng(48.319442, -35.246421),
            LatLng(48.314226, -35.113178),
            LatLng(48.308843, -34.978692),
            LatLng(48.303288, -34.84293),
            LatLng(48.297558, -34.705856),
            LatLng(48.291646, -34.567434),
            LatLng(48.285548, -34.427624),
            LatLng(48.279258, -34.286386),
            LatLng(48.272771, -34.143677),
            LatLng(48.26608, -33.999451),
            LatLng(48.25918, -33.853661),
            LatLng(48.252062, -33.706257),
            LatLng(48.244722, -33.557186),
            LatLng(48.23715, -33.406392),
            LatLng(48.229339, -33.253817),
            LatLng(48.221281, -33.099398),
            LatLng(48.212967, -32.943068),
            LatLng(48.204387, -32.784757),
            LatLng(48.195532, -32.62439),
            LatLng(48.186391, -32.461888),
            LatLng(48.176953, -32.297165),
            LatLng(48.167205, -32.130131),
            LatLng(48.157135, -31.960688),
            LatLng(48.146729, -31.788732),
            LatLng(48.135971, -31.614151),
            LatLng(48.124846, -31.436824),
            LatLng(48.113336, -31.256619),
            LatLng(48.101423, -31.073397),
            LatLng(48.089086, -30.887003),
            LatLng(48.076303, -30.697271),
            LatLng(48.06305, -30.504019),
            LatLng(48.049301, -30.307047),
            LatLng(48.035025, -30.106137),
            LatLng(48.020192, -29.901047),
            LatLng(48.004766, -29.691509),
            LatLng(47.988708, -29.477227),
            LatLng(47.971972, -29.257868),
            LatLng(47.954511, -29.03306),
            LatLng(47.936267, -28.802381),
            LatLng(47.917179, -28.565353),
            LatLng(47.897172, -28.321429),
            LatLng(47.876164, -28.069977),
            LatLng(47.854058, -27.810262),
            LatLng(47.830738, -27.541424),
            LatLng(47.80607, -27.262436),
            LatLng(47.779891, -26.972068),
            LatLng(47.752001, -26.668814),
            LatLng(47.722153, -26.350807),
            LatLng(47.690034, -26.015676),
            LatLng(47.655236, -25.660335),
            LatLng(47.617212, -25.280644),
            LatLng(47.575196, -24.870815),
            LatLng(47.528062, -24.422323),
            LatLng(47.474022, -23.921644),
            LatLng(47.409917, -23.344848),
            LatLng(47.329012, -22.640979),
            LatLng(47.209774, -21.647125),
          ],),
          Polyline(
          polylineId: PolylineId('line'),
          color: Colors.orangeAccent,
          width: 4,
          points: [
            LatLng(-7.154697, -158.500705),
            LatLng(-7.004821, -157.472276),
            LatLng(-6.920645, -156.928056),
            LatLng(-6.853007, -156.505073),
            LatLng(-6.794252, -156.147146),
            LatLng(-6.741278, -155.831522),
            LatLng(-6.692454, -155.546262),
            LatLng(-6.646799, -155.284174),
            LatLng(-6.603667, -155.040524),
            LatLng(-6.562605, -154.811999),
            LatLng(-6.523283, -154.596177),
            LatLng(-6.485448, -154.391218),
            LatLng(-6.448905, -154.195688),
            LatLng(-6.413499, -154.008444),
            LatLng(-6.3791, -153.828557),
            LatLng(-6.345606, -153.655259),
            LatLng(-6.312928, -153.487907),
            LatLng(-6.280991, -153.325957),
            LatLng(-6.249731, -153.168942),
            LatLng(-6.219094, -153.016459),
            LatLng(-6.189032, -152.868159),
            LatLng(-6.159502, -152.723733),
            LatLng(-6.130468, -152.582908),
            LatLng(-6.101896, -152.445445),
            LatLng(-6.073756, -152.311127),
            LatLng(-6.046023, -152.179761),
            LatLng(-6.018672, -152.051172),
            LatLng(-5.991682, -151.925203),
            LatLng(-5.965033, -151.801709),
            LatLng(-5.938707, -151.680561),
            LatLng(-5.912688, -151.561638),
            LatLng(-5.88696, -151.44483),
            LatLng(-5.861511, -151.330037),
            LatLng(-5.836326, -151.217165),
            LatLng(-5.811395, -151.106127),
            LatLng(-5.786706, -150.996844),
            LatLng(-5.76225, -150.889242),
            LatLng(-5.738016, -150.78325),
            LatLng(-5.713995, -150.678804),
            LatLng(-5.69018, -150.575845),
            LatLng(-5.666563, -150.474314),
            LatLng(-5.643136, -150.37416),
            LatLng(-5.619893, -150.275332),
            LatLng(-5.596827, -150.177783),
            LatLng(-5.573932, -150.081469),
            LatLng(-5.551202, -149.986349),
            LatLng(-5.528632, -149.892382),
            LatLng(-5.506217, -149.799532),
            LatLng(-5.483952, -149.707762),
            LatLng(-5.461832, -149.617041),
            LatLng(-5.439854, -149.527335),
            LatLng(-5.418012, -149.438614),
            LatLng(-5.396303, -149.35085),
            LatLng(-5.374722, -149.264016),
            LatLng(-5.353268, -149.178084),
            LatLng(-5.331935, -149.09303),
            LatLng(-5.310722, -149.008831),
            LatLng(-5.289624, -148.925464),
            LatLng(-5.268639, -148.842906),
            LatLng(-5.247763, -148.761138),
            LatLng(-5.226995, -148.680138),
            LatLng(-5.206331, -148.599889),
            LatLng(-5.185769, -148.520371),
            LatLng(-5.165306, -148.441567),
            LatLng(-5.144941, -148.36346),
            LatLng(-5.124671, -148.286034),
            LatLng(-5.104493, -148.209273),
            LatLng(-5.084407, -148.133162),
            LatLng(-5.064409, -148.057686),
            LatLng(-5.044498, -147.982833),
            LatLng(-5.024671, -147.908587),
            LatLng(-5.004928, -147.834937),
            LatLng(-4.985267, -147.76187),
            LatLng(-4.965685, -147.689373),
            LatLng(-4.946182, -147.617435),
            LatLng(-4.926755, -147.546044),
            LatLng(-4.907403, -147.47519),
            LatLng(-4.888125, -147.404863),
            LatLng(-4.868919, -147.335051),
            LatLng(-4.849784, -147.265746),
            LatLng(-4.830719, -147.196936),
            LatLng(-4.811722, -147.128614),
            LatLng(-4.792792, -147.06077),
            LatLng(-4.773928, -146.993396),
            LatLng(-4.755128, -146.926482),
            LatLng(-4.736392, -146.860022),
            LatLng(-4.717719, -146.794006),
            LatLng(-4.699107, -146.728427),
            LatLng(-4.680556, -146.663278),
            LatLng(-4.662063, -146.59855),
            LatLng(-4.64363, -146.534238),
            LatLng(-4.625253, -146.470335),
            LatLng(-4.606933, -146.406832),
            LatLng(-4.588669, -146.343725),
            LatLng(-4.57046, -146.281006),
            LatLng(-4.552304, -146.21867),
            LatLng(-4.534201, -146.15671),
            LatLng(-4.516151, -146.09512),
            LatLng(-4.498152, -146.033895),
            LatLng(-4.480204, -145.97303),
            LatLng(-4.462306, -145.912518),
            LatLng(-4.444456, -145.852355),
            LatLng(-4.426656, -145.792535),
            LatLng(-4.408903, -145.733053),
            LatLng(-4.391197, -145.673904),
            LatLng(-4.373538, -145.615084),
            LatLng(-4.355924, -145.556588),
            LatLng(-4.338356, -145.498411),
            LatLng(-4.320832, -145.440549),
            LatLng(-4.303352, -145.382997),
            LatLng(-4.285915, -145.325751),
            LatLng(-4.268521, -145.268807),
            LatLng(-4.25117, -145.212161),
            LatLng(-4.23386, -145.155809),
            LatLng(-4.216591, -145.099747),
            LatLng(-4.199362, -145.043971),
            LatLng(-4.182174, -144.988478),
            LatLng(-4.165025, -144.933263),
            LatLng(-4.147916, -144.878323),
            LatLng(-4.130845, -144.823655),
            LatLng(-4.113812, -144.769256),
            LatLng(-4.096816, -144.715121),
            LatLng(-4.079858, -144.661248),
            LatLng(-4.062937, -144.607633),
            LatLng(-4.046052, -144.554273),
            LatLng(-4.029203, -144.501166),
            LatLng(-4.012389, -144.448308),
            LatLng(-3.99561, -144.395695),
            LatLng(-3.978866, -144.343327),
            LatLng(-3.962156, -144.291198),
            LatLng(-3.94548, -144.239307),
            LatLng(-3.928838, -144.187651),
            LatLng(-3.912228, -144.136227),
            LatLng(-3.895652, -144.085032),
            LatLng(-3.879108, -144.034064),
            LatLng(-3.862595, -143.983321),
            LatLng(-3.846115, -143.9328),
            LatLng(-3.829666, -143.882497),
            LatLng(-3.813247, -143.832412),
            LatLng(-3.79686, -143.782542),
            LatLng(-3.780503, -143.732884),
            LatLng(-3.764176, -143.683435),
            LatLng(-3.747878, -143.634195),
            LatLng(-3.73161, -143.58516),
            LatLng(-3.715371, -143.536329),
            LatLng(-3.699161, -143.487699),
            LatLng(-3.68298, -143.439268),
            LatLng(-3.666827, -143.391034),
            LatLng(-3.650701, -143.342995),
            LatLng(-3.634604, -143.29515),
            LatLng(-3.618534, -143.247495),
            LatLng(-3.602491, -143.20003),
            LatLng(-3.586475, -143.152753),
            LatLng(-3.570485, -143.10566),
            LatLng(-3.554522, -143.058752),
            LatLng(-3.538585, -143.012025),
            LatLng(-3.522674, -142.965479),
            LatLng(-3.506789, -142.919111),
            LatLng(-3.490929, -142.87292),
            LatLng(-3.475095, -142.826903),
            LatLng(-3.459285, -142.78106),
            LatLng(-3.4435, -142.735389),
            LatLng(-3.427739, -142.689888),
            LatLng(-3.412003, -142.644555),
            LatLng(-3.396291, -142.599389),
            LatLng(-3.380602, -142.554389),
            LatLng(-3.364937, -142.509553),
            LatLng(-3.349296, -142.464879),
            LatLng(-3.333678, -142.420366),
            LatLng(-3.318083, -142.376012),
            LatLng(-3.302511, -142.331817),
            LatLng(-3.286961, -142.287778),
            LatLng(-3.271434, -142.243895),
            LatLng(-3.255929, -142.200165),
            LatLng(-3.240446, -142.156588),
            LatLng(-3.224985, -142.113163),
            LatLng(-3.209546, -142.069887),
            LatLng(-3.194128, -142.02676),
            LatLng(-3.178732, -141.983781),
            LatLng(-3.163357, -141.940948),
            LatLng(-3.148003, -141.898259),
            LatLng(-3.132669, -141.855715),
            LatLng(-3.117357, -141.813312),
            LatLng(-3.102064, -141.771052),
            LatLng(-3.086792, -141.728931),
            LatLng(-3.071541, -141.686949),
            LatLng(-3.056309, -141.645106),
            LatLng(-3.041097, -141.603399),
            LatLng(-3.025905, -141.561827),
            LatLng(-3.010732, -141.520391),
            LatLng(-2.995579, -141.479088),
            LatLng(-2.980445, -141.437917),
            LatLng(-2.96533, -141.396877),
            LatLng(-2.950235, -141.355968),
            LatLng(-2.935158, -141.315189),
            LatLng(-2.920099, -141.274537),
            LatLng(-2.905059, -141.234013),
            LatLng(-2.890038, -141.193616),
            LatLng(-2.875035, -141.153343),
            LatLng(-2.86005, -141.113196),
            LatLng(-2.845083, -141.073171),
            LatLng(-2.830134, -141.033269),
            LatLng(-2.815202, -140.993489),
            LatLng(-2.800289, -140.953829),
            LatLng(-2.785392, -140.91429),
            LatLng(-2.770513, -140.874869),
            LatLng(-2.755652, -140.835566),
            LatLng(-2.740807, -140.796381),
            LatLng(-2.72598, -140.757311),
            LatLng(-2.711169, -140.718358),
            LatLng(-2.696375, -140.679518),
            LatLng(-2.681598, -140.640793),
            LatLng(-2.666837, -140.602181),
            LatLng(-2.652093, -140.563681),
            LatLng(-2.637365, -140.525292),
            LatLng(-2.622654, -140.487014),
            LatLng(-2.607958, -140.448845),
            LatLng(-2.593278, -140.410786),
            LatLng(-2.578615, -140.372835),
            LatLng(-2.563967, -140.334992),
            LatLng(-2.549334, -140.297255),
            LatLng(-2.534718, -140.259624),
            LatLng(-2.520116, -140.222099),
            LatLng(-2.50553, -140.184678),
            LatLng(-2.49096, -140.147362),
            LatLng(-2.476404, -140.110148),
            LatLng(-2.461864, -140.073037),
            LatLng(-2.447339, -140.036028),
            LatLng(-2.432828, -139.99912),
            LatLng(-2.418332, -139.962312),
            LatLng(-2.403851, -139.925604),
            LatLng(-2.389385, -139.888995),
            LatLng(-2.374933, -139.852485),
            LatLng(-2.360495, -139.816073),
            LatLng(-2.346072, -139.779758),
            LatLng(-2.331663, -139.743539),
            LatLng(-2.317268, -139.707416),
            LatLng(-2.302888, -139.671389),
            LatLng(-2.288521, -139.635456),
            LatLng(-2.274168, -139.599618),
            LatLng(-2.259829, -139.563873),
            LatLng(-2.245504, -139.528221),
            LatLng(-2.231192, -139.492661),
            LatLng(-2.216894, -139.457193),
            LatLng(-2.202609, -139.421817),
            LatLng(-2.188338, -139.38653),
            LatLng(-2.17408, -139.351334),
            LatLng(-2.159836, -139.316228),
            LatLng(-1.531408, -137.821025),
            LatLng(-0.924089, -136.46645),
            LatLng(-0.333922, -135.224557),
            LatLng(0.241929, -134.075435),
            LatLng(0.805582, -133.004297),
            LatLng(1.35867, -131.999803),
            LatLng(1.902488, -131.053027),
            LatLng(2.438082, -130.156791),
            LatLng(2.966316, -129.305217),
            LatLng(3.48791, -128.493419),
            LatLng(4.003475, -127.717282),
            LatLng(4.513537, -126.973296),
            LatLng(5.018549, -126.258442),
            LatLng(5.518907, -125.570097),
            LatLng(6.014961, -124.905964),
            LatLng(6.50702, -124.264014),
            LatLng(6.995361, -123.642448),
            LatLng(7.480233, -123.039658),
            LatLng(7.96186, -122.454197),
            LatLng(8.440445, -121.88476),
            LatLng(8.916174, -121.33016),
            LatLng(9.389216, -120.789318),
            LatLng(9.859728, -120.261244),
            LatLng(10.327852, -119.745025),
            LatLng(10.793722, -119.239824),
            LatLng(11.257461, -118.74486),
            LatLng(11.719183, -118.259411),
            LatLng(12.178997, -117.7828),
            LatLng(12.637001, -117.314397),
            LatLng(13.093289, -116.853607),
            LatLng(13.54795, -116.399872),
            LatLng(14.001067, -115.952663),
            LatLng(14.452717, -115.511482),
            LatLng(14.902974, -115.075851),
            LatLng(15.351909, -114.64532),
            LatLng(15.799587, -114.219455),
            LatLng(16.246071, -113.797842),
            LatLng(16.69142, -113.380083),
            LatLng(17.135693, -112.965795),
            LatLng(17.578941, -112.554606),
            LatLng(18.021218, -112.146159),
            LatLng(18.462571, -111.740106),
            LatLng(18.903049, -111.336108),
            LatLng(19.342695, -110.933833),
            LatLng(19.781552, -110.53296),
            LatLng(20.219662, -110.133171),
            LatLng(20.657062, -109.734154),
            LatLng(21.093792, -109.335601),
            LatLng(21.529885, -108.93721),
            LatLng(21.965377, -108.53868),
            LatLng(22.4003, -108.139713),
            LatLng(22.834685, -107.740011),
            LatLng(23.268561, -107.339278),
            LatLng(23.701958, -106.937219),
            LatLng(24.134901, -106.533538),
            LatLng(24.567417, -106.127936),
            LatLng(24.999529, -105.720115),
            LatLng(25.431261, -105.309771),
            LatLng(25.862633, -104.896601),
            LatLng(26.293667, -104.480296),
            LatLng(26.72438, -104.060542),
            LatLng(27.15479, -103.63702),
            LatLng(27.584914, -103.209406),
            LatLng(28.014765, -102.77737),
            LatLng(28.444357, -102.340573),
            LatLng(28.873702, -101.898668),
            LatLng(29.302809, -101.451299),
            LatLng(29.731687, -100.998103),
            LatLng(30.160343, -100.538701),
            LatLng(30.588781, -100.072707),
            LatLng(31.017005, -99.59972),
            LatLng(31.445015, -99.119325),
            LatLng(31.87281, -98.631094),
            LatLng(32.300388, -98.134579),
            LatLng(32.727741, -97.629318),
            LatLng(33.154863, -97.114828),
            LatLng(33.581741, -96.590606),
            LatLng(34.008362, -96.056127),
            LatLng(34.434709, -95.510841),
            LatLng(34.860761, -94.954172),
            LatLng(35.286494, -94.385517),
            LatLng(35.711879, -93.80424),
            LatLng(36.136883, -93.209674),
            LatLng(36.561469, -92.601114),
            LatLng(36.985594, -91.977816),
            LatLng(37.40921, -91.338994),
            LatLng(37.832261, -90.683814),
            LatLng(38.254685, -90.011391),
            LatLng(38.676414, -89.320785),
            LatLng(39.097368, -88.610994),
            LatLng(39.517461, -87.880947),
            LatLng(39.936594, -87.129501),
            LatLng(40.354659, -86.355428),
            LatLng(40.771531, -85.557411),
            LatLng(41.187075, -84.734031),
            LatLng(41.601137, -83.883753),
            LatLng(42.013543, -83.004921),
            LatLng(42.424102, -82.095731),
            LatLng(42.832595, -81.154221),
            LatLng(43.238779, -80.178247),
            LatLng(43.642377, -79.165457),
            LatLng(44.043078, -78.113258),
            LatLng(44.440527, -77.018786),
            LatLng(44.834322, -75.878856),
            LatLng(45.224003, -74.689909),
            LatLng(45.609041, -73.447945),
            LatLng(45.988826, -72.14844),
            LatLng(46.362652, -70.786235),
            LatLng(46.729691, -69.355402),
            LatLng(47.088971, -67.849063),
            LatLng(47.439332, -66.259144),
            LatLng(47.779385, -64.576055),
            LatLng(48.107434, -62.788224),
            LatLng(48.421385, -60.881448),
            LatLng(48.718594, -58.83791),
            LatLng(48.99565, -56.634682),
            LatLng(49.248018, -54.24129),
            LatLng(49.469424, -51.615518),
            LatLng(49.650728, -48.69561),
            LatLng(49.654206, -48.626732),
            LatLng(49.657657, -48.557663),
            LatLng(49.661082, -48.488401),
            LatLng(49.664479, -48.418944),
            LatLng(49.667849, -48.349291),
            LatLng(49.671191, -48.27944),
            LatLng(49.674506, -48.209391),
            LatLng(49.677793, -48.139141),
            LatLng(49.681051, -48.068689),
            LatLng(49.684282, -47.998034),
            LatLng(49.687484, -47.927175),
            LatLng(49.690657, -47.856109),
            LatLng(49.693801, -47.784836),
            LatLng(49.696916, -47.713353),
            LatLng(49.700001, -47.64166),
            LatLng(49.703057, -47.569754),
            LatLng(49.706083, -47.497634),
            LatLng(49.709079, -47.425298),
            LatLng(49.712044, -47.352745),
            LatLng(49.714979, -47.279973),
            LatLng(49.717883, -47.20698),
            LatLng(49.720755, -47.133765),
            LatLng(49.723597, -47.060326),
            LatLng(49.726406, -46.986661),
            LatLng(49.729184, -46.912768),
            LatLng(49.73193, -46.838645),
            LatLng(49.734643, -46.764291),
            LatLng(49.737324, -46.689704),
            LatLng(49.739971, -46.614882),
            LatLng(49.742585, -46.539823),
            LatLng(49.745166, -46.464525),
            LatLng(49.747713, -46.388986),
            LatLng(49.750226, -46.313204),
            LatLng(49.752704, -46.237177),
            LatLng(49.755147, -46.160903),
            LatLng(49.757556, -46.08438),
            LatLng(49.759929, -46.007606),
            LatLng(49.762267, -45.930578),
            LatLng(49.764569, -45.853295),
            LatLng(49.766834, -45.775754),
            LatLng(49.769063, -45.697953),
            LatLng(49.771254, -45.61989),
            LatLng(49.773409, -45.541562),
            LatLng(49.775526, -45.462967),
            LatLng(49.777605, -45.384103),
            LatLng(49.779645, -45.304966),
            LatLng(49.781647, -45.225556),
            LatLng(49.78361, -45.145869),
            LatLng(49.785534, -45.065903),
            LatLng(49.787418, -44.985654),
            LatLng(49.789261, -44.905122),
            LatLng(49.791064, -44.824302),
            LatLng(49.792826, -44.743192),
            LatLng(49.794547, -44.66179),
            LatLng(49.796226, -44.580092),
            LatLng(49.797863, -44.498096),
            LatLng(49.799457, -44.415798),
            LatLng(49.801008, -44.333197),
            LatLng(49.802516, -44.250288),
            LatLng(49.80398, -44.16707),
            LatLng(49.805399, -44.083538),
            LatLng(49.806774, -43.99969),
            LatLng(49.808104, -43.915522),
            LatLng(49.809388, -43.831031),
            LatLng(49.810625, -43.746214),
            LatLng(49.811816, -43.661068),
            LatLng(49.81296, -43.575589),
            LatLng(49.814056, -43.489773),
            LatLng(49.815104, -43.403617),
            LatLng(49.816103, -43.317117),
            LatLng(49.817053, -43.230271),
            LatLng(49.817953, -43.143073),
            LatLng(49.818803, -43.05552),
            LatLng(49.819602, -42.967608),
            LatLng(49.820349, -42.879333),
            LatLng(49.821044, -42.790692),
            LatLng(49.821687, -42.701679),
            LatLng(49.822276, -42.612291),
            LatLng(49.822812, -42.522524),
            LatLng(49.823293, -42.432373),
            LatLng(49.823718, -42.341833),
            LatLng(49.824088, -42.250901),
            LatLng(49.824401, -42.159571),
            LatLng(49.824658, -42.067838),
            LatLng(49.824856, -41.975698),
            LatLng(49.824996, -41.883147),
            LatLng(49.825076, -41.790177),
            LatLng(49.825096, -41.696786),
            LatLng(49.825056, -41.602967),
            LatLng(49.824954, -41.508715),
            LatLng(49.824789, -41.414024),
            LatLng(49.824562, -41.31889),
            LatLng(49.82427, -41.223305),
            LatLng(49.823914, -41.127265),
            LatLng(49.823491, -41.030763),
            LatLng(49.823003, -40.933793),
            LatLng(49.822446, -40.836349),
            LatLng(49.821822, -40.738425),
            LatLng(49.821128, -40.640013),
            LatLng(49.820363, -40.541107),
            LatLng(49.819527, -40.441701),
            LatLng(49.818619, -40.341786),
            LatLng(49.817638, -40.241357),
            LatLng(49.816582, -40.140405),
            LatLng(49.815451, -40.038923),
            LatLng(49.814243, -39.936904),
            LatLng(49.812957, -39.834338),
            LatLng(49.811593, -39.731219),
            LatLng(49.810148, -39.627537),
            LatLng(49.808622, -39.523284),
            LatLng(49.807013, -39.418451),
            LatLng(49.80532, -39.313029),
            LatLng(49.803542, -39.207009),
            LatLng(49.801678, -39.100382),
            LatLng(49.799725, -38.993136),
            LatLng(49.797683, -38.885263),
            LatLng(49.79555, -38.776752),
            LatLng(49.793325, -38.667592),
            LatLng(49.791005, -38.557772),
            LatLng(49.78859, -38.447281),
            LatLng(49.786078, -38.336107),
            LatLng(49.783466, -38.224239),
            LatLng(49.780754, -38.111663),
            LatLng(49.777939, -37.998367),
            LatLng(49.77502, -37.884339),
            LatLng(49.771995, -37.769564),
            LatLng(49.768861, -37.654028),
            LatLng(49.765616, -37.537717),
            LatLng(49.762259, -37.420616),
            LatLng(49.758787, -37.30271),
            LatLng(49.755199, -37.183983),
            LatLng(49.75149, -37.064419),
            LatLng(49.747661, -36.943999),
            LatLng(49.743707, -36.822708),
            LatLng(49.739626, -36.700526),
            LatLng(49.735415, -36.577434),
            LatLng(49.731072, -36.453414),
            LatLng(49.726595, -36.328444),
            LatLng(49.721978, -36.202504),
            LatLng(49.717221, -36.075572),
            LatLng(49.712319, -35.947625),
            LatLng(49.70727, -35.81864),
            LatLng(49.702069, -35.688592),
            LatLng(49.696713, -35.557455),
            LatLng(49.691198, -35.425203),
            LatLng(49.685521, -35.291808),
            LatLng(49.679678, -35.157241),
            LatLng(49.673663, -35.021473),
            LatLng(49.667473, -34.884471),
            LatLng(49.661102, -34.746203),
            LatLng(49.654547, -34.606634),
            LatLng(49.647802, -34.465728),
            LatLng(49.640862, -34.323448),
            LatLng(49.63372, -34.179754),
            LatLng(49.626372, -34.034605),
            LatLng(49.618811, -33.887956),
            LatLng(49.611031, -33.739762),
            LatLng(49.603024, -33.589975),
            LatLng(49.594784, -33.438544),
            LatLng(49.586303, -33.285415),
            LatLng(49.577573, -33.130531),
            LatLng(49.568585, -32.973833),
            LatLng(49.559331, -32.815258),
            LatLng(49.549802, -32.654736),
            LatLng(49.539986, -32.492198),
            LatLng(49.529874, -32.327568),
            LatLng(49.519454, -32.160763),
            LatLng(49.508714, -31.991699),
            LatLng(49.497641, -31.820282),
            LatLng(49.486221, -31.646415),
            LatLng(49.474439, -31.46999),
            LatLng(49.462279, -31.290895),
            LatLng(49.449724, -31.109007),
            LatLng(49.436756, -30.924192),
            LatLng(49.423354, -30.736309),
            LatLng(49.409496, -30.545202),
            LatLng(49.395159, -30.350701),
            LatLng(49.380316, -30.152622),
            LatLng(49.364941, -29.950763),
            LatLng(49.349, -29.744903),
            LatLng(49.332461, -29.534797),
            LatLng(49.315285, -29.320174),
            LatLng(49.297431, -29.100734),
            LatLng(49.27885, -28.876141),
            LatLng(49.259491, -28.646018),
            LatLng(49.239293, -28.409939),
            LatLng(49.21819, -28.167422),
            LatLng(49.196104, -27.917913),
            LatLng(49.172945, -27.660776),
            LatLng(49.148611, -27.39527),
            LatLng(49.122979, -27.120528),
            LatLng(49.095907, -26.835517),
            LatLng(49.06722, -26.539),
            LatLng(49.036708, -26.229466),
            LatLng(49.004109, -25.905041),
            LatLng(48.969093, -25.563353),
            LatLng(48.931228, -25.201319),
            LatLng(48.889941, -24.814815),
            LatLng(48.844429, -24.398095),
            LatLng(48.793517, -23.942732),
            LatLng(48.735356, -23.435451),
            LatLng(48.666706, -22.852993),
            LatLng(48.580799, -22.146739),
            LatLng(48.457038, -21.168624),
          ],
          ), },
        markers: {Marker(markerId: MarkerId("_currentLocation"), icon: BitmapDescriptor.defaultMarker, position: LatLng(double.parse(lat), double.parse(long)))}
    );

    setCircumTable(jsRuntime);
  }

  Future<void> getLocationInfo() async {
    print("-----------------------------------------------------------");
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(double.parse(lat), double.parse(long));

      if (placemarks != null && placemarks.isNotEmpty) {
        Placemark currentPlace = placemarks[0];

        String city = currentPlace.locality ?? '';
        String state = currentPlace.administrativeArea ?? '';
        String country = currentPlace.country ?? '';

        if (city.isNotEmpty){
          if (state.isNotEmpty){
            city = city + ',';
          }
        }


        setState(() {
          locationMessage = '$city $state';
        });
        print('$city, $state, $country');
      } else {
        print('No location information available');
      }
    } catch (e) {
      print('Error retrieving location information: $e');
    }
  }

  String extractInfo(String pattern, String input, bool timeBool) {
    RegExp regex = RegExp(pattern);
    var match = regex.firstMatch(input);
    if (timeBool) {
    return match != null ? convertTo12HourFormat(match.group(1).toString()) ?? "" : "N/A";
    } else {
    return match != null ? double.parse((double.parse(match.group(1)!) * 100).toStringAsFixed(2)).toString() + "%" ?? "" : "N/A";
    }
  }

  DateTime extract24Hour(String pattern, String input) {
    RegExp regex = RegExp(pattern);
    var match = regex.firstMatch(input);
    if (match != null) {
      String extractedString = match.group(1).toString();
      print(extractedString);

      // Define a formatter for the time format
      DateFormat timeFormatter = DateFormat('HH:mm:ss');

      // Parse the time string into a DateTime object
      DateTime time = timeFormatter.parse(extractedString);

      // Define the desired date
      DateTime date = DateTime(2024, 4, 8);

      // Combine the time and date into a single DateTime object
      DateTime combinedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);

      return combinedDateTime;

    } else {
      return DateTime(1970);
    }
  }

  String _printDuration(Duration duration) {
    String negativeSign = duration.isNegative ? '' : '-';
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
    return "$negativeSign${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  String convertTo12HourFormat(String time24Hour) {
    // Parse the input time string
    DateFormat inputFormat = DateFormat('HH:mm:ss');
    DateTime time = inputFormat.parse(time24Hour);

    // Format the time in 12-hour format
    DateFormat outputFormat = DateFormat('h:mm a');
    String time12Hour = outputFormat.format(time);

    return time12Hour;
  }

  void setCircumTable( JavascriptRuntime jsRuntime) async {
    // sets solar eclipse data
    String loadJs = await rootBundle.loadString("lib/sources/eclipse_explorer_flut.jsx");
    double doubleLat = double.parse(lat);
    double doubleLong = double.parse(long);
    double doubleAltitude = double.parse(altitude);
    DateTime dateTime = DateTime.now();
    Duration timeZone = dateTime.timeZoneOffset;
    String strTime = _printDuration(timeZone);
    // Remove '-' if present
    if (strTime.startsWith("-")) {
      strTime = strTime.substring(1);
    } else {
      // Add '-' if not present
      strTime = "-" + strTime;
    }

    Duration offset = DateTime.now().timeZoneOffset;
    int offsetInHours = offset.inHours * -1;

    final jsResult =
    jsRuntime.evaluate(loadJs + """recalculate($doubleLat, $doubleLong, $doubleAltitude, $offsetInHours)""");
    final jsStringResult = jsResult.stringResult;
    print("0000000000000000000000000000000000000");
    print(jsStringResult);



    List<String> resultList = jsStringResult.split(' ');
    setState(() {

      // store in shared preferences
      timeEclipseBegins = DateTime(2024, 3, 17, 23, 41);//extract24Hour(r'(\d+:\d+:\d+)ec_start', jsStringResult);
      timeMaxEclipse = DateTime(2024, 3, 17, 23, 47); //extract24Hour(r'(\d+:\d+:\d+)max_ec', jsStringResult);
      timeEclipseEnds = DateTime(2024, 3, 17, 23, 52); //extract24Hour(r'(\d+:\d+:\d+)ec_ends', jsStringResult);
      timeTotalityBegins = extract24Hour(r'(\d+:\d+:\d+)tot_start', jsStringResult);
      timeTotalityEnds = extract24Hour(r'(\d+:\d+:\d+)tot_ends', jsStringResult);

      timeUntilEclipseBegins = extractInfo(r'(\d+:\d+:\d+)ec_start', jsStringResult, true);
      timeUntilTotalityBegins = extractInfo(r'(\d+:\d+:\d+)tot_start', jsStringResult, true);
      timeUntilMaxEclipse = extractInfo(r'(\d+:\d+:\d+)max_ec', jsStringResult, true);
      expectedObscuration = extractInfo(r'(\d+\.\d+)mag', jsStringResult, false);
      expectedMagnitude = extractInfo(r'(\d+\.\d+)obsc', jsStringResult, false);

      text_col = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Eclipse begins: ${timeUntilEclipseBegins}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'Totality begins: ${timeUntilTotalityBegins}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'Max Eclipse: ${timeUntilMaxEclipse}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '',
            style: TextStyle(fontSize: 18),
          ),
          Text(
            'Max Coverage: ${expectedMagnitude}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      );
    });

    if (timeTotalityBegins != DateTime(1970)) {
      print("TIMETOTALITYBEGINS");
      print(timeTotalityBegins);
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 15,
          channelKey: 'scheduled',
          title: "1 hour until Total Solar Eclipse Begins",
          body: 'Totality begins at ${timeTotalityBegins}',
          category: NotificationCategory.Reminder,
          icon: 'resource://drawable/out_logo_draw2',
          backgroundColor: Color(0xFFF69A06),
        ),
        schedule: NotificationCalendar.fromDate(
            date: timeTotalityBegins.subtract(Duration(hours: 1))),
      );

      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 16,
          channelKey: 'scheduled',
          title: "5 min until Total Solar Eclipse Begins",
          body: 'Totality begins at ${timeTotalityBegins}',
          category: NotificationCategory.Reminder,
          icon: 'resource://drawable/out_logo_draw2',
          backgroundColor: Color(0xFFF69A06),
        ),
        schedule: NotificationCalendar.fromDate(
            date: timeTotalityBegins.subtract(Duration(minutes: 5))),
      );
    }

    if (timeEclipseBegins != DateTime(1970)){
      print("TIMEECLIPSEBEGINS");
      print(timeEclipseBegins);
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 17,
          channelKey: 'scheduled',
          title: "1 hour until Solar Eclipse Begins",
          body: 'Eclipse begins at ${timeEclipseBegins}',
          category: NotificationCategory.Reminder,
          icon: 'resource://drawable/out_logo_draw2',
          backgroundColor: Color(0xFFF69A06),
        ),
        schedule: NotificationCalendar.fromDate(
            date: timeEclipseBegins.subtract(Duration(hours: 1))),
      );

      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 18,
          channelKey: 'scheduled',
          title: "5 min until Solar Eclipse Begins",
          body: 'Eclipse begins at ${timeEclipseBegins}',
          category: NotificationCategory.Reminder,
          icon: 'resource://drawable/out_logo_draw2',
          backgroundColor: Color(0xFFF69A06),
        ),
        schedule: NotificationCalendar.fromDate(
            date: timeEclipseBegins.subtract(Duration(minutes: 5))),
      );
    }

    if (timeMaxEclipse != DateTime(1970)) {
      print("MAXECLIPSE");
      print(timeMaxEclipse);
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 19,
          channelKey: 'scheduled',
          title: "10 mins until Max Eclipse",
          body: 'Max Eclipse is at ${timeMaxEclipse}',
          category: NotificationCategory.Reminder,
          icon: 'resource://drawable/out_logo_draw2',
          backgroundColor: Color(0xFFF69A06),
        ),
        schedule: NotificationCalendar.fromDate(
            date: timeMaxEclipse.subtract(Duration(minutes: 10))),
      );
    }
  }

}
