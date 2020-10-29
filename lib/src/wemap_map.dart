

part of wemapgl;

typedef void MapCreatedCallback(WeMapController controller);

class WeMap extends StatefulWidget {
  WeMap({
    @required this.initialCameraPosition,
    this.onMapCreated,
    this.onStyleLoadedCallback,
    this.gestureRecognizers,
    this.compassEnabled = true,
    this.cameraTargetBounds = CameraTargetBounds.unbounded,
    this.styleString,
    this.minMaxZoomPreference = MinMaxZoomPreference.unbounded,
    this.rotateGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.zoomGesturesEnabled = true,
    this.tiltGesturesEnabled = true,
    this.trackCameraPosition = false,
    this.myLocationEnabled = false,
    this.myLocationTrackingMode = MyLocationTrackingMode.Tracking,
    this.myLocationRenderMode = MyLocationRenderMode.COMPASS,
    this.logoViewMargins,
    this.compassViewPosition,
    this.compassViewMargins,
    this.attributionButtonMargins,
    this.onMapClick,
    this.onCameraTrackingDismissed,
    this.onCameraTrackingChanged,
    this.onMapIdle,
    this.reverse = false,
    this.showReverseClearButton = true,
    this.onPlaceCardClose,
    this.destinationIcon
  }) : assert(initialCameraPosition != null) {
    if (this.styleString == null) this.styleString = WeMapStyles.WEMAP_VECTOR_STYLE;
    if (this.logoViewMargins == null) this.logoViewMargins = Point(0, 0);
  }

  /// default is false,
  /// if true the Place Card at the bottom will be called.
  /// If reverse is true, you need to declare onCardClose.
  final bool reverse;
  final bool showReverseClearButton;

  /// The callback function that is called when close this place card.
  /// If reverse is true, you need to declare onCardClose.
  final void Function() onPlaceCardClose;

  final MapCreatedCallback onMapCreated;
  final OnStyleLoadedCallback onStyleLoadedCallback;

  /// The initial position of the map's camera.
  final CameraPosition initialCameraPosition;

  /// True if the map should show a compass when rotated.
  final bool compassEnabled;

  /// Geographical bounding box for the camera target.
  final CameraTargetBounds cameraTargetBounds;

  /// Style URL or Style JSON
  /// default is (https://apis.wemap.asia/vector-tiles/styles/osm-bright/style.json?key=IqzJukzUWpWrcDHJeDpUPLSGndDx)
  String styleString;

  /// Preferred bounds for the camera zoom level.
  ///
  /// Actual bounds depend on map data and device.
  final MinMaxZoomPreference minMaxZoomPreference;

  /// True if the map view should respond to rotate gestures.
  final bool rotateGesturesEnabled;

  /// True if the map view should respond to scroll gestures.
  final bool scrollGesturesEnabled;

  /// True if the map view should respond to zoom gestures.
  final bool zoomGesturesEnabled;

  /// True if the map view should respond to tilt gestures.
  final bool tiltGesturesEnabled;

  /// True if the map view should relay camera move events to Flutter.
  final bool trackCameraPosition;

  /// True if a "My Location" layer should be shown on the map.
  ///
  /// This layer includes a location indicator at the current device location,
  /// as well as a My Location button.
  /// * The indicator is a small blue dot if the device is stationary, or a
  /// chevron if the device is moving.
  /// * The My Location button animates to focus on the user's current location
  /// if the user's location is currently known.
  ///
  /// Enabling this feature requires adding location permissions to both native
  /// platforms of your app.
  /// * On Android add either
  /// `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />`
  /// or `<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />`
  /// to your `AndroidManifest.xml` file. `ACCESS_COARSE_LOCATION` returns a
  /// location with an accuracy approximately equivalent to a city block, while
  /// `ACCESS_FINE_LOCATION` returns as precise a location as possible, although
  /// it consumes more battery power. You will also need to request these
  /// permissions during run-time. If they are not granted, the My Location
  /// feature will fail silently.
  /// * On iOS add a `NSLocationWhenInUseUsageDescription` key to your
  /// `Info.plist` file. This will automatically prompt the user for permissions
  /// when the map tries to turn on the My Location layer.
  final bool myLocationEnabled;

  /// The mode used to track the user location on the map
  final MyLocationTrackingMode myLocationTrackingMode;

  /// The mode to render the user location symbol
  final MyLocationRenderMode myLocationRenderMode;

  /// Set the layout margins for the WeMap Logo
  Point logoViewMargins;

  /// Set the position for the WeMap Compass
  final CompassViewPosition compassViewPosition;

