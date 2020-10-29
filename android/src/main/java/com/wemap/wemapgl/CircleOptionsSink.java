// This file is generated.



package com.wemap.wemapgl;

import com.mapbox.mapboxsdk.geometry.LatLng;

/** Receiver of Circle configuration options. */
interface CircleOptionsSink {
      
  void setCircleRadius(float circleRadius);
          
  void setCircleColor(String circleColor);
          
  void setCircleBlur(float circleBlur);
          
  void setCircleOpacity(float circleOpacity);
                          
  void setCircleStrokeWidth(float circleStrokeWidth);
          
  void setCircleStrokeColor(String circleStrokeColor);
          
  void setCircleStrokeOpacity(float circleStrokeOpacity);
      
  void setGeometry(LatLng geometry);

  void setDraggable(boolean draggable);
}
