
#define kWebDataInconsistencyDomain @"kWebDataInconsistencyDomain"
#define kWebDataInconsistencyDomainErrorCode1 4444451

#import "TMCoreDataUtility.h"
#import "TMConstants.h"
#import "TMReview.h"

@interface TMCoreDataUtility()
@property(nonatomic,strong)NSManagedObjectContext *managedObjectContext;
@end

@implementation TMCoreDataUtility

@synthesize managedObjectContext;


-(id)init
{
  return [self initWithManagedContext:nil];
}
-(id)initWithManagedContext:(NSManagedObjectContext*)moc
{
  
  self = [super init];
  if (self) {
    managedObjectContext = moc;
    if (moc == nil) {
      return nil;
    }
    
  }
  return self;
}




-(NSArray*)allDistinctValuesOfProperty:(NSString*)propertyName  withPredicate:(NSPredicate*)predicate inEntityClass:(Class)className withSortDescriptors:(NSArray*)sortDescriptors
{
  
  NSEntityDescription *entity = [NSEntityDescription  entityForName:NSStringFromClass(className) inManagedObjectContext:managedObjectContext];
  NSFetchRequest *request = [[NSFetchRequest alloc]init];
  [request setEntity:entity];
  [request setPredicate:predicate];
  [request setResultType:NSDictionaryResultType];
  [request setReturnsDistinctResults:YES];
  [request setPropertiesToFetch:[NSArray arrayWithObject:propertyName] ];
  [request setSortDescriptors:sortDescriptors];
  
  // Execute the fetch.
  NSError *error;
  NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
  NSAssert1(objects, @"Contents not present %s",__func__);
  return objects;
  
}

-(NSDictionary*)distinctDictionaryOfProperty:(NSString*)propertyName  withPredicate:(NSPredicate*)predicate inEntityClass:(Class)className withError:(NSError**)error
{
  NSArray *list = [self allDistinctValuesOfProperty:propertyName withPredicate:predicate inEntityClass:className withSortDescriptors:nil];
  
  if (list.count == 1   ) {
    return [list objectAtIndex:0];
  }
  else{
    // NSDictionary *errorInfo = [[NSDictionary alloc]initWithObjectsAndKeys:@"There can be no more than one record woth the same ID",NSLocalizedDescriptionKey, nil];
    //(*error) = [[NSError alloc]initWithDomain:kWebDataInconsistencyDomain code:kWebDataInconsistencyDomainErrorCode1 userInfo:errorInfo];
    return nil;
  }
  
}

-(NSArray*)allDistinctValuesOfPropertyInAssetAttribute:(NSString*)propertyName
{
  
  NSEntityDescription *entity = [NSEntityDescription  entityForName:@"A3AssetAttributeType" inManagedObjectContext:managedObjectContext];
  NSFetchRequest *request = [[NSFetchRequest alloc]init];
  [request setEntity:entity];
  [request setResultType:NSDictionaryResultType];
  [request setReturnsDistinctResults:YES];
  [request setPropertiesToFetch:[NSArray arrayWithObject:propertyName] ];
  
  
  // Execute the fetch.
  NSError *error;
  NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
  NSAssert1(objects, @"Contents not present %s",__func__);
  return objects;
  
}


-(NSArray*)allEntitiesOfClass:(Class)className
{
  
  
  NSArray *entities =  [self allEntitiesOfClass:className withPredicate:nil withSortDescriptorList:nil];
  
  
  
  return entities;
  
  
}

-(NSArray*)allEntitiesOfClass:(Class)className withPredicate:(NSPredicate*)predicate withSortDescriptorList:(NSArray*)sortDescriptorList withFetchOffset:(NSUInteger)fetchOffset withFetchLimit:(NSUInteger)fetchLimit
{
  NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass( className)  inManagedObjectContext:managedObjectContext];
  
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:NSStringFromClass( className) ];
  
  if (fetchOffset > 0 ) {
    fetchRequest.fetchOffset = fetchOffset;
  }
  if (fetchLimit > 0 ) {
    fetchRequest.fetchLimit = fetchLimit;
  }
  [fetchRequest setEntity:entityDescription];
  if (predicate) {
    [fetchRequest setPredicate:predicate];
  }
  if (sortDescriptorList) {
    [fetchRequest setSortDescriptors:sortDescriptorList];
  }
  NSError *error = nil;
  NSArray *entities =  [managedObjectContext executeFetchRequest:fetchRequest error:&error];
  if (!entities) {
    ALog(@"Fetch error in %s: %@",__func__, error);
  }
  
  
  
  return entities;
  
}
-(NSArray*)allEntitiesOfClass:(Class)className withPredicate:(NSPredicate*)predicate withSortDescriptorList:(NSArray*)sortDescriptorList
{
  
  NSArray *entities = [self allEntitiesOfClass:className withPredicate:predicate withSortDescriptorList:sortDescriptorList withFetchOffset:0 withFetchLimit:0];
  return entities;
  
  
}


-(NSManagedObject*)itemWithPredicate:(NSPredicate*)predicate withEntityType:(Class)className
{
  
  
  NSArray *listOfItems = [self allEntitiesOfClass:className withPredicate:predicate withSortDescriptorList:nil];
  NSAssert(listOfItems.count <= 1, @"There can maximum be only one %@ with same ID ",NSStringFromClass(className));
  NSManagedObject *managedObject = nil;
  if (listOfItems.count == 1) {
    
    managedObject =   [listOfItems  objectAtIndex:0];
    
    
  }
  return  managedObject;
  
}


-(NSManagedObject*)entityWithProperty:(NSString*)propertyName withValue:(NSString*)propertyValue withEntityType:(Class)className
{
  NSPredicate  *predicateForAbstractItem =  [NSPredicate predicateWithFormat:@"%K == %@",propertyName,propertyValue];
  
  
  NSArray *listOfItems = [self allEntitiesOfClass:className withPredicate:predicateForAbstractItem withSortDescriptorList:nil];
  
  NSManagedObject *managedObject = nil;
  if (listOfItems.count == 1) {
    
    managedObject =   [listOfItems  objectAtIndex:0];
    
    
  }
  return  managedObject;
}
/* Delete all records for the entity name passed */
- (void) coreDataDeleteAllFromEntityName: (NSString *) entityName withPredicate:(NSPredicate*)predicate
{
  
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
  
  if (predicate != nil) {
    request.predicate = predicate;
  }
  [request setEntity:entity];
  
  NSError *error = nil;
  NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
  
  if (!results) {
    ALog(@" Fetch error in coreDataDeleteAllFromEntityName: %@", error);
  }
  
  
  
  //Delete the fetched results
  for (NSManagedObject *record in results)
  {
    [managedObjectContext deleteObject:record];
    
    
  }
  //[self.coreDataContext processPendingChanges];
  //NSError *saveError = nil;
  
  if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
       ALog(@"%@ \nUnresolved error %@\n %@",[error localizedDescription], error, [error userInfo]);
    abort();
  }
  
}
-(NSArray*)allEntitiesOfTMReviewWithSearchText:(NSString*)searchText
{
  
  NSPredicate *predicateSearch = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary * bindings) {
    TMReview *reviewInfo = evaluatedObject;
    
   DLog(@"%@",reviewInfo.text)
    if ([reviewInfo.text isEqualToString:searchText])
      return YES;
    return NO;
  }];
  
  return [self allEntitiesOfClass:[TMReview class] withPredicate:predicateSearch withSortDescriptorList:nil];
  
}

@end
