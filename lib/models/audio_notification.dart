

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';

class AudioNotification {

  ///Gives a local notification with audio alert when approach hotspot
  showOnApproachNotification() async {
    
    var android = AndroidNotificationDetails('id', 'channel ', 'description',
        sound: RawResourceAndroidNotificationSound('prone'),
        playSound: true,
        priority: Priority.high, importance: Importance.max);
        
    var iOS = IOSNotificationDetails();
    var platform = new NotificationDetails(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(0, 'Accident Alert',
        'Car is approaching an accident prone area', platform,
        payload: 'Welcome to the Local Notification demo');
  }

  showOnWithinNotification() async {
    
    var android = AndroidNotificationDetails('id', 'channel ', 'description',
        sound: RawResourceAndroidNotificationSound('inside'),
        playSound: true,
        priority: Priority.high, importance: Importance.max);
        
    var iOS = IOSNotificationDetails();
    var platform = new NotificationDetails(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(0, 'Accident Alert',
        'Car is within an accident prone area', platform,
        payload: 'Welcome to the Local Notification demo');
  }

}