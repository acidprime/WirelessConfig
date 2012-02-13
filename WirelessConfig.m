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
		NSLog(@"DEBUG: Setting Title");
		
		[self setTitle:@"GenenAir2"];
		
		NSLog(@"DEBUG: Loading Nib");
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
	NSLog(@"DEBUG: Recieved root access");
	rootObject = object;
}

-(NSURL *) url{
	NSString *urlString = @"";
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	return url;
}
-(NSString *) pluginID{
	NSString *pluginID = @"org.wallcity.foo";
	return pluginID;
}
-(void) viewWillAppear{
	NSLog(@"DEBUG: View will Appear...");
}

-(void) viewDidAppear{
	NSLog(@"DEBUG: View did Appear...");
	[self loadView];
	
	NSLog(@"DEBUG: Updating Tableview");
	[self updateTable];

}


- (IBAction)connectButtonClicked:(id)sender
{
	NSMutableArray *arguments = [[NSMutableArray alloc] init];
	
	NSString *settingsPath = [mainBundle pathForResource:SettingsFileResourceID
												  ofType:@"plist"];
	
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
	
	
	[rootObject runTask:utility
		  withArguments:arguments
		   withDelegate:self]; 

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
	NSLog(@"DEBUG: Sending Global Status Update: %@",globalStatusUpdate);
	
	// Pass the mutated Data to our NSTable
	[[NSNotificationCenter defaultCenter]
	 postNotificationName:StatusUpdateNotification
	 object:self
	 userInfo:globalStatusUpdate];
	[pool release];
}


@end
