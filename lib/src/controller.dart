

part of wemapgl;

typedef void OnMapClickCallback(
    Point<double> point, LatLng coordinates, Future<WeMapPlace> place);

typedef void OnStyleLoadedCallback();

typedef void OnCameraTrackingDismissedCallback();
typedef void OnCameraTrackingChangedCallback(MyLocationTrackingMode mode);

typedef void OnMapIdleCallback();

typedef void ShowPlaceCard(WeMapPlace place);

/// Controller for a single WeMap instance running on the host platform.
///
/// Change listeners are notified upon changes to any of
///
/// * the [options] property
/// * the collection of [Symbol]s added to this map
/// * the collection of [Line]s added to this map
/// * the [isCameraMoving] property
/// * the [cameraPosition] property
///
/// Listeners are notified after changes have been applied on the platform side.
///
/// Symbol tap events can be received by adding callbacks to [onSymbolTapped].
/// Line tap events can be received by adding callbacks to [onLineTapped].
/// Circle tap events can be received by adding callbacks to [onCircleTapped].
class WeMapController extends ChangeNotifier {
  WeMapController._(
      this._id, MethodChannel channel, CameraPosition initialCameraPosition,
      {this.onStyleLoadedCallback,
      this.onMapClick,
      this.onCameraTrackingDismissed,
      this.onCameraTrackingChanged,
      this.onMapIdle,
      this.showPlaceCard,
      this.reverse})
      : assert(_id != null),
        assert(channel != null),
        _channel = channel {
    _cameraPosition = initialCameraPosition;
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static Future<WeMapController> init(
      int id, CameraPosition initialCameraPosition,
      {OnStyleLoadedCallback onStyleLoadedCallback,
      OnMapClickCallback onMapClick,
      OnCameraTrackingDismissedCallback onCameraTrackingDismissed,
      OnCameraTrackingChangedCallback onCameraTrackingChanged,
      OnMapIdleCallback onMapIdle,
      ShowPlaceCard showPlaceCard,
      bool reverse}) async {
    assert(id != null);
    final MethodChannel channel = MethodChannel('plugins.flutter.io/wemap');
    await channel.invokeMethod('map#waitForMap');
    return WeMapController._(id, channel, initialCameraPosition,
        onStyleLoadedCallback: onStyleLoadedCallback,
        showPlaceCard: showPlaceCard,
        reverse: reverse,
        onMapClick: onMapClick,
        onCameraTrackingDismissed: onCameraTrackingDismissed,
        onCameraTrackingChanged: onCameraTrackingChanged,
        onMapIdle: onMapIdle);
  }

  /// On/Off the place card at the bottom
  final ShowPlaceCard showPlaceCard;

  final bool reverse;

  final MethodChannel _channel;

  final OnStyleLoadedCallback onStyleLoadedCallback;

  final OnMapClickCallback onMapClick;

  final OnCameraTrackingDismissedCallback onCameraTrackingDismissed;
  final OnCameraTrackingChangedCallback onCameraTrackingChanged;

  final OnMapIdleCallback onMapIdle;

  /// Callbacks to receive tap events for symbols placed on this map.
  final ArgumentCallbacks<Symbol> onSymbolTapped = ArgumentCallbacks<Symbol>();

  /// Callbacks to receive tap events for symbols placed on this map.
  final ArgumentCallbacks<Circle> onCircleTapped = ArgumentCallbacks<Circle>();

  /// Callbacks to receive tap events for info windows on symbols
  final ArgumentCallbacks<Symbol> onInfoWindowTapped =
      ArgumentCallbacks<Symbol>();

  /// The current set of symbols on this map.
  ///
  /// The returned set will be a detached snapshot of the symbols collection.
  Set<Symbol> get symbols => Set<Symbol>.from(_symbols.values);
  final Map<String, Symbol> _symbols = <String, Symbol>{};

  /// Callbacks to receive tap events for lines placed on this map.
  final ArgumentCallbacks<Line> onLineTapped = ArgumentCallbacks<Line>();

  /// The current set of lines on this map.
  ///
  /// The returned set will be a detached snapshot of the lines collection.
  Set<Line> get lines => Set<Line>.from(_lines.values);
  final Map<String, Line> _lines = <String, Line>{};

  /// The current set of circles on this map.
  ///
  /// The returned set will be a detached snapshot of the symbols collection.
  Set<Circle> get circles => Set<Circle>.from(_circles.values);
  final Map<String, Circle> _circles = <String, Circle>{};

  /// True if the map camera is currently moving.
  bool get isCameraMoving => _isCameraMoving;
  bool _isCameraMoving = false;

  /// Returns the most recent camera position reported by the platform side.
  /// Will be null, if [WeMap.trackCameraPosition] is false.
  CameraPosition get cameraPosition => _cameraPosition;
  CameraPosition _cameraPosition;

  final int _id; //ignore: unused_field

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'infoWindow#onTap':
        final String symbolId = call.arguments['symbol'];
        final Symbol symbol = _symbols[symbolId];
        if (symbol != null) {
          onInfoWindowTapped(symbol);
        }
        break;
      case 'symbol#onTap':
        final String symbolId = call.arguments['symbol'];
        final Symbol symbol = _symbols[symbolId];
        if (symbol != null) {
          onSymbolTapped(symbol);
        }
        break;
      case 'line#onTap':
        final String lineId = call.arguments['line'];
        final Line line = _lines[lineId];
        if (line != null) {
          onLineTapped(line);
        }
        break;
      case 'circle#onTap':
        final String circleId = call.arguments['circle'];
        final Circle circle = _circles[circleId];
        if (circle != null) {
          onCircleTapped(circle);
        }
        break;
      case 'camera#onMoveStarted':
        _isCameraMoving = true;
        notifyListeners();
        break;
      case 'camera#onMove':
        _cameraPosition = CameraPosition.fromMap(call.arguments['position']);
        notifyListeners();
        break;
      case 'camera#onIdle':
        _isCameraMoving = false;
        notifyListeners();
        break;
      case 'map#onStyleLoaded':
        if (onStyleLoadedCallback != null) {
          onStyleLoadedCallback();
        }
        break;
      case 'map#onMapClick':
        final double x = call.arguments['x'];
        final double y = call.arguments['y'];
        final double lng = call.arguments['lng'];
        final double lat = call.arguments['lat'];
        if (onMapClick != null) {
          onMapClick(
            Point<double>(x, y),
            LatLng(lat, lng),
            getPlace(LatLng(lat, lng)),
          );
        }
        await getPlace(LatLng(lat, lng)).then((place) async {
          await getExtraTag(place.placeId).then((extratags) {
            if (extratags != null) {
              place.setExtraTags(extratags);
            } else {
              place.setExtraTags({});
            }
            if (reverse) {
              showPlaceCard(place);
            }
          });
        });
        break;
      case 'map#onCameraTrackingChanged':
        if (onCameraTrackingChanged != null) {
          final int mode = call.arguments['mode'];
          onCameraTrackingChanged(MyLocationTrackingMode.values[mode]);
        }
        break;
      case 'map#onCameraTrackingDismissed':
        if (onCameraTrackingDismissed != null) {
          onCameraTrackingDismissed();
        }
        break;
      case 'map#onIdle':
        if (onMapIdle != null) {
          onMapIdle();
        }
        break;
      default:
        throw MissingPluginException();
    }
  }

  Future<void> _updateMapOptions(Map<String, dynamic> optionsUpdate) async {
    assert(optionsUpdate != null);
    final dynamic json = await _channel.invokeMethod(
      'map#update',
      <String, dynamic>{
        'options': optionsUpdate,
      },
    );
    _cameraPosition = CameraPosition.fromMap(json);
    notifyListeners();
  }

  Future<bool> animateCamera(CameraUpdate cameraUpdate) async {
    return await _channel.invokeMethod('camera#animate', <String, dynamic>{
      'cameraUpdate': cameraUpdate._toJson(),
    });
  }

  Future<bool> moveCamera(CameraUpdate cameraUpdate) async {
    return await _channel.invokeMethod('camera#move', <String, dynamic>{
      'cameraUpdate': cameraUpdate._toJson(),
    });
  }

  Future<bool> addWMSLayer(String layerID, String wmsURL, int tileSize) async {
    return await _channel.invokeMethod('map#addWMSLayer', <String, String>{
      'layerID': layerID,
      'wmsURL': wmsURL,
      'tileSize': tileSize.toString(),
    });
  }

  Future<bool> removeWMSLayer(String layerID) async {
    return await _channel.invokeMethod('map#removeWMSLayer', <String, String>{
      'layerID': layerID,
    });
  }

  Future<bool> addTrafficLayer() async {
    return await _channel.invokeMethod('map#addTraffic');
  }

  Future<bool> removeTrafficLayer() async {
    return await _channel.invokeMethod('map#removeTraffic');
  }

  Future<bool> addSatelliteLayer() async {
    return await _channel.invokeMethod('map#addSatellite');
  }

  Future<bool> removeSatelliteLayer() async {
    return await _channel.invokeMethod('map#removeSatellite');
  }

  Future<void> updateMyLocationTrackingMode(
      MyLocationTrackingMode myLocationTrackingMode) async {
    await _channel
        .invokeMethod('map#updateMyLocationTrackingMode', <String, dynamic>{
      'mode': myLocationTrackingMode.index,
    });
  }

  Future<void> matchMapLanguageWithDeviceDefault() async {
    await _channel.invokeMethod('map#matchMapLanguageWithDeviceDefault');
  }

  Future<void> updateContentInsets(EdgeInsets insets,
      [bool animated = false]) async {
    await _channel.invokeMethod('map#updateContentInsets', <String, dynamic>{
      'bounds': <String, double>{
        'top': insets.top,
        'left': insets.left,
        'bottom': insets.bottom,
        'right': insets.right,
      },
      'animated': animated,
    });
  }

  Future<void> setMapLanguage(String language) async {
    await _channel.invokeMethod('map#setMapLanguage', <String, dynamic>{
      'language': language,
    });
  }

  /// Enables or disables the collection of anonymized telemetry data.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> setTelemetryEnabled(bool enabled) async {
    await _channel.invokeMethod('map#setTelemetryEnabled', <String, dynamic>{
      'enabled': enabled,
    });
  }

  /// Retrieves whether collection of anonymized telemetry data is enabled.
  ///
  /// The returned [Future] completes after the query has been made on the
  /// platform side.
  Future<bool> getTelemetryEnabled() async {
    return await _channel.invokeMethod('map#getTelemetryEnabled');
  }

  /// Adds a symbol to the map, configured using the specified custom [options].
  ///
  /// Change listeners are notified once the symbol has been added on the
  /// platform side.
  ///
  /// The returned [Future] completes with the added symbol once listeners have
  /// been notified.
  Future<Symbol> addSymbol(SymbolOptions options, [Map data]) async {
    final SymbolOptions effectiveOptions =
        SymbolOptions.defaultOptions.copyWith(options);
    final String symbolId = await _channel.invokeMethod(
      'symbol#add',
      <String, dynamic>{
        'options': effectiveOptions._toJson(),
      },
    );
    final Symbol symbol = Symbol(symbolId, effectiveOptions, data);
    _symbols[symbolId] = symbol;
    notifyListeners();
    return symbol;
  }

  /// Updates the specified [symbol] with the given [changes]. The symbol must
  /// be a current member of the [symbols] set.
  ///
  /// Change listeners are notified once the symbol has been updated on the
  /// platform side.
  ///
  /// The returned [Future] completes once listeners have been notified.
  Future<void> updateSymbol(Symbol symbol, SymbolOptions changes) async {
    assert(symbol != null);
    assert(_symbols[symbol._id] == symbol);
    assert(changes != null);
    await _channel.invokeMethod('symbol#update', <String, dynamic>{
      'symbol': symbol._id,
      'options': changes._toJson(),
    });
    symbol._options = symbol._options.copyWith(changes);
    notifyListeners();
  }

  /// Removes the specified [symbol] from the map. The symbol must be a current
  /// member of the [symbols] set.
  ///
  /// Change listeners are notified once the symbol has been removed on the
  /// platform side.
  ///
  /// The returned [Future] completes once listeners have been notified.
  Future<void> removeSymbol(Symbol symbol) async {
    assert(symbol != null);
    assert(_symbols[symbol._id] == symbol);
    await _removeSymbol(symbol._id);
    notifyListeners();
  }

  /// Removes all [symbols] from the map.
  ///
  /// Change listeners are notified once all symbols have been removed on the
  /// platform side.
  ///
  /// The returned [Future] completes once listeners have been notified.
  Future<void> clearSymbols() async {
    assert(_symbols != null);
    final List<String> symbolIds = List<String>.from(_symbols.keys);
    for (String id in symbolIds) {
      await _removeSymbol(id);
    }
    notifyListeners();
  }

  /// Helper method to remove a single symbol from the map. Consumed by
  /// [removeSymbol] and [clearSymbols].
  ///
  /// The returned [Future] completes once the symbol has been removed from
  /// [_symbols].
  Future<void> _removeSymbol(String id) async {
    await _channel.invokeMethod('symbol#remove', <String, dynamic>{
      'symbol': id,
    });
    _symbols.remove(id);
  }

  /// Adds a line to the map, configured using the specified custom [options].
  ///
  /// Change listeners are notified once the line has been added on the
  /// platform side.
  ///
  /// The returned [Future] completes with the added line once listeners have
  /// been notified.
  Future<Line> addLine(LineOptions options, [Map data]) async {
    final LineOptions effectiveOptions =
        LineOptions.defaultOptions.copyWith(options);
    final String lineId = await _channel.invokeMethod(
      'line#add',
      <String, dynamic>{
        'options': effectiveOptions._toJson(),
      },
    );
    final Line line = Line(lineId, effectiveOptions, data);
    _lines[lineId] = line;
    notifyListeners();
    return line;
  }

  /// Updates the specified [line] with the given [changes]. The line must
  /// be a current member of the [lines] set.
  ///
  /// Change listeners are notified once the line has been updated on the
  /// platform side.
  ///
  /// The returned [Future] completes once listeners have been notified.
  Future<void> updateLine(Line line, LineOptions changes) async {
    assert(line != null);
    assert(_lines[line._id] == line);
    assert(changes != null);
    await _channel.invokeMethod('line#update', <String, dynamic>{
      'line': line._id,
      'options': changes._toJson(),
    });
    line._options = line._options.copyWith(changes);
    notifyListeners();
  }

  /// Removes the specified [line] from the map. The line must be a current
  /// member of the [lines] set.
  ///
  /// Change listeners are notified once the line has been removed on the
  /// platform side.
  ///
  /// The returned [Future] completes once listeners have been notified.
  Future<void> removeLine(Line line) async {
    assert(line != null);
    assert(_lines[line._id] == line);
    await _removeLine(line._id);
    notifyListeners();
  }

  /// Removes all [lines] from the map.
  ///
  /// Change listeners are notified once all lines have been removed on the
  /// platform side.
  ///
  /// The returned [Future] completes once listeners have been notified.
  Future<void> clearLines() async {
    assert(_lines != null);
    final List<String> lineIds = List<String>.from(_lines.keys);
    for (String id in lineIds) {
      await _removeLine(id);
    }
    notifyListeners();
  }

  /// Helper method to remove a single line from the map. Consumed by
  /// [removeLine] and [clearLines].
  ///
  /// The returned [Future] completes once the line has been removed from
  /// [_lines].
  Future<void> _removeLine(String id) async {
    await _channel.invokeMethod('line#remove', <String, dynamic>{
      'line': id,
    });
    _lines.remove(id);
  }

  /// Adds a circle to the map, configured using the specified custom [options].
  ///
  /// Change listeners are notified once the circle has been added on the
  /// platform side.
  ///
  /// The returned [Future] completes with the added circle once listeners have
  /// been notified.
  Future<Circle> addCircle(CircleOptions options, [Map data]) async {
    final CircleOptions effectiveOptions =
        CircleOptions.defaultOptions.copyWith(options);
    final String circleId = await _channel.invokeMethod(
      'circle#add',
      <String, dynamic>{
        'options': effectiveOptions._toJson(),
      },
    );
    final Circle circle = Circle(circleId, effectiveOptions, data);
    _circles[circleId] = circle;
    notifyListeners();
    return circle;
  }

  /// Updates the specified [circle] with the given [changes]. The circle must
  /// be a current member of the [circles] set.
  ///
  /// Change listeners are notified once the circle has been updated on the
  /// platform side.
  ///
  /// The returned [Future] completes once listeners have been notified.
  Future<void> updateCircle(Circle circle, CircleOptions changes) async {
    assert(circle != null);
    assert(_circles[circle._id] == circle);
    assert(changes != null);
    await _channel.invokeMethod('circle#update', <String, dynamic>{
      'circle': circle._id,
      'options': changes._toJson(),
    });
    circle._options = circle._options.copyWith(changes);
    notifyListeners();
  }

  /// `circle.options.geometry` can't get real-time location.For example, when you
  /// set circle `draggable` is true,and you dragged circle.At this time you
  /// should use `getCircleLatLng()`
  Future<LatLng> getCircleLatLng(Circle circle) async {
    assert(circle != null);
    assert(_circles[circle._id] == circle);
    Map mapLatLng =
        await _channel.invokeMethod('circle#getGeometry', <String, dynamic>{
      'circle': circle._id,
    });
    LatLng circleLatLng =
        new LatLng(mapLatLng['latitude'], mapLatLng['longitude']);
    notifyListeners();
    return circleLatLng;
  }

  /// Removes the specified [circle] from the map. The circle must be a current
  /// member of the [circles] set.
  ///
  /// Change listeners are notified once the circle has been removed on the
  /// platform side.
  ///
  /// The returned [Future] completes once listeners have been notified.
  Future<void> removeCircle(Circle circle) async {
    assert(circle != null);
    assert(_circles[circle._id] == circle);
    await _removeCircle(circle._id);
    notifyListeners();
  }

  /// Removes all [circles] from the map.
  ///
  /// Change listeners are notified once all circles have been removed on the
  /// platform side.
  ///
  /// The returned [Future] completes once listeners have been notified.
  Future<void> clearCircles() async {
    assert(_circles != null);
    final List<String> circleIds = List<String>.from(_circles.keys);
    for (String id in circleIds) {
      await _removeCircle(id);
    }
    notifyListeners();
  }

  /// Helper method to remove a single circle from the map. Consumed by
  /// [removeCircle] and [clearCircles].
  ///
  /// The returned [Future] completes once the circle has been removed from
  /// [_circles].
  Future<void> _removeCircle(String id) async {
    await _channel.invokeMethod('circle#remove', <String, dynamic>{
      'circle': id,
    });
    _circles.remove(id);
  }

  Future<List> queryRenderedFeatures(
      Point<double> point, List<String> layerIds, String filter) async {
    try {
      final Map<Object, Object> reply = await _channel.invokeMethod(
        'map#queryRenderedFeatures',
        <String, Object>{
          'x': point.x,
          'y': point.y,
          'layerIds': layerIds,
          'filter': filter,
        },
      );
      return reply['features'];
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  Future<WeMapPlace> _getPlace(LatLng latLng) async {
    Map json;
    WeMapPlace _place;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      try {
        final response = await http.get(apiReverse(latLng));
        final jsondecode = jsonDecode(response.body);
        json = jsondecode;
        print(json);
      } catch (e) {
        print('Loi goi info from http');
      }
      Map features;
      if (json["features"].length > 0) {
        features = json["features"][0];
      }
      if (features != null) {
        _place = WeMapPlace.fromPelias(features);
        if (_place.distance > 0.02) {
          Map jsonLocality;
          try {
            final responseLocality = await http.get(apiLocality(latLng));
            final jsondecodeLocality = jsonDecode(responseLocality.body);
            jsonLocality = jsondecodeLocality;
            print(jsonLocality);
          } catch (e) {
            print('Loi goi info from http');
          }
          Map featuresLocality;
          if (jsonLocality["features"].length > 0) {
            featuresLocality = jsonLocality["features"][0];
          }
          if (featuresLocality != null)
            _place = WeMapPlace.fromPelias(featuresLocality);
        }
      } else
        _place = WeMapPlace(
          description:
              '${latLng.latitude.toStringAsFixed(5)}, ${latLng.longitude.toStringAsFixed(5)}',
          cityState: '',
          location: latLng,
          placeId: -1,
          placeName: 'Địa điểm chưa biết',
          state: '',
          street: '',
        );
    }
    return _place;
  }

  Future<Map> _getExtraTag(int osmID) async {
    Map extraTags = {};
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      try {
        final responseLookup = await http.get(apiLookup(osmID));
        final jsondecodeLookup = jsonDecode(responseLookup.body);
        extraTags = jsondecodeLookup["extratags"];
      } catch (e) {
        print('lookup error');
      }
    }
    return extraTags;
  }

  Future<List> queryRenderedFeaturesInRect(
      Rect rect, List<String> layerIds, String filter) async {
    try {
      final Map<Object, Object> reply = await _channel.invokeMethod(
        'map#queryRenderedFeatures',
        <String, Object>{
          'left': rect.left,
          'top': rect.top,
          'right': rect.right,
          'bottom': rect.bottom,
          'layerIds': layerIds,
          'filter': filter,
        },
      );
      return reply['features'];
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  Future invalidateAmbientCache() async {
    try {
      await _channel.invokeMethod('map#invalidateAmbientCache');
      return null;
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  /// Get last my location
  ///
  /// Return last latlng, nullable

  Future<LatLng> requestMyLocationLatLng() async {
    try {
      final location = GPSService.Location();
      var locationData = await location.getLocation();
      return LatLng(locationData.latitude, locationData.longitude);
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  ///This method returns the boundaries of the region currently displayed in the map.
  Future<LatLngBounds> getVisibleRegion() async {
    try {
      final Map<Object, Object> reply =
          await _channel.invokeMethod('map#getVisibleRegion', null);
      LatLng southwest, northeast;
      if (reply.containsKey("sw")) {
        List<dynamic> coordinates = reply["sw"];
        southwest = LatLng(coordinates[0], coordinates[1]);
      }
      if (reply.containsKey("ne")) {
        List<dynamic> coordinates = reply["ne"];
        northeast = LatLng(coordinates[0], coordinates[1]);
      }
      return LatLngBounds(southwest: southwest, northeast: northeast);
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }
}
