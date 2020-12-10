

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:wemapgl_example/full_map.dart';

import 'animate_camera.dart';
import 'full_map.dart';
import 'line.dart';
import 'map_ui.dart';
import 'move_camera.dart';
import 'ePage.dart';
import 'place_circle.dart';
import 'place_symbol.dart';
import 'place_fill.dart';
import 'place_geojson.dart';
import 'scrolling_map.dart';
import 'route.dart';
import 'search.dart';
import 'simpleDirection.dart';
import 'package:wemapgl/wemapgl.dart' as WEMAP;

final List<ePage> _allPages = <ePage>[
  MapUiPage(),
  SearchPage(),
  SimpleDirectionPage(),
  FullMapPage(),
  RoutePage(),
  AnimateCameraPage(),
  MoveCameraPage(),
  PlaceSymbolPage(),
  LinePage(),
  PlaceCirclePage(),
  PlaceFillPage(),
  PlaceGeoJSONPage(),
  ScrollingMapPage(),
];

class MapsDemo extends StatelessWidget {
  void _pushPage(BuildContext context, ePage page) async {
    final location = Location();
    final hasPermissions = await location.hasPermission();
    if (hasPermissions != PermissionStatus.GRANTED) {
      await location.requestPermission();
    }

    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => Scaffold(
              body: page,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WeMap examples')),
      body: ListView.builder(
        itemCount: _allPages.length,
        itemBuilder: (_, int index) => ListTile(
          leading: _allPages[index].leading,
          title: Text(_allPages[index].title),
          onTap: () => _pushPage(context, _allPages[index]),
        ),
      ),
    );
  }
}

void main() {
  WEMAP.Configuration.setWeMapKey('YOUR_WEMAP_API_KEY');
  runApp(MaterialApp(home: MapsDemo()));
}
