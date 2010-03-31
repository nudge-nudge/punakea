//
//  PATagCloudProtocols.h
//  punakea
//
//  Created by hoffart on 30.03.10.
//  Copyright 2010 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PATagCloud;

@protocol PATagCloudDataSource <NSObject>

- (NSUInteger)numberOfTagsInTagCloud:(PATagCloud*)aTagCloud;
- (NNTag*)tagCloud:(PATagCloud*)aTagCloud tagForIndex:(NSUInteger)index;
- (BOOL)tagCloud:(PATagCloud*)aTagCloud containsTag:(NNTag*)aTag;
- (NNTag*)currentBestTagInTagCloud:(PATagCloud*)aTagCloud;

@end

@protocol PATagCloudDelegate <NSObject>

@optional
- (void)taggableObjectsHaveBeenDropped:(NSArray*)objects;
- (BOOL)isWorking;
- (void)makeControlledViewFirstResponder;
- (IBAction)tagButtonClicked:(PATagButton*)button;

@end
