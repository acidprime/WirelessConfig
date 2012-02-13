//
//  TableController.m
//  WirelessConfig
//
//  Created by Zack Smith on 8/17/11.
//  Copyright 2011 318. All rights reserved.
//

#import "TableController.h"
#import "ConfigIconCell.h"
#import "Constants.h"


@implementation TableController

# pragma mark Method Overrides

- (id)init
{	
	[super init];
	[self readInSettings];
	if(debugEnabled)NSLog(@"DEBUG: (init) Registering for ReceiveStatusUpdateNotification");
	//ReceiveStatusUpdateNotification
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTableBufferNow:) 
                                                 name:ReceiveStatusUpdateNotification
                                               object:nil];
	// And Return
	if (!self) return nil;
    return self;
}

- (void)awakeFromNib {
	// StatusUpdateNotification
	// Register for notifications on Global Status Array updates
	// Ask for an update to the global status array on init
	
	if(debugEnabled)NSLog(@"DEBUG: (awakeFromNib) Configuration Table Requesting Status Update from controller");
	
	[[NSNotificationCenter defaultCenter]
	 postNotificationName:RequestStatusUpdateNotification
	 object:self];

	// Hide the Dock
	ConfigIconCell *statusIconCell = [[ConfigIconCell alloc] init];
	
	[discriptionCol setDataCell:statusIconCell];
	
	// Set the button title to blank
	[toggleSummaryPredicateButton setTitle:@""];
	
	// Reload data
	[tableView reloadData];

}

-(void)dealloc 
{ 
	// Remove observer for window close
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	// Release Array buffer
	[aBuffer release];
	//[self.globalStatusArray release];
	[super dealloc]; 
}

# pragma mark -
# pragma mark Notification Observered Methods
# pragma mark -

// Need to update for panel close
- (void)windowClosing:(NSNotification*)aNotification {
	if(debugEnabled)NSLog(@"DEBUG: (windowClosing) Received window close notification");
	if (aBuffer) {
		if(debugEnabled)NSLog(@"DEBUG: (windowClosing)  Clearing the current table buffer");
		[aBuffer removeAllObjects];
	}
}


# pragma mark -
# pragma mark NSTableView Methods
# pragma mark -

- (NSMutableArray*)aBuffer
{
	return aBuffer;
}


- (id)tableView:(NSTableView *)tableView 
objectValueForTableColumn:(NSTableColumn *)tableColumn 
			row:(NSInteger)row{
	

	if (![aBuffer count]) {
		NSLog(@"DEBUG: (tableView) No entries, setting predicate to default");
		statusPredicate = @"";
		return nil;
	}
	else {
		NSLog(@"DEBUG: (tableView)setting predicate to nil");
		statusPredicate = nil;
	}
	if (row > [aBuffer count] -1) {
		if(debugEnabled)NSLog(@"DEBUG: (tableView) We Have run out of rows?");
		return nil;
	}
	if(debugEnabled)NSLog(@"DEBUG: (tableView) Processing row: %d of %d",row,[aBuffer count] -1);


	if (statusCol == tableColumn) {
		NSString *status = [[aBuffer objectAtIndex:row] objectForKey:@"status"];
			NSImage *image = [[NSImage alloc] initWithContentsOfFile: [ mainBundle
																		   pathForResource:status ofType:@"png"]];
			if (row != -1) return image;
	}
	
	if (discriptionCol == tableColumn) {
		NSMutableDictionary *displayDictionary = [[NSMutableDictionary alloc] init];
		if ([aBuffer objectAtIndex:row]) {
			return [aBuffer objectAtIndex:row];

		}
		else {
			NSString *nameValue = @"Unknown SSID";
			[displayDictionary setValue:nameValue forKey:@"title"];
			
			NSString *image = @"WirelessConfig";
			[displayDictionary setValue:image forKey:@"image"];
			return displayDictionary;
		}
		
	}
	
	if (statusTxtCol == tableColumn) {
		if ([aBuffer objectAtIndex:row] !=nil) {
			NSString * discription = @"";
			NSString * status = @"";
			NSString * metric = @"";
			NSString * nsStr = @"";
			
			if ([[aBuffer objectAtIndex:row] objectForKey:@"discription"] !=nil) {
				discription =  [[aBuffer objectAtIndex:row] objectForKey:@"discription"];
				if(debugEnabled)NSLog(@"Processed Description: %@",discription);
				
			}
			if ([[aBuffer objectAtIndex:row] objectForKey:@"status"] !=nil) {
				status =  [[aBuffer objectAtIndex:row] objectForKey:@"status"];
				if(debugEnabled)NSLog(@"DEBUG: Processed Status: %@",status);
				
			}
			if ([[aBuffer objectAtIndex:row] objectForKey:@"metric"] !=nil) {
				metric =  [[aBuffer objectAtIndex:row] objectForKey:@"metric"];
				if(debugEnabled)NSLog(@"DEBUG: Metric Status: %@",metric);
				
			}
			nsStr =[NSString stringWithFormat: @"Blah blah blah %@", metric];
			
			NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
			
			[paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
			
			
			NSMutableAttributedString * attributedStr = [[[NSMutableAttributedString alloc] initWithString:nsStr] autorelease];
			[attributedStr
			 addAttribute:NSParagraphStyleAttributeName
			 value:paragraphStyle
			 range:NSMakeRange(0,[attributedStr length])];
			
			if(debugEnabled)NSLog(@"DEBUG: Generated Attribute String:%@",attributedStr);
			if (row != -1) return attributedStr;
		}
		
	}
	else {
		return nil;
		
	}
	return nil;
}


// Table View Protocol

# pragma mark Table View Protocol
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	if ([aBuffer count] != 0) {
		return ([aBuffer count]);
		
	}
	else {
		return ([aBuffer count] -1);
	}
}

