

#import "NSString+AnagramCheck.h"

@implementation NSString (AnagramCheck)

-(BOOL)containsAnagramOfString:(NSString*)searchString isDistinct:(BOOL)isDistinct
{
  if (isDistinct) {
    
    if (searchString.length == self.length) {
      return [self containsAnagramOfString:searchString];
    }
    else
    {
      return NO;
    }
  }
  else
  {
    return [self containsAnagramOfString:searchString];
  }
  
}


-(BOOL)containsAnagramOfString:(NSString*)searchString
{
  NSMutableSet *targetSet = [[NSMutableSet alloc]init];
  NSMutableSet *searchSet = [[NSMutableSet alloc]init];
  NSUInteger totalCount = ( searchString.length<self.length) ? searchString.length:self.length;
  NSLog(@"Search String %@\n Target String %@\n",searchString,self);
  if ([self isEqualToString:@"rabbish"]) {
    
  }
  @autoreleasepool {
    
    for (NSUInteger index = 0; index <  totalCount; index++) {
      
      [targetSet addObject:@([self characterAtIndex:index])];
      [searchSet addObject:@([searchString characterAtIndex:index])];
    }
  }
  BOOL isPresent = [searchSet isSubsetOfSet:targetSet];
  if (isPresent == YES && searchSet.count < searchString.length) {
    return NO;
  }
  return isPresent;
  
  
}

-(BOOL)doesItContainAnagramOfString:(NSString*)searchString
{
  NSString *longWord;
  NSString *shortWord;
  if (searchString.length<self.length)
  {
    longWord = self;
    shortWord = searchString;
  }
  else
  {
    longWord = searchString ;
    shortWord = self;
  }
  return [self doesLongWord:longWord containShortWord:shortWord];
  
}
-(BOOL)doesLongWord: (NSString* )longWord containShortWord: (NSString *)shortWord {
  NSString *haystack = [longWord copy];
  NSString *needle = [shortWord copy];
  while([haystack length] > 0 && [needle length] > 0) {
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString: [needle substringToIndex:1]];
    if ([haystack rangeOfCharacterFromSet:set].location == NSNotFound) {
      return NO;
    }
    haystack = [haystack substringFromIndex: [haystack rangeOfCharacterFromSet: set].location+1];
    needle = [needle substringFromIndex: 1];
  }
  
  return YES;
}
@end
