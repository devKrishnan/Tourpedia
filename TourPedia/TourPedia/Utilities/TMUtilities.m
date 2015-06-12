//
//  TMUtilities.m
//  PlacesReview
//
//  Created by devKrishnan on 09/06/15.
//  Copyright (c) 2015 Sample. All rights reserved.
//
//http://stackoverflow.com/questions/19851510/convert-any-data-type-into-nsdata-and-back-again
#import "TMUtilities.h"
#import "NSString+Hashes.h"
#import "TMConstants.h"
#import "PDKeychainBindings.h"

@implementation TMUtilities
+(NSString*)uniqueIDForObject:(NSObject*)object
{
  
  NSString *md5Digest = [[NSString stringWithFormat:@"%@", object] md5];
  
  NSLog(@"object %@\n%@",object,md5Digest);
  
  return  md5Digest;
}
+(NSString*)imageNameForSource:(NSString*)source
{
  if ([source isEqualToString:@"Foursquare"]) {
    return @"foursquare";
  }
  else if ([source isEqualToString:@"Facebook"]) {
    return @"Facebook-32";
  }
  else if ([source isEqualToString:@"GooglePlaces"]) {
    return @"Google_Places";
  }
  else if ([source isEqualToString:@"Booking"]) {
    return @"Booking";
  }
  else
  {
    NSAssert1(NO, @"Not supported source for reviews %s",__func__);
    return @"";
  }
}
//http://stackoverflow.com/questions/516443/nsmanagedobjectid-into-nsdata
#define ActiveFetchRequestObjectIDKey @"TMActiveFetchRequestObjectIDKey"
+(NSManagedObjectID*)objectIDOfLastFilterRequestForManagedObjectContext:(NSManagedObjectContext*)moc
{
  
  
  
  PDKeychainBindings *sharedBindings = [PDKeychainBindings sharedKeychainBindings];
  NSString *uriDataString = [sharedBindings objectForKey:ActiveFetchRequestObjectIDKey];
  if (uriDataString == nil) {
    return nil;
  }
  // NSData *uriData = [uriDataString dataUsingEncoding:NSUTF8StringEncoding];
  //NSURL *uri = [NSKeyedUnarchiver unarchiveObjectWithData:uriData];
  
  NSURL *uri = [[NSURL alloc]initWithString:uriDataString];
  
  NSManagedObjectID *objectID = [moc.persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
  
  return objectID;
  
}
+(void)setFilterRequest:(NSManagedObjectID*)managedObjectID
{
  PDKeychainBindings *sharedBindings = [PDKeychainBindings sharedKeychainBindings];
  
  NSURL *uri = [managedObjectID URIRepresentation];


  [sharedBindings setObject:uri.absoluteString forKey:ActiveFetchRequestObjectIDKey];
}
@end
