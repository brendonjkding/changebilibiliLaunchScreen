@interface LaunchScreenModel:NSObject
@property (strong) NSString* name;
@property (strong) NSString* path;
@property (strong) NSString* nibName;
@property BOOL hasAnimation;
-(void)findNib;
@end