  /// Set the layout margins for the WeMap Compass
  final Point compassViewMargins;

  /// Set the layout margins for the WeMap Attribution Buttons
  final Point attributionButtonMargins;

  /// Which gestures should be consumed by the map.
  ///
  /// It is possible for other gesture recognizers to be competing with the map on pointer
  /// events, e.g if the map is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The map will claim gestures that are recognized by any of the
  /// recognizers on this list.
  ///
  /// When this set is empty or null, the map will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  final OnMapClickCallback onMapClick;

  /// Called when the location tracking mode changes, such as when the user moves the map
  final OnCameraTrackingDismissedCallback onCameraTrackingDismissed;
  final OnCameraTrackingChangedCallback onCameraTrackingChanged;

  /// Called when map view is entering an idle state, and no more drawing will
  /// be necessary until new data is loaded or there is some interaction with
  /// the map.
  /// * No camera transitions are in progress
  /// * All currently requested tiles have loaded
  /// * All fade/transition animations have completed
  final OnMapIdleCallback onMapIdle;

  String destinationIcon;

  @override
  State createState() => _WeMapState();
}

class _WeMapState extends State<WeMap> {
  final Completer<WeMapController> _controller = Completer<WeMapController>();

  WeMapPlace place;
  bool visible = true;
  var logo;
  _MapboxMapOptions _WeMapMapOptions;
  

  @override
  Widget build(BuildContext context) {
    Configuration.validateWeMapKey();
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'initialCameraPosition': widget.initialCameraPosition?._toMap(),
      'options': _MapboxMapOptions.fromWidget(widget).toMap(),
    };
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Stack(
        children: <Widget>[
          AndroidView(
            viewType: 'wemap_gl',
            onPlatformViewCreated: onPlatformViewCreated,
            gestureRecognizers: widget.gestureRecognizers,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
          ),
          Positioned(
            bottom: 10 + widget.logoViewMargins.y.toDouble(),
            left: 4 + widget.logoViewMargins.x.toDouble(),
            child: Image.memory(
              logo,
              height: 40,
              width: 80,
            ),
          ),
          (place != null)
              ? WeMapPlaceCard(
                  showClearButton: widget.showReverseClearButton,
                  place: place,
                  onPlaceCardClose: widget.onPlaceCardClose,
                  destinationIcon: widget.destinationIcon,
                )
              : Container(),
        ],
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Stack(
        children: <Widget>[
          UiKitView(
            viewType: 'wemap_gl',
            onPlatformViewCreated: onPlatformViewCreated,
            gestureRecognizers: widget.gestureRecognizers,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
          ),
          Positioned(
            bottom: 10 + widget.logoViewMargins.y.toDouble(),
            left: 4 + widget.logoViewMargins.x.toDouble(),
            child: Image.memory(
              logo,
              height: 40,
              width: 80,
            ),
          ),
          (place != null)
              ? WeMapPlaceCard(
                  showClearButton: widget.showReverseClearButton,
                  place: place,
                  onPlaceCardClose: widget.onPlaceCardClose,
                  destinationIcon: widget.destinationIcon,
                )
              : Container(),
        ],
      );
    }

    return Text(
        '$defaultTargetPlatform is not yet supported by the maps plugin');
  }

  @override
  void initState() {
    super.initState();
    logo = base64.decode(wemap_logo);
    _WeMapMapOptions = _MapboxMapOptions.fromWidget(widget);
  }

  @override
  void didUpdateWidget(WeMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final _MapboxMapOptions newOptions = _MapboxMapOptions.fromWidget(widget);
    final Map<String, dynamic> updates =
        _WeMapMapOptions.updatesMap(newOptions);
    _updateOptions(updates);
    _WeMapMapOptions = newOptions;
  }

  void _updateOptions(Map<String, dynamic> updates) async {
    if (updates.isEmpty) {
      return;
    }
    final WeMapController controller = await _controller.future;
    controller._updateMapOptions(updates);
  }

  Future<void> onPlatformViewCreated(int id) async {
    final WeMapController controller = await WeMapController.init(
        id, widget.initialCameraPosition, reverse: widget.reverse,
        showPlaceCard: (_place) {
      setState(() {
        place = _place;
      });
    },
        onStyleLoadedCallback: widget.onStyleLoadedCallback,
        onMapClick: widget.onMapClick,
        onCameraTrackingDismissed: widget.onCameraTrackingDismissed,
        onCameraTrackingChanged: widget.onCameraTrackingChanged,
        onMapIdle: widget.onMapIdle);
    _controller.complete(controller);
    if (widget.onMapCreated != null) {
      widget.onMapCreated(controller);
    }
  }
}

