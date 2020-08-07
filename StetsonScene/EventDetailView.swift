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
    @ObservedObject var evm:EventViewModel
    @EnvironmentObject var config: Configuration
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var event: EventInstance
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 20).frame(width: Constants.width*0.25, height: 5, alignment: .center).foregroundColor(Color.secondaryLabel.opacity(0.2)).padding(.bottom, 10)
            //Event name
            Text(event.name).fontWeight(.medium).font(.system(size: 30)).frame(maxWidth: .infinity, alignment: .center).multilineTextAlignment(.center).foregroundColor(event.hasCultural ? config.accent : Color.label).padding([.horizontal, .vertical])
            //Info row
           Text("\(event.date) | \(event.location) | \(event.time)").fontWeight(.light).font(.system(size: 20)).frame(maxWidth: Constants.width, alignment: .center).foregroundColor(event.hasCultural ? Color.label : config.accent)
            //Buttons
            Buttons(evm: self.evm, event: event).padding(.vertical, 5)
            //Divider
            Rectangle().frame(width: Constants.width*0.75, height: 1, alignment: .center).foregroundColor(Color.secondaryLabel.opacity(0.2)).padding(.vertical, 10)
            
            ScrollView {
                //Description
                Text(event.eventDescription!).fontWeight(.light).font(.system(size: 16)).multilineTextAlignment(.leading).foregroundColor(Color.label).padding(.horizontal, 10)
                Text("DETAILS").fontWeight(.light).font(.system(size: 16)).foregroundColor(config.accent).padding(.top)
            }.padding([.horizontal]).padding(.bottom, 5)
        }.background(Color.secondarySystemBackground).edgesIgnoringSafeArea(.bottom)
    }
}

struct Buttons: View {
    @ObservedObject var evm:EventViewModel
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
                    haptic()
                    self.share.toggle()
                    self.evm.isVirtual(event: self.event)
                    if self.event.isVirtual {
                        self.event.linkText = self.evm.makeLink(text: self.event.eventDescription)
                            if self.event.linkText == "" { self.event.isVirtual = false }
                            self.event.shareDetails = "Check out this event I found via StetsonScene! \(self.event.name!) is happening on \(self.event.date!) at \(self.event.time!)!"
                    } else {
                            self.event.shareDetails = "Check out this event I found via StetsonScene! \(self.event.name!), on \(self.event.date!) at \(self.event.time!), is happening at the \(self.event.location!)!"
                    }
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
                    haptic()
                    self.calendar = true
            }.actionSheet(isPresented: $calendar) {
                self.evm.manageCalendar(self.event)
            }
            //NUMATTENDING- not a button
            VStack {
                Image(systemName: "person.fill").resizable().frame(width: 16, height: 16).foregroundColor(config.accent)
                Text(String(event.numAttending)).fontWeight(.light).font(.system(size: 12)).foregroundColor(config.accent)
            }
            //FAVORITE
            ZStack {
                Circle().foregroundColor(self.event.isFavorite ? config.accent : Color.tertiarySystemBackground).clipShape(Circle())
                Image(systemName: "heart").resizable().frame(width: 20, height: 20).foregroundColor(self.event.isFavorite ? Color.tertiarySystemBackground : config.accent)
            }.frame(width: 40, height: 40)
                .onTapGesture {
                    haptic()
                    self.evm.toggleFavorite(self.event)
            }
            //NAVIGATE
            ZStack {
                Circle().foregroundColor(navigate ? config.accent : Color.tertiarySystemBackground).clipShape(Circle())
                Image(systemName: "location").resizable().frame(width: 20, height: 20).foregroundColor(navigate ? Color.tertiarySystemBackground : config.accent)
            }.frame(width: 40, height: 40)
                .onTapGesture {
                    haptic()
                    self.evm.isVirtual(event: self.event)
                    //if you're trying to navigate to an event and are too far from campus, alert user and don't go to map
                    let locationManager = CLLocationManager()
                    let StetsonUniversity = CLLocation(latitude: 29.0349780, longitude: -81.3026430)
                    if !self.event.isVirtual && locationManager.location != nil && (CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways) && StetsonUniversity.distance(from: locationManager.location!) > 805 {
                            self.externalAlert = true
                            self.tooFar = true
                            self.navigate = false
                    } else if self.event.isVirtual { //if you're trying to navigate to a virtual event, alert user and don't go to map
                        //TODO: add in the capability to follow a link to register or something
                        self.externalAlert = true
                        self.isVirtual = true
                        self.navigate = false
                    } else { //otherwise go to map
                        self.externalAlert = false
                        self.isVirtual = false
                        self.tooFar = false
                        self.navigate = true
                    }
            }.sheet(isPresented: $navigate, content: {
                ZStack {
                    if self.arMode && !self.event.isVirtual {
                        ARNavigationIndicator(evm: self.evm, arFindMode: false, navToEvent: self.event, internalAlert: self.$internalAlert, externalAlert: self.$externalAlert, tooFar: .constant(false), allVirtual: .constant(false), arrived: self.$arrived, eventDetails: self.$eventDetails).environmentObject(self.config)
                    } else if !self.event.isVirtual { //mapMode
                        MapView(evm: self.evm, mapFindMode: false, navToEvent: self.event, internalAlert: self.$internalAlert, externalAlert: self.$externalAlert, tooFar: .constant(false), allVirtual: .constant(false), arrived: self.$arrived, eventDetails: self.$eventDetails).environmentObject(self.config)
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
                        return self.evm.alert(title: "You've Arrived!", message: "Have fun at \(String(describing: self.event.name!))!")
                    } else if self.eventDetails {
                        return self.evm.alert(title: "\(self.event.name!)", message: "This event is at \(self.event.time!) on \(self.event.date!).")/*, and you are \(distanceFromBuilding!)m from \(event!.location!)*/
                    }
                    return self.evm.alert(title: "ERROR", message: "Please report as a bug.")
                }
            }).alert(isPresented: self.$externalAlert) { () -> Alert in //done outside the view
                if self.isVirtual {
                    return self.evm.alert(title: "Virtual Event", message: "Sorry! This event is virtual, so you have no where to navigate to.")
                } else if self.tooFar {
                    //return self.evm.alert(title: "Too Far to Navigate to Event", message: "You're currently too far away from campus to navigate to this event. You can still view it in the map, and once you get closer to campus, can navigate there.")
                    return self.evm.navAlert(lat: self.event.mainLat, lon: self.event.mainLon)
                }
                return self.evm.alert(title: "ERROR", message: "Please report as a bug.")
            }
        }
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
