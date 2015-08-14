//
//  Game.m
//  Detonate
//
//  Created by Marco Piccardo on 04/02/11.
//  Copyright 2011 Eurotraining Engineering. All rights reserved.
//
/*
 *  Modified and Updated
 *
 *  Copyright 2014 Wizcorp Inc. http://www.wizcorp.jp
 *  Author Ally Ogilvie
 */
//Copyright (c) 2014 Sang Ki Kwon (Cranberrygame)
//Email: cranberrygame@yahoo.com
//Homepage: http://www.github.com/cranberrygame
//License: MIT (http://opensource.org/licenses/MIT)

//Copyright (c) 2015 Paulo Cristo (uareurapid)
//Email: cristo.paulo@gmail.com
//Homepage: http://www.github.com/uareurapid
//License: MIT (http://opensource.org/licenses/MIT)

#import "Game.h"
#import <Cordova/CDVViewController.h>

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface Game ()
@property (nonatomic, retain) GKLeaderboardViewController *leaderboardController;
@property (nonatomic, retain) GKAchievementViewController *achievementsController;
@end

@implementation Game

- (void)setUp:(CDVInvokedUrlCommand *)command {

}

- (void)showAllLeaderboards:(CDVInvokedUrlCommand *)command {

 	//[self.commandDelegate runInBackground:^{
         if ( self.leaderboardController == nil ) {
             self.leaderboardController = [[GKLeaderboardViewController alloc] init];
             self.leaderboardController.leaderboardDelegate = self;//
         }
         self.leaderboardController.category = nil;
         CDVViewController *vc = (CDVViewController *)[super viewController];
         [vc presentViewController:self.leaderboardController animated:YES completion: ^{
         }];
    // }];
}

- (void)login:(CDVInvokedUrlCommand *)command {
    
    //[self.commandDelegate runInBackground:^{//cranberrygame
        [[GKLocalPlayer localPlayer] setAuthenticateHandler: ^(UIViewController *viewcontroller, NSError *error) {
          
            //already logged in
            if ([GKLocalPlayer localPlayer].authenticated) {
			
				NSString *playerID = [GKLocalPlayer localPlayer].playerID;
				NSString *displayName = [GKLocalPlayer localPlayer].displayName;
				
				NSDictionary* playerDetail = @{
					@"playerId":playerID,
					@"playerDisplayName":displayName
				};
						
				CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:playerDetail];
				//[pr setKeepCallbackAsBool:YES];
				[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];
				//CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
				//[pr setKeepCallbackAsBool:YES];
				//[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];
            }
            else if (viewcontroller != nil) {
                CDVViewController *vc = (CDVViewController *)[super viewController];
                [vc presentViewController:viewcontroller animated:YES completion:^{
                }];
            }
            else {
                // Called the second time with result
                if (error != nil) {	
					//CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
					//[pr setKeepCallbackAsBool:YES];
					//[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];
					CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
					//[pr setKeepCallbackAsBool:YES];
					[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];
                }
                else {
					NSString *playerID = [GKLocalPlayer localPlayer].playerID;
					NSString *displayName = [GKLocalPlayer localPlayer].displayName;
					
					NSDictionary* playerDetail = @{
						@"playerId":playerID,
						@"playerDisplayName":displayName
					};
							
					CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:playerDetail];		
					//[pr setKeepCallbackAsBool:YES];
					[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];
					//CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
					//[pr setKeepCallbackAsBool:YES];
					//[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];	
                }
            }
        }];
    //}];//cranberrygame
}

- (void)isPlayerAuthenticated:(CDVInvokedUrlCommand *)command {
    
    if ([GKLocalPlayer localPlayer]!=nil && [GKLocalPlayer localPlayer].authenticated) {
        CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:true];
        [self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];
    }
    else {
        CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsBool:false];
        [self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];
        
    }
}

- (void)logout:(CDVInvokedUrlCommand *)command {
    //Unfortunately, this takes the user outside your app.
    //http://stackoverflow.com/questions/9995576/how-to-show-game-centers-player-profile-view
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"gamecenter:/me/account"]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"gamecenter:/me/signout"]];
}

