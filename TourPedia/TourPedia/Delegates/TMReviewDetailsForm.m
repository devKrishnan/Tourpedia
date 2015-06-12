//
//  TMReviewDetailsForm.m
//  PlacesReview
//
//  Created by devKrishnan on 09/06/15.
//  Copyright (c) 2015 Sample. All rights reserved.
//

#import "TMReviewDetailsForm.h"
#import "TMConstants.h"


@implementation TMReviewDetailsForm

- (NSArray *)fields
{
  
  
 

  return  @[
            @{FXFormFieldType:FXFormFieldTypeLongText, FXFormFieldKey: @"text",FXFormFieldTitle:@"Review",@"textLabel.font": UIAppFontGillSansLightWithSize(14),@"textView.font":UIAppFontGillSansWithSize(17),@"textView.editable":@NO,FXFormFieldSortable:@YES},
        
            
            ];
  
  
  
  
}

@end
