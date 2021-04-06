part of wemapgl_platform_interface;

class GeoJSON {
  @visibleForTesting
  GeoJSON(this._id, this.options, [this._data]);

  /// A unique identifier for this geojson.
  ///
  /// The identifier is an arbitrary unique string.
  final String _id;
  String get id => _id;

  final Map _data;
  Map get data => _data;

  /// The geojson configuration options most recently applied programmatically
  /// via the map controller.
  ///
  /// The returned value does not reflect any changes made to the geojson through
  /// touch events. Add listeners to the owning map controller to track those.
  GeoJSONOptions options;
}

/// Configuration options for [GeoJSON] instances.
///
/// When used to change configuration, null values will be interpreted as
/// "do not change this configuration option".
class GeoJSONOptions {
  /// Creates a set of geojson configuration options.
  ///
  /// By default, every non-specified field is null, meaning no desire to change
  /// geojson defaults or current configuration.
  const GeoJSONOptions(
      {this.fillOpacity,
      this.fillColor,
      this.fillOutlineColor,
      this.fillPattern,
      this.circleRadius,
      this.circleColor,
      this.circleBlur,
      this.circleOpacity,
      this.circleStrokeWidth,
      this.circleStrokeColor,
      this.circleStrokeOpacity,
      this.lineJoin,
      this.lineOpacity,
      this.lineColor,
      this.lineWidth,
      this.lineGapWidth,
      this.lineOffset,
      this.lineBlur,
      this.linePattern,
      this.iconSize,
      this.iconImage,
      this.iconRotate,
      this.iconOffset,
      this.iconAnchor,
      this.fontNames,
      this.textField,
      this.textSize,
      this.textMaxWidth,
      this.textLetterSpacing,
      this.textJustify,
      this.textAnchor,
      this.textRotate,
      this.textTransform,
      this.textOffset,
      this.iconOpacity,
      this.iconColor,
      this.iconHaloColor,
      this.iconHaloWidth,
      this.iconHaloBlur,
      this.textOpacity,
      this.textColor,
      this.textHaloColor,
      this.textHaloWidth,
      this.textHaloBlur,
      this.geojson,
      this.type,
      this.draggable,
      this.tinh_trong_diem});

  static const String POINT = "Circle";
  static const String SYMBOL = "Symbol";
  static const String POLYLINE = "Line";
  static const String POLYGOL = "Fill";

  final double fillOpacity;
  final String fillColor;
  final String fillOutlineColor;
  final String fillPattern;

  final double iconSize;
  final String iconImage;
  final double iconRotate;
  final Offset iconOffset;
  final String iconAnchor;
  final List<String> fontNames;
  final String textField;
  final double textSize;
  final double textMaxWidth;
  final double textLetterSpacing;
  final String textJustify;
  final String textAnchor;
  final double textRotate;
  final String textTransform;
  final Offset textOffset;
  final double iconOpacity;
  final String iconColor;
  final String iconHaloColor;
  final double iconHaloWidth;
  final double iconHaloBlur;
  final double textOpacity;
  final String textColor;
  final String textHaloColor;
  final double textHaloWidth;
  final double textHaloBlur;

  final double circleRadius;
  final String circleColor;
  final double circleBlur;
  final double circleOpacity;
  final double circleStrokeWidth;
  final String circleStrokeColor;
  final double circleStrokeOpacity;

  final String lineJoin;
  final double lineOpacity;
  final String lineColor;
  final double lineWidth;
  final double lineGapWidth;
  final double lineOffset;
  final double lineBlur;
  final String linePattern;

  final String type;
  final String geojson;
  final bool draggable;

  final bool tinh_trong_diem;

  static const GeoJSONOptions defaultOptions = GeoJSONOptions();

