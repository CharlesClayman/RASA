import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HotspotPage extends StatefulWidget {
  final GeoPoint latLng;
  String markerid;
  Set<Marker> _marker = {};
  String hotspot_id;

  HotspotPage({
    this.latLng,
    this.markerid,
    this.hotspot_id,
  });

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<HotspotPage> {
  static final LatLng _center = const LatLng(6.7470, -1.5209);
  Completer<GoogleMapController> mapController = Completer();
  Set<Circle> _circle = Set<Circle>();

  void _onMapCreated(GoogleMapController controller) {
    mapController.complete(controller);
  }

  void _drawCircle() {
    _circle.add(Circle(
      circleId: CircleId("HotSpotArea"),
      center: LatLng(widget.latLng.latitude, widget.latLng.longitude),
      radius: 1000,
      fillColor: Color.fromRGBO(0, 105, 148, 0.5),
      strokeWidth: 2,
      strokeColor: Colors.black,
    ));
  }

  @override
  void initState() {
    widget._marker.add(Marker(
      markerId: MarkerId(widget.markerid),
      position: LatLng(widget.latLng.latitude, widget.latLng.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ));
    _drawCircle();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('hotspot_markers');
    return FutureBuilder<DocumentSnapshot>(
        future: collectionReference.doc(widget.hotspot_id).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }
          if (snapshot.hasData && !snapshot.data.exists) {
            return Text("Document does not exist");
          }
          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data = snapshot.data.data();
            return Scaffold(
              appBar: AppBar(
                title: Text(widget.markerid),
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                    Color.fromRGBO(26, 21, 0, 0.8),
                    Color.fromRGBO(221, 255, 51, 0.8),
                  ])),
                ),
              ),
              body: Column(children: <Widget>[
                Container(
                  height: 0.45 * MediaQuery.of(context).size.height,
                  child: GoogleMap(
                    circles: _circle,
                    markers: widget._marker,
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                          widget.latLng.latitude, widget.latLng.longitude),
                      zoom: 13.0,
                    ),
                    zoomControlsEnabled: false,
                  ),
                ),
                Expanded(
                    child: Container(
                  padding: EdgeInsets.only(
                      top: 10.0, left: 20.0, right: 20.0, bottom: 0.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 2.0),
                        child: Center(
                            child: Text(
                          "ACCIDENT SEVERITY",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        )),
                      ),
                      ListTile(
                        dense: true,
                        visualDensity:
                            VisualDensity(horizontal: 0, vertical: -2),
                        contentPadding:
                            EdgeInsets.only(top: 0.0, bottom: 0.0, right: 8),
                        leading: Image(
                          image: AssetImage('assets/icons/death.png'),
                        ),
                        trailing: Text(data["Fatal"]),
                        title: Text(
                          "Fatal",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        visualDensity:
                            VisualDensity(horizontal: 0, vertical: -2),
                        contentPadding:
                            EdgeInsets.only(top: 0.0, bottom: 0.0, right: 8),
                        leading: Image(
                          image: AssetImage('assets/icons/serious.jpg'),
                        ),
                        trailing: Text(data["Serious"]),
                        title: Text(
                          "Serious",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        visualDensity:
                            VisualDensity(horizontal: 0, vertical: -2),
                        contentPadding:
                            EdgeInsets.only(top: 0.0, bottom: 0.0, right: 8),
                        leading: Image(
                          image: AssetImage('assets/icons/slight.jpg'),
                        ),
                        trailing: Text(data["Slight"]),
                        title: Text(
                          "Slight",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        visualDensity:
                            VisualDensity(horizontal: 0, vertical: -2),
                        contentPadding:
                            EdgeInsets.only(top: 0.0, bottom: 0.0, right: 8),
                        leading: Image(
                          image: AssetImage('assets/icons/damage.png'),
                        ),
                        trailing: Text(data["DamageOnly"]),
                        title: Text(
                          "Damage only",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      Divider(
                        height: 1.0,
                        color: Colors.black,
                      ),
                      ListTile(
                        dense: true,
                        visualDensity:
                            VisualDensity(horizontal: 0, vertical: -2),
                        contentPadding:
                            EdgeInsets.only(top: 0.0, bottom: 0.0, right: 8),
                        trailing: Text(data["Total"]),
                        title: Text(
                          "Total",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ))
              ]),
            );
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
