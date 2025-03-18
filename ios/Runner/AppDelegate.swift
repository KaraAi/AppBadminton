import Flutter
import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate ,MessagingDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
     Messaging.messaging().delegate = self
        
        requestNotificationPermission()

      // DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { 
      //   self.addDebugOverlay()
      // }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
 func requestNotificationPermission() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self // Đặt delegate cho UNUserNotificationCenter
        notificationCenter.requestAuthorization(options: authOptions) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("🚨 Người dùng từ chối quyền thông báo.")
            }
        }
    }
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("✅ APNs Token nhận được: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("✅ FCM Token: \(fcmToken ?? "Không có")")
    }
}


// //MARK: - Debug Overlay
// extension AppDelegate {
//     func addDebugOverlay() {
//         guard let window = UIApplication.shared.windows.first else { return }

//         let debugLabel = UILabel()
//         debugLabel.numberOfLines = 0
//         debugLabel.textAlignment = .left
//         debugLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
//         debugLabel.textColor = .white
//         debugLabel.font = UIFont.systemFont(ofSize: 12)
//         debugLabel.layer.cornerRadius = 8
//         debugLabel.layer.masksToBounds = true
//         debugLabel.translatesAutoresizingMaskIntoConstraints = false

//         window.addSubview(debugLabel)

//         // Định vị Debug Overlay
//         NSLayoutConstraint.activate([
//             debugLabel.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: -20),
//             debugLabel.leadingAnchor.constraint(equalTo: window.safeAreaLayoutGuide.leadingAnchor, constant: 20),
//             debugLabel.trailingAnchor.constraint(equalTo: window.safeAreaLayoutGuide.trailingAnchor, constant: -20)
//         ])

//         // Lấy token từ UserDefaults
//         let apnsToken = UserDefaults.standard.string(forKey: "apnsToken")
//         let fcmToken = UserDefaults.standard.string(forKey: "fcmToken")

//         // Kiểm tra nếu token có hay không
//         var debugText = ""

//         if let apns = apnsToken, !apns.isEmpty {
//             debugText += "✅ APNs Token: \(apns)\n"
//         } else {
//             debugText += "❌ APNs Token: Not Available\n"
//             print("❌ LỖI: Không lấy được APNs Token!")
//         }

//         if let fcm = fcmToken, !fcm.isEmpty {
//             debugText += "✅ FCM Token: \(fcm)\n"
//         } else {
//             debugText += "❌ FCM Token: Not Available\n"
//             print("❌ LỖI: Không lấy được FCM Token!")
//         }

//         // Hiển thị thông tin token hoặc lỗi lên Debug Overlay
//         debugLabel.text = debugText
//     }
// }

