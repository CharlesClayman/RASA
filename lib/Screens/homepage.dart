import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:road_safety/models/directions_model.dart';
import 'package:road_safety/models/directions_repository.dart';
import 'package:road_safety/services/instructions.dart';
import 'hotspotListPage.dart';
import 'package:road_safety/blocs/application_bloc.dart';
import 'package:road_safety/models/audio_notification.dart';
import 'package:flutter_mapbox_navigation/library.dart';

class HomePage extends StatefulWidget {
  final AudioNotification audioNotification = new AudioNotification();
  final Instructions instructions = new Instructions();

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<HomePage> {
  //My Map Variables;
  Completer<GoogleMapController> mapController = Completer();
  BitmapDescriptor _carMarker;
  static final LatLng _center = const LatLng(6.7470, -1.5209);
  final List<GeoPoint> hotspotAreaLatlng = [];
  Set<Marker> _markers = {};
  Set<Circle> _circle = Set<Circle>();
  LatLng _currentMapPosition = _center;

  //Reference to database
  final CollectionReference hotspotReference =
      FirebaseFirestore.instance.collection('hotspot_markers');

  //Car Tracker variables
  StreamSubscription _locationSubscription;
  final Location _locationTracker = Location();
  Marker marker;

  //Destination textfield
  var _destinationTextController = TextEditingController();
  Marker _destinationMarker;
  Directions _info;
  Set<Polyline> _polyline = {};
  StreamSubscription destinationSubscription;
  LatLng originLatlng;

  //Traffic variable
  bool checkTraffic = false;

  //Navigation variables
  String _instruction = "";
   MapBoxNavigation _directions;
   MapBoxOptions _options;
     bool _isMultipleStop = false;
   double _distanceRemaining = null;
   double _durationRemaining = null;
  MapBoxNavigationViewController _controller;
  bool _routeBuilt = false;
  bool _isNavigating = false;
  var startingPoint,endingPoint ;


  void _addDestinationMarker({LatLng originPos, LatLng destinationPos}) async {
    _destinationMarker = Marker(
      markerId: MarkerId("destination"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      position: destinationPos,
    );
    _markers.add(_destinationMarker);
    final directions = await DirectionsRepository()
        .getDirections(origin: originPos, destination: destinationPos);
    _info = directions;

    _polyline.add(Polyline(
      polylineId: const PolylineId("overview_polyline"),
      color: Colors.black,
      width: 5,
      startCap: Cap.roundCap,
      endCap: Cap.buttCap,
      geodesic: true,
      points: _info.polylinePoints
          .map((e) => LatLng(e.latitude, e.longitude))
          .toList(),
    ));
  }

  Widget loadMap() {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection('hotspot_markers').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData)
          return Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(
                width: 20.0,
              ),
              Text("Loading map"),
            ],
          ));

        //reading map markers into list
        for (int i = 0; i < snapshot.data.size; i++) {
          _markers.add(Marker(
              markerId: MarkerId(snapshot.data.docs[i]["PlaceName"]),
              position: LatLng(snapshot.data.docs[i]["PlaceLocation"].latitude,
                  snapshot.data.docs[i]["PlaceLocation"].longitude),
              infoWindow: InfoWindow(
                  title: snapshot.data.docs[i]["PlaceName"],
                  snippet: 'An accident Hotspot'),
              icon: BitmapDescriptor.defaultMarker));

          //creating circles around hotspot
          _circle.add(Circle(
            circleId: CircleId(snapshot.data.docs[i]["PlaceName"]),
            center: LatLng(snapshot.data.docs[i]["PlaceLocation"].latitude,
                snapshot.data.docs[i]["PlaceLocation"].longitude),
            radius: 200,
            fillColor: Color.fromRGBO(0, 105, 148, 0.5),
            strokeWidth: 2,
            strokeColor: Colors.black,
          ));

          //Adding list hotspot areas for alert function
          hotspotAreaLatlng.add(snapshot.data.docs[i]['PlaceLocation']);
        }
        final applicationBloc =
            Provider.of<ApplicationBloc>(context, listen: false);
        return Scaffold(
          floatingActionButton: Container(
            height: 60,
            width: 60,
            child: FittedBox(
              child: FloatingActionButton(
                elevation: 10,
                onPressed: () async {
                  setState(() {
                    checkTraffic = !checkTraffic;
                  }); 
               
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 60,
                  width: 60,
                  child: Text("Traffic\nStatus"),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [
                        Color.fromRGBO(26, 21, 0, 0.8),
                        Color.fromRGBO(221, 255, 51, 0.8),
                      ])),
                ),
              ),
            ),
          ),
          body: Stack(
            children: <Widget>[
              Container(
                child: GoogleMap(
                    myLocationButtonEnabled: true,
                    onMapCreated: _onMapCreated,
                    zoomControlsEnabled: false,
                    initialCameraPosition: CameraPosition(
                      target: _currentMapPosition,
                      zoom: 17.0,
                      tilt: 45.0,
                    ),
                    markers: _markers,
                    trafficEnabled: checkTraffic,
                    circles: _circle,
                    polylines: _polyline,
                    onCameraMove: _onCameraMove),
              ),
              if (applicationBloc.searchResults != null &&
                  applicationBloc.searchResults.length != 0)
                Container(
                    height: 300.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.6),
                        backgroundBlendMode: BlendMode.darken)),
              if (applicationBloc.searchResults != null)
                Container(
                  height: 300.0,
                  child: ListView.builder(
                      itemCount: applicationBloc.searchResults.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            applicationBloc.searchResults[index].description,
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            _destinationTextController.text = applicationBloc
                                .searchResults[index].description;

                            applicationBloc.setSelectedLocation(
                                applicationBloc.searchResults[index].placeId);

                            //Listen for selected Location
                            destinationSubscription = applicationBloc
                                .selectedLocation.stream
                                .listen((place) {
                              if (place != null) {
                                _polyline.clear();
                                LatLng destlatLng = LatLng(
                                    place.geometry.location.lat,
                                    place.geometry.location.lng);

                                setState(() {
                                  _addDestinationMarker(
                                      originPos: originLatlng,
                                      destinationPos: destlatLng);

                                      startingPoint = WayPoint(name:"Starting Point",latitude:originLatlng.latitude ,longitude: originLatlng.longitude);
                                      endingPoint = WayPoint(name:"${_destinationTextController.text}",latitude:destlatLng.latitude ,longitude: destlatLng.longitude);

                                        var wayPoints = <WayPoint>[];
                            wayPoints.add(startingPoint);
                            wayPoints.add(endingPoint);

                             _directions.startNavigation(
                                wayPoints: wayPoints,
                                options: MapBoxOptions(                               
                                    mode:
                                        MapBoxNavigationMode.drivingWithTraffic,
                                    simulateRoute: false,
                                    language: "en",
                                    units: VoiceUnits.metric));
                                });
                              } else
                                _destinationTextController.text = "";
                            });
                          },
                        );
                      }),
                ),
              Positioned(
                top: 30,
                right: 15,
                left: 15,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                          splashColor: Colors.grey,
                          icon: Icon(Icons.menu),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HotspotListPage(),
                                ));
                          }),
                      Expanded(
                        child: TextField(
                          controller: _destinationTextController,
                          onChanged: (value) {
                            applicationBloc.searchPlaces(value);
                          },
                          cursorColor: Colors.black,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.go,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 15),
                              hintText: "Destination..."),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: CircleAvatar(
                          child: Icon(
                            FontAwesomeIcons.search,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onCameraMove(CameraPosition position) {
    _currentMapPosition = position.target;
  }

  void _setMarkerIcon() async {
    _carMarker = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      "assets/icons/smallGreyCar.png",
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController.complete(controller);
    updateDriversCurrentLocation();
  }

  void updateDriverMarker(LocationData location) async {
    LatLng latLng = LatLng(location.latitude, location.longitude);
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId("car"),
          position: latLng,
          rotation: location.heading,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: _carMarker));
    });
  }

  void updateDriversCurrentLocation() async {
    try {
      var location = await _locationTracker.getLocation();

      updateDriverMarker(location);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged.listen((location) async {
        if (mapController != null) {
          final GoogleMapController controller = await mapController.future;
          controller
              .animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
            bearing: 192.8334901395799,
            target: LatLng(location.latitude, location.longitude),
            zoom: 17.0,
          )));

          updateDriverMarker(location);
          //  setState(() {
          originLatlng = LatLng(location.latitude, location.longitude);
          // });

        }
        await _onApproachingHotspotArea(location);
      });
    } on PlatformException catch (e) {
      if (e.code == "PERMISSION_DENIED") {
        debugPrint("Permission denied");
      }
    }
  }

  //Function to alerting driver when  approaching an accident prone area
  Future _onApproachingHotspotArea(LocationData _carCurrentLocation) async {
    for (int i = 0; i < hotspotAreaLatlng.length; ++i) {
      //distance here is in meters
      var carHotspotDistance = Geolocator.distanceBetween(
          _carCurrentLocation.latitude,
          _carCurrentLocation.longitude,
          hotspotAreaLatlng[i].latitude,
          hotspotAreaLatlng[i].longitude);
      if (carHotspotDistance > 200.0 && carHotspotDistance <= 500) {
        // the delay is to allow audio notification to complete statement
        // before repeating alert again while car is at most 200 meters away from accident hotspot
        await Future.delayed(const Duration(milliseconds: 8000), () {
          widget.audioNotification.showOnApproachNotification();
        });
        break;
      }

      if (carHotspotDistance < 200) {
        await Future.delayed(const Duration(milliseconds: 8000), () {
          widget.audioNotification.showOnWithinNotification();
        });
        break;
      }
    }
  } 

  @override
  void initState() {
    _setMarkerIcon();

    updateDriversCurrentLocation();

    initialize();
    super.initState();
  }

  @override
  void dispose() {
    final applicationBloc =
        Provider.of<ApplicationBloc>(context, listen: false);

    applicationBloc.dispose();
    destinationSubscription.cancel();
    super.dispose();
  }

  Future<void> initialize() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    _directions = MapBoxNavigation(onRouteEvent: _onEmbeddedRouteEvent);
    _options = MapBoxOptions(

        initialLatitude: _currentMapPosition.latitude,
        initialLongitude: _currentMapPosition.longitude,
        zoom: 20.0,
        tilt: 0.0,
        bearing: 0.0,
        enableRefresh: false,
        alternatives: true,
        voiceInstructionsEnabled: true,
        bannerInstructionsEnabled: true,
        allowsUTurnAtWayPoints: true,
        mode: MapBoxNavigationMode.drivingWithTraffic,
        units: VoiceUnits.imperial,
        simulateRoute: false,
        animateBuildRoute: true,
        longPressDestinationEnabled: true,
        language: "en");
  }

  Future<void> _onEmbeddedRouteEvent(e) async {
    _distanceRemaining = await _directions.distanceRemaining;
    _durationRemaining = await _directions.durationRemaining;

    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        if (progressEvent.currentStepInstruction != null)
          _instruction = progressEvent.currentStepInstruction.toString();
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        setState(() {
          _routeBuilt = true;
        });
        break;
      case MapBoxEvent.route_build_failed:
        setState(() {
          _routeBuilt = false;
        });
        break;
      case MapBoxEvent.navigation_running:
        setState(() {
          _isNavigating = true;
        });
        break;
      case MapBoxEvent.on_arrival:
        if (!_isMultipleStop) {
          await Future.delayed(Duration(seconds: 3));
          await _controller.finishNavigation();
        } else {}
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        setState(() {
          _routeBuilt = false;
          _isNavigating = false;
        });
        break;
      default:
        break;
    }
  
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loadMap(),
    );
  }
}