  GeoJSONOptions copyWith(GeoJSONOptions changes) {
    if (changes == null) {
      return this;
    }
    return GeoJSONOptions(
        fillOpacity: changes.fillOpacity ?? fillOpacity,
        fillColor: changes.fillColor ?? fillColor,
        fillOutlineColor: changes.fillOutlineColor ?? fillOutlineColor,
        fillPattern: changes.fillPattern ?? fillPattern,
        circleRadius: changes.circleRadius ?? circleRadius,
        circleColor: changes.circleColor ?? circleColor,
        circleBlur: changes.circleBlur ?? circleBlur,
        circleOpacity: changes.circleOpacity ?? circleOpacity,
        circleStrokeWidth: changes.circleStrokeWidth ?? circleStrokeWidth,
        circleStrokeColor: changes.circleStrokeColor ?? circleStrokeColor,
        circleStrokeOpacity: changes.circleStrokeOpacity ?? circleStrokeOpacity,
        lineJoin: changes.lineJoin ?? lineJoin,
        lineOpacity: changes.lineOpacity ?? lineOpacity,
        lineColor: changes.lineColor ?? lineColor,
        lineWidth: changes.lineWidth ?? lineWidth,
        lineGapWidth: changes.lineGapWidth ?? lineGapWidth,
        lineOffset: changes.lineOffset ?? lineOffset,
        lineBlur: changes.lineBlur ?? lineBlur,
        linePattern: changes.linePattern ?? linePattern,
        geojson: changes.geojson ?? geojson,
        type: changes.type ?? type,
        draggable: changes.draggable ?? draggable,
        tinh_trong_diem: changes.tinh_trong_diem ?? tinh_trong_diem);
  }

  Future<List<dynamic>> addToMap(dynamic controller) async {
    List<dynamic> result = [];
    if (controller != null)
      switch (this.type) {
        case SYMBOL:
          var points = await getSymbols();
          var data = await getDatas(SYMBOL);
          for (int i = 0; i < points.length; i++) {
            result.add(controller.addSymbol(points[i], data[i]));
          }
          break;
        case POINT:
          var points = await getCircles();
          for (int i = 0; i < points.length; i++) {
            result.add(controller.addCircle(points[i]));
          }
          break;
        case POLYLINE:
          var lines = await getLines();
          for (int i = 0; i < lines.length; i++) {
            result.add(controller.addLine(lines[i]));
          }
          break;
        case POLYGOL:
          var fills = await getFills();
          var data = await getDatas(POLYGOL);
          for (int i = 0; i < fills.length; i++) {
            result.add(controller.addFill(fills[i], data[i]));
          }
          break;
        default:
      }
    return result;
  }

  Future<List<SymbolOptions>> getSymbols() async {
    List<SymbolOptions> result = [];
    var points = await getGeometries(SYMBOL);
    for (int i = 0; i < points.length; i++) {
      result.add(new SymbolOptions(
          iconSize: this.iconSize,
          iconImage: this.iconImage,
          iconRotate: this.iconRotate,
          iconOffset: this.iconOffset,
          iconAnchor: this.iconAnchor,
          fontNames: this.fontNames,
          textField: this.textField,
          textSize: this.textSize,
          textMaxWidth: this.textMaxWidth,
          textLetterSpacing: this.textLetterSpacing,
          textJustify: this.textJustify,
          textAnchor: this.textAnchor,
          iconOpacity: this.iconOpacity,
          iconColor: this.iconColor,
          iconHaloColor: this.iconHaloColor,
          iconHaloWidth: this.iconHaloWidth,
          iconHaloBlur: this.iconHaloBlur,
          textOpacity: this.textOpacity,
          textColor: this.textColor,
          textHaloColor: this.textHaloColor,
          textHaloWidth: this.textHaloWidth,
          textHaloBlur: this.textHaloBlur,
          geometry: points[i],
          draggable: this.draggable));
    }
    return result;
  }

  Future<List<CircleOptions>> getCircles() async {
    List<CircleOptions> result = [];
    var points = await getGeometries(POINT);
    for (int i = 0; i < points.length; i++) {
      result.add(new CircleOptions(
          circleRadius: this.circleRadius,
          circleColor: this.circleColor,
          circleBlur: this.circleBlur,
          circleOpacity: this.circleOpacity,
          circleStrokeWidth: this.circleStrokeWidth,
          circleStrokeColor: this.circleStrokeColor,
          circleStrokeOpacity: this.circleStrokeOpacity,
          geometry: points[i],
          draggable: this.draggable));
    }
    return result;
  }

