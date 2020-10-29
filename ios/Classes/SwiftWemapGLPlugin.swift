import Flutter
import UIKit

public class SwiftWemapGLPlugin: NSObject, FlutterPlugin{
    
    var _eventSink: FlutterEventSink? = nil
    
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "wemapgl", binaryMessenger: registrar.messenger())
    let instance = SwiftWemapGLPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    
    
    let instanceMapview = WeMapFactory(withRegistrar: registrar)
    registrar.register(instanceMapview, withId: "wemap_gl")

    let channelMapview = FlutterMethodChannel(name: "wemap_gl", binaryMessenger: registrar.messenger())

    channelMapview.setMethodCallHandler { (methodCall, result) in
        switch(methodCall.method) {
        case "installOfflineMapTiles":
            guard let arguments = methodCall.arguments as? [String: String] else { return }
            let tilesdb = arguments["tilesdb"]
            installOfflineMapTiles(registrar: registrar, tilesdb: tilesdb!)
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
  }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        _eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        _eventSink = nil
        return nil
    }

    
    private static func getTilesUrl() -> URL {
        guard var cachesUrl = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first,
            let bundleId = Bundle.main.object(forInfoDictionaryKey: kCFBundleIdentifierKey as String) as? String else {
                fatalError("Could not get map tiles directory")
        }
        cachesUrl.appendPathComponent(bundleId)
        cachesUrl.appendPathComponent(".mapbox")
        cachesUrl.appendPathComponent("cache.db")
        return cachesUrl
    }

    // Copies the "offline" tiles to where Mapbox expects them
    private static func installOfflineMapTiles(registrar: FlutterPluginRegistrar, tilesdb: String) {
        var tilesUrl = getTilesUrl()
        let bundlePath = getTilesDbPath(registrar: registrar, tilesdb: tilesdb)
        NSLog("Cached tiles not found, copying from bundle... \(String(describing: bundlePath)) ==> \(tilesUrl)")
        do {
            let parentDir = tilesUrl.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: parentDir, withIntermediateDirectories: true, attributes: nil)
            if FileManager.default.fileExists(atPath: tilesUrl.path) {
                try FileManager.default.removeItem(atPath: tilesUrl.path)
            }
            try FileManager.default.copyItem(atPath: bundlePath!, toPath: tilesUrl.path)
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try tilesUrl.setResourceValues(resourceValues)
        } catch let error {
            NSLog("Error copying bundled tiles: \(error)")
        }
    }
    
    private static func getTilesDbPath(registrar: FlutterPluginRegistrar, tilesdb: String) -> String? {
        if (tilesdb.starts(with: "/")) {
            return tilesdb;
        } else {
            let key = registrar.lookupKey(forAsset: tilesdb)
            return Bundle.main.path(forResource: key, ofType: nil)
        }
    }
}

public class Location
{
    let name: String
    let latitude: Double
    let longitude: Double
    
    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}
