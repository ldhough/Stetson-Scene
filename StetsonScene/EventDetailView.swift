//
//  EventDetailView.swift
//  StetsonScene
//
//  Created by Madison Gipson on 7/15/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import SwiftUI
import CoreLocation

struct EventDetailView : View {
    @EnvironmentObject var config: Configuration
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var event: EventInstance
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 20).frame(width: Constants.width*0.25, height: 5, alignment: .center).foregroundColor(Color.secondaryLabel.opacity(0.2)).padding(.bottom, 10)
            
                //Event name
            Text(event.name).fontWeight(.medium).font(.system(size: 30)).frame(maxWidth: .infinity, alignment: .center).multilineTextAlignment(.center).foregroundColor(event.hasCultural ? config.accent : Color.label).padding([.horizontal])
                //Info row
                HStack(spacing: 20) {
                    Text(event.date).fontWeight(.light).font(.system(size: 20)).frame(maxWidth: .infinity, alignment: .trailing).foregroundColor(event.hasCultural ? Color.label : config.accent)
                    VStack {
                        Image(systemName: "person.fill").resizable().frame(width: 20, height: 20).foregroundColor(event.hasCultural ? Color.label : config.accent)
                        Text(String(event.numAttending)).fontWeight(.light).font(.system(size: 14)).foregroundColor(event.hasCultural ? Color.label : config.accent)
                    }
                    Text(event.time).fontWeight(.light).font(.system(size: 20)).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(event.hasCultural ? Color.label : config.accent)
                }
                Rectangle().frame(width: Constants.width*0.75, height: 1, alignment: .center).foregroundColor(Color.secondaryLabel.opacity(0.2)).padding(.vertical, 10)
            ScrollView {
                //Description
                Text(event.eventDescription!).fontWeight(.light).font(.system(size: 16)).multilineTextAlignment(.leading).foregroundColor(Color.label).padding(.horizontal, 10)
                Text("DETAILS").fontWeight(.light).font(.system(size: 16)).foregroundColor(config.accent).padding(.top)
            }.padding([.horizontal])
            
            Spacer()
            Buttons(event: event).padding(.vertical, 5)
        }.padding([.vertical]).background(Color.secondarySystemBackground).edgesIgnoringSafeArea(.bottom)
    }
}

struct Buttons: View {
    @EnvironmentObject var config: Configuration
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var event: EventInstance
    @State var share: Bool = false
    @State var calendar: Bool = false
    @State var navigate: Bool = false
    @State var arMode: Bool = true //false=mapMode
    //for alerts
    @State var internalAlert: Bool = false
    @State var externalAlert: Bool = false
    @State var tooFar: Bool = false
    @State var arrived: Bool = false
    @State var eventDetails: Bool = false
    @State var isVirtual: Bool = false
    
