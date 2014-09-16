//
//  CityWeather.m
//
//  Created by Robert Ryan on 8/13/13.
//  Copyright (c) 2013 Robert Ryan. All rights reserved.
//

#import "CityOperation.h"
#import "City.h"
#import "NetworkQueueManager.h"

@interface CityOperation () <NSURLConnectionDataDelegate, NSXMLParserDelegate>

@property (nonatomic, readwrite, getter = isFinished)  BOOL finished;
@property (nonatomic, readwrite, getter = isExecuting) BOOL executing;

@property (nonatomic, strong) NSMutableData *responseData;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *temp;
@property (nonatomic, strong) NSString *name;

@end

@implementation CityOperation

@synthesize executing = _executing;
@synthesize finished  = _finished;

- (id)initWithWoeid:(NSString *)woeid successBlock:(CityCompletion)completion
{
    self = [super init];
    if (self) {
        _woeid = [woeid copy];
        _cityCompletion = [completion copy];
    }
    return self;
}

- (void)start
{
    if ([self isCancelled]) {
        self.finished = YES;
        return;
    }

    [self performSelector:@selector(startOnNetworkThread)
                 onThread:[NetworkQueueManager networkRequestThread]
               withObject:nil
            waitUntilDone:NO
                    modes:@[NSDefaultRunLoopMode]];
}

- (void)startOnNetworkThread
{
    self.executing = YES;

    NSString *urlString = [NSString stringWithFormat:@"http://weather.yahooapis.com/forecastrss?w=%@", self.woeid];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [connection start];
}

#pragma mark - NSOperation methods

- (BOOL)isConcurrent
{
    return YES;
}

- (void)setExecuting:(BOOL)executing
{
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)setFinished:(BOOL)finished
{
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.responseData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if ([self isCancelled]) {
        self.executing = NO;
        self.finished = YES;
        [connection cancel];
        
        return;
    }

    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.executing = NO;
    self.finished = YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // you probably don't need to, but I'm going to push XML parsing on to background queue to avoid
    // taxing this network thread (which this method is called on)

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.responseData];
        parser.delegate = self;
        [parser parse];

        City *city  = [[City alloc] initWithName:self.name temperature:self.temp];

        // only try to call completion block if it exists
        
        if (self.cityCompletion)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self.cityCompletion(city);
            }];
        }

        self.executing = NO;
        self.finished = YES;
    });
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([self isCancelled]) {
        self.executing = NO;
        self.finished = YES;
        [parser abortParsing];
        return;
    }

    if ([elementName isEqualToString:@"yweather:condition"])
    {
        self.temp = attributeDict[@"temp"];
        self.text = attributeDict[@"text"];
    }
    else if ([elementName isEqualToString:@"yweather:location"])
    {
        self.name = attributeDict[@"city"];
    }
}

@end
