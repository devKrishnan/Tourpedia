
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TMCoreDataUtility : NSObject
-(id)initWithManagedContext:(NSManagedObjectContext*)moc;

-(NSManagedObject*)itemWithPredicate:(NSPredicate*)predicate withEntityType:(Class)className;

//This should be allowed only for properties in the abstract entity class
-(NSManagedObject*)entityWithProperty:(NSString*)propertyName withValue:(NSString*)propertyValue withEntityType:(Class)className;

-(NSArray*)allEntitiesOfClass:(Class)className withPredicate:(NSPredicate*)predicate withSortDescriptorList:(NSArray*)sortDescriptorList withFetchOffset:(NSUInteger)fetchOffset withFetchLimit:(NSUInteger)fetchLimit;
-(NSArray*)allEntitiesOfClass:(Class)className withPredicate:(NSPredicate*)predicate withSortDescriptorList:(NSArray*)sortDescriptorList;
-(NSArray*)allEntitiesOfClass:(Class)className;
-(NSArray*)allEntitiesOfTMReviewWithSearchText:(NSString*)searchText;
-(NSArray*)allDistinctValuesOfPropertyInAssetAttribute:(NSString*)propertyName;
-(NSArray*)allDistinctValuesOfProperty:(NSString*)propertyName  withPredicate:(NSPredicate*)predicate inEntityClass:(Class)className withSortDescriptors:(NSArray*)sortDescriptors;
-(NSDictionary*)distinctDictionaryOfProperty:(NSString*)propertyName  withPredicate:(NSPredicate*)predicate inEntityClass:(Class)className withError:(NSError**)error;
-(void)coreDataDeleteAllFromEntityName: (NSString *) entityName withPredicate:(NSPredicate*)predicate
;

@end
