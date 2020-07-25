import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Petrol Price',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position _currentPosition;
  String _currentAddress;
  static String _city;
  String url = "https://www.goodreturns.in/petrol-price-in-${_city}.html";
  String petrolPrice;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Petrol Prices"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_currentAddress ?? 'No '),
            Text(petrolPrice ?? 'No '),
            FlatButton(
              child: Text("Get location"),
              onPressed: () {
                _getCurrentLocation();
              },
            ),
          ],
        ),
      ),
    );
  }

  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
        _city = "${place.locality}";
      });
      _fetchPetrolPrice();
    } catch (e) {
      print(e);
    }
  }

  _fetchPetrolPrice() async {
    String url =
        "https://www.goodreturns.in/petrol-price-in-${_city.toLowerCase()}.html";
    final response = await http.Client().get(Uri.parse(url));
    if (response.statusCode == 200) {
      var document = parse(response.body);
      var index = document.outerHtml.toString().indexOf('Rs.');
      setState(() {
        petrolPrice =
            document.outerHtml.toString().substring(index + 4, index + 9);
      });

      print(document.outerHtml.toString().indexOf('Rs.'));
    } else {
      throw Exception();
    }
  }
}
