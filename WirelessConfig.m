//
//  WirelessConfig.m
//  WirelessConfig
//
//  Created by Zack Smith on 2/10/12.
//  Copyright 2012 wallcity.org All rights reserved.
//
#import "Constants.h"
#import "WirelessConfig.h"
#import "SSPluginProtocol.h"
#import "GlobalStatus.h"



@implementation WirelessConfig

@synthesize userName;
@synthesize passWord;
@synthesize scriptRunning;

#pragma mark Init Methods

- (void)readInSettings 
{ 	
	mainBundle = [NSBundle bundleForClass:[self class]];
	NSString *settingsPath = [mainBundle pathForResource:SettingsFileResourceID
												  ofType:@"plist"];
	settings = [[NSDictionary alloc] initWithContentsOfFile:settingsPath];
	debugEnabled = [[settings objectForKey:@"debugEnabled"] boolValue];
}

- (id) initWithBundle:(NSBundle *)bundle{
	if(self = [super init]){
		if(debugEnabled)NSLog(@"DEBUG: Setting Title");
		
		[self setTitle:@"GenenAir2"];
		
		if(debugEnabled)NSLog(@"DEBUG: Loading Nib");
        [self initWithNibName:@"WirelessConfig" bundle:bundle];
		
		// Read in our settings
		[self readInSettings];
		
		// Init our status controller
		if (!globalStatusController) {
			globalStatusController = [[GlobalStatus alloc] init];
		}
		if (!globalStatusArray) {
			globalStatusArray = [[NSMutableArray alloc] init];
		}
		
    }
	return self;
}

#pragma mark Delegate Methods

- (void)controlTextDidChange:(NSNotification *)nd
{
	if(debugEnabled)NSLog(@"DEBUG: User edited content");
	if(debugEnabled)NSLog(@"DEBUG: userNameField %d",[[userNameField stringValue] length]);
	if(debugEnabled)NSLog(@"DEBUG: passWordField %d",[[passWordField stringValue] length]);
	if ([[userNameField stringValue] length] > 0 && [[passWordField stringValue] length] > 0){
		[mainButton setEnabled:YES];
	}
}

#pragma mark Instance Methods

-(NSImage *) image{
	NSImage *logo = [[NSImage alloc] initWithContentsOfFile: [[NSBundle bundleForClass:[self class]]
	 pathForResource:@"WirelessConfig" ofType:@"png"]];
	return logo;
}

-(NSString *) subtitle{
	NSString *title = @"Connect to GenenAir2!";
	return title;
}

-(void)rootAccessObject:object;
{
	if(debugEnabled)NSLog(@"DEBUG: Recieved root access");
	rootObject = object;
}

-(NSURL *) url{
	NSString *urlString = @"";
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	return url;
}
-(NSString *) pluginID{
	NSString *pluginID = @"org.wallcity.wirelessconfig";
	return pluginID;
}
-(void) viewWillAppear{
	if(debugEnabled)NSLog(@"DEBUG: View will Appear...");
}

-(void) viewDidAppear{
	if(debugEnabled)NSLog(@"DEBUG: View did Appear...");
	[self loadView];
	
	if(debugEnabled)NSLog(@"DEBUG: Updating Tableview");
	//[self updateTable];



}


- (IBAction)connectButtonClicked:(id)sender
{	
	if (self.scriptRunning) {
		NSLog(@"Script already running");
	}
	else {
		
		[NSThread detachNewThreadSelector:@selector(runScript:)
								 toTarget:self
							   withObject:sender];
	}
}

- (void)runScript:(id)sender
{

	NSMutableArray *arguments = [[NSMutableArray alloc] init];
	
	NSString *settingsPath = [mainBundle pathForResource:SettingsFileResourceID
												  ofType:@"plist"];
	
	[mainProgressIndicator setUsesThreadedAnimation:YES];
	
	self.scriptRunning = YES;
	
	[ arguments addObject:[NSString stringWithFormat:@"--plist=%@",settingsPath]];
	[ arguments addObject:[NSString stringWithFormat:@"--username=%@",self.userName]];
	[ arguments addObject:[NSString stringWithFormat:@"--password=%@",self.passWord]];
	
	// Add debug to the script if told do so in settins.plist
	
	if ([[settings objectForKey:@"debugEnabled"] boolValue]) {
		[ arguments addObject:[NSString stringWithFormat:@"-d"]];
		
	}
	
	NSString *utility = [mainBundle pathForResource:UtilityScriptName
											 ofType:UtilityScriptExt];
	
	NSLog(@"Utility path: %@",utility);
	NSLog(@"Script Arguments: %@",arguments);
	
	// Run using the rootObject from Self Service
	[rootObject runTask:utility
		  withArguments:arguments
		   withDelegate:self]; 
	
	// Display the NSAlert
	[self displaySetupComplete:sender];
	
	self.scriptRunning = NO;
}

- (void)displaySetupComplete:(id)sender
{
	// Activate Our Application
	[NSApp arrangeInFront:self];
	[NSApp activateIgnoringOtherApps:YES];
	// Display a standard alert
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:@"GenenAir2 Setup Complete"];
	[alert setInformativeText:@"GenenAir2 has been configured on your system"];
	[alert setAlertStyle:NSWarningAlertStyle];
	//[alert runModal];
	[alert beginSheetModalForWindow:[sender window]
					  modalDelegate:self
					 didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
						contextInfo:nil];
	
	[alert release];

}

- (void)alertDidEnd:(NSAlert *)alert
		 returnCode:(NSInteger)returnCode
		contextInfo:(void *)contextInfo
{
    if (returnCode == NSAlertFirstButtonReturn) {
		// For the casper policy reporting
		NSLog(@"--------------------------------------------------------------------------------");
		NSLog(@"------------------------>User clicked ok<-----------------------------------");
		NSLog(@"--------------------------------------------------------------------------------");
	}
}

- (void) receivedStdout:(NSString *)text
{
	NSLog(@"%@",text);
}

- (void) receivedStderr:(NSString *)text
{
	NSLog(@"%@",text);

}

-(void)updateTable
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// Create a temp status dictionary that we can mutate
	NSMutableDictionary * statusDictionary = [[ NSMutableDictionary alloc] init];
	
	// Add the passed information
	[ statusDictionary setObject:@"WirelessConfig" forKey:@"status"];
	[ statusDictionary setObject:@"discription" forKey:@"discription"];
	[ statusDictionary setObject:@"reason" forKey:@"reason"];
	[ statusDictionary setObject:@"metric" forKey:@"metric"];
	[ statusDictionary setObject:@"WirelessConfig" forKey:@"image"];
	[ statusDictionary setObject:@"title" forKey:@"title"];
	[ statusDictionary setObject:@"output" forKey:@"output"];
	
	// Add our status Dictionary to the Global Status Array
	[globalStatusArray addObject:statusDictionary];
	
	// Let objects know the Global Status is being updated
	NSMutableDictionary *globalStatusUpdate = [[NSMutableDictionary alloc] init];
	
	
	[ globalStatusUpdate setValue:globalStatusArray forKey:@"globalStatusArray"];
	if(debugEnabled)NSLog(@"DEBUG: Sending Global Status Update: %@",globalStatusUpdate);
	
	// Pass the mutated Data to our NSTable
	[[NSNotificationCenter defaultCenter]
	 postNotificationName:StatusUpdateNotification
	 object:self
	 userInfo:globalStatusUpdate];
	[pool release];
}


@end