- (void)getPlayerImage:(CDVInvokedUrlCommand *)command {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *playerImageUrl = [documentsDirectory stringByAppendingPathComponent: @"user.jpg" ];

    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:playerImageUrl];    
    if(fileExists){
		NSLog(@"%@", playerImageUrl);
		
		CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:playerImageUrl];
		//[pr setKeepCallbackAsBool:YES];
		[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];
		//CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
		//[pr setKeepCallbackAsBool:YES];
		//[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];	
    }
    else{
		GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
        [localPlayer loadPhotoForSize:GKPhotoSizeSmall withCompletionHandler: ^(UIImage *photo, NSError *error) {            
            if (photo != nil)
            {
                NSData* data = UIImageJPEGRepresentation(photo, 0.8);
                [data writeToFile:playerImageUrl atomically:YES];
				NSLog(@"%@", playerImageUrl);
				
				CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:playerImageUrl];
				//[pr setKeepCallbackAsBool:YES];
				[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];
				//CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
				//[pr setKeepCallbackAsBool:YES];
				//[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];				
            }
            else if (error != nil)
            {
                NSLog(@"%@", [error localizedDescription]);
                
				//CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
				//[pr setKeepCallbackAsBool:YES];
				//[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];
				CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
				//[pr setKeepCallbackAsBool:YES];
				[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];
            }
        }];
    }
}

- (void)getPlayerScore:(CDVInvokedUrlCommand *)command {
 	NSString *leaderboardId = [command.arguments objectAtIndex:0];
    
	//http://stackoverflow.com/questions/21591123/how-to-get-local-player-score-from-game-center

	//GKLeaderboard *leaderboard = [[GKLeaderboard alloc] init];
	//for some reason the above call fails many times with error code kCFURLErrorTimedOut  = -1001,
	//The change/fix found in the following link solves this issue
	//http://stackoverflow.com/questions/28072536/nsurlerrordomain-code-1005-from-gkleaderboard-loadscoreswithcompletionhandler

	GKLeaderboard *leaderboard = [[GKLeaderboard alloc] initWithPlayers:@[ GKLocalPlayer.localPlayer ]];

  	leaderboard.identifier = leaderboardId;
	[leaderboard loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
		if (error) {
			NSLog(@"%@", error);
			
			//CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
			//[pr setKeepCallbackAsBool:YES];
			//[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];
			CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
			//[pr setKeepCallbackAsBool:YES];
			[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];
		}
		else if (scores) {
			GKScore *s = leaderboard.localPlayerScore;
			NSLog(@"Local player's score: %lld", s.value);
			
            CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat:@"%lld", s.value]];
 			//[pr setKeepCallbackAsBool:YES];
			[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];
			//CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
			//[pr setKeepCallbackAsBool:YES];
			//[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];
		}
		//no scores yet, put 0
        else if (scores==nil) {
            CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat:@"%lld", (long)0]];
            //[pr setKeepCallbackAsBool:YES];
            [self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];
        }
	}];
}

- (void)submitScore:(CDVInvokedUrlCommand *)command {

    //[self.commandDelegate runInBackground:^{//cranberrygame
		NSString *leaderboardId = [command.arguments objectAtIndex:0];
        int64_t score = [[command.arguments objectAtIndex:1] integerValue];
		
		GKScore *s = [[GKScore alloc] initWithLeaderboardIdentifier: leaderboardId];
        s.value = score;
        s.context = 0;
			
		[GKScore reportScores:@[s] withCompletionHandler: ^(NSError *error) {
            if (error != nil)
            {				
				//CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
				//[pr setKeepCallbackAsBool:YES];
				//[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];
				CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
				//[pr setKeepCallbackAsBool:YES];
				[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];
            }
            else
            {
				CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
				//[pr setKeepCallbackAsBool:YES];
				[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];
				//CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
				//[pr setKeepCallbackAsBool:YES];
				//[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];
			}
		}];
    //}];//cranberrygame
}

