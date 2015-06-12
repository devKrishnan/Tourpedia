

#import "NSString+UniqueCharactersSet.h"

@implementation NSString (UniqueCharactersSet)
-(NSSet*)uniqueCharacterSet
{
  NSMutableSet *uniqueCharSet = [[NSMutableSet alloc]init];
  @autoreleasepool {
    
    for (NSUInteger index = 0; index <  self.length; index++) {
      
      [uniqueCharSet addObject:@([self characterAtIndex:index])];
    }
  }
  return uniqueCharSet;
}
@end
