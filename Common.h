#import <Foundation/Foundation.h>

#define SH_ROOT @"/Users/PoomSmart/Desktop/CydiaTweaks/SimulatorHooker"
#define SH_PATH(name) [NSString stringWithFormat:@"%@/.theos/obj/iphone_simulator/%@.dylib", SH_ROOT, name]

#define runIn(process) NSLog(@"%@", [NSString stringWithFormat:@"========== init for %@ ==========", process])
