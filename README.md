
# 📱 **Revide iOS Application**  
An Objective-C iOS app developed for **Revide**, a Brazilian news and cultural content platform. The app offers an interactive experience for accessing news, cultural guides, gastronomic content, videos, and promotions, all wrapped in an intuitive interface with sidebar navigation and multimedia support.

---

## 🌟 **About Revide**  
[**Revide**](https://www.revide.com.br/) is a prominent platform that delivers news, cultural insights, gastronomic guides, and event promotions to its audience. The iOS app was developed to bring these features directly to mobile users with a focus on usability and responsiveness.

---

## 🚀 **Key Features**  
- **📰 News Access:** Browse the latest news and explore by categories.  
- **🎭 Cultural Guide:** Stay updated with cultural and artistic events.  
- **🍽️ Gastronomic Guide:** Discover the best culinary experiences.  
- **📹 Video Integration:** Watch embedded YouTube videos seamlessly.  
- **📊 Segmented Content:** Organized tabs for streamlined navigation.  
- **📸 Photo Browser:** Browse high-resolution photos with zoom and share capabilities.  
- **🔔 Push Notifications:** Get updates with in-app messages and alerts.  
- **📲 Sidebar Navigation:** Quick and intuitive menu access for all sections.  

---

## 🛠️ **Technologies and Libraries Used**  
This project utilizes key third-party libraries to ensure scalability, performance, and a smooth user experience:

### **CocoaPods Dependencies:**  
```ruby
pod 'MWPhotoBrowser'          # Elegant photo browsing and sharing
pod 'TSMessages'              # Stylish in-app notifications
pod 'HMSegmentedControl'      # Custom segmented control
pod 'youtube-ios-player-helper', '~> 0.1.4' # Embed and play YouTube videos
pod 'CZPicker'                # Custom picker for user selections
```

### **Core Frameworks:**  
- UIKit  
- CoreGraphics  
- AVFoundation  

### **Architecture Highlights:**  
- **SWRevealViewController:** Manages side navigation for menu interactions.  
- **SidebarViewController:** Handles sidebar navigation and dynamic menu content.  
- **Custom ViewControllers:** For each major section like News, Videos, and Guides.  

---

## 🛠️ **Installation Guide**  
1. **Clone the Repository:**  
   ```bash
   git clone https://github.com/Fabersp/revide-ios.git
   cd revide-ios
   ```

2. **Install Dependencies:**  
   ```bash
   pod install
   ```

3. **Open the Project in Xcode:**  
   ```bash
   open RevideApp.xcworkspace
   ```

4. **Run on Simulator or Device:**  
   - Select an iOS device/simulator in Xcode.  
   - Press **Cmd + R** to build and run.  

---

## 🧠 **Code Examples**  

### **Sidebar Navigation Example:**  
```objective-c
#import "SidebarViewController.h"
#import "SWRevealViewController.h"

- (void)viewDidLoad {
    [super viewDidLoad];
    self.revealViewController.panGestureRecognizer.enabled = YES;
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}
```

### **YouTube Player Integration Example:**  
```objective-c
#import "YTPlayerView.h"

[self.youtubePlayerView loadWithVideoId:@"VIDEO_ID"];
```

### **Photo Browser Example:**  
```objective-c
MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithPhotos:@[photo1, photo2]];
[self.navigationController pushViewController:browser animated:YES];
```

---

## 👨‍💻 **Author**  
- **Fabricio Aguiar de Padua**  
- **LinkedIn:** www.linkedin.com/fabricio-padua  
- **Email:** fabricio_0505_@hotmail.com

---

## 📜 **License**  
This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

---

## 🤝 **Acknowledgments**  
- Thanks to **Revide** for the opportunity to develop this application.  
- Special thanks to the teams behind **MWPhotoBrowser**, **TSMessages**, **HMSegmentedControl**, **CZPicker**, and **youtube-ios-player-helper** for their contributions to the iOS community.  
