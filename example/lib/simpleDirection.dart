import 'package:flutter/material.dart';
import 'package:wemapgl/wemapgl.dart';

import 'ePage.dart';

class SimpleDirectionPage extends ePage {
  SimpleDirectionPage() : super(const Icon(Icons.map), 'Simple Direction');

  @override
  Widget build(BuildContext context) {
    return const DirectionAPI();
  }
}

class DirectionAPI extends StatefulWidget {
  const DirectionAPI();

  @override
  State createState() => DirectionAPIState();
}

class DirectionAPIState extends State<DirectionAPI> {
  WeMapDirections directionAPI = WeMapDirections();

  final String from = '21.036751,105.782013';
  final String to = '21.004880,105.817432';
  int _tripDistance = 0;
  int _tripTime = 0;

  WeMapController mapController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Direction example",
        home: Scaffold(
            appBar: AppBar(
              title: Text("Direction example"),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: Text(
                      "Trip distance: $_tripDistance m. Trip time estimate: $_tripTime ms"),
                ),
                Center(
                  child: SizedBox(
                    width: 300.0,
                    height: 200.0,
                    child: WeMap(
                      onMapCreated: _onMapCreated,
                      onStyleLoadedCallback: onStyleLoadedCallback,
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(21.017273, 105.798138),
                        zoom: 11.0,
                      ),
                    ),
                  ),
                ),
              ],
            )));
  }

  void _onMapCreated(WeMapController mapController) {
    this.mapController = mapController;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onStyleLoadedCallback() async {
    final json = await directionAPI.getResponse(
        0, from, to); //0 = car, 1 = bike, 2 = foot
    List<LatLng> _route = await directionAPI.getRoute(json);

    setState(() {
      _tripDistance = directionAPI.getDistance(json);
      _tripTime = directionAPI.getTime(json);
    });

    if (_route != null) {
      await mapController.addLine(
        LineOptions(
          geometry: _route,
          lineColor: "#0071bc",
          lineWidth: 5.0,
          lineOpacity: 1,
        ),
      );
      await mapController.addCircle(CircleOptions(
          geometry: _route[0],
          circleRadius: 8.0,
          circleColor: '#d3d3d3',
          circleStrokeWidth: 1.5,
          circleStrokeColor: '#0071bc'));
      await mapController.addCircle(CircleOptions(
          geometry: _route[_route.length - 1],
          circleRadius: 8.0,
          circleColor: '#ffffff',
          circleStrokeWidth: 1.5,
          circleStrokeColor: '#0071bc'));
    }
  }
}
