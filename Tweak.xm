#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import "UIView+draggable.h"

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
                return [UIColor blackColor];
            } else if (isLightMode) {
                return [UIColor whiteColor];
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
        
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithFrame:self.darkModeButtonView.bounds];
        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterial];
        blurView.effect = blurEffect;
        blurView.layer.masksToBounds = YES;
        blurView.layer.cornerRadius = self.darkModeButtonView.frame.size.width/2;

        [self.darkModeButtonView insertSubview:blurView atIndex:0];
        
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
    } else if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
        darkModeImage = [UIImage systemImageNamed:@"circle.lefthalf.fill"];
    }
    [self.darkModeButtonImageView setImage:darkModeImage];
}
%end
