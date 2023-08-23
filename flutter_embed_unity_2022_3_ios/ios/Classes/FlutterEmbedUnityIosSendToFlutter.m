//
//  SendToFlutter.m
//  flutter_embed_unity_ios
//
//  Created by James Allen on 23/08/2023.
//

#import <Foundation/Foundation.h>
#import <flutter_embed_unity_ios-Swift.h>

// DO NOT change the name of this function: it is referenced in C# Unity scripts
// (<unity project>/Assets/FlutterEmbed/SendToFlutter/SendToFlutter.cs)
void FlutterEmbedUnityIosSendToFlutter(const char * data)
{
    NSLog(@"FlutterEmbedUnityIosSendToFlutter: %s", data);
    [SendToFlutter test:data];
//    NSData * jsonData = [[NSString stringWithUTF8String: data] dataUsingEncoding: NSUTF8StringEncoding];
//    NSError * error;
//    NSDictionary * jsonObject = [NSJSONSerialization JSONObjectWithData: jsonData options: kNilOptions error: &error];
//    if (!jsonObject && error) {
//        NSLog(@"%@", [error localizedDescription]);
//    } else {
//        id messageId = jsonObject[@"id"];
//        id messageData = jsonObject[@"data"];
//        for (FlutterUnityView * view in gViews) {
//            if ((int64_t)messageId < 0 || (int64_t)messageId == [view viewId]) {
//                [view onMessage: messageData];
//            }
//        }
//    }
}
