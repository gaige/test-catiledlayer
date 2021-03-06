//
//  CATiledLayerTestView.h
//  test-catiledlayer
//
//  Created by Gaige B. Paulsen on 4/9/20.
//  Copyright © 2020 Gaige B. Paulsen. All rights reserved.
//

#include <stdatomic.h>
#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "MyDrawingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface CATiledLayerTestView: NSView<CALayerDelegate> {
    atomic_flag waitingForDraw;
    atomic_int drawers;
    int32_t maxDrawers;
}
@property(retain) CATiledLayer *tiledLayer;
@property(retain) dispatch_queue_t drawSynchronizeQueue;
@property(retain) MyDrawingDelegate *tlDelegate;
@end

NS_ASSUME_NONNULL_END
