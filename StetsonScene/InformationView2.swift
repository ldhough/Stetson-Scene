////
////  InformationView.swift
////  StetsonScene
////
////  Created by Lannie Hough on 4/29/20.
////  Copyright © 2020 Madison Gipson. All rights reserved.
////
//
//import SwiftUI
//import MessageUI
//
//struct InformationView: View {
//    @ObservedObject var eventModelController:EventModelController
//    @State var isShowingMailView = false
//    @State var isShowingBugReportView = false
//    @State var alertNoMail = false
//    @State var isShowingHelpView = false
//    @State var result: Result<MFMailComposeResult, Error>? = nil
//    @Environment(\.colorScheme) var colorScheme
//    
////    func haptic() {
////        print("activated haptic")
////        let generator = UINotificationFeedbackGenerator()
////        generator.notificationOccurred(.success)
////    }
//    
//    var body: some View {
//        
//        VStack/*(alignment: .leading)*/ {
//            Button(action: {
//                self.eventModelController.haptic()
//                if MFMailComposeViewController.canSendMail() {
//                    self.isShowingMailView.toggle()
//                } else {
//                    self.alertNoMail.toggle()
//                }
//            }) {
//                ZStack {
//                    RoundedRectangle(cornerRadius: 10).foregroundColor(colorScheme == .dark ? Constants.medGray : Constants.brightYellow).frame(width: Constants.screenSize.width*0.9, height: Constants.screenSize.height/10, alignment: .center)
//
//                    HStack {
//                        Text("Submit Feedback").foregroundColor(colorScheme == .dark ? Constants.brightYellow : Color.white).padding()
//                        Spacer()
//                        Image(systemName: "text.bubble").foregroundColor(colorScheme == .dark ? Constants.brightYellow : Color.white).scaleEffect(1.5).padding()
//                    }
//                }.padding()
//            }.sheet(isPresented: $isShowingMailView) {MailView(result: self.$result, email: "stetsonscene@gmail.com", eventName: "StetsonScene Feedback", mBody: "<p>Feedback here:</p>")}.alert(isPresented: self.$alertNoMail) {
//                    Alert(title: Text("Mail not set up on this phone!"))
//                }
//            Button(action: {
//                self.eventModelController.haptic()
//                if MFMailComposeViewController.canSendMail() {
//                    self.isShowingBugReportView.toggle()
//                } else {
//                    self.alertNoMail.toggle()
//                }
//            }) {
//                ZStack {
//                    RoundedRectangle(cornerRadius: 10).foregroundColor(colorScheme == .dark ? Constants.medGray : Constants.brightYellow).frame(width: Constants.screenSize.width*0.9, height: Constants.screenSize.height/10, alignment: .center)
//
//                    HStack {
//                        Text("Submit Bug Report").foregroundColor(colorScheme == .dark ? Constants.brightYellow : Color.white).padding()
//                        Spacer()
//                        Image(systemName: "ant.circle").foregroundColor(colorScheme == .dark ? Constants.brightYellow : Color.white).scaleEffect(1.5).padding()
//                    }
//                }.padding()
//            }.sheet(isPresented: $isShowingBugReportView) {MailView(result: self.$result, email: "stetsonscene@gmail.com", eventName: "StetsonScene Bug Report", mBody: "<p>Description of bug/glitch:</p><p>Describe what you were doing when the bug or glitch happened, be as descriptive as possible:</p>")}.alert(isPresented: self.$alertNoMail) {
//                    Alert(title: Text("Mail not set up on this phone!"))
//                }
//            Button(action: {
//                self.eventModelController.haptic()
//                self.isShowingHelpView.toggle()
//            }) {
//                ZStack {
//                    RoundedRectangle(cornerRadius: 10).foregroundColor(colorScheme == .dark ? Constants.medGray : Constants.brightYellow).frame(width: Constants.screenSize.width*0.9, height: Constants.screenSize.height/10, alignment: .center)
//
//                    HStack {
//                        Text("Help").foregroundColor(colorScheme == .dark ? Constants.brightYellow : Color.white).padding()
//                        Spacer()
//                        Image(systemName: "questionmark.circle").foregroundColor(colorScheme == .dark ? Constants.brightYellow : Color.white).scaleEffect(1.5).padding()
//                    }
//                }.padding()
//            }.sheet(isPresented: $isShowingHelpView) {HelpView()}
//            Button(action: {
//                self.eventModelController.haptic()
//                self.eventModelController.eventMode.toggle()
//                print("eventMode: ", self.eventModelController.eventMode)
//            }) {
//                ZStack {
//                    RoundedRectangle(cornerRadius: 10).foregroundColor(colorScheme == .dark ? Constants.medGray : Constants.brightYellow).frame(width: Constants.screenSize.width*0.9, height: Constants.screenSize.height/10, alignment: .center)
//
//                    HStack {
//                        Text(self.eventModelController.eventMode ? "Switch to Tour Campus Mode" : "Switch to Event Mode").foregroundColor(colorScheme == .dark ? Constants.brightYellow : Color.white).padding()
//                        Spacer()
//                        Image(systemName: self.eventModelController.eventMode ? "map" : "calendar.circle").foregroundColor(colorScheme == .dark ? Constants.brightYellow : Color.white).scaleEffect(1.5).padding()
//                    }
//                }.padding()
//            }
//            Spacer()
//        }.background(colorScheme == .dark ? Constants.darkGray : Color.white)
//    }
//}
//
//struct HelpView: View {
//    @Environment(\.colorScheme) var colorScheme
//
//    func returnBulletText(text: String) -> some View {
//        HStack {
//            Image(systemName: "circle.fill").foregroundColor(colorScheme == .dark ? Color.white : Color.black).scaleEffect(0.5)
//            Text(text).lineLimit(999).multilineTextAlignment(.leading)
//        }.padding(.horizontal, 10).alignmentGuide(.leading, computeValue: {_ in return 10.0})
//    }
//
//    func returnNavBulletText() -> some View {
//        VStack(alignment: .leading) {
//            returnBulletText(text: "After clicking an event from any list of events, the navigation arrow will open up a map.")
//            returnBulletText(text: "While navigating, you have the option to swap between navigating by map or by augmented reality.  Toggle between the two with the button in the bottom right of the navigation screen.")
//            returnBulletText(text: "You can also access navigation from lists by way of a 'hard press' on the event cells.")
//        }
//    }
//
//    func returnSearchBulletText() -> some View {
//        VStack(alignment: .leading) {
//            returnBulletText(text: "You can search for events by name using the searchbar at the top of the main 'event list' screen.  You can erase your text with the 'X' that will appear when you enter text.")
//            returnBulletText(text: "Select 'Custom Search' near the top of the main event list screen to do a more advanced filter of events.")
//            returnBulletText(text: "The next week worth of events is loaded into the app by default.  Load more events with the slider in custom search.")
//            returnBulletText(text: "The M-S icons allow you to filter by specific days of the week.  If none are selected it will be the same as if they were all selected.")
//            returnBulletText(text: "Custom search also allows you to filter by specific event types, and provides an option to only show events which have cultural credit opportunities.")
//        }
//    }
//
//    func returnFavBulletText() -> some View {
//        VStack(alignment: .leading) {
//            returnBulletText(text: "StetsonScene is fully integrated with your Apple calendar.  While looking at an event, tap the calendar icon to add it to your calendar.  You have the option to add it with or without an alert which will occur shortly before the event as a reminder.")
//            returnBulletText(text: "'Favoriting' an event gives you an in-app way to remember which events you are interested in.  When you favorite an event, it will show up on your favorite screen and be used to influence our recommendations to you about which events to attend.")
//            returnBulletText(text: "The number next to the favorite button and underneath the person icon indicates how many app users have favorited that event as a measure of popularity.")
//        }
//    }
//
//    func returnDeveloperText() -> some View {
//        VStack(alignment: .leading) {
//            returnBulletText(text: "Madison Gipson")
//            returnBulletText(text: "Lannie Dalton Hough")
//            returnBulletText(text: "Aaron Stewart")
//        }
//    }
//
//    var body: some View {
//        VStack {
//            Text("Help").font(.system(size: 22, weight: .heavy, design: .default)).foregroundColor(Constants.brightYellow).padding([.horizontal]).padding([.top])
//            Divider().background(self.colorScheme == .dark ? Color.white : Constants.darkGray).frame(width: 2*(Constants.screenSize.width/3), height: 10, alignment: .center)
//            ScrollView {
//                VStack(alignment: .leading) {
//                    HStack {
//                        Text("Navigating").font(.system(size: 18, weight: .medium, design: .default)).foregroundColor(Constants.brightYellow).padding()
//                        Spacer()
//                    }
//                    returnNavBulletText()
//                    HStack {
//                        Text("Searching").font(.system(size: 18, weight: .medium, design: .default)).foregroundColor(Constants.brightYellow).padding()
//                        Spacer()
//                    }
//                    returnSearchBulletText()
//                    HStack {
//                        Text("Favorite and Calendar").font(.system(size: 18, weight: .medium, design: .default)).foregroundColor(Constants.brightYellow).padding()
//                        Spacer()
//                    }
//                    returnFavBulletText()
//                    HStack {
//                        Text("Developers").font(.system(size: 18, weight: .medium, design: .default)).foregroundColor(Constants.brightYellow).padding()
//                        Spacer()
//                    }
//                    returnDeveloperText()
//                }
//            }
//        }
//    }
//}
//
////    var mBody:String = ""
////        vc.setMessageBody(mBody, isHTML: true)
////&& self.eventModelController.dataReturnedFromSnapshot
