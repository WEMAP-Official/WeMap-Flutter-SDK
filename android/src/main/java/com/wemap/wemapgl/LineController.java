// This file is generated.



package com.wemap.wemapgl;

import java.util.List;

import android.graphics.PointF;
import android.util.Log;

import com.mapbox.geojson.Point;
import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.mapboxsdk.plugins.annotation.Line;
import com.mapbox.mapboxsdk.plugins.annotation.LineManager;
import com.mapbox.mapboxsdk.utils.ColorUtils;

/**
 * Controller of a single Line on the map.
 */
class LineController implements LineOptionsSink {
  private final Line line;
  private final OnLineTappedListener onTappedListener;
  private boolean consumeTapEvents;

  LineController(Line line, boolean consumeTapEvents, OnLineTappedListener onTappedListener) {
    this.line = line;
    this.consumeTapEvents = consumeTapEvents;
    this.onTappedListener = onTappedListener;
  }

  boolean onTap() {
    if (onTappedListener != null) {
      onTappedListener.onLineTapped(line);
    }
    return consumeTapEvents;
  }

  void remove(LineManager lineManager) {
    lineManager.delete(line);
  }

  @Override
  public void setLineJoin(String lineJoin) {
    line.setLineJoin(lineJoin);
  }
  
  @Override
  public void setLineOpacity(float lineOpacity) {
    line.setLineOpacity(lineOpacity);
  }
  
  @Override
  public void setLineColor(String lineColor) {
    line.setLineColor(ColorUtils.rgbaToColor(lineColor));
  }

  @Override
  public void setLineWidth(float lineWidth) {
    line.setLineWidth(lineWidth);
  }

  @Override
  public void setLineGapWidth(float lineGapWidth) {
    line.setLineGapWidth(lineGapWidth);
  }

  @Override
  public void setLineOffset(float lineOffset) {
    line.setLineOffset(lineOffset);
  }

  @Override
  public void setLineBlur(float lineBlur) {
    line.setLineBlur(lineBlur);
  }

  @Override
  public void setLinePattern(String linePattern) {
    line.setLinePattern(linePattern);
  }

  @Override
  public void setGeometry(List<LatLng> geometry) {
    line.setLatLngs(geometry);
  }

  @Override
  public void setDraggable(boolean draggable) {
    line.setDraggable(draggable);
  }

  public void update(LineManager lineManager) {
    lineManager.update(line);
  }
}
