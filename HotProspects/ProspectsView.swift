//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Gavin Butler on 21-09-2020.
//

import SwiftUI
import CodeScanner
import UserNotifications

struct ProspectsView: View {
    
    enum FilterType {
        case none, contacted, uncontacted
    }
    
    enum SortType {
        case none, byEmail, byCreatedDate
    }
    
    @EnvironmentObject var prospects: Prospects
    @State private var isShowingScanner = false
    @State private var isShowingSortSheet = false
    @State private var sortType: SortType = .none
    
    let filter: FilterType
    
    var title: String {
        switch filter {
        case .none: return "Everyone"
        case .contacted: return "Contacted people"
        case .uncontacted: return "Uncontacted people"
        }
    }
    
    var filteredProspects: [Prospect] {
        switch filter {
        case .none: return prospects.people
        case .contacted: return prospects.people.filter { $0.isContacted }
        case .uncontacted: return prospects.people.filter { !$0.isContacted }
        }
    }
    
    var sortedProspects: [Prospect] {
            switch sortType {
            case .none: return filteredProspects
            case .byEmail: return filteredProspects.sorted { $0.emailAddress < $1.emailAddress }
            case .byCreatedDate: return filteredProspects.sorted { $0.createdDate < $1.createdDate }
            }
        }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sortedProspects) { prospect in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(prospect.name)
                                .font(.headline)
                            Text(prospect.emailAddress)
                                .foregroundColor(.secondary)
                        }
                        if self.filter == .none {
                            Spacer()
                            if prospect.isContacted {
                                Image(systemName: "person.crop.circle.badge.checkmark")
                            } else {
                                Image(systemName: "person.crop.circle")
                            }
                        }
                    }
                    .contextMenu {
                        Button(prospect.isContacted ? "Mark Uncontacted" : "Mark Contacted") {
                            self.prospects.toggle(prospect)
                        }
                        
                        if !prospect.isContacted {
                            Button("Remind Me") {
                                self.addNotification(for: prospect)
                            }
                        }
                    }
                }
            }
                .navigationBarTitle(title, displayMode: .inline)
                .navigationBarItems(leading: Button(action: {
                    self.isShowingSortSheet = true
                }) {
                    Image(systemName: "arrow.up.arrow.down.circle")
                    Text("Sort")
                }, trailing: Button(action: {
                    self.isShowingScanner = true
                }) {
                    Image(systemName: "qrcode.viewfinder")
                    Text("Scan")
                })
                
            .sheet(isPresented: $isShowingScanner) {
                let randomIntAsString = String(Int.random(in: 1..<10))
                CodeScannerView(codeTypes: [.qr], simulatedData: "PaulHudson\npaul" + randomIntAsString + "@hackingwithswift.com", completion: self.handleScan)
            }
            .actionSheet(isPresented: $isShowingSortSheet) {
                ActionSheet(title: Text("Sort Order"), message: Text("Select a new sort order"), buttons: [
                    .default(Text("None")) { self.sortType = .none },
                    .default(Text("Email")) { self.sortType = .byEmail },
                    .default(Text("Created Date")) { self.sortType = .byCreatedDate },
                    .cancel()
                ])
            }
        }
    }
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        self.isShowingScanner = false
        switch result {
        case .success(let code):
            let details = code.components(separatedBy: "\n")
            guard details.count == 2 else { return }
            
            let person = Prospect()
            person.name = details[0]
            person.emailAddress = details[1]
            self.prospects.add(person)
        case .failure(let error):
            print("Scanning Failed: \(error.localizedDescription)")
        }
    }
    
    //Note that, for some reason, this won't post a notification if the app is in the foreground!
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default
            
            //Triggers at 9am
//            var dateComponents = DateComponents()
//            dateComponents.hour = 9
//            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            center.add(request)
        }
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else {
                        print("DOH")
                    }
                }
            }
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
    }
}
