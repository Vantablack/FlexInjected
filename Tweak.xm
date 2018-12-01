/* How to Hook with Logos
Hooks are written with syntax similar to that of an Objective-C @implementation.
You don't need to #include <substrate.h>, it will be done automatically, as will
the generation of a class list and an automatic constructor.
*/
#include <dlfcn.h>

NSString * const PREFS_CONST = @"/var/mobile/Library/Preferences/com.yaowei.flexinjected.plist";

@interface MyDKFLEXLoader : NSObject

@end

@implementation MyDKFLEXLoader

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static MyDKFLEXLoader *_sharedInstance;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

- (void)show
{
    // [[FLEXManager sharedManager] showExplorer];
    Class FLEXManager = NSClassFromString(@"FLEXManager");
    id sharedManager = [FLEXManager performSelector:@selector(sharedManager)];
    [sharedManager performSelector:@selector(showExplorer)];
}

@end

%group GROUP_STATUS_BAR_ACTIVATION
    %hook UIStatusBarWindow
        - (id)initWithFrame:(CGRect)frame {
            self = %orig;

            Class FLEXManager = NSClassFromString(@"FLEXManager");
            id sharedManager = [FLEXManager performSelector:@selector(sharedManager)];
            [self addGestureRecognizer:[[UILongPressGestureRecognizer alloc]
                initWithTarget:sharedManager action:@selector(showExplorer)]];
            
            return self;
        }
    %end
%end

%ctor {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:PREFS_CONST];
        
    NSString *keyPath = [NSString stringWithFormat:@"FLEXInjectedEnabled-%@", [[NSBundle mainBundle] bundleIdentifier]];

    bool statusbar_activation = [prefs objectForKey:@"pref_statusbar_activation"] ? [[prefs objectForKey:@"pref_statusbar_activation"] boolValue] : NO;

    if (statusbar_activation) {
        %init(GROUP_STATUS_BAR_ACTIVATION);
    }

    if ([[prefs objectForKey:keyPath] boolValue]) {
        [[NSNotificationCenter defaultCenter] addObserver:[MyDKFLEXLoader sharedInstance] 
                                            selector:@selector(show) 
                                            name:UIApplicationDidBecomeActiveNotification 
                                            object:nil];
    } else {
        NSLog(@"FLEXInjected not enabled for current app");
    }

    [pool drain];
}