/// Configuration options for the WeMapMaps user interface.
///
/// When used to change configuration, null values will be interpreted as
/// "do not change this configuration option".
class _MapboxMapOptions {
  _MapboxMapOptions({
    this.compassEnabled,
    this.cameraTargetBounds,
    this.styleString,
    this.minMaxZoomPreference,
    this.rotateGesturesEnabled,
    this.scrollGesturesEnabled,
    this.tiltGesturesEnabled,
    this.trackCameraPosition,
    this.zoomGesturesEnabled,
    this.myLocationEnabled,
    this.myLocationTrackingMode,
    this.myLocationRenderMode,
    this.logoViewMargins,
    this.compassViewPosition,
    this.compassViewMargins,
    this.attributionButtonMargins,
  });

  static _MapboxMapOptions fromWidget(WeMap map) {
    return _MapboxMapOptions(
        compassEnabled: map.compassEnabled,
        cameraTargetBounds: map.cameraTargetBounds,
        styleString: map.styleString,
        minMaxZoomPreference: map.minMaxZoomPreference,
        rotateGesturesEnabled: map.rotateGesturesEnabled,
        scrollGesturesEnabled: map.scrollGesturesEnabled,
        tiltGesturesEnabled: map.tiltGesturesEnabled,
        trackCameraPosition: map.trackCameraPosition,
        zoomGesturesEnabled: map.zoomGesturesEnabled,
        myLocationEnabled: map.myLocationEnabled,
        myLocationTrackingMode: map.myLocationTrackingMode,
        myLocationRenderMode: map.myLocationRenderMode,
        logoViewMargins: map.logoViewMargins,
        compassViewPosition: map.compassViewPosition,
        compassViewMargins: map.compassViewMargins,
        attributionButtonMargins: map.attributionButtonMargins);
  }

  final bool compassEnabled;

  final CameraTargetBounds cameraTargetBounds;

  final String styleString;

  final MinMaxZoomPreference minMaxZoomPreference;

  final bool rotateGesturesEnabled;

  final bool scrollGesturesEnabled;

  final bool tiltGesturesEnabled;

  final bool trackCameraPosition;

  final bool zoomGesturesEnabled;

  final bool myLocationEnabled;

  final MyLocationTrackingMode myLocationTrackingMode;

  final MyLocationRenderMode myLocationRenderMode;

  final Point logoViewMargins;

  final CompassViewPosition compassViewPosition;

  final Point compassViewMargins;

  final Point attributionButtonMargins;

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> optionsMap = <String, dynamic>{};

    void addIfNonNull(String fieldName, dynamic value) {
      if (value != null) {
        optionsMap[fieldName] = value;
      }
    }

    List<dynamic> pointToArray(Point fieldName) {
      if (fieldName != null) {
        return <dynamic>[fieldName.x, fieldName.y];
      }

      return null;
    }

    addIfNonNull('compassEnabled', compassEnabled);
    addIfNonNull('cameraTargetBounds', cameraTargetBounds?._toJson());
    addIfNonNull('styleString', styleString);
    addIfNonNull('minMaxZoomPreference', minMaxZoomPreference?._toJson());
    addIfNonNull('rotateGesturesEnabled', rotateGesturesEnabled);
    addIfNonNull('scrollGesturesEnabled', scrollGesturesEnabled);
    addIfNonNull('tiltGesturesEnabled', tiltGesturesEnabled);
    addIfNonNull('zoomGesturesEnabled', zoomGesturesEnabled);
    addIfNonNull('trackCameraPosition', trackCameraPosition);
    addIfNonNull('myLocationEnabled', myLocationEnabled);
    addIfNonNull('myLocationTrackingMode', myLocationTrackingMode?.index);
    addIfNonNull('myLocationRenderMode', myLocationRenderMode?.index);
    addIfNonNull('logoViewMargins', pointToArray(Point(0, -1000)));
    addIfNonNull('compassViewPosition', compassViewPosition?.index);
    addIfNonNull('compassViewMargins', pointToArray(compassViewMargins));
    addIfNonNull(
        'attributionButtonMargins', pointToArray(attributionButtonMargins));
    return optionsMap;
  }

  Map<String, dynamic> updatesMap(_MapboxMapOptions newOptions) {
    final Map<String, dynamic> prevOptionsMap = toMap();
    return newOptions.toMap()
      ..removeWhere(
          (String key, dynamic value) => prevOptionsMap[key] == value);
  }
}
