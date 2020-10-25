#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import "UIView+draggable.h"

UITapGestureRecognizer *tapGesture;
UIView *darkModeButtonView;
UIImageView *darkModeButtonImageView;

@interface UIUserInterfaceStyleArbiter : NSObject
@property (nonatomic,readonly) long long currentStyle;
+ (id)sharedInstance;
- (void)toggleCurrentStyleWithOverrideTiming:(long long)arg1;
@end

@interface UIWindow (Private)
@property (getter=isKeyWindow,nonatomic,readonly) BOOL keyWindow;
@end

%hook UIWindow
-(void)orderFront:(id)arg1 {

        if (![NSStringFromClass([((UIWindow *)self) class]) isEqualToString:@"SBControlCenterWindow"]) {

            %orig;
            
            darkModeButtonView = [[UIView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 70, [UIScreen mainScreen].bounds.size.height - 70, 60, 60)];
            
            darkModeButtonView.hidden = NO;

            darkModeButtonView.backgroundColor = [UIColor clearColor];
            
            darkModeButtonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, darkModeButtonView.frame.size.height*0.60, darkModeButtonView.frame.size.width*0.60)];
            
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
            
                darkModeButtonImageView.tintColor = darkModeLabelColor;
            
            BOOL isDarkMode = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
            BOOL isLightMode = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight;
            UIImage *darkModeImage;
            if (isDarkMode) {
                darkModeImage = [UIImage systemImageNamed:@"circle.righthalf.fill"];
            } else if (isLightMode) {
                darkModeImage = [UIImage systemImageNamed:@"circle.lefthalf.fill"];
            }
            darkModeButtonImageView.image = darkModeImage;
            
            darkModeButtonImageView.center = CGPointMake(darkModeButtonView.frame.size.width/2, darkModeButtonView.frame.size.height/2);
            
            darkModeButtonImageView.contentMode = UIViewContentModeScaleAspectFit;
            
            [darkModeButtonView enableDragging];
            darkModeButtonView.cagingArea = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
            darkModeButtonView.shouldMoveAlongX = true;
            darkModeButtonView.shouldMoveAlongY = true;
            darkModeButtonView.handle = CGRectMake([UIScreen mainScreen].bounds.size.width - 70, [UIScreen mainScreen].bounds.size.height - 70, 60, 60);
            
            [darkModeButtonView addSubview:darkModeButtonImageView];
            
            UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithFrame:darkModeButtonView.bounds];
            UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterial];
            blurView.effect = blurEffect;
            blurView.layer.masksToBounds = YES;
            blurView.layer.cornerRadius = darkModeButtonView.frame.size.width/2;

            [darkModeButtonView insertSubview:blurView atIndex:0];
            
            tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
            [darkModeButtonView addGestureRecognizer:tapGesture];
            
            darkModeButtonView.layer.masksToBounds = YES;
            darkModeButtonView.layer.cornerRadius = darkModeButtonView.frame.size.height/2;

            [self.rootViewController.view addSubview:darkModeButtonView];

        }
        %orig;
}

%new
- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
    [[%c(UIUserInterfaceStyleArbiter) sharedInstance] toggleCurrentStyleWithOverrideTiming:2];
    AudioServicesPlaySystemSound(1521);
}

- (void)viewWillDisappear:(BOOL)animated {

    %orig;
    
    darkModeButtonView.hidden = YES;
    darkModeButtonView = nil;
    
}

%end