    //MARK: VIEW
    var body: some View {
        return HStack(spacing: 25) {
            //SHARE
            ZStack {
                Circle().foregroundColor(share ? config.accent : Color.tertiarySystemBackground).clipShape(Circle())
                Image(systemName: "square.and.arrow.up").resizable().frame(width: 18, height: 22).foregroundColor(share ? Color.tertiarySystemBackground : config.accent)
            }.frame(width: 40, height: 40)
                .onTapGesture {
                    self.share.toggle()
                    self.config.eventViewModel.isVirtual(event: self.event)
                    if self.event.isVirtual {
                        self.event.linkText = self.makeLink(text: self.event.eventDescription)
                            if self.event.linkText == "" { self.event.isVirtual = false }
                            self.event.shareDetails = "Check out this event I found via StetsonScene! \(self.event.name!) is happening on \(self.event.date!) at \(self.event.time!)!"
                    } else {
                            self.event.shareDetails = "Check out this event I found via StetsonScene! \(self.event.name!), on \(self.event.date!) at \(self.event.time!), is happening at the \(self.event.location!)!"
                    }
                    //GIVE HAPTIC
            }
            .sheet(isPresented: $share, content: { //NEED TO LINK TO APPROPRIATE LINKS ONCE APP IS PUBLISHED
                ShareView(activityItems: [/*"linktoapp.com"*/self.event.isVirtual ? URL(string: self.event.linkText)!:"", self.event.hasCultural ? "\(self.event.shareDetails) It’s even offering a cultural credit!" : "\(self.event.shareDetails)"/*, event.isVirtual ? URL(string: event.linkText)!:""*/], applicationActivities: nil)
            })
            //ADD TO CALENDAR
            ZStack {
                Circle().foregroundColor(self.event.isInCalendar ? config.accent : Color.tertiarySystemBackground).clipShape(Circle())
                Image(systemName: "calendar.badge.plus").resizable().frame(width: 22, height: 20).foregroundColor(self.event.isInCalendar ? Color.tertiarySystemBackground : config.accent)
            }.frame(width: 40, height: 40)
                .onTapGesture {
                    self.calendar = true
                    haptic()
            }.actionSheet(isPresented: $calendar) {
                self.config.eventViewModel.manageCalendar(self.event)
            }
            //FAVORITE
            ZStack {
                Circle().foregroundColor(self.event.isFavorite ? config.accent : Color.tertiarySystemBackground).clipShape(Circle())
                Image(systemName: "heart").resizable().frame(width: 20, height: 20).foregroundColor(self.event.isFavorite ? Color.tertiarySystemBackground : config.accent)
            }.frame(width: 40, height: 40)
                .onTapGesture {
                    haptic()
                    self.config.eventViewModel.toggleFavorite(self.event)
            }
            //NAVIGATE
            ZStack {
                Circle().foregroundColor(navigate ? config.accent : Color.tertiarySystemBackground).clipShape(Circle())
                Image(systemName: "location").resizable().frame(width: 20, height: 20).foregroundColor(navigate ? Color.tertiarySystemBackground : config.accent)
            }.frame(width: 40, height: 40)
                .onTapGesture {
                    haptic()
                    self.config.eventViewModel.isVirtual(event: self.event)
                    print("HERE HERE HERE")
                    //if you're trying to navigate to an event and are too far from campus, alert user and don't go to map
                    let locationManager = CLLocationManager()
                    let StetsonUniversity = CLLocation(latitude: 29.0349780, longitude: -81.3026430)
                    if locationManager.location != nil && (CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways) && StetsonUniversity.distance(from: locationManager.location!) > 805 {
                            self.externalAlert = true
                            self.tooFar = true
                            self.navigate = false
                            print("navigate false")
                    } else if self.event.isVirtual { //if you're trying to navigate to a virtual event, alert user and don't go to map
                        //TODO: add in the capability to follow a link to register or something
                        self.externalAlert = true
                        self.isVirtual = true
                        self.navigate = false
                        print("navigate false")
                    } else { //otherwise go to map
                        self.externalAlert = false
                        self.isVirtual = false
                        self.tooFar = false
                        self.navigate = true
                        print("navigate true")
                    }
            }.sheet(isPresented: $navigate, content: {
                ZStack {
                    if self.arMode && !self.event.isVirtual {
                        ARNavigationIndicator(arFindMode: false, navToEvent: self.event, internalAlert: self.$internalAlert, externalAlert: self.$externalAlert, tooFar: self.$tooFar, allVirtual: .constant(false), arrived: self.$arrived, eventDetails: self.$eventDetails).environmentObject(self.config)
                    } else if !self.event.isVirtual { //mapMode
                        MapView(mapFindMode: false, navToEvent: self.event, internalAlert: self.$internalAlert, externalAlert: self.$externalAlert, tooFar: self.$tooFar, allVirtual: .constant(false), arrived: self.$arrived, eventDetails: self.$eventDetails).environmentObject(self.config)
                    }
                    if self.config.appEventMode {
                        ZStack {
                            Text(self.arMode ? "Map View" : "AR View").fontWeight(.light).font(.system(size: 18)).foregroundColor(self.config.accent)
                        }.padding(10)
                            .background(RoundedRectangle(cornerRadius: 15).stroke(Color.clear).foregroundColor(Color.tertiarySystemBackground.opacity(0.8)).background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.tertiarySystemBackground.opacity(0.8))))
                            .onTapGesture { withAnimation { self.arMode.toggle() } }
                            .offset(y: Constants.height*0.4)
                    }
                }.alert(isPresented: self.$internalAlert) { () -> Alert in //done in the view
                    if self.arrived {
                        return self.config.eventViewModel.alert(title: "You've Arrived!", message: "Have fun at \(String(describing: self.event.name!))!")
                    } else if self.eventDetails {
                        return self.config.eventViewModel.alert(title: "\(self.event.name!)", message: "This event is at \(self.event.time!) on \(self.event.date!).")/*, and you are \(distanceFromBuilding!)m from \(event!.location!)*/
                    }
                    return self.config.eventViewModel.alert(title: "ERROR", message: "Please report as a bug.")
                }
            }).alert(isPresented: self.$externalAlert) { () -> Alert in //done outside the view
                if self.isVirtual {
                    return self.config.eventViewModel.alert(title: "Virtual Event", message: "Sorry! This event is virtual, so you have no where to navigate to.")
                } else if self.tooFar {
                    return self.config.eventViewModel.alert(title: "Too Far to Navigate to Event", message: "You're currently too far away from campus to navigate to this event. You can still view it in the map, and once you get closer to campus, can navigate there.")
                }
                return self.config.eventViewModel.alert(title: "ERROR", message: "Please report as a bug.")
            }
        }
    }
    
    //MARK: FOR SHARING
    //scrapes html for links
    func makeLink(text: String) -> String {
        //print("AIUGKSBAKJBKBFEKB")
        let linkPattern = #"(<a href=")(.)+?(?=")"#
        do {
            let linkRegex = try NSRegularExpression(pattern: linkPattern, options: [])
            if linkRegex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) != nil {
                //print("matched")
                let linkCG = linkRegex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text))
                let range = linkCG?.range(at: 0)
                var link:String = (text as NSString).substring(with: range!)
                let scrapeHTMLPattern = #"(<a href=")"#
                let scrapeHTMLRegex = try NSRegularExpression(pattern: scrapeHTMLPattern, options: [])
                link = scrapeHTMLRegex.stringByReplacingMatches(in: link, options: [], range: NSRange(link.startIndex..., in: link), withTemplate: "")
                //print(link)
                if !link.contains("http") && !link.contains("https") { return "" } else { return link }
            }
        } catch { print("Regex error") }
        return ""
    }
    
} //end of Buttons struct