# pragma mark Notification Handlers
# pragma mark -

- (void) reloadTableBufferNow:(NSNotification *) notification
{	
	if(debugEnabled)NSLog(@"DEBUG:Configuration Tavble received ReceiveStatusUpdateNotification notification");
	lastGlobalStatusUpdate = [notification userInfo];
	[self reloadTableBuffer:lastGlobalStatusUpdate];
}

-(void)reloadTableBuffer:(NSDictionary *)globalStatusUpdate
{
	if(debugEnabled)NSLog(@"DEBUG: (reloadTableBuffer) Recieved request to Reload Table Buffer...");
	if (aBuffer) {
		if(debugEnabled)NSLog(@"DEBUG:(reloadTableBuffer) found existing buffer releasing");
		[aBuffer release];
	}
	
	globalStatusArray = [[NSMutableArray alloc] initWithArray:[globalStatusUpdate objectForKey:@"globalStatusArray"]];
	if(debugEnabled)NSLog(@"DEBUG: Notification Array: %@",globalStatusArray);

	aBuffer = [[ NSMutableArray alloc] initWithArray:globalStatusArray];
	
	// Reload the table
	if (statusPredicate) {
		[toggleSummaryPredicateButton setTitle:statusPredicate];
		// Reset for the next go around
		[statusPredicate release];
	}
	if(debugEnabled)NSLog(@"DEBUG: (reloadTableBuffer) aBuffer: %@",aBuffer);
	if(debugEnabled)NSLog(@"DEBUG: (reloadTableBuffer) Telling table to reload data on main thread");
	
	/*
	[tableView performSelectorOnMainThread:@selector(reloadData)
								withObject:nil
							 waitUntilDone:false];*/
	
	[tableView reloadData];

}
# pragma mark -
# pragma mark Class Methods
# pragma mark -

- (void)readInSettings 
{ 	
	mainBundle = [NSBundle bundleForClass:[self class]];
	NSString *settingsPath = [mainBundle pathForResource:SettingsFileResourceID
												  ofType:@"plist"];
	settings = [[NSDictionary alloc] initWithContentsOfFile:settingsPath];
	
	debugEnabled = [[settings objectForKey:@"debugEnabled"] boolValue];
}

# pragma mark -
# pragma mark IBAction Methods
# pragma mark -

-(IBAction)toggleSummaryPredicate:(id)sender
{	
	statusPredicate = [ toggleSummaryPredicateButton title];
	if(debugEnabled)NSLog(@"DEBUG: (toggleSummaryPredicate) updating status predicate to :%@",statusPredicate);
	[[NSNotificationCenter defaultCenter]
	 postNotificationName:RequestStatusUpdateNotification
	 object:self];
}


@end
