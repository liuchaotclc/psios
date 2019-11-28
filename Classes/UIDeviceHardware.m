#include <sys/sysctl.h>
#import "UIDeviceHardware.h"

@implementation UIDeviceHardware

+ (NSString *) platform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = @(machine);
    free(machine);
    return platform;
}

@end
