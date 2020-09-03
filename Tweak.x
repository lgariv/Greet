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

@interface NCNotificationListViewController : UICollectionViewController
-(BOOL)hasVisibleContent;
@end

@interface CSCombinedListViewController : UIViewController {
    NCNotificationListViewController *_structuredListViewController;
}
@property (assign,setter=_setFooterCallToActionLabelHidden:,getter=_footerCallToActionLabelHidden,nonatomic) BOOL footerCallToActionLabelHidden;              //@synthesize footerCallToActionLabelHidden=_footerCallToActionLabelHidden - In the implementation block
@property(readonly, nonatomic) BOOL hasContent;
-(void)_evaluateShouldShowGreeting:(id)arg1 animated:(BOOL)arg2 ;
-(void)_setDisableScrolling:(BOOL)arg1 ;
@end

@interface UIBlurEffect ()
+(id)effectWithBlurRadius:(double)arg1 ;
@end

@interface CSCoverSheetViewControllerBase : UIViewController
@end

@interface CSPresentationViewController : CSCoverSheetViewControllerBase
@property (nonatomic,copy,readonly) NSArray * presentedViewControllers;
@end

@interface CSModalPresentationViewController : CSPresentationViewController
@end

@interface CSPageViewController : CSPresentationViewController
@end

@interface CSMainPageContentViewController : CSPageViewController
@property(readonly, nonatomic) CSCombinedListViewController *combinedListViewController;
@end

@interface NCNotificationStructuredListViewController : UIViewController
@property (nonatomic,readonly) BOOL hasVisibleContent; 
@end

@interface CSCoverSheetViewController : UIViewController
@property(assign, nonatomic) BOOL fux_alreadyAuthenticated;
@property(nonatomic, getter=isAuthenticated) BOOL authenticated;
@property(retain, nonatomic) CSMainPageContentViewController *mainPageContentViewController;
@property (nonatomic,retain) CSModalPresentationViewController * modalPresentationController;
-(BOOL)isShowingMediaControls;
-(BOOL)isInScreenOffMode;
-(BOOL)biometricUnlockBehavior:(id)arg1 requestsUnlock:(id)arg2 withFeedback:(id)arg3 ;

// %new
-(void)loadWeatherIfShould;
@end

@interface SBUIFlashlightController : NSObject
+(id)sharedInstance;
-(NSInteger)level;
@end

@interface SBLockScreenManager : NSObject
+ (id)sharedInstance;
- (void)tapToWakeControllerDidRecognizeWakeGesture:(id)arg1;
- (void)lockScreenViewControllerRequestsUnlock;
@end


#pragma mark Variables

static CSDNDBedtimeGreetingViewController *DNDVC = nil;
//static CSDNDBedtimeGreetingViewController *DNDC = nil;
UIVisualEffect *blurEffect;
UIVisualEffectView *visualEffectView;


#pragma mark Hooks

%hook CSCoverSheetViewController
-(void)viewDidAppear:(BOOL)arg1 {
    %orig;
    [self loadWeatherIfShould];
}

-(void)viewWillDisappear:(BOOL)animated {
    %orig;

    if (DNDVC == nil) return;

    [UIView animateWithDuration:0.5 animations:^{
        visualEffectView.alpha = 0;
        [DNDVC view].alpha = 0;
    } completion:^(BOOL finished){
        [[DNDVC view] removeFromSuperview];
        DNDVC = nil;
        [visualEffectView removeFromSuperview];
        visualEffectView = nil;
    }];

}

-(void)setInScreenOffMode:(BOOL)arg1 {
    %orig;
    if (arg1) {
        [visualEffectView removeFromSuperview];
        [[DNDVC view] removeFromSuperview];
        visualEffectView = nil;
        DNDVC = nil;
    } else [self loadWeatherIfShould];
}

-(void)setInScreenOffMode:(BOOL)arg1 forAutoUnlock:(BOOL)arg2 fromUnlockSource:(int)arg3 {
    %orig;
    if (arg1) {
        [visualEffectView removeFromSuperview];
        [[DNDVC view] removeFromSuperview];
        visualEffectView = nil;
        DNDVC = nil;
    } else [self loadWeatherIfShould];
}

%new
-(void)loadWeatherIfShould {
    if (self.mainPageContentViewController.combinedListViewController.hasContent) {
        NCNotificationListViewController *listController = [self.mainPageContentViewController.combinedListViewController valueForKey:@"_structuredListViewController"];
        if (self.isShowingMediaControls) return;
        if ([listController hasVisibleContent]) return;
    }

    if (DNDVC != nil) return;

    if (!DNDVC) {
        DNDVC = [[%c(CSDNDBedtimeGreetingViewController) alloc] initWithLegibilityPrimaryColor:[UIColor whiteColor]];

        [DNDVC loadView];
        [[DNDVC view] setDelegate:DNDVC];
    }

    blurEffect = [UIBlurEffect effectWithBlurRadius:30.0f];
    if (!visualEffectView) visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = [self view].bounds;
    
    [DNDVC view].alpha = 0;
    visualEffectView.alpha = 0;

    [UIView animateWithDuration:0.25 animations:^{
        [DNDVC view].alpha = 1;
        visualEffectView.alpha = 1;

        [[self view] addSubview:visualEffectView];
        [[self view] addSubview:[DNDVC view]];
        //[[self view] sendSubviewToBack:[DNDVC view]];
        [[self view] sendSubviewToBack:visualEffectView];
    } completion:^(BOOL finished){
    }];
}
%end

%hook CSCombinedListViewController
-(void)viewDidAppear:(BOOL)arg1 {
    %orig;
    if (DNDVC) [self _setFooterCallToActionLabelHidden:YES];
}

-(void)viewWillDisappear:(BOOL)arg1 {
    %orig;
    if ([self _footerCallToActionLabelHidden] && DNDVC != nil) [self _setFooterCallToActionLabelHidden:NO];
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
