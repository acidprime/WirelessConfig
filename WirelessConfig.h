//
//  WirelessConfig.h
//  WirelessConfig
//
//  Created by Zack Smith on 2/10/12.
//  Copyright 2012 318 All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GlobalStatus;


@interface WirelessConfig : NSViewController {
	NSDictionary *settings;
	NSBundle *mainBundle;

	// Properties
	NSString *userName;
	NSString *passWord;
	
	id rootObject;
	
	// IBOutlets
	IBOutlet NSTextField *userNameField;
	IBOutlet NSSecureTextField *passWordField;
	
	// Custom Class instance variables
	GlobalStatus  *globalStatusController;

	// Global status arrays
	NSMutableArray *globalStatusArray;
	
	BOOL debugEnabled;
}


// Init Methods
- (void)readInSettings;


//Protocol Methods
-(NSImage *) image;
-(NSString *) subtitle;
-(NSURL *) url;
-(NSString *) pluginID;
-(id) initWithBundle:(NSBundle *)bundle;
-(void) viewWillAppear;
-(void) viewDidAppear;
-(void) receivedStdout:(NSString *)text;
-(void) receivedStderr:(NSString *)text;

-(void)updateTable;

// IBActions
-(IBAction)connectButtonClicked:(id)sender;

// Fields
@property (retain) NSString* userName;
@property (retain) NSString* passWord;

@end

