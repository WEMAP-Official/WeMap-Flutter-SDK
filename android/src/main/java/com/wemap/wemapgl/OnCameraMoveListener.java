

package com.wemap.wemapgl;

import com.mapbox.mapboxsdk.camera.CameraPosition;

interface OnCameraMoveListener {
  void onCameraMoveStarted(boolean isGesture);

  void onCameraMove(CameraPosition newPosition);

  void onCameraIdle();
}
