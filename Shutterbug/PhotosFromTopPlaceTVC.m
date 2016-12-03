//
//  PhotosFromTopPlaceTVC.m
//  Shutterbug
//
//  Created by Ultimate on 11/29/15.
//  Copyright (c) 2015 Lehman College. All rights reserved.
//

#import "PhotosFromTopPlaceTVC.h"
#import "FlickrFetcher.h"
#import "ImageViewController.h"

@interface PhotosFromTopPlaceTVC ()
@property (strong,nonatomic)NSArray *photosFromPlace;
@end

@implementation PhotosFromTopPlaceTVC

- (void)setPassedPlaceID:(NSString *)passedPlaceID{
    _passedPlaceID = passedPlaceID;
    [self.tableView reloadData];
}
- (void)setPassedCity:(NSString *)passedCity{
    _passedCity = passedCity;
    [self.tableView reloadData];
}
- (void)setPhotosFromPlace:(NSArray *)photosFromPlace{
    _photosFromPlace = photosFromPlace;
    [self.tableView reloadData];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self fetchPhotosFromTopPlace];
}
- (void)fetchPhotosFromTopPlace{
    NSURL *url = [FlickrFetcher URLforPhotosInPlace:self.passedPlaceID maxResults:50];
    dispatch_queue_t fetchQ = dispatch_queue_create("flickr fetcher", NULL);
    dispatch_async(fetchQ, ^{
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        NSDictionary *placePhotoResults = [NSJSONSerialization
                                             JSONObjectWithData:jsonResults
                                             options:0
                                             error:NULL];
        
        NSArray *photos = [placePhotoResults valueForKeyPath:FLICKR_RESULTS_PHOTOS];
        // This needs to be done on the main thrread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            self.photosFromPlace = photos;
        });
    });
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
    self.title = [NSString stringWithFormat:@"Photos From: %@",self.passedCity];
    return [self.photosFromPlace count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Top Place Photo" forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *photo = self.photosFromPlace[indexPath.row];
    //Checking cases of no title,no description or both
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"View Photo"]) {
                NSDictionary *photo = self.photosFromPlace[indexPath.row];
                NSUserDefaults *userDeafults = [NSUserDefaults standardUserDefaults];
                NSArray *recentlyViewed = [userDeafults objectForKey:@"RECENT_PHOTOS"];
                NSMutableArray *mutableRecents;
                if (!recentlyViewed) {
                    mutableRecents = [[NSMutableArray alloc]init];
                }else{
                    mutableRecents = [recentlyViewed mutableCopy];
                }
                int indexOfDuplicatedPhoto = -100;
                for (int i = 0; i<[recentlyViewed count];i++) {
                    NSDictionary *dPhoto = [recentlyViewed objectAtIndex:i];
                    if ([dPhoto isEqualToDictionary:photo]) {
                        indexOfDuplicatedPhoto = i;
                        break;
                    }
                }
                if (indexOfDuplicatedPhoto != -100) {
                    [mutableRecents removeObjectAtIndex:indexOfDuplicatedPhoto];
                }
                [mutableRecents insertObject:photo atIndex:0];
                if ([mutableRecents count]>20) {
                    [mutableRecents removeLastObject];
                }
                [userDeafults setObject:mutableRecents forKey:@"RECENT_PHOTOS"];
                //NSDictionary *photo = [self syncRecentlyViewedPhotoFrom:indexPath];
                if ([segue.destinationViewController isKindOfClass:[ImageViewController class]]) {
                    [self prepareImageViewController:segue.destinationViewController toDisplayPhoto:self.photosFromPlace[indexPath.row]];//photo
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
/*- (NSDictionary *)syncRecentlyViewedPhotoFrom:(NSIndexPath *)indexPath{
    NSDictionary *photo = self.photosFromPlace[indexPath.row];
    NSUserDefaults *userDeafults = [NSUserDefaults standardUserDefaults];
    NSArray *recentlyViewed = [userDeafults objectForKey:@"RECENT_PHOTOS"];
    NSMutableArray *mutableRecents;
    if (!recentlyViewed) {
        mutableRecents = [[NSMutableArray alloc]init];
    }else{
        mutableRecents = [recentlyViewed mutableCopy];
    }
    int indexOfDuplicatedPhoto = -100;
    for (int i = 0; i<[recentlyViewed count];i++) {
        NSDictionary *dPhoto = [recentlyViewed objectAtIndex:i];
        if ([dPhoto isEqualToDictionary:photo]) {
            indexOfDuplicatedPhoto = i;
            break;
        }
    }
    if (indexOfDuplicatedPhoto != -100) {
        [mutableRecents removeObjectAtIndex:indexOfDuplicatedPhoto];
    }
    [mutableRecents insertObject:photo atIndex:0];
    if ([mutableRecents count]>20) {
        [mutableRecents removeLastObject];
    }
    [userDeafults setObject:mutableRecents forKey:@"RECENT_PHOTOS"];
    return photo;
}*/
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *photo = self.photosFromPlace[indexPath.row];
    NSUserDefaults *userDeafults = [NSUserDefaults standardUserDefaults];
    NSArray *recentlyViewed = [userDeafults objectForKey:@"RECENT_PHOTOS"];
    NSMutableArray *mutableRecents;
    if (!recentlyViewed) {
        mutableRecents = [[NSMutableArray alloc]init];
    }else{
        mutableRecents = [recentlyViewed mutableCopy];
    }
    int indexOfDuplicatedPhoto = -100;
    for (int i = 0; i<[recentlyViewed count];i++) {
        NSDictionary *dPhoto = [recentlyViewed objectAtIndex:i];
        if ([dPhoto isEqualToDictionary:photo]) {
            indexOfDuplicatedPhoto = i;
            break;
        }
    }
    if (indexOfDuplicatedPhoto != -100) {
        [mutableRecents removeObjectAtIndex:indexOfDuplicatedPhoto];
    }
    [mutableRecents insertObject:photo atIndex:0];
    if ([mutableRecents count]>20) {
        [mutableRecents removeLastObject];
    }
    [userDeafults setObject:mutableRecents forKey:@"RECENT_PHOTOS"];
    //NSDictionary *photo = [self syncRecentlyViewedPhotoFrom:indexPath];
    id detail = self.splitViewController.viewControllers[1];
    
    if ([detail isKindOfClass:[UINavigationController class]]) {
        detail = [((UINavigationController *)detail).viewControllers firstObject];
    }
    
    if ([detail isKindOfClass:[ImageViewController class]]) {
        [self prepareImageViewController:detail toDisplayPhoto:self.photosFromPlace[indexPath.row]];//photo
    }
}
@end
