//
//  ContentView.swift
//  HotProspects
//
//  Created by Gavin Butler on 19-09-2020.
//

import SwiftUI

struct ContentView: View {
    
    var prospects = Prospects()

    var body: some View {
        TabView {
            ProspectsView(filter: .none)
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Everyone")
                }
            ProspectsView(filter: .contacted)
                .tabItem {
                    Image(systemName: "checkmark.circle")
                    Text("Contacted")
                }
            ProspectsView(filter: .uncontacted)
                .tabItem {
                    Image(systemName: "questionmark.diamond")
                    Text("Uncontacted")
                }
            MeView()
                .tabItem {
                    Image(systemName: "person.crop.square")
                    Text("Me")
                }
        }
        .environmentObject(prospects)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
//Adding Swift package dependencies in Xcode:
/*1. Go to the File menu.
 2. Look in the Swift Packages submenu.
 3. Choose Add Package Dependency.
 4. For the URL enter https://github.com/twostraws/SamplePackage
 5. Leave the default rules alone, and click Next.
 6. Click Finish to complete the process.

 Once that’s done, you should be able to add `import SamplePackage` to one of your Swift files, then try out the example code that is included in the package: an extension on `Sequence` that returns some random number of items from the sequence.
 
 import SwiftUI
 import SamplePackage

 struct ContentView: View {
     
     let possibleNumbers = Array(1...60)
     
     var results: String {
         let selected = possibleNumbers.random(7).sorted()
         let strings = selected.map(String.init)
         return strings.joined(separator: ", ")
     }

     var body: some View {
         Text(results)
     }
 }*/

//Scheduling local notifications:
/*import UserNotifications

struct ContentView: View {
 
 var body: some View {
     VStack {
         Button("Request Permission") {
             UNUserNotificationCenter.current()
                 .requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                     if success {
                         print("All Set")
                     } else if let error = error {
                         print(error.localizedDescription)
                     }
                 }
         }
         Button("Schedule Notification") {
             let content = UNMutableNotificationContent()
             content.title = "Feed the Cat"
             content.subtitle = "It looks hungry"
             content.sound = UNNotificationSound.default
             
             let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
             
             let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
     
             UNUserNotificationCenter.current().add(request)
         }
     }
 }
}*/

//Context Menus:
/*struct ContentView: View {
 
 @State private var backgroundColour = Color.red
 
 var body: some View {
     VStack {
         Text("Hello There")
             .padding()
             .background(backgroundColour)
         
         Text("Change Colour")
             .padding()
             .contextMenu {
                 Button(action: {
                     self.backgroundColour = .red
                 }) {
                     Text("Red")
                     Image(systemName: "checkmark.circle.fill")
                         .foregroundColor(.red)
                 }
                 Button(action: {
                     self.backgroundColour = .green
                 }) {
                     Text("Green")
                 }
                 Button(action: {
                     self.backgroundColour = .blue
                 }) {
                     Text("Blue")
                 }
             }
     }
 }
}*/

//Controlling image interpolation in SwiftUI
/*struct ContentView: View {
 
 var body: some View {
     Image("example")
         .interpolation(.none)   //Stops the blurring of pixels as they're scaled up to fit the screen from this very small image.
         .resizable()
         .scaledToFit()
         .frame(maxHeight: .infinity)
         .background(Color.black)
         .edgesIgnoringSafeArea(.all)
 }
}*/

//Manually publishing ObservableObject changes (with intervention!):
/*class DelayedUpdater: ObservableObject {
 var value = 0 {
     willSet {
         //Opportunity here to put any other code we like as this variable's changes are published!
         objectWillChange.send()
     }
 }
 
 init() {
     for i in 1...10 {
         DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) {
             self.value += 1
         }
     }
 }
}

struct ContentView: View {
 
 @ObservedObject var updater = DelayedUpdater()
 
 var body: some View {
     Text("Value is: \(updater.value)")

 }
}*/

//Simple @Published example:
/*class DelayedUpdater: ObservableObject {
 @Published var value = 0
 
 init() {
     for i in 1...10 {
         DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) {
             self.value += 1
         }
     }
 }
}

struct ContentView: View {
 
 @ObservedObject var updater = DelayedUpdater()
 
 var body: some View {
     Text("Value is: \(updater.value)")

 }
}*/

//Data retrieval using Result type:
/*enum NetworkError: Error {
 case badURL, requestFailed, unknown
}

struct ContentView: View {
 
 var body: some View {
     Text("Howdy Verld")
         .onAppear {
             self.fetchData(from: "https://www.apple.com") { result in
                 switch result {
                 case .success(let str):
                     print(str)
                 case .failure(let error):
                     switch error {
                         case .badURL:
                             print("Bad URL \(error.localizedDescription)")
                         case .requestFailed:
                             print("Network problems \(error.localizedDescription)")
                         case .unknown:
                             print("Unknown error \(error.localizedDescription)")
                     }
                 }
             }
         }
 }
 
//  Paul calls this a blocking function because it runs immediately:
//    func fetchData(from urlString: String) -> Result<String, NetworkError> {
//        .failure(.badURL)
//    }
 
 //This version is non blocking because it uses a closure, and particularly an escaping closure which allows the closure
 //to be run asynchronously, even if the calling method is removed from the stack.
 func fetchData(from urlString: String, completion: @escaping (Result<String, NetworkError>) -> Void) {
     guard let url = URL(string: urlString) else {
         completion(.failure(.badURL))
         return
     }
     URLSession.shared.dataTask(with: url) { data, response, error in
         DispatchQueue.main.async {
             if let data = data {
                 let stringData = String(decoding: data, as: UTF8.self)
                 completion(.success(stringData))
             } else if error != nil {
                 completion(.failure(.requestFailed))
             } else {
                 completion(.failure(.unknown))
             }
         }
     }.resume()
 }
}*/

//Basic data retrieval without using Result type:
/*struct ContentView: View {
 
 @State private var selectedTab = "Tab-1"
 
 var body: some View {
     Text("Howdy Verld")
         .onAppear {
             let url = URL(string: "https://www.apple.com")!
             URLSession.shared.dataTask(with: url) { data, response, error in
                 if data != nil {
                     print("We got data!")
                 } else if let error = error {
                     print(error.localizedDescription)
                 }
             }.resume()
        }
    }
 }*/

//Creating tabs with TabView and tabItem()
//Note if ever using tab views and navigation views, use the Tab View as the parent, not the other way around!
/*struct ContentView: View {
 
 @State private var selectedTab = "Tab-1"
 
 var body: some View {
     TabView(selection: $selectedTab) {
         Text("Tab 1")
             .onTapGesture {
                 self.selectedTab = "Tab-2"
             }
             .tabItem {
                 Image(systemName: "star")
                 Text("One")
             }
             .tag("Tab-1")
         Text("Tab 2")
             .onTapGesture {
                 self.selectedTab = "Tab-1"
             }
             .tabItem {
                 Image(systemName: "star.fill")
                 Text("Two")
             }
             .tag("Tab-2")
     }
 }
}*/

//Simple TabView Setup:
/*struct ContentView: View {
 
 var body: some View {
     TabView {
         Text("Tab 1")
             .tabItem {
                 Image(systemName: "star")
                 Text("One")
             }
         Text("Tab 2")
             .tabItem {
                 Image(systemName: "star.fill")
                 Text("Two")
             }
     }
 }
}*/

//Reading custom values from the environment with @EnvironmentObject:
//Note that this technique can also apply for all views in your app by
//specifying this at the ContentView level in the top scene level (or @Main) code
//with let user = User()
//ContentView().environmentObject(user)
//See also Sundell's web post on how to provide it everywhere in the app by specifying keys.
/*class User: ObservableObject {
 @Published var name = "Taylor Swift"
}

struct EditView: View {
 @EnvironmentObject var user: User
 
 var body: some View {
     TextField("Name", text: $user.name)
 }
}

struct DisplayView: View {
 @EnvironmentObject var user: User
 
 var body: some View {
     Text(user.name)
 }
}

struct ContentView: View {
 let user = User()
 var body: some View {
//        VStack {
//            EditView().environmentObject(user)
//            DisplayView().environmentObject(user)
//        }
     //The above is the same as below, as all child views inherit access to the environmentObject
     VStack {
         EditView()
         DisplayView()
     }
     .environmentObject(user)
 }
}*/
