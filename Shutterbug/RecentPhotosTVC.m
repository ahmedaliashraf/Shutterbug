//
//  RecentPhotosTVC.m
//  Shutterbug
//
//  Created by Ultimate on 11/29/15.
//  Copyright (c) 2015 Lehman College. All rights reserved.
//

#import "RecentPhotosTVC.h"
#import "FlickrFetcher.h"
#import "ImageViewController.h"

@interface RecentPhotosTVC ()
@property (strong,nonatomic)NSMutableArray *recentArray;
@end

@implementation RecentPhotosTVC
- (void)setRecentArray:(NSMutableArray *)recentArray{
    _recentArray = recentArray;
    [self.tableView reloadData];
}
- (void)viewDidLoad{
    //[[NSUserDefaults standardUserDefaults]synchronize];
    self.recentArray = [[[NSUserDefaults standardUserDefaults]valueForKey:@"RECENT_PHOTOS"] mutableCopy];
}
- (void)viewWillAppear:(BOOL)animated{
    //[[NSUserDefaults standardUserDefaults]synchronize];
    self.recentArray = [[[NSUserDefaults standardUserDefaults]valueForKey:@"RECENT_PHOTOS"] mutableCopy];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[NSUserDefaults standardUserDefaults]valueForKey:@"RECENT_PHOTOS"]count];;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Recent Photo Cell" forIndexPath:indexPath];
    if (!self.recentArray) {
        self.recentArray = [[[NSUserDefaults standardUserDefaults]valueForKey:@"RECENT_PHOTOS"] mutableCopy];
    }
    // Configure the cell...
    NSDictionary *photo = self.recentArray[indexPath.row];
    if ([[photo valueForKeyPath:FLICKR_PHOTO_TITLE] length] !=0 && [[photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] length] != 0) {
        cell.textLabel.text = [photo valueForKeyPath:FLICKR_PHOTO_TITLE];
        cell.detailTextLabel.text = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    } else if ([[photo valueForKeyPath:FLICKR_PHOTO_TITLE] length] ==0 && [[photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] length] != 0){
        cell.textLabel.text = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        cell.detailTextLabel.text = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    } else if ([[photo valueForKeyPath:FLICKR_PHOTO_TITLE] length] !=0 && [[photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] length] == 0){
        cell.textLabel.text = [photo valueForKeyPath:FLICKR_PHOTO_TITLE];
        cell.detailTextLabel.text = [photo valueForKeyPath:FLICKR_PHOTO_TITLE];
    }else if ([[photo valueForKeyPath:FLICKR_PHOTO_TITLE] length] == 0 && [[photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] length] == 0){
        cell.textLabel.text = @"Unknown";
        cell.detailTextLabel.text = @"Unknown";
    }
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Recent Photos Segue"]) {
                if ([segue.destinationViewController isKindOfClass:[ImageViewController class]]) {
                    NSDictionary *photo = self.recentArray[indexPath.row];
                    [self.recentArray removeObjectAtIndex:indexPath.row];
                    [self.recentArray insertObject:photo atIndex:0];
                    NSUserDefaults *userDeafults = [NSUserDefaults standardUserDefaults];
                    [userDeafults setObject:self.recentArray forKey:@"RECENT_PHOTOS"];
                    [self prepareImageViewController:segue.destinationViewController toDisplayPhoto:photo];
                }
            }
        }
    }
}
- (void)prepareImageViewController:(ImageViewController *)ivc toDisplayPhoto:(NSDictionary *)photo
{
    ivc.imageURL = [FlickrFetcher URLforPhoto:photo format:FlickrPhotoFormatLarge];
    ivc.title = [photo valueForKeyPath:FLICKR_PHOTO_TITLE];
}
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *photo = self.recentArray[indexPath.row];
    [self.recentArray removeObjectAtIndex:indexPath.row];
    [self.recentArray insertObject:photo atIndex:0];
    NSUserDefaults *userDeafults = [NSUserDefaults standardUserDefaults];
    [userDeafults setObject:self.recentArray forKey:@"RECENT_PHOTOS"];
    id detail = self.splitViewController.viewControllers[1];
    
    if ([detail isKindOfClass:[UINavigationController class]]) {
        detail = [((UINavigationController *)detail).viewControllers firstObject];
    }
    
    if ([detail isKindOfClass:[ImageViewController class]]) {
        [self prepareImageViewController:detail toDisplayPhoto:photo];
    }
}

@end
