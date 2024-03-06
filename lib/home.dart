import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' show Geolocator, LocationAccuracy, LocationSettings, LocationPermission, Position;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
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
      setState(() {
        _getCurrentLocation().then((value) {
          lat = '${value.latitude}';
          long = '${value.longitude}';
          altitude = '${value.altitude}';
          setState(() {
            online_color = Colors.green;
            locationMessage = 'Lat: $lat, Long: $long, Alt: $altitude';
            getLocationInfo();
            locationRetrieved = true;
            _setMap();
          });});
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
                          left: 171.5, // Adjust the left position as needed
                          child: Container(
                            width: 50, // Adjust the size as needed
                            height: 50, // Adjust the size as needed
                            decoration: BoxDecoration(
                              color: Color(0xFF000000), // White color
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
                      color: Colors.black,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() { loading = true; });
                        _getCurrentLocation().then((value) {
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
                          });

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

    Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      lat = position.latitude.toString();
      long = position.longitude.toString();

      setState(() {
        //locationMessage = 'Lat: $lat, Long: $long, Alt: $altitude';
        getLocationInfo();
        mapController.animateCamera(CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)));
        _setMap();
      });


    });

    }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller.setMapStyle('''[
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
]''') as GoogleMapController;
    });
  }

  Future<void> _setMap() async {
    map = GoogleMap(
      onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(double.parse(lat), double.parse(long)),
          zoom: 13.0,
        ),
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
    print(jsStringResult);

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'basic_channel',
        title: "1 hour until Total Solar Eclipse Begins",
        body: 'Totality begins at 12:20PM',
      ),
       // Schedules the notification to trigger 10 seconds after the current time
    );



    List<String> resultList = jsStringResult.split(' ');
    setState(() {
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


  }

}
