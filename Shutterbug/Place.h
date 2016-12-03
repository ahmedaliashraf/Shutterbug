//
//  Place.h
//  Shutterbug
//
//  Created by Ultimate on 11/28/15.
//  Copyright (c) 2015 Lehman College. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Place : NSObject
@property (strong,nonatomic) NSString *city;
@property (strong,nonatomic) NSString *province;
@property (strong,nonatomic) NSString *country;
@property (strong,nonatomic) NSString *placeID;
@property (nonatomic) BOOL assignedToRow;
@property (nonatomic) NSInteger section;
@end
