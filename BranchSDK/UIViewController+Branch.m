//
//  UIViewController+Branch.m
//  Branch-SDK
//
//  Created by Edward Smith on 11/16/17.
//  Copyright © 2017 Branch. All rights reserved.
//

#import "UIViewController+Branch.h"

@implementation UIViewController (Branch)

+ (UIWindow *_Nullable)bnc_currentWindow {
    UIWindow *foundWindow = nil;
    
    // Directly using the Scene API for iOS 13 and later
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        // Ensure the scene is in the foreground and active
        if (scene.activationState == UISceneActivationStateForegroundActive) {
            // Check if the scene is of type UIWindowScene for window management
            if ([scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                for (UIWindow *window in windowScene.windows) {
                    if (!window.isHidden && window.isKeyWindow && window.rootViewController) {
                        foundWindow = window;
                        break;
                    }
                }
            }
        }
        if (foundWindow) {
            break;
        }
    }
    
    return foundWindow;
}

+ (UIViewController*_Nullable) bnc_currentViewController {
    UIWindow *window = [UIViewController bnc_currentWindow];
    return [window.rootViewController bnc_currentViewController];
}

- (UIViewController*_Nonnull) bnc_currentViewController {
    if ([self isKindOfClass:[UINavigationController class]]) {
        return [((UINavigationController *)self).visibleViewController bnc_currentViewController];
    }

    if ([self isKindOfClass:[UITabBarController class]]) {
        return [((UITabBarController *)self).selectedViewController bnc_currentViewController];
    }

    if ([self isKindOfClass:[UISplitViewController class]]) {
        return [((UISplitViewController *)self).viewControllers.lastObject bnc_currentViewController];
    }

    if ([self isKindOfClass:[UIPageViewController class]]) {
        return [((UIPageViewController*)self).viewControllers.lastObject bnc_currentViewController];
    }

    if (self.presentedViewController != nil && !self.presentedViewController.isBeingDismissed) {
        return [self.presentedViewController bnc_currentViewController];
    }

    return self;
}

@end

__attribute__((constructor)) void BNCForceUIViewControllerCategoryToLoad(void) {
    //  Nothing here, but forces linker to load the category.
}
