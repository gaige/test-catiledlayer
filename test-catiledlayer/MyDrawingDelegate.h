//
//  MyDrawingDelegate.h
//  test-catiledlayer
//
//  Created by Gaige B. Paulsen on 4/9/20.
//  Copyright © 2020 Gaige B. Paulsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyDrawingDelegate : NSObject<CALayerDelegate> {
    atomic_flag waitingForDraw;
    atomic_int drawers;
    int32_t maxDrawers;
}
@property(retain) CATiledLayer *tiledLayer;
@property(retain) dispatch_queue_t drawSynchronizeQueue;
@end

NS_ASSUME_NONNULL_END
