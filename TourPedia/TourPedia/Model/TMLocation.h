//
//  TMLocation.h
//  PlacesReview
//
//  Created by devKrishnan on 09/06/15.
//  Copyright (c) 2015 Sample. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TMFilterRequest, TMPlace;

@interface TMLocation : NSManagedObject

@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *hasPlaces;
@property (nonatomic, retain) NSSet *partOfFilterRequests;
@end

@interface TMLocation (CoreDataGeneratedAccessors)

- (void)addHasPlacesObject:(TMPlace *)value;
- (void)removeHasPlacesObject:(TMPlace *)value;
- (void)addHasPlaces:(NSSet *)values;
- (void)removeHasPlaces:(NSSet *)values;

- (void)addPartOfFilterRequestsObject:(TMFilterRequest *)value;
- (void)removePartOfFilterRequestsObject:(TMFilterRequest *)value;
- (void)addPartOfFilterRequests:(NSSet *)values;
- (void)removePartOfFilterRequests:(NSSet *)values;

@end
