#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import "UIView+draggable.h"

UIVisualEffectView *blurryView;
UIVisualEffect *blurEffect;

static NSString *domainString = @"com.nahtedetihw.floatingdarkmode";
static NSString *notificationString = @"com.nahtedetihw.floatingdarkmode/preferences.changed";
static BOOL enabled;

@interface UIUserInterfaceStyleArbiter : NSObject
@property (nonatomic, readonly) long long currentStyle;
+ (id)sharedInstance;
- (void)toggleCurrentStyleWithOverrideTiming:(long long)arg1;
@end

@interface UIWindow (Private)
@property (getter=isKeyWindow, nonatomic, readonly) BOOL keyWindow;
@property (strong, nonatomic) UIView *darkModeButtonView;
@property (strong, nonatomic) UIImageView *darkModeButtonImageView;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@end

@interface NSUserDefaults (FDM)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end

%group Tweak
%hook UIWindow
%property (strong, nonatomic) UIView *darkModeButtonView;
%property (strong, nonatomic) UIImageView *darkModeButtonImageView;
%property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
- (void)orderFront:(id)arg1 {
    %orig;
    if (![NSStringFromClass([((UIWindow *)self) class]) isEqualToString:@"SBControlCenterWindow"] && !self.darkModeButtonView) {
        self.darkModeButtonView = [[UIView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 70, [UIScreen mainScreen].bounds.size.height - 70, 60, 60)];
        self.darkModeButtonView.hidden = NO;
        self.darkModeButtonView.backgroundColor = [UIColor clearColor];
        self.darkModeButtonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.darkModeButtonView.frame.size.height*0.60, self.darkModeButtonView.frame.size.width*0.60)];
        
        UIColor *darkModeLabelColor = [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *traitCollection) {
            BOOL isDarkMode = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
            BOOL isLightMode = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight;
            if (isDarkMode) {
                return [UIColor whiteColor];
            } else if (isLightMode) {
                return [UIColor blackColor];
            }
            return [UIColor blackColor];
        }];
        
        self.darkModeButtonImageView.tintColor = darkModeLabelColor;
        UIImage *darkModeImage;
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            darkModeImage = [UIImage systemImageNamed:@"circle.righthalf.fill"];
        } else if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
            darkModeImage = [UIImage systemImageNamed:@"circle.lefthalf.fill"];
        }
        self.darkModeButtonImageView.image = darkModeImage;
        self.darkModeButtonImageView.center = CGPointMake(self.darkModeButtonView.frame.size.width / 2, self.darkModeButtonView.frame.size.height / 2);
        self.darkModeButtonImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.darkModeButtonView enableDragging];
        self.darkModeButtonView.cagingArea = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
        self.darkModeButtonView.shouldMoveAlongX = true;
        self.darkModeButtonView.shouldMoveAlongY = true;
        self.darkModeButtonView.handle = CGRectMake([UIScreen mainScreen].bounds.size.width - 70, [UIScreen mainScreen].bounds.size.height - 70, 60, 60);
        
        [self.darkModeButtonView addSubview:self.darkModeButtonImageView];
        
        blurryView = [[UIVisualEffectView alloc] initWithFrame:self.darkModeButtonView.bounds];
        
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialDark];
        } else if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialLight];
        }
        blurryView.effect = blurEffect;
        blurryView.layer.masksToBounds = YES;
        blurryView.layer.cornerRadius = self.darkModeButtonView.frame.size.width/2;

        [self.darkModeButtonView insertSubview:blurryView atIndex:0];
        
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [self.darkModeButtonView addGestureRecognizer:self.tapGesture];
        
        self.darkModeButtonView.layer.masksToBounds = YES;
        self.darkModeButtonView.layer.cornerRadius = self.darkModeButtonView.frame.size.height/2;

        [self.rootViewController.view addSubview:self.darkModeButtonView];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    %orig;
    self.darkModeButtonView.hidden = YES;
    self.darkModeButtonView = nil;
}
%new
- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
    [[%c(UIUserInterfaceStyleArbiter) sharedInstance] toggleCurrentStyleWithOverrideTiming:2];
    AudioServicesPlaySystemSound(1519);
}
- (void)traitCollectionDidChange:(id)arg1 {
    %orig;
    UIImage *darkModeImage;
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
        darkModeImage = [UIImage systemImageNamed:@"circle.righthalf.fill"];
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialDark];
    } else if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
        darkModeImage = [UIImage systemImageNamed:@"circle.lefthalf.fill"];
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialLight];
    }
        blurryView.effect = blurEffect;
    [self.darkModeButtonImageView setImage:darkModeImage];
}
%end
%end

static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	NSNumber *enabledValue = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"enabled" inDomain:domainString];
	enabled = (enabledValue)? [enabledValue boolValue] : YES;
}

%ctor {
	notificationCallback(NULL, NULL, NULL, NULL, NULL);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, notificationCallback, (CFStringRef)notificationString, NULL, CFNotificationSuspensionBehaviorCoalesce);
	if (enabled) {
		%init(Tweak);
	}
}