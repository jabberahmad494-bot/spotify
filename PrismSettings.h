#import <UIKit/UIKit.h>

BOOL PrismAccentEnabled(void);
UIColor *PrismStoredAccent(void);
void PrismSetAccentEnabled(BOOL enabled);
void PrismSetAccent(UIColor *color);

// Re-applies the current settings to every window in the app.
void PrismApplyToAllWindows(void);
void PrismApplyToWindow(UIWindow *window);

@interface PrismSettingsViewController : UITableViewController
@end
