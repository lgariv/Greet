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
-(void)_evaluateShouldShowGreeting:(id)arg1 animated:(BOOL)arg2 ;
-(void)_setFooterCallToActionLabelHidden:(BOOL)arg1 ;
-(void)_setDisableScrolling:(BOOL)arg1 ;
@end

@interface UIBlurEffect ()
+(id)effectWithBlurRadius:(double)arg1 ;
@end


#pragma mark Variables

static CSDNDBedtimeGreetingViewController *DNDVC = nil;
static CSDNDBedtimeGreetingViewController *DNDC = nil;


#pragma mark Hooks

@interface CSCoverSheetView : UIView
@end

%hook CSCoverSheetView
-(id)initWithFrame:(CGRect)arg1 {
    %orig;
    
    if (DNDVC != nil) return self;
    DNDVC = [[%c(CSDNDBedtimeGreetingViewController) alloc] initWithLegibilityPrimaryColor:[UIColor whiteColor]];
    
    [DNDVC loadView];
    [[DNDVC view] setDelegate:DNDVC];

    UIVisualEffect *blurEffect = [UIBlurEffect effectWithBlurRadius:30.0f];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = self.bounds;

    [self addSubview:visualEffectView];
    [self addSubview:[DNDVC view]];
    [self sendSubviewToBack:[DNDVC view]];
    [self sendSubviewToBack:visualEffectView];

    return self;
}
%end

/*%hook CSCombinedListViewController
-(void)viewDidAppear:(BOOL)arg1 {
    %orig;

    if (DNDVC != nil) return;
    DNDVC = [[%c(CSDNDBedtimeGreetingViewController) alloc] initWithLegibilityPrimaryColor:[UIColor whiteColor]];
    
    //DNDC = [[%c(CSDNDBedtimeController) alloc] init];
    //[self _evaluateShouldShowGreeting:DNDC animated:YES];
    //return;
    
    [DNDVC loadView];
    [[DNDVC view] setDelegate:DNDVC];

    UIVisualEffect *blurEffect = [UIBlurEffect effectWithBlurRadius:30.0f];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = [self view].bounds;

    [[self view] addSubview:visualEffectView];
    [[self view] addSubview:[DNDVC view]];
    [[self view] sendSubviewToBack:[DNDVC view]];
    [[self view] sendSubviewToBack:visualEffectView];

    [self _setFooterCallToActionLabelHidden:YES];
}
%end*/


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
