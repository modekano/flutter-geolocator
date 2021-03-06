import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../common_widgets/placeholder_widget.dart';

class LocationStreamWidget extends StatefulWidget {
  @override
  State<LocationStreamWidget> createState() => LocationStreamState();
}

class LocationStreamState extends State<LocationStreamWidget> {
  StreamSubscription<Position> _positionStreamSubscription;
  List<Position> _positions = <Position>[];

  void _toggleListening() async {
    if (_positionStreamSubscription == null) {
      final LocationOptions locationOptions = const LocationOptions(
          accuracy: LocationAccuracy.best, distanceFilter: 10);
      final Stream<Position> positionStream =
          await Geolocator().getPositionStream(locationOptions);
      _positionStreamSubscription = positionStream
          .listen((position) => setState(() => _positions.add(position)));
      _positionStreamSubscription.pause();
    }

    setState(() {
      if (_positionStreamSubscription.isPaused) {
        _positionStreamSubscription.resume();
      } else {
        _positionStreamSubscription.pause();
      }
    });
  }

  @override
  void dispose() {
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription.cancel();
      _positionStreamSubscription = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Geolocator().checkGeolocationPermissionStatus(),
        builder:
            (BuildContext context, AsyncSnapshot<GeolocationStatus> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == GeolocationStatus.denied) {
            return PlaceholderWidget("Location services disabled",
                "Enable location services for this App using the device settings.");
          }

          return _buildListView();
        });
  }

  Widget _buildListView() {
    List<Widget> listItems = <Widget>[
      ListTile(
        title: RaisedButton(
          child: _buildButtonText(),
          color: _determineButtonColor(),
          padding: EdgeInsets.all(8.0),
          onPressed: _toggleListening,
        ),
      ),
    ];

    listItems.addAll(
        _positions.map((position) => PositionListItem(position)).toList());

    return ListView(
      children: listItems,
    );
  }

  bool _isListening() => !(_positionStreamSubscription == null ||
      _positionStreamSubscription.isPaused);

  Widget _buildButtonText() {
    return Text(_isListening() ? "Stop listening" : "Start listening");
  }

  Color _determineButtonColor() {
    return _isListening() ? Colors.red : Colors.green;
  }
}

class PositionListItem extends StatefulWidget {
  PositionListItem(this._position);

  final Position _position;

  @override
  State<PositionListItem> createState() => PositionListItemState(_position);
}

class PositionListItemState extends State<PositionListItem> {
  PositionListItemState(this._position);

  final Position _position;
  String _address = "";

  @override
  Widget build(BuildContext context) {
    Row row = Row(
      children: <Widget>[
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                "Lat: ${_position.latitude}",
                style: TextStyle(fontSize: 16.0, color: Colors.black),
              ),
              Text(
                "Lon: ${_position.longitude}",
                style: TextStyle(fontSize: 16.0, color: Colors.black),
              ),
            ]),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  _position.timestamp.toLocal().toString(),
                  style: TextStyle(fontSize: 14.0, color: Colors.grey),
                )
              ]),
        ),
      ],
    );

    return ListTile(
      onTap: _onTap,
      title: row,
      subtitle: Text(_address),
    );
  }

  void _onTap() async {
    String address = "unknown";
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(_position.latitude, _position.longitude);

    if (placemarks != null && placemarks.length > 0) {
      address = _buildAddressString(placemarks.first);
    }

    setState(() {
      _address = "$address";
    });
  }

  static String _buildAddressString(Placemark placemark) {
    String name = placemark.name ?? "";
    String city = placemark.locality ?? "";
    String state = placemark.administrativeArea ?? "";
    String country = placemark.country ?? "";

    return "$name, $city, $state, $country";
  }
}
