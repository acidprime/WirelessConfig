//
//  GlobalStatus.m
//  PasswordUtility
//
//  Created by Zack Smith on 11/29/11.
//  Copyright 2011 318 All rights reserved.
//

#import "GlobalStatus.h"
#import "Constants.h"


@implementation GlobalStatus

#pragma mark Method Overides
-(id)init
{
    [ super init];
	NSLog(@"Init OK Global Status Controller Initialized");
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifRequestStatusUpdateNotification:) 
                                                 name:RequestStatusUpdateNotification
                                               object:nil];
	
	// Plugin -> GlobalStatus
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifStatusUpdateNotification:) 
                                                 name:StatusUpdateNotification
                                               object:nil];
	
	if (!globalStatusArray) {
		globalStatusArray = [[NSMutableArray alloc] init];
	}
	// And Return
	if (!self) return nil;
    return self;
}


-(void)dealloc 
{ 
	// Remove observer for window close
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	//[self.globalStatusArray release];
	[super dealloc]; 
}

#pragma mark Notifications Methods


- (void) notifRequestStatusUpdateNotification:(NSNotification *) notification
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSLog(@"DEBUG: Request Status Update Notification Received");
	NSMutableDictionary *globalStatusUpdate = [[NSMutableDictionary alloc] init];
	
	[ globalStatusUpdate setValue:globalStatusArray forKey:@"globalStatusArray"];
	
	// Post the current Data to our NSTable via userInfo
	[[NSNotificationCenter defaultCenter]
	 postNotificationName:ReceiveStatusUpdateNotification
	 object:self
	 userInfo:globalStatusUpdate];
	NSLog(@"DEBUG: Recieved Request to Send Complete Global Status Array");
	[pool release];
}

- (void) notifStatusUpdateNotification:(NSNotification *) notification
{
	// Add the status item to the Array
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSLog(@" (notifStatusUpdateNotification) Status Update Notification Received");
	
	NSDictionary *globalStatusUpdate = [notification userInfo];
	
	NSLog(@"DEBUG: (notifStatusUpdateNotification) Recieved New Global Status Array Item: %@",globalStatusUpdate);

	[globalStatusArray addObjectsFromArray:[globalStatusUpdate objectForKey:@"globalStatusArray"]];
	
	 NSLog(@"DEBUG: (notifStatusUpdateNotification) Global Array Status Update: %@",globalStatusArray);
	
	// Post the current Data to our NSTable via userInfo
	[[NSNotificationCenter defaultCenter]
	 postNotificationName:ReceiveStatusUpdateNotification
	 object:self
	 userInfo:globalStatusUpdate];
	
	 [pool release];
}


@end
