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

@interface SBFLockScreenDateView : UIView
@end

@interface CSCoverSheetView : UIView
@property (nonatomic,retain) SBFLockScreenDateView *dateView;
@end

@interface CSCoverSheetViewController : UIViewController
@property (assign, nonatomic) BOOL fux_alreadyAuthenticated;
@property (nonatomic, getter=isAuthenticated) BOOL authenticated;
@property (retain, nonatomic) CSMainPageContentViewController *mainPageContentViewController;
@property (nonatomic,retain) CSModalPresentationViewController * modalPresentationController;
@property (retain, nonatomic) CSCoverSheetView *view;
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
    visualEffectView.frame = [[[self view] dateView] superview].bounds;
    
    [DNDVC view].alpha = 0;
    visualEffectView.alpha = 0;

    [UIView animateWithDuration:0.25 animations:^{
        [DNDVC view].alpha = 1;
        visualEffectView.alpha = 1;

        [[[[self view] dateView] superview] addSubview:visualEffectView];
        [[[[self view] dateView] superview] bringSubviewToFront:[[self view] dateView]];
        [[[[self view] dateView] superview] addSubview:[DNDVC view]];
        //[[[[self view] dateView] superview] sendSubviewToBack:[DNDVC view]];
        //[[[[self view] dateView] superview] sendSubviewToBack:visualEffectView];
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

@interface SBFTouchPassThroughView : UIView
@end

%hook SBFTouchPassThroughView
-(id)hitTest:(CGPoint)arg1 withEvent:(id)arg2 {
    if ([[self superview] isKindOfClass:[%c(CSCoverSheetView) class]] && DNDVC) if ([DNDVC view].alpha == 1) {
        [UIView animateWithDuration:0.25 animations:^{
            visualEffectView.alpha = 0;
            [DNDVC view].alpha = 0;
        } completion:^(BOOL finished){
            [visualEffectView removeFromSuperview];
            [[DNDVC view] removeFromSuperview];
            visualEffectView = nil;
            DNDVC = nil;
        }];
    }
    return %orig;
}
%end

/*@interface CSCoverSheetViewBase : SBFTouchPassThroughView
@end

@interface CSModalView : CSCoverSheetViewBase
@end

%hook CSModalView
-(void)_buttonTapped:(id)arg1 {
    NSLog(@"[TTT] superview: %@",[[self superview] superview]);
}
%end*/
