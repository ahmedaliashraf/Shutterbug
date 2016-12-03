//
//  TopPlacesByCountryTVC.m
//  Shutterbug
//
//  Created by Ultimate on 11/25/15.
//  Copyright (c) 2015 Lehman College. All rights reserved.
//

#import "TopPlacesByCountryTVC.h"
#import "FlickrFetcher.h"
#import "Place.h"

@interface TopPlacesByCountryTVC ()

@end

@implementation TopPlacesByCountryTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchPlaces];
}


- (IBAction)fetchPlaces
{
    NSURL *url = [FlickrFetcher URLforTopPlaces];
    
    // create a new queue to do the fetching
    dispatch_queue_t fetchQ = dispatch_queue_create("flickr fetcher", NULL);
    
    // dispatch the fetch on this queue
    dispatch_async(fetchQ, ^{
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        NSDictionary *propertyListResults = [NSJSONSerialization
                                             JSONObjectWithData:jsonResults
                                             options:0
                                             error:NULL];
        
        NSArray *fullPlacesResults = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PLACES];
        NSMutableArray *placesInitial = [[NSMutableArray alloc]init];
        NSMutableArray *countriesInitial = [[NSMutableArray alloc]init];
        for (NSDictionary *placeResult in fullPlacesResults){
            NSString *fullPlaceNames = [placeResult valueForKey:@"_content"];
            NSArray *fullPlaceNamesArray = [fullPlaceNames componentsSeparatedByString:@", "];
            NSString *city = [fullPlaceNamesArray firstObject];
            NSString *province = [fullPlaceNamesArray objectAtIndex:1];
            NSString *country = [fullPlaceNamesArray lastObject];
            NSString *placeID = [placeResult valueForKey:@"place_id"];
            Place *place = [[Place alloc]init];
            place.city = city;
            if (![province isEqualToString:country]){
                place.province = province;
            }
            place.country = country;
            place.placeID = placeID;
            [placesInitial addObject:place];
            [countriesInitial addObject:country];
        }
        NSOrderedSet *orderedCountries = [NSOrderedSet orderedSetWithArray:countriesInitial];
        NSArray *orderedCountriesArray = [orderedCountries array];
        NSArray *countries = [orderedCountriesArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        NSArray *places = [placesInitial sortedArrayUsingSelector:@selector(compare:)];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            self.places = places;
            self.countries = countries;
            [self.tableView reloadData];
        });
    });
}
@end