  Future<List<LineOptions>> getLines() async {
    List<LineOptions> result = [];
    var lines = await getGeometries(POLYLINE);
    for (int i = 0; i < lines.length; i++) {
      result.add(new LineOptions(
          lineJoin: this.lineJoin,
          lineOpacity: this.lineOpacity,
          lineColor: this.lineColor,
          lineWidth: this.lineWidth,
          lineGapWidth: this.lineGapWidth,
          lineOffset: this.lineOffset,
          lineBlur: this.lineBlur,
          linePattern: this.linePattern,
          geometry: lines[i],
          draggable: this.draggable));
    }
    return result;
  }

  Future<List<FillOptions>> getFills() async {
    List<FillOptions> result = [];
    var fills = await getGeometries(POLYGOL);
    for (int i = 0; i < fills.length; i++) {
      result.add(new FillOptions(
          fillOpacity: this.fillOpacity,
          fillColor: this.fillColor,
          fillOutlineColor: this.fillOutlineColor,
          fillPattern: this.fillPattern,
          geometry: fills[i],
          draggable: this.draggable));
    }
    return result;
  }

  Future<dynamic> getGeoJSON() async {
    dynamic json;
    if (this.geojson.contains("http")) {
      try {
        final response = await http.get(Uri.parse(this.geojson));
        json = JSON.jsonDecode(utf8.decode(response.bodyBytes));
      } catch (err) {
        print(err.toString());
      }
    } else if (this.geojson.contains("assets")) {
      try {
        final response = await rootBundle.loadString(this.geojson);
        json = JSON.jsonDecode(response);
      } catch (err) {
        print(err.toString());
      }
    } else {
      try {
        json = JSON.jsonDecode(this.geojson);
      } catch (err) {
        print(err.toString());
      }
    }
    return json;
  }

  Future<dynamic> getDatas(String type) async {
    dynamic json = await getGeoJSON();
    if (json != []) {
      List<dynamic> geometries = [];
      List<int> trongdiem = [];
      List<dynamic> data = [];
      List<Map<dynamic, dynamic>> result = [];
      if (json["type"] == "GeometryCollection") {
        if (json["geometries"] != null && json["geometries"].length > 0) {
          geometries = json["geometries"];
        }
      } else if (json["type"] == "FeatureCollection") {
        if (json["features"] != null && json["features"].length > 0) {
          for (int i = 0; i < json["features"].length; i++) {
            geometries.add(json["features"][i]["geometry"]);
            trongdiem.add(json["features"][i]["properties"]["tdkt"]);
            data.add(json["features"][i]["properties"]);
          }
        }
      }
      if (geometries.length == 0) {
        return [];
      } else {
        switch (type) {
          case SYMBOL:
            for (int i = 0; i < geometries.length; i++) {
              if (geometries[i]["type"] == "Point") {
                result.add(data[i]);
              } else if (geometries[i]["type"] == "MultiPoint") {
                for (int j = 0; j < geometries[i]["coordinates"].length; j++) {
                  result.add(data[i]);
                }
              }
            }
            break;
          case POINT:
            for (int i = 0; i < geometries.length; i++) {
              if (geometries[i]["type"] == "Point") {
                if ((tinh_trong_diem == true && trongdiem[i] == 1) ||
                    (tinh_trong_diem == false && trongdiem[i] == 0))
                  result.add(data[i]);
              } else if (geometries[i]["type"] == "MultiPoint") {
                for (int j = 0; j < geometries[i]["coordinates"].length; j++) {
                  if ((tinh_trong_diem == true && trongdiem[i] == 1) ||
                      (tinh_trong_diem == false && trongdiem[i] == 0))
                    result.add(data[i]);
                }
              }
            }
            break;
          case POLYLINE:
            for (int i = 0; i < geometries.length; i++) {
              if (geometries[i]["type"] == "LineString") {
                List<dynamic> line = [];
                for (int j = 0; j < geometries[i]["coordinates"].length; j++) {
                  if ((tinh_trong_diem == true && trongdiem[i] == 1) ||
                      (tinh_trong_diem == false && trongdiem[i] == 0))
                    result.add(data[i]);
                }
              } else if (geometries[i]["type"] == "MultiLineString") {
                for (int j = 0; j < geometries[i]["coordinates"].length; j++) {
                  if ((tinh_trong_diem == true && trongdiem[i] == 1) ||
                      (tinh_trong_diem == false && trongdiem[i] == 0))
                    result.add(data[i]);
                }
              } else if (geometries[i]["type"] == "Polygon") {
                for (int j = 0; j < geometries[i]["coordinates"].length; j++) {
                  if ((tinh_trong_diem == true && trongdiem[i] == 1) ||
                      (tinh_trong_diem == false && trongdiem[i] == 0))
                    result.add(data[i]);
                }
              } else if (geometries[i]["type"] == "MultiPolygon") {
                for (int j = 0; j < geometries[i]["coordinates"].length; j++) {
                  for (int k = 0;
                      k < geometries[i]["coordinates"][j].length;
                      k++) {
                    if ((tinh_trong_diem == true && trongdiem[i] == 1) ||
                        (tinh_trong_diem == false && trongdiem[i] == 0))
                      result.add(data[i]);
                  }
                }
              }
            }
            break;
          case POLYGOL:
            for (int i = 0; i < geometries.length; i++) {
              if (geometries[i]["type"] == "Polygon") {
                List<List<Map<dynamic, dynamic>>> fill = [];
                for (int j = 0; j < geometries[i]["coordinates"].length; j++) {
                  if ((tinh_trong_diem == true && trongdiem[i] == 1) ||
                      (tinh_trong_diem == false && trongdiem[i] == 0))
                    result.add(data[i]);
                }
              } else if (geometries[i]["type"] == "MultiPolygon") {
                for (int j = 0; j < geometries[i]["coordinates"].length; j++) {
                  List<List<Map<dynamic, dynamic>>> fill = [];
                  for (int k = 0;
                      k < geometries[i]["coordinates"][j].length;
                      k++) {
                    if ((tinh_trong_diem == true && trongdiem[i] == 1) ||
                        (tinh_trong_diem == false && trongdiem[i] == 0))
                      result.add(data[i]);
                  }
                }
              }
            }
            break;
          default:
        }
        return result;
      }
    } else {
      return null;
    }
  }

