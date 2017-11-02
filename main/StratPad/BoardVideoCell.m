//
//  BoardVideoCell.m
//  StratPad
//
//  Created by Kevin on 8/9/17.
//  Copyright © 2017 Glassey Strategy. All rights reserved.
//

#import "BoardVideoCell.h"
#import "RootViewController.h"

@implementation BoardVideoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onClickPlayVideo:(id)sender {
    [_controller performSelector:@selector(playBoardVideo)];
/*
    RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    //[rootViewController dismissAllMenus];
    MPMoviePlayerViewController* player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"SP iPad StratBoard" ofType:@"mp4"]]];
    [player.view setBounds:rootViewController.view.bounds];
    [player.moviePlayer prepareToPlay];
    [player.moviePlayer setFullscreen:YES animated:YES];
    [player.moviePlayer setShouldAutoplay:YES];
    [player.moviePlayer setMovieSourceType:MPMovieSourceTypeFile];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlayingErrorNotification:) name:MPMoviePlayerPlaybackDidFinishNotification object:player.moviePlayer];
    
    if (_controller != NULL)
        [_controller presentMoviePlayerViewControllerAnimated:player];
    else
        [rootViewController presentMoviePlayerViewControllerAnimated:player];
    
    [player release];
*/
}


@end
