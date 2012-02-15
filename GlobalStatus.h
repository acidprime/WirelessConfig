//
//  GlobalStatus.h
//  PasswordUtility
//
//  Created by Zack Smith on 11/29/11.
//  Copyright 2011 318. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Constants.h"


@interface GlobalStatus : NSObject {
	
	//NSArrays
	NSMutableArray *globalStatusArray;
	
	// Standard iVars
	NSBundle *mainBundle;
	NSDictionary *settings;
	BOOL debugEnabled;
	

}

- (void) notifRequestStatusUpdateNotification:(NSNotification *) notification;
- (void) notifStatusUpdateNotification:(NSNotification *) notification;
@end
