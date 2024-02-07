import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' show Geolocator, LocationAccuracy, LocationSettings, LocationPermission, Position;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:geocoding/geocoding.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {

  bool locationRetrieved = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

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
        'Time when:',
        style: TextStyle(fontSize: 20),
      ),
      Text(
        'Eclipse begins: ${timeUntilEclipseBegins}',
        style: TextStyle(fontSize: 18),
      ),
      Text(
        'Totality begins: ${timeUntilTotalityBegins}',
        style: TextStyle(fontSize: 18),
      ),
      Text(
        'Max Eclipse: ${timeUntilMaxEclipse}',
        style: TextStyle(fontSize: 18),
      ),
      Text(
        '',
        style: TextStyle(fontSize: 18),
      ),
      Text(
        'Expected Obscuration: ${expectedObscuration}',
        style: TextStyle(fontSize: 20),
      ),
      Text(
        'Expected Magnitude: ${expectedMagnitude}',
        style: TextStyle(fontSize: 20),
      ),
    ],
  );
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
                    SizedBox(height: 40), // Add some spacing

                    // Text section for time until different eclipse events
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      padding: EdgeInsets.all(10), // Add padding for better appearance
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10), // Set border radius for rounded edges
                        border: Border.all(width: 2, color: Colors.black), // Set border properties
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
                          });
                          _liveLocation();
                        });
                      },
                      child: Text("Get Location"),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
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
      mapController = controller;
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

  String extractTime(String pattern, String input) {
    RegExp regex = RegExp(pattern);
    var match = regex.firstMatch(input);
    return match != null ? match.group(1) ?? "" : "N/A";
  }

  void setCircumTable( JavascriptRuntime jsRuntime) async {
    // sets solar eclipse data
    String loadJs = await rootBundle.loadString("lib/sources/eclipse_explorer_flut.jsx");
    double doubleLat = double.parse(lat);
    double doubleLong = double.parse(long);
    double doubleAltitude = double.parse(altitude);
    final jsResult =
    jsRuntime.evaluate(loadJs + """recalculate($doubleLat, $doubleLong, $doubleAltitude)""");
    final jsStringResult = jsResult.stringResult;
    //print(jsStringResult);

    List<String> resultList = jsStringResult.split(' ');
    setState(() {
      timeUntilEclipseBegins = extractTime(r'(\d+:\d+:\d+)ec_start', jsStringResult);
      timeUntilTotalityBegins = extractTime(r'(\d+:\d+:\d+)tot_start', jsStringResult);
      timeUntilMaxEclipse = extractTime(r'(\d+:\d+:\d+)max_ec', jsStringResult);
      expectedObscuration = extractTime(r'(\d+\.\d+)mag', jsStringResult);
      expectedMagnitude = extractTime(r'(\d+\.\d+)obsc', jsStringResult);

      text_col = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Time when:',
            style: TextStyle(fontSize: 20),
          ),
          Text(
            'Eclipse begins: ${timeUntilEclipseBegins}',
            style: TextStyle(fontSize: 18),
          ),
          Text(
            'Totality begins: ${timeUntilTotalityBegins}',
            style: TextStyle(fontSize: 18),
          ),
          Text(
            'Max Eclipse: ${timeUntilMaxEclipse}',
            style: TextStyle(fontSize: 18),
          ),
          Text(
            '',
            style: TextStyle(fontSize: 18),
          ),
          Text(
            'Expected Obscuration: ${expectedObscuration}',
            style: TextStyle(fontSize: 20),
          ),
          Text(
            'Expected Magnitude: ${expectedMagnitude}',
            style: TextStyle(fontSize: 20),
          ),
        ],
      );
    });
  }

}
