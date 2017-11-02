//
//  YouTubeView.m
//  StratPad
//
//  Created by Julian Wood on 12-05-18.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "YouTubeView.h"

@implementation YouTubeView

- (id)init
{
    self = [super init];
    if (self) {
        self.useBorderHack = NO;
        self.mediaPlaybackRequiresUserAction = NO;
    }
    return self;
}

-(void)loadVideo:(NSString*)url
{
    // HTML to embed YouTube video
    NSString *youTubeVideoHTML = @" \
    <html><head><style type=\"text/css\"> \
    html,body,iframe {margin:0; padding:0; background:black;} \
    #borderhack {background-color:black; width:1px; height:300px; position:absolute; top:0; left: 449px} \
    </style> \
    <script type=\"text/javascript\"> \
    function hideActionBar() { \
        var iframe = document.getElementById('youtube'); \
        var innerDoc = iframe.contentDocument || iframe.contentWindow.document; \
        var classNamesToHide = ['html5-share-button', 'html5-like-button', 'html5-dislike-button', 'html5-watermark', 'html5-info-bar']; \
        for (var i=0; i<classNamesToHide.length; ++i) { \
            var elements = innerDoc.getElementsByClassName(classNamesToHide[i]); \
            for (var j=0; j<elements.length; ++j) { \
                elements[j].style.display = 'none'; \
                elements[j].style.visibility = 'hidden'; \
                elements[j].style.opacity = '0'; \
            } \
        } \
    } \
    </script> \
    </head><body> \
    <iframe id=\"youtube\" onload=\"hideActionBar()\" width=\"%0.0f\" height=\"%0.0f\" src=\%@&autoplay=1\" frameborder=\"0\" autoplay=\"autoplay\" allowfullscreen></iframe> \
    %@ \
    </body></html>";
    
    // Populate HTML with the URL and requested frame size
    NSString *html = [NSString stringWithFormat:youTubeVideoHTML, self.bounds.size.width, self.bounds.size.height, url,
                      _useBorderHack?@"<div id=\"borderhack\"></div>":@""];
    
    // Load the html into the webview
    [self loadHTMLString:html baseURL:[[NSBundle mainBundle] resourceURL]];
    
}

-(void)loadErrorText:(NSString*)errorText
{
    NSString *messageHTML = @" \
    <html><head><style type=\"text/css\"> \
    html,body {margin:0; padding:0; background:#000; font:15px helvetica;} \
    p {color:white; padding: 0 50px;} \
    a {color:white; text-decoration:underline;} \
    #outer {display:table; height:%0.0f; overflow:hidden; width: 878px;} \
    #inner {display:table-cell; vertical-align:middle; text-align:center;} \
    </style></head><body> \
    <div id=\"outer\"> \
    <div id=\"inner\"> \
    <p>%@</p> \
    <a href=\"refresh://refresh\">Refresh</a> \
    </div></div> \
    </body></html> \
    ";
    
    // Populate HTML with the URL and requested frame size
    NSString *html = [NSString stringWithFormat:messageHTML, self.bounds.size.height, errorText];
    
    // Load the html into the webview
    [self loadHTMLString:html baseURL:nil];    
}

@end