  Future<dynamic> getGeometries(String type) async {
    dynamic json = await getGeoJSON();
    if (json != []) {
      List<dynamic> geometries = [];
      List<int> trongdiem = [];
      List<dynamic> data = [];
      List<dynamic> result = [];
      if (json["type"] == "GeometryCollection") {
        if (json["geometries"] != null && json["geometries"].length > 0) {
          geometries = json["geometries"];
        }
      } else if (json["type"] == "FeatureCollection") {
        if (json["features"] != null && json["features"].length > 0) {
          for (int i = 0; i < json["features"].length; i++) {
            geometries.add(json["features"][i]["geometry"]);
            trongdiem.add(json["features"][i]["properties"]["tdkt"]);
            data.add(json["features"][i]["properties"]);
          }
        }
      }
      if (geometries.length == 0) {
        return [];
      } else {
        switch (type) {
          case SYMBOL:
            for (int i = 0; i < geometries.length; i++) {
              if (geometries[i]["type"] == "Point") {
                result.add(LatLng(geometries[i]["coordinates"][1].toDouble(),
                    geometries[i]["coordinates"][0].toDouble()));
              } else if (geometries[i]["type"] == "MultiPoint") {
                for (int j = 0; j < geometries[i]["coordinates"].length; j++) {
                  result.add(LatLng(
                      geometries[i]["coordinates"][j][1].toDouble(),
                      geometries[i]["coordinates"][j][0].toDouble()));
                }
              }
            }
            break;
          case POINT:
            for (int i = 0; i < geometries.length; i++) {
              if (geometries[i]["type"] == "Point") {
                result.add(LatLng(geometries[i]["coordinates"][1].toDouble(),
                    geometries[i]["coordinates"][0].toDouble()));
              } else if (geometries[i]["type"] == "MultiPoint") {
                for (int j = 0; j < geometries[i]["coordinates"].length; j++) {
                  result.add(LatLng(
                      geometries[i]["coordinates"][j][1].toDouble(),
                      geometries[i]["coordinates"][j][0].toDouble()));
                }
              }
            }
            break;
          case POLYLINE:
            for (int i = 0; i < geometries.length; i++) {
              if (geometries[i]["type"] == "LineString") {
                List<LatLng> line = [];
                for (int j = 0; j < geometries[i]["coordinates"].length; j++) {
                  line.add(LatLng(geometries[i]["coordinates"][j][1].toDouble(),
                      geometries[i]["coordinates"][j][0].toDouble()));
                }
                result.add(line);
              } else if (geometries[i]["type"] == "MultiLineString") {
                for (int j = 0; j < geometries[i]["coordinates"].length; j++) {
                  List<LatLng> line = [];
                  for (int k = 0;
                      k < geometries[i]["coordinates"][j].length;
                      k++) {
                    line.add(LatLng(
                        geometries[i]["coordinates"][j][k][1].toDouble(),
                        geometries[i]["coordinates"][j][k][0].toDouble()));
                  }
                  result.add(line);
                }
              } else if (geometries[i]["type"] == "Polygon") {
                // for(int j=0; j < geometries[i]["coordinates"].length; j++){
                //   List<List<LatLng>> lines = [];
                //   for(int k=0; k < geometries[i]["coordinates"][j].length; k++){
                //     List<LatLng> line = [];
                //     if(geometries[i]["coordinates"][j][k][0] is double)
                //       line.add(LatLng(geometries[i]["coordinates"][j][k][1].toDouble(), geometries[i]["coordinates"][j][k][0].toDouble()));
                //     else
                //       for(int l=0; l < geometries[i]["coordinates"][j][k].length; l++){
                //         line.add(LatLng(geometries[i]["coordinates"][j][k][l][1].toDouble(), geometries[i]["coordinates"][j][k][l][0].toDouble()));
                //       }
                //     lines.add(line);
                //   }
                //   result.addAll(lines);
                // }

                for (int j = 0; j < geometries[i]["coordinates"].length; j++) {
                  List<LatLng> line = [];
                  for (int k = 0;
                      k < geometries[i]["coordinates"][j].length;
                      k++) {
                    if (tinh_trong_diem == true && trongdiem[i] == 1) {
                      line.add(LatLng(
                          geometries[i]["coordinates"][j][k][1].toDouble(),
                          geometries[i]["coordinates"][j][k][0].toDouble()));
                    } else if (tinh_trong_diem == false && trongdiem[i] == 0) {
                      line.add(LatLng(
                          geometries[i]["coordinates"][j][k][1].toDouble(),
                          geometries[i]["coordinates"][j][k][0].toDouble()));
                    }
                  }
                  if (line.isNotEmpty) result.add(line);
                }
              } else if (geometries[i]["type"] == "MultiPolygon") {
                for (int j = 0; j < geometries[i]["coordinates"].length; j++) {
                  for (int k = 0;
                      k < geometries[i]["coordinates"][j].length;
                      k++) {
                    List<LatLng> line = [];
                    for (int l = 0;
                        l < geometries[i]["coordinates"][j][k].length;
                        l++) {
                      if (tinh_trong_diem == true && trongdiem[i] == 1) {
                        line.add(LatLng(
                            geometries[i]["coordinates"][j][k][l][1].toDouble(),
                            geometries[i]["coordinates"][j][k][l][0]
                                .toDouble()));
                      } else if (tinh_trong_diem == false &&
                          trongdiem[i] == 0) {
                        line.add(LatLng(
                            geometries[i]["coordinates"][j][k][l][1].toDouble(),
                            geometries[i]["coordinates"][j][k][l][0]
                                .toDouble()));
                      }
                    }
                    if (line.isNotEmpty) result.add(line);
                  }
                }
              }
            }
            break;
          case POLYGOL:
            for (int i = 0; i < geometries.length; i++) {
              if (geometries[i]["type"] == "Polygon") {
                List<List<LatLng>> fill = [];
                for (int j = 0; j < geometries[i]["coordinates"].length; j++) {
                  List<LatLng> line = [];
                  for (int k = 0;
                      k < geometries[i]["coordinates"][j].length;
                      k++) {
                    if (tinh_trong_diem == true && trongdiem[i] == 1)
                      line.add(LatLng(
                          geometries[i]["coordinates"][j][k][1].toDouble(),
                          geometries[i]["coordinates"][j][k][0].toDouble()));
                    else if (tinh_trong_diem == false && trongdiem[i] == 0)
                      line.add(LatLng(
                          geometries[i]["coordinates"][j][k][1].toDouble(),
                          geometries[i]["coordinates"][j][k][0].toDouble()));
                  }
                  if (line.isNotEmpty) fill.add(line);
                }
                if (fill.isNotEmpty) result.add(fill);
              } else if (geometries[i]["type"] == "MultiPolygon") {
                for (int j = 0; j < geometries[i]["coordinates"].length; j++) {
                  List<List<LatLng>> fill = [];
                  for (int k = 0;
                      k < geometries[i]["coordinates"][j].length;
                      k++) {
                    List<LatLng> line = [];
                    for (int l = 0;
                        l < geometries[i]["coordinates"][j][k].length;
                        l++) {
                      if (tinh_trong_diem == true && trongdiem[i] == 1)
                        line.add(LatLng(
                            geometries[i]["coordinates"][j][k][l][1].toDouble(),
                            geometries[i]["coordinates"][j][k][l][0]
                                .toDouble()));
                      else if (tinh_trong_diem == false && trongdiem[i] == 0)
                        line.add(LatLng(
                            geometries[i]["coordinates"][j][k][l][1].toDouble(),
                            geometries[i]["coordinates"][j][k][l][0]
                                .toDouble()));
                    }
                    if (line.isNotEmpty) fill.add(line);
                  }
                  if (fill.isNotEmpty) result.add(fill);
                }
              }
            }
            break;
          default:
        }
        return result;
      }
    } else {
      return null;
    }
  }

