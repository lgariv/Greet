#pragma mark Headers

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
@property (assign,setter=_setFooterCallToActionLabelHidden:,getter=_footerCallToActionLabelHidden,nonatomic) BOOL footerCallToActionLabelHidden;
@property(readonly, nonatomic) BOOL hasContent;
@end

@interface UIBlurEffect ()
+(id)effectWithBlurRadius:(double)arg1 ;
@end

@interface CSCoverSheetViewControllerBase : UIViewController
@end

@interface CSPresentationViewController : CSCoverSheetViewControllerBase
@property (nonatomic,copy,readonly) NSArray * presentedViewControllers;
@end

@interface CSPageViewController : CSPresentationViewController
@end

@interface CSMainPageContentViewController : CSPageViewController
@property (assign,nonatomic) BOOL useFakeBlur;                                                                         //@synthesize useFakeBlur=_useFakeBlur - In the implementation block
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
@property (retain, nonatomic) CSCoverSheetView *view;
-(BOOL)isShowingMediaControls;
-(BOOL)isInScreenOffMode;

// %new
-(void)loadWeatherIfShould;
@end

@interface SBFTouchPassThroughView : UIView
@end

#pragma mark Variables

static CSDNDBedtimeGreetingViewController *DNDVC = nil;
UIVisualEffect *blurEffect;
UIVisualEffectView *visualEffectView;
BOOL shouldHideLabel = YES;

#pragma mark Hooks

%hook CSCoverSheetViewController
-(void)viewDidAppear:(BOOL)arg1 {
    [self loadWeatherIfShould];
    %orig;
}

-(void)viewWillDisappear:(BOOL)animated {
    %orig;

    if (DNDVC == nil) return;

    [UIView animateWithDuration:0.33 animations:^{
        visualEffectView.alpha = 0;
        [DNDVC view].alpha = 0;
    } completion:^(BOOL finished){
        [[DNDVC view] removeFromSuperview];
        DNDVC = nil;
        [visualEffectView removeFromSuperview];
        visualEffectView = nil;
        shouldHideLabel = NO;
    }];
}

-(void)setInScreenOffMode:(BOOL)arg1 {
    %orig;
    if (arg1) {
        [visualEffectView removeFromSuperview];
        [[DNDVC view] removeFromSuperview];
        visualEffectView = nil;
        DNDVC = nil;
        shouldHideLabel = NO;
    } else [self loadWeatherIfShould];
}

-(void)setInScreenOffMode:(BOOL)arg1 forAutoUnlock:(BOOL)arg2 fromUnlockSource:(int)arg3 {
    %orig;
    if (arg1) {
        [visualEffectView removeFromSuperview];
        [[DNDVC view] removeFromSuperview];
        visualEffectView = nil;
        DNDVC = nil;
        shouldHideLabel = NO;
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

    shouldHideLabel = YES;

    if (!DNDVC) {
        DNDVC = [[%c(CSDNDBedtimeGreetingViewController) alloc] initWithLegibilityPrimaryColor:[UIColor whiteColor]];

        [DNDVC loadView];
        [[DNDVC view] setDelegate:DNDVC];
    }

    blurEffect = [UIBlurEffect effectWithBlurRadius:22.5f];
    if (!visualEffectView) visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = [[[self view] dateView] superview].bounds;
    
    [DNDVC view].alpha = 0;
    visualEffectView.alpha = 0;

    [UIView animateWithDuration:0.33 animations:^{
        [DNDVC view].alpha = 1;
        visualEffectView.alpha = 1;

        if (![self.mainPageContentViewController useFakeBlur]) [[[[self view] dateView] superview] addSubview:visualEffectView];
        [[[[self view] dateView] superview] addSubview:[DNDVC view]];
        [[[[self view] dateView] superview] bringSubviewToFront:[[self view] dateView]];
        //[[[[self view] dateView] superview] sendSubviewToBack:[DNDVC view]];
        //[[[[self view] dateView] superview] sendSubviewToBack:visualEffectView];
    }];
}
%end

%hook CSCombinedListViewController
-(void)viewWillAppear:(BOOL)arg1 {
    %orig;
    NCNotificationListViewController *listController = [self valueForKey:@"_structuredListViewController"];
    if ((DNDVC && ([self hasContent] || [listController hasVisibleContent])) || shouldHideLabel) [self _setFooterCallToActionLabelHidden:YES];
}

-(void)viewDidAppear:(BOOL)arg1 {
    %orig;
    NCNotificationListViewController *listController = [self valueForKey:@"_structuredListViewController"];
    if ((DNDVC && ([self hasContent] || [listController hasVisibleContent])) || shouldHideLabel) [self _setFooterCallToActionLabelHidden:YES];
}

-(void)viewWillDisappear:(BOOL)arg1 {
    %orig;
    if (([self _footerCallToActionLabelHidden] && (DNDVC != nil || [DNDVC view].alpha == 0.0f)) || !shouldHideLabel) [self _setFooterCallToActionLabelHidden:NO];
}
%end

%hook SBFTouchPassThroughView
-(id)hitTest:(CGPoint)arg1 withEvent:(id)arg2 {
    if ([[self superview] isKindOfClass:[%c(CSCoverSheetView) class]] && DNDVC) if ([DNDVC view].alpha == 1) {
        [UIView animateWithDuration:0.33 animations:^{
            visualEffectView.alpha = 0;
            [DNDVC view].alpha = 0;
        } completion:^(BOOL finished){
            [visualEffectView removeFromSuperview];
            [[DNDVC view] removeFromSuperview];
            visualEffectView = nil;
            DNDVC = nil;
            shouldHideLabel = NO;
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
