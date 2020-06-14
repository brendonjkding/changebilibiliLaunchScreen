#import <notify.h>
#import "LaunchScreenModel.h"
#import "LaunchScreenDetailViewController.h"
BOOL enabled;

BOOL loadPref(){
	NSLog(@"loadPref..........");
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.brend0n.changebilibiliLaunchScreen.plist"];
	if(!prefs) enabled=NO;
	else enabled=[prefs[@"enabled"] boolValue];
	return enabled;
}
@interface BFCLaunchSplashViewController:UIViewController
@end
%group hook
%hook BFCLaunchSplashViewController
-(void)loadView{
	NSLog(@"BFCLaunchSplashViewController loadView");
	%orig;
	[[self.view superview] setHidden:YES];
	
}
%end
%hook BiliWindow
- (void)setRootViewController:(id)arg1{
	NSLog(@"setRootViewController:%@",arg1);

	NSString*prefPath=@"/var/mobile/Library/Preferences/com.brend0n.changebilibiliLaunchScreen.plist";
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
    BOOL hasAnimation=[prefs[@"hasAnimation"] boolValue];


	LaunchScreenModel *model=[LaunchScreenModel new];
	[model setPath:[[NSBundle mainBundle] bundlePath]];
    [model setNibName:prefs[@"nibName"]];
    [model setHasAnimation:hasAnimation];

	LaunchScreenDetailViewController* controller=[[LaunchScreenDetailViewController alloc] initWithModel:model];
	%orig(controller);
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			%orig(arg1);
	      	
	 	});
	return;
}
%end
%end
%ctor{
	if(!loadPref()) return;
	NSLog(@"ctor: Tweak");
	%init(hook);
	
}
