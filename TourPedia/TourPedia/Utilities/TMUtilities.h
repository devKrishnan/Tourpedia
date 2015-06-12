//
//  TMUtilities.h
//  PlacesReview
//
//  Created by devKrishnan on 09/06/15.
//  Copyright (c) 2015 Sample. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@interface TMUtilities : NSObject
//Utilities
+(NSString*)uniqueIDForObject:(NSObject*)object;
+(NSString*)imageNameForSource:(NSString*)source;
+(NSManagedObjectID*)objectIDOfLastFilterRequestForManagedObjectContext:(NSManagedObjectContext*)moc;
+(void)setFilterRequest:(NSManagedObjectID*)managedObjectID;
@end
