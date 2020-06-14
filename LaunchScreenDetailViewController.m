#import "LaunchScreenDetailViewController.h"
#import <spawn.h>
#import <QuartzCore/QuartzCore.h>
@implementation LaunchScreenDetailViewController
-(id) initWithModel:(LaunchScreenModel*)model{
	self=[super init];
	if(!self) return self;
	_model=model;
	

	NSBundle *bundle=[NSBundle bundleWithPath:[model path]];
	NSArray *array=[bundle loadNibNamed:[model nibName] owner:self options:nil];
	_launchScreenView=array[0];

    [_launchScreenView setFrame:[self.view bounds]];
    [self.view addSubview:_launchScreenView];

	_scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.contentSize = _launchScreenView.frame.size;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.delegate = self;
    _scrollView.minimumZoomScale = 0.1;
    _scrollView.maximumZoomScale = 4.0;
    
	
	// [_scrollView addSubview:_launchScreenView];
	// [self.view addSubview:_scrollView];
    if(![model hasAnimation]) return self;
    UIImage*image=[UIImage imageNamed:@"bilibili_splash_default" inBundle:[NSBundle bundleWithPath:[model path]] compatibleWithTraitCollection:nil];
    if(image){
        UIImageView* imageView=[[UIImageView alloc] initWithFrame:[self.view bounds]];
        [imageView setImage:image];
        [imageView setContentMode:5];
        [imageView setAutoresizingMask:18];
        [self.view addSubview:imageView];
        CALayer*layer=[imageView layer];
        CABasicAnimation*animation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animation.fromValue = [NSNumber numberWithInt:0];
        animation.toValue = [NSNumber numberWithInt:1];
        animation.duration = 0.5;
        [layer addAnimation:animation forKey:@"scaleAnimationStart"];
        animation=[CABasicAnimation animationWithKeyPath:@"opacity"];
        animation.fromValue = [NSNumber numberWithInt:0];
        animation.toValue = [NSNumber numberWithInt:1];
        animation.duration = 0.5;
        [layer addAnimation:animation forKey:@"opacityAnimationStart"];
        
    }
    
    // [self setZoomScale];
	return self;
}
-(void)setNavigationItem{
    self.title = [_model name];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"替换" style:UIBarButtonItemStylePlain target:self action:@selector(changeLaunchScreen:)];
    // self.view.backgroundColor=[UIColor whiteColor];
}
- (void)setZoomScale {
    CGFloat widthScale = CGRectGetWidth(self.scrollView.frame) / CGRectGetWidth(self.launchScreenView.frame);
    CGFloat heightScale = CGRectGetHeight(self.scrollView.frame) / CGRectGetHeight(self.launchScreenView.frame);
    
    self.scrollView.minimumZoomScale = MIN(widthScale, heightScale);
    _scrollView.zoomScale=MIN(widthScale, heightScale);
}
- (void)changeLaunchScreen:(id)sender {
	NSError*error;
	NSString*bundlePath=[self getBiliBundlePath];
	NSString*containerPath=[self getBiliContainerPath];
    NSLog(@"%@",bundlePath);
    NSLog(@"%@",containerPath);
	if(!bundlePath||!containerPath){
        UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"提示" message:@"无法找到安装目录" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
        return;
    }

    [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/bilibili_splash_default@3x.png",bundlePath] error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/bilibili_splash_default@2x.png",bundlePath] error:&error];

	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[_model path] error:&error];
	if(error)NSLog(@"error:%@",error);
    for(NSString* file in files){
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@",bundlePath,file] error:nil];
        [[NSFileManager defaultManager] copyItemAtPath:[NSString stringWithFormat:@"%@/%@",[_model path],file] toPath:[NSString stringWithFormat:@"%@/%@",bundlePath,file] error:&error];
        if(error)NSLog(@"error:%@",error);
    }
	


	if(!containerPath) return;
	if(@available(iOS 13.0, *)){
		[[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/Library/SplashBoard/Snapshots",containerPath] error:&error];
		if(error)NSLog(@"error:%@",error);
	}
	else{
		[[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/Library/Caches/Snapshots",containerPath] error:&error];
		if(error)NSLog(@"error:%@",error);
	}

	pid_t pid;
    const char *argv[] = {"sh", "-c", "bili-universal", NULL};
    
    int status = posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)argv, NULL);
    if (status == 0) {
        if (waitpid(pid, &status, 0) == -1) {
            perror("waitpid");
        }
    }

    [self saveConf];


    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"提示" message:@"替换完毕" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _launchScreenView;
}
- (void)saveConf{
    NSString*prefPath=@"/var/mobile/Library/Preferences/com.brend0n.changebilibiliLaunchScreen.plist";
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
    if(!prefs) prefs=[NSMutableDictionary new];
    prefs[@"nibName"]=[[self model] nibName];
    prefs[@"hasAnimation"]=[NSNumber numberWithBool:[[self model] hasAnimation]];
    [prefs writeToFile:prefPath atomically:YES];

}
-(NSString*)getBiliBundlePath{
	NSString *bundlePath=@"/var/containers/Bundle/Application";
    NSArray *applications = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bundlePath error:nil];
    for(id application in applications){
        NSString* metadataPath=[NSString  stringWithFormat:@"%@/%@/iTunesMetadata.plist",bundlePath,application];
        NSMutableDictionary *metadata = [[NSMutableDictionary alloc] initWithContentsOfFile:metadataPath];
        if([metadata[@"softwareVersionBundleId"] isEqualToString:@"tv.danmaku.bilianime"]){
            return [NSString stringWithFormat:@"%@/%@/bili-universal.app",bundlePath,application];
        }
    }
    return nil;
}
-(NSString*)getBiliContainerPath{
	NSString *containerPath=@"/var/mobile/Containers/Data/Application";
    NSArray *applications = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:containerPath error:nil];
    for(id application in applications){
        NSString* metadataPath=[NSString  stringWithFormat:@"%@/%@/.com.apple.mobile_container_manager.metadata.plist",containerPath,application];
        NSMutableDictionary *metadata = [[NSMutableDictionary alloc] initWithContentsOfFile:metadataPath];
        if([metadata[@"MCMMetadataIdentifier"] isEqualToString:@"tv.danmaku.bilianime"]){
            return [NSString stringWithFormat:@"%@/%@",containerPath,application];
        }
    }
    return nil;
}
@end