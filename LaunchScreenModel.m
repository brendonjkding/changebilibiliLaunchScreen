#import "LaunchScreenModel.h"
@interface LaunchScreenModel()

@end
@implementation LaunchScreenModel
-(void)findNib{
	_name=[_path lastPathComponent];
	_hasAnimation=NO;
	NSError*error;
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_path error:&error];
	for(NSString* file in files){
		if([[file pathExtension] isEqualToString:@"nib"]){
			_nibName=[file stringByDeletingPathExtension];
		}
		if([file containsString:@"bilibili_splash_default"]){
			_hasAnimation=YES;
		}
	}
}
@end