- (void)showLeaderboard:(CDVInvokedUrlCommand *)command {
    //[self.commandDelegate runInBackground:^{//cranberrygame
        if ( self.leaderboardController == nil ) {
            self.leaderboardController = [[GKLeaderboardViewController alloc] init];
            self.leaderboardController.leaderboardDelegate = self;//
        }
        self.leaderboardController.category = (NSString *) [command.arguments objectAtIndex:0];
        CDVViewController *vc = (CDVViewController *)[super viewController];
        [vc presentViewController:self.leaderboardController animated:YES completion: ^{
        }];
    //}];//cranberrygame
}

- (void)unlockAchievement:(CDVInvokedUrlCommand *)command {
    //[self.commandDelegate runInBackground:^{//cranberrygame
		NSString *achievementId = [command.arguments objectAtIndex:0];
				
		GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier: achievementId];
		if (achievement)
		{
			achievement.percentComplete = 100;
			
			[achievement reportAchievementWithCompletionHandler: ^(NSError *error)
			{
				 if (error != nil)
				 {
					//CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
					//[pr setKeepCallbackAsBool:YES];
					//[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];
					CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
					//[pr setKeepCallbackAsBool:YES];
					[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];
				} 
				 else {
					CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
					//[pr setKeepCallbackAsBool:YES];
					[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];
					//CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
					//[pr setKeepCallbackAsBool:YES];
					//[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];
					

				 }
			}];
		}
    //}];//cranberrygame
}

- (void)incrementAchievement:(CDVInvokedUrlCommand *)command {
    //[self.commandDelegate runInBackground:^{//cranberrygame
		NSString *achievementId = [command.arguments objectAtIndex:0];
		NSString *stepsOrPercent = [command.arguments objectAtIndex:1];
		float stepsOrPercentFloat = [stepsOrPercent floatValue];
				
		GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier: achievementId];
		if (achievement)
		{
			achievement.percentComplete = stepsOrPercentFloat;
			
			[achievement reportAchievementWithCompletionHandler: ^(NSError *error)
			{
				 if (error != nil)
				 {
					//CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
					//[pr setKeepCallbackAsBool:YES];
					//[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];
					CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
					//[pr setKeepCallbackAsBool:YES];
					[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];
				} 
				 else {
					CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
					//[pr setKeepCallbackAsBool:YES];
					[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];
					//CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
					//[pr setKeepCallbackAsBool:YES];
					//[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];
					

				 }
			}];
		}
    //}];//cranberrygame
}

- (void)showAchievements:(CDVInvokedUrlCommand *)command {//cranberrygame
    //[self.commandDelegate runInBackground:^{
        if ( self.achievementsController == nil ) {
            self.achievementsController = [[GKAchievementViewController alloc] init];
            self.achievementsController.achievementDelegate = self;//
        }
        CDVViewController *vc = (CDVViewController *)[super viewController];
        [vc presentViewController:self.achievementsController animated:YES completion: ^{
        }];
    //}];//cranberrygame
}

- (void) resetAchievements:(CDVInvokedUrlCommand*)command;
{
    [GKAchievement resetAchievementsWithCompletionHandler: ^(NSError *error)
    {
         if (error != nil)
         {
			 
			//CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
			//[pr setKeepCallbackAsBool:YES];
			//[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];
			CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
			//[pr setKeepCallbackAsBool:YES];
			[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];			 
         } else {
			CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
			//[pr setKeepCallbackAsBool:YES];
			[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];
			//CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
			//[pr setKeepCallbackAsBool:YES];
			//[self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];				 
         }
	}];    
}

//GKLeaderboardViewControllerDelegate
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
/*
    CDVViewController *vc = (CDVViewController *)[super viewController];
    [vc dismissViewControllerAnimated:YES completion:nil];
*/
	[viewController dismissViewControllerAnimated:YES completion:nil];
}

//GKAchievementViewControllerDelegate
- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController {
/*
    CDVViewController* vc = (CDVViewController *)[super viewController];
    [vc dismissViewControllerAnimated:YES completion:nil];
*/
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    self.leaderboardController = nil;
    self.achievementsController = nil;
    
    [super dealloc];
}

@end
