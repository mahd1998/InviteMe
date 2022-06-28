import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:assessment_task/components/globals.dart' as globals;

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

typedef MarkerUpdateAction = Marker Function(Marker marker);
const kGoogleApiKey = '***************************';
final homeScaffoldKey = GlobalKey<ScaffoldState>();

class MapSampleState extends State<MapSample> {
  Set<Marker> markersList = {};
  LatLng tempLocation = LatLng(0.0000000, 0.0000000);
  late GoogleMapController googleMapController;
  Completer<GoogleMapController> _controller = Completer();
  List<Marker> myMarker = [];
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(31.985395645514572, 35.89801872827074),
    zoom: 14.4746,
  );

  final Mode _mode = Mode.overlay;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('Pick Event Location'),
        elevation: 0,
        backgroundColor: Color(0xff7252E7).withOpacity(0.6),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _handlePressButton,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            markers: Set.from(myMarker),
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              googleMapController = controller;
              _controller.complete(controller);
            },
            onTap: _handleTap,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          globals.location = tempLocation;

          Navigator.pop(context);
        },
        label: Text('confirm'),
        icon: Icon(Icons.directions_boat),
        backgroundColor: Color(0xff7252E7),
      ),
    );
  }

  Future<void> _handlePressButton() async {
    Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: kGoogleApiKey,
        onError: onError,
        mode: _mode,
        language: 'en',
        strictbounds: false,
        types: [""],
        decoration: InputDecoration(
            hintText: 'Search',
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.white))),
        components: [new Component(Component.country, "jor")]);

    displayPrediction(p!, homeScaffoldKey.currentState);
  }

  void onError(PlacesAutocompleteResponse response) {
    homeScaffoldKey.currentState!
        .showSnackBar(SnackBar(content: Text(response.errorMessage!)));
  }

  _handleTap(LatLng tappedPoint) async {
    tempLocation = tappedPoint;
    print(tappedPoint);
    setState(() {
      myMarker = [];
      myMarker.add(Marker(
        markerId: MarkerId(tappedPoint.toString()),
        position: tappedPoint,
      ));
    });
  }

  Future<void> displayPrediction(
      Prediction p, ScaffoldState? currentState) async {
    GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: kGoogleApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders());

    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);

    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;

    markersList.clear();
    markersList.add(Marker(
        markerId: const MarkerId("0"),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: detail.result.name)));

    setState(() {});

    googleMapController
        .animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0));
  }
}
