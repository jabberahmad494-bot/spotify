#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "PrismSettings.h"

static const void *kGestureKey = &kGestureKey;

@interface PrismGestureHandler : NSObject
+ (instancetype)shared;
- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture;
@end

@implementation PrismGestureHandler

+ (instancetype)shared {
    static PrismGestureHandler *handler;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ handler = [PrismGestureHandler new]; });
    return handler;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateBegan) return;

    UIViewController *top = gesture.view.window.rootViewController;
    while (top.presentedViewController) top = top.presentedViewController;
    if ([top isKindOfClass:UINavigationController.class] &&
        [((UINavigationController *)top).viewControllers.firstObject isKindOfClass:PrismSettingsViewController.class]) {
        return;
    }

    UINavigationController *nav =
        [[UINavigationController alloc] initWithRootViewController:[PrismSettingsViewController new]];
    [top presentViewController:nav animated:YES completion:nil];
}

@end

static void PrismAttach(UIWindow *window) {
    PrismApplyToWindow(window);
    if (objc_getAssociatedObject(window, kGestureKey)) return;

    UILongPressGestureRecognizer *press =
        [[UILongPressGestureRecognizer alloc] initWithTarget:PrismGestureHandler.shared
                                                      action:@selector(handleLongPress:)];
    press.numberOfTouchesRequired = 3;
    press.cancelsTouchesInView = NO;
    [window addGestureRecognizer:press];
    objc_setAssociatedObject(window, kGestureKey, press, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%hook UIWindow

- (void)becomeKeyWindow {
    %orig;
    PrismAttach(self);
}

%end

%ctor {
    NSLog(@"[Prism] loaded into %@", NSBundle.mainBundle.bundleIdentifier);
}
