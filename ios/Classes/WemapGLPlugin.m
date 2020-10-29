#import "WemapGLPlugin.h"
#import <wemapgl/wemapgl-Swift.h>

@implementation WemapGLPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftWemapGLPlugin registerWithRegistrar:registrar];
}
@end
