import 'package:flutter/material.dart';

import 'pages/calculate_distance_widget.dart';
import 'pages/current_location_widget.dart';
import 'pages/location_stream_widget.dart';
import 'pages/google_play_services_widget.dart';

void main() => runApp(new GeolocatorExampleApp());

enum TabItem { singleLocation, locationStream, distance, googlePlayServices }

class GeolocatorExampleApp extends StatefulWidget {
  @override
  State<GeolocatorExampleApp> createState() => BottomNavigationState();
}

class BottomNavigationState extends State<GeolocatorExampleApp> {
  TabItem _currentItem = TabItem.singleLocation;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Geolocator Example App'),
        ),
        body: _buildBody(),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentItem) {
      case TabItem.locationStream:
        return LocationStreamWidget();
      case TabItem.distance:
        return CalculateDistanceWidget();
      case TabItem.googlePlayServices:
        return GooglePlayServicesWidget();
      case TabItem.singleLocation:
      default:
        return CurrentLocationWidget();
    }
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        _buildBottomNavigationBarItem(
            Icons.location_on, TabItem.singleLocation),
        _buildBottomNavigationBarItem(Icons.clear_all, TabItem.locationStream),
        _buildBottomNavigationBarItem(Icons.redo, TabItem.distance),
        _buildBottomNavigationBarItem(Icons.adb, TabItem.googlePlayServices),
      ],
      onTap: _onSelectTab,
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(
      IconData icon, TabItem tabItem) {
    String text = tabItem.toString().split('.').last;
    Color color =
        _currentItem == tabItem ? Theme.of(context).primaryColor : Colors.grey;

    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: color,
      ),
      title: Text(
        text,
        style: TextStyle(
          color: color,
        ),
      ),
    );
  }

  void _onSelectTab(int index) {
    TabItem selectedTabItem;

    switch (index) {
      case 1:
        selectedTabItem = TabItem.locationStream;
        break;
      case 2:
        selectedTabItem = TabItem.distance;
        break;
      case 3:
        selectedTabItem = TabItem.googlePlayServices;
        break;
      default:
        selectedTabItem = TabItem.singleLocation;
    }

    setState(() {
      _currentItem = selectedTabItem;
    });
  }
}
