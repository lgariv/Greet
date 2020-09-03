#pragma mark Headers

@interface CSDNDBedtimeController : NSObject
-(void)setActive:(BOOL)arg1 ;
-(void)setShouldShowGreeting:(BOOL)arg1 ;
@end

@interface UIView ()
@property (assign,nonatomic) id delegate;
@end

@interface CSDNDBedtimeGreetingViewController : UIViewController
@property (assign,nonatomic) id delegate;
@property (nonatomic, strong) UIView *view;
-(void)dealloc;
-(id)initWithLegibilityPrimaryColor:(id)arg1 ;
-(void)loadView;
@end

@interface CSCombinedListViewController : UIViewController
@end

@interface UIBlurEffect ()
+(id)effectWithBlurRadius:(double)arg1 ;
@end


#pragma mark Variables

static CSDNDBedtimeGreetingViewController *DNDVC = nil;


#pragma mark Hooks

%hook CSCombinedListViewController
-(void)viewDidAppear:(BOOL)arg1 {
    %orig;
    if (DNDVC != nil) return;
    DNDVC = [[%c(CSDNDBedtimeGreetingViewController) alloc] initWithLegibilityPrimaryColor:[UIColor whiteColor]];
    DNDVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [DNDVC setDelegate:self];
    [DNDVC loadView];
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithBlurRadius:30.0f];
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = [self view].bounds;
    [[self view] addSubview:visualEffectView];
    [[self view] addSubview:[DNDVC view]];
    [[self view] sendSubviewToBack:[DNDVC view]];
    [[self view] sendSubviewToBack:visualEffectView];
    //[self _setFooterCallToActionLabelHidden:YES];
    //[[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:DNDVC animated:NO completion:nil];
}
%end


#pragma mark Handle preferences

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Tweak_Category)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end

static NSString * nsDomainString = @"com.miwix.terrible";
static NSString * nsNotificationString = @"com.miwix.terrible/preferences.changed";
static BOOL enabled;

static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	NSNumber * enabledValue = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"enabled" inDomain:nsDomainString];
	enabled = (enabledValue)? [enabledValue boolValue] : YES;
}

%ctor {
	// Set variables on start up
	notificationCallback(NULL, NULL, NULL, NULL, NULL);

	// Register for 'PostNotification' notifications
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, notificationCallback, (CFStringRef)nsNotificationString, NULL, CFNotificationSuspensionBehaviorCoalesce);

	// Add any personal initializations

}