  dynamic toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    void addIfPresent(String fieldName, dynamic value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('circleRadius', circleRadius);
    addIfPresent('circleColor', circleColor);
    addIfPresent('circleBlur', circleBlur);
    addIfPresent('circleOpacity', circleOpacity);
    addIfPresent('circleStrokeWidth', circleStrokeWidth);
    addIfPresent('circleStrokeColor', circleStrokeColor);
    addIfPresent('circleStrokeOpacity', circleStrokeOpacity);
    addIfPresent('lineJoin', lineJoin);
    addIfPresent('lineOpacity', lineOpacity);
    addIfPresent('lineColor', lineColor);
    addIfPresent('lineWidth', lineWidth);
    addIfPresent('lineGapWidth', lineGapWidth);
    addIfPresent('lineOffset', lineOffset);
    addIfPresent('lineBlur', lineBlur);
    addIfPresent('linePattern', linePattern);
    addIfPresent('fillOpacity', fillOpacity);
    addIfPresent('fillColor', fillColor);
    addIfPresent('fillOutlineColor', fillOutlineColor);
    addIfPresent('fillPattern', fillPattern);
    addIfPresent('iconSize', iconSize);
    addIfPresent('iconImage', iconImage);
    addIfPresent('iconRotate', iconRotate);
    addIfPresent('iconOffset', _offsetToJson(iconOffset));
    addIfPresent('iconAnchor', iconAnchor);
    addIfPresent('fontNames', fontNames);
    addIfPresent('textField', textField);
    addIfPresent('textSize', textSize);
    addIfPresent('textMaxWidth', textMaxWidth);
    addIfPresent('textLetterSpacing', textLetterSpacing);
    addIfPresent('textJustify', textJustify);
    addIfPresent('textAnchor', textAnchor);
    addIfPresent('textRotate', textRotate);
    addIfPresent('textTransform', textTransform);
    addIfPresent('textOffset', _offsetToJson(textOffset));
    addIfPresent('iconOpacity', iconOpacity);
    addIfPresent('iconColor', iconColor);
    addIfPresent('iconHaloColor', iconHaloColor);
    addIfPresent('iconHaloWidth', iconHaloWidth);
    addIfPresent('iconHaloBlur', iconHaloBlur);
    addIfPresent('textOpacity', textOpacity);
    addIfPresent('textColor', textColor);
    addIfPresent('textHaloColor', textHaloColor);
    addIfPresent('textHaloWidth', textHaloWidth);
    addIfPresent('textHaloBlur', textHaloBlur);
    addIfPresent('geojson', geojson);
    addIfPresent('draggable', draggable);
    return json;
  }
}
