#import "BBLSRootViewController.h"
#import "LaunchScreenModel.h"
#import "LaunchScreenDetailViewController.h"
#import "BBLSSettingsViewController.h"
#import "BDInfoListController.h"
@implementation BBLSRootViewController {
	NSMutableArray *_objects;
	NSMutableArray *_launchScreenModels;
}

- (void)loadView {
	[super loadView];

	_objects = [NSMutableArray array];
	_launchScreenModels=[NSMutableArray array];

	self.title = @"";
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关于" style:UIBarButtonItemStylePlain target:self action:@selector(showInfo)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"动画设置" style:UIBarButtonItemStylePlain target:self action:@selector(showSettings)];
	[self loadLaunchScreens];

}
-(void)showInfo{
	BDInfoListController* controller=[BDInfoListController new];
	UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = backItem; 
	[self.navigationController pushViewController:controller animated:YES];
}
-(void)showSettings{
	BBLSSettingsViewController* controller=[BBLSSettingsViewController new];
	UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = backItem; 
	[self.navigationController pushViewController:controller animated:YES];
}
-(void)loadLaunchScreens{
	NSBundle*mainBundle=[NSBundle mainBundle];
	NSString*bundlePath=[mainBundle bundlePath];
	NSString*launchScreensPath=[NSString stringWithFormat:@"%@/BBLaunchScreens",bundlePath];
	NSArray *lauchScreenFolders = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:launchScreensPath error:nil];

	for(NSString* lauchScreenFolder in lauchScreenFolders){
		// NSLog(@"%@",lauchScreenFolder);
		NSString*lauchScreenPath=[NSString stringWithFormat:@"%@/%@",launchScreensPath,lauchScreenFolder];
		LaunchScreenModel* model=[LaunchScreenModel new];
		[model setPath:lauchScreenPath];
		[model findNib];
		[_launchScreenModels addObject:model];
	}
}
- (void)addButtonTapped:(id)sender {
	[_objects insertObject:[NSDate date] atIndex:0];
	[self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0] ] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _launchScreenModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}

	// NSDate *date = _objects[indexPath.row];
	cell.textLabel.text = [_launchScreenModels[indexPath.row] name];
	return cell;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	[_launchScreenModels removeObjectAtIndex:indexPath.row];
	[tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	LaunchScreenModel* model=_launchScreenModels[indexPath.row];
	LaunchScreenDetailViewController* controller=[[LaunchScreenDetailViewController alloc] initWithModel:model];
	[controller setNavigationItem];
	UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = backItem; 
	[self.navigationController pushViewController:controller animated:YES];
}

@end
