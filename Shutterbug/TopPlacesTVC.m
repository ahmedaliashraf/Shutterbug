//
//  TopPlacesTVC.m
//  Shutterbug
//
//  Created by Ultimate on 11/25/15.
//  Copyright (c) 2015 Lehman College. All rights reserved.
//

#import "TopPlacesTVC.h"
#import "Place.h"
#import "PhotosFromTopPlaceTVC.h"

@interface TopPlacesTVC ()
@property (strong,nonatomic)NSMutableArray *countryWithPlaces;

@end

@implementation TopPlacesTVC
- (void)viewDidLoad{
}

- (void)setCountries:(NSArray *)countries{
    _countries = countries;
    [self.tableView reloadData];
}

- (void)setPlaces:(NSArray *)places{
    _places = places;
    [self.tableView reloadData];
}

- (void)indexPlacesWithCountry{
    if (!_countryWithPlaces) {
        _countryWithPlaces = [[NSMutableArray alloc]initWithCapacity:[self.countries count]];
    }
    for (int i = 0; i <[self.countries count]; i++) {
        NSMutableArray *countryPlace = [[NSMutableArray alloc]init];
        for (int j = 0;j<[self.places count];j++) {
            Place *place = [self.places objectAtIndex:j];
            if ([[self.countries objectAtIndex:i] isEqualToString:place.country]){
                [countryPlace addObject:place];
            }
        }
        [self.countryWithPlaces addObject:countryPlace];
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    [self indexPlacesWithCountry];
    return [self.countries count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    int rowCount = 0;
//    for (Place *place in self.places) {
//        if ([[self.countries objectAtIndex:section] isEqualToString:place.country]) {
//            rowCount++;
//        }
//    }
//    return rowCount;
    return [self.countryWithPlaces[section]count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return self.countries[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Place Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSArray *placeArray = [self.countryWithPlaces objectAtIndex:indexPath.section];
    Place *place = placeArray[indexPath.row];
    cell.textLabel.text = place.city;
    NSString * placeDetail = [NSString stringWithFormat:@"%@%@%@", place.province, @", ", place.placeID];
    cell.detailTextLabel.text = placeDetail;
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
            if ([segue.identifier isEqualToString:@"Top Place Photos"]) {
                if ([segue.destinationViewController isKindOfClass:[PhotosFromTopPlaceTVC class]]) {
                    UITableViewCell *tvCell = sender;
                    PhotosFromTopPlaceTVC *pftp = (PhotosFromTopPlaceTVC *)segue.destinationViewController;
                    NSArray *cellDetailArray = [tvCell.detailTextLabel.text componentsSeparatedByString:@", "];
                    pftp.passedPlaceID =[cellDetailArray lastObject];
                    pftp.passedCity = tvCell.textLabel.text;
                }
            }
        }
    }
    
}


@end