//struct SafariView: UIViewControllerRepresentable {
//    let url: URL
//    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
//        return SFSafariViewController(url: url)
//    }
//    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
//
//    }
//}
//

struct ShareView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]?
    func makeUIViewController(context: UIViewControllerRepresentableContext<ShareView>) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems,
                                        applicationActivities: applicationActivities)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController,
                                context: UIViewControllerRepresentableContext<ShareView>) {
    }
}

//
//struct MailView: UIViewControllerRepresentable {
//
//    @Environment(\.presentationMode) var presentation
//    @Binding var result: Result<MFMailComposeResult, Error>?
//    var email:String
//    var eventName:String
//    var mBody:String = ""
//
//    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
//
//        @Binding var presentation: PresentationMode
//        @Binding var result: Result<MFMailComposeResult, Error>?
//
//        init(presentation: Binding<PresentationMode>,
//             result: Binding<Result<MFMailComposeResult, Error>?>) {
//            _presentation = presentation
//            _result = result
//        }
//
//        func mailComposeController(_ controller: MFMailComposeViewController,
//                                   didFinishWith result: MFMailComposeResult,
//                                   error: Error?) {
//            defer {
//                $presentation.wrappedValue.dismiss()
//            }
//            guard error == nil else {
//                self.result = .failure(error!)
//                return
//            }
//            self.result = .success(result)
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {return Coordinator(presentation: presentation,
//                           result: $result)}
//
//    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
//        let vc = MFMailComposeViewController()
//        vc.setToRecipients([email])
//        vc.setSubject(eventName)
//        vc.setMessageBody(mBody, isHTML: true)
//        vc.mailComposeDelegate = context.coordinator
//        return vc
//    }
//
//    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
//                                context: UIViewControllerRepresentableContext<MailView>) {}
//}
