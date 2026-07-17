import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class OverlayService {
  static const int bubbleOverlaySize = 200;

  static Future<void> startOverlay() async {
    bool? permission = await FlutterOverlayWindow.isPermissionGranted();

    if (permission != true) {
      bool? granted = await FlutterOverlayWindow.requestPermission();

      if (granted != true) {
        return;
      }
    }

    await FlutterOverlayWindow.showOverlay(
      enableDrag: true,
      overlayTitle: "TrueCart",
      overlayContent: "TrueCart Overlay",
      flag: OverlayFlag.defaultFlag,
      visibility: NotificationVisibility.visibilityPublic,
      positionGravity: PositionGravity.right,
      height: bubbleOverlaySize,
      width: bubbleOverlaySize,
    );
  }

  // static Future<void> expandOverlay() async {
  //   await FlutterOverlayWindow.resizeOverlay(
  //     WindowSize.matchParent,
  //     WindowSize.matchParent,
  //     false,
  //   );
  // }

  // static Future<void> collapseOverlay() async {
  //   await FlutterOverlayWindow.resizeOverlay(
  //     bubbleOverlaySize,
  //     bubbleOverlaySize,
  //     true,
  //   );
  // }

  static Future<void> closeOverlay() async {
    await FlutterOverlayWindow.closeOverlay();
  }
}
