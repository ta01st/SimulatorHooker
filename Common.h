#import <Foundation/Foundation.h>

#define SH_ROOT @"/Users/PoomSmart/Desktop/CydiaTweaks/SimulatorHooker"
#define SH_PATH(name) [NSString stringWithFormat:@"%@/%@/%@.dylib", SH_ROOT, name, name]

#define runIn(process) NSLog(@"%@", [NSString stringWithFormat:@"========== init for %@ ==========", process])
