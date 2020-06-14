#import "LaunchScreenModel.h"
@interface LaunchScreenDetailViewController:UIViewController<UIScrollViewDelegate>
@property (strong) LaunchScreenModel* model;
@property (strong) UIScrollView* scrollView;
@property (strong) UIView* launchScreenView;
-(LaunchScreenDetailViewController*) initWithModel:(LaunchScreenModel*)model;
-(void)setNavigationItem;
@end