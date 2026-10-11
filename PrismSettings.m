#import "PrismSettings.h"
#import <objc/runtime.h>

static NSString *const kAccentEnabled = @"prism.accentEnabled";
static NSString *const kAccentHex = @"prism.accentHex";
static const void *kOriginalTintKey = &kOriginalTintKey;

#pragma mark - Colour helpers

static NSString *HexFromColor(UIColor *color) {
    CGFloat r = 0, g = 0, b = 0, a = 0;
    [color getRed:&r green:&g blue:&b alpha:&a];
    return [NSString stringWithFormat:@"%02X%02X%02X",
            (int)lround(r * 255), (int)lround(g * 255), (int)lround(b * 255)];
}

static UIColor *ColorFromHex(NSString *hex) {
    unsigned int rgb = 0;
    if (hex.length != 6 || ![[NSScanner scannerWithString:hex] scanHexInt:&rgb]) return nil;
    return [UIColor colorWithRed:((rgb >> 16) & 0xFF) / 255.0
                           green:((rgb >> 8) & 0xFF) / 255.0
                            blue:(rgb & 0xFF) / 255.0
                           alpha:1];
}

#pragma mark - Settings

BOOL PrismAccentEnabled(void) {
    return [NSUserDefaults.standardUserDefaults boolForKey:kAccentEnabled];
}

UIColor *PrismStoredAccent(void) {
    UIColor *c = ColorFromHex([NSUserDefaults.standardUserDefaults stringForKey:kAccentHex]);
    return c ?: [UIColor colorWithRed:0.75 green:0.35 blue:1 alpha:1];
}

void PrismSetAccentEnabled(BOOL enabled) {
    [NSUserDefaults.standardUserDefaults setBool:enabled forKey:kAccentEnabled];
    PrismApplyToAllWindows();
}

void PrismSetAccent(UIColor *color) {
    [NSUserDefaults.standardUserDefaults setObject:HexFromColor(color) forKey:kAccentHex];
    PrismApplyToAllWindows();
}

void PrismApplyToWindow(UIWindow *window) {
    // Remember Spotify's own tint the first time, so turning the accent off restores it.
    if (!objc_getAssociatedObject(window, kOriginalTintKey)) {
        objc_setAssociatedObject(window, kOriginalTintKey, window.tintColor ?: NSNull.null,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    if (PrismAccentEnabled()) {
        window.tintColor = PrismStoredAccent();
    } else {
        id original = objc_getAssociatedObject(window, kOriginalTintKey);
        window.tintColor = original == NSNull.null ? nil : original;
    }
}

void PrismApplyToAllWindows(void) {
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if (![scene isKindOfClass:UIWindowScene.class]) continue;
        for (UIWindow *window in ((UIWindowScene *)scene).windows) PrismApplyToWindow(window);
    }
}

#pragma mark - Settings screen

@interface PrismSettingsViewController () <UIColorPickerViewControllerDelegate>
@end

@implementation PrismSettingsViewController

- (instancetype)init {
    return [super initWithStyle:UITableViewStyleInsetGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Prism";
    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                      target:self
                                                      action:@selector(done)];
}

- (void)done {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString *version = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    return [NSString stringWithFormat:@"Long-press anywhere with three fingers to open this screen.\nSpotify %@", version];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Custom accent";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UISwitch *toggle = [UISwitch new];
        toggle.on = PrismAccentEnabled();
        [toggle addTarget:self action:@selector(accentToggled:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = toggle;
    } else {
        cell.textLabel.text = @"Accent colour";
        UIView *swatch = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        swatch.layer.cornerRadius = 12;
        swatch.backgroundColor = PrismStoredAccent();
        cell.accessoryView = swatch;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row != 1) return;
    UIColorPickerViewController *picker = [UIColorPickerViewController new];
    picker.selectedColor = PrismStoredAccent();
    picker.supportsAlpha = NO;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)accentToggled:(UISwitch *)toggle {
    PrismSetAccentEnabled(toggle.on);
}

- (void)colorPickerViewControllerDidFinish:(UIColorPickerViewController *)picker {
    PrismSetAccent(picker.selectedColor);
    [self.tableView reloadData];
}

@end
