//
//  EventDetailView.swift
//  StetsonScene
//
//  Created by Lannie Hough on 1/9/20.
//  Copyright © 2020 Lannie Hough. All rights reserved.
//
import SwiftUI
import EventKit
import MapKit
import UIKit
import SafariServices
import MessageUI

enum ActiveAlert {
    case success, error
}

///Displays more detailed information about events
struct EventDetailView: View {
    @ObservedObject var event:EventInstance
    var numAttendingState:Int //can probably retire
    @State var isFavorite = false
    @State private var calendarAlert = false
    @State private var activeAlert:ActiveAlert = .success
    @ObservedObject var eventModelController:EventModelController
    @State private var showDetails = false
    @State private var showARNavForm = false
    
    @State private var calendarFill = false
    @State private var navigateFill = false
    @State private var shareFill = false
    
    @State private var linkText:String = ""
    
    @State private var canHitFavorites:Bool = true
    
    @State private var showNavAlert = false
    
    @State var shareDetails:String!
    @State var shareClosing:String!
    @State var virtualEvent:Bool = false
    
    let image = UIImage(named: "App-Icon.png")
    
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var isShowingMailView = false
    @State var alertNoMail = false
    @State var url:NSURL!
    
    @Environment(\.presentationMode)
    var presentationMode: Binding<PresentationMode>
    
    @Environment(\.colorScheme) var colorScheme
    
    var navAlert: Alert {
        Alert(title: Text("Uh oh!"), message: Text("You can't navigate to this event.  It might be virtual, or we might have incomplete data."), dismissButton: .default(Text("Dismiss")))
    }
    
    @State var navMap:Bool = false
    @State var navAR:Bool = false
    @State var safariView:Bool = false
    @State private var safariUrl = ""
    
    func returnToDetailsButton(imageName: String, toggleOrReturn: Bool) -> some View { //true is toggle, false is return to detail view
        Button(action: {
            if toggleOrReturn {
                self.navMap.toggle()
                self.navAR.toggle()
            } else {
                if self.navMap {
                    self.navMap = false
                }
                if self.navAR {
                    self.navAR = false
                }
            }
        }) {
            HStack {
                ZStack {
                    Image(systemName: "square.fill").foregroundColor(self.colorScheme == .dark ? Color.black : Constants.medGray).opacity(self.colorScheme == .dark ? 0.1 : 0.4).scaleEffect(3.0)
                    if imageName == "doc.plaintext" {
                        HStack {
                            Image(systemName: "chevron.left").foregroundColor(Constants.brightYellow).scaleEffect(0.5)
                            Image(systemName: imageName).foregroundColor(Constants.brightYellow).scaleEffect(1.5)
                        }
                    } else {
                        Image(systemName: imageName).foregroundColor(Constants.brightYellow).scaleEffect(1.5)
                    }
                }
            }.padding(toggleOrReturn ? .trailing : .leading, Constants.screenSize.width*0.1).padding(.bottom, Constants.screenSize.height < 700 ? Constants.screenSize.width*0.1 : Constants.screenSize.width*0.05)
        }
    }
    
    var body: some View {
        VStack {
        if navMap {
            ZStack {
                MapNavView(event: event, checkpoints: {
                    return [Checkpoint(title: event.name, coordinate: .init(latitude: Double(event.mainLat)!, longitude: Double(event.mainLon)!))]
                }()).edgesIgnoringSafeArea(.all).edgesIgnoringSafeArea(.all)
                VStack {
                    ZStack {
                        Rectangle().frame(width: Constants.screenSize.width, height: Constants.screenSize.height/9, alignment: .center).opacity(0.1).foregroundColor(self.colorScheme == .dark ? Constants.darkGray : Color.white)
                        Rectangle().foregroundColor(Constants.brightYellow).opacity(0.6).cornerRadius(10).frame(width: Constants.screenSize.width/6, height: 5, alignment: .center).padding(.top, 10)
//                        if self.colorScheme == .dark {
//                        Image(systemName: "chevron.down").foregroundColor(Constants.brightYellow)
//                        }
                    }
                    //Rectangle().foregroundColor(Constants.brightYellow).opacity(0.6).cornerRadius(10).frame(width: Constants.screenSize.width/6, height: 5, alignment: .center).padding(.top, 10)
                    Spacer()
                    HStack {
                        returnToDetailsButton(imageName: "doc.plaintext", toggleOrReturn: false)
                        Spacer()
                        returnToDetailsButton(imageName: "arkit", toggleOrReturn: true)
                    }
                }
            }
        }; if navAR {
            ZStack {
                NavigationIndicator(eventModelController: self.eventModelController, event: self.event, mode: "navigation").edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                    HStack {
                        returnToDetailsButton(imageName: "doc.plaintext", toggleOrReturn: false)
                        Spacer()
                        returnToDetailsButton(imageName: "mappin.and.ellipse", toggleOrReturn: true)
                    }
                }
            }
        }; if !navMap && !navAR {
        ScrollView {
            VStack {
                VStack {
                Rectangle().foregroundColor(self.colorScheme == .dark ? Color.white : Constants.darkGray).opacity(0.6).cornerRadius(10).frame(width: Constants.screenSize.width/6, height: 5, alignment: .center)
                //MAKE EVENT TITLE ALL CAPS
                    Text(event.name).multilineTextAlignment(.center).font(.system(size: 22, weight: .light, design: .default)).foregroundColor(event.hasCultural ? Constants.brightYellow : (self.colorScheme == .dark ? Color.white : Color.black)).padding([.horizontal]).padding([.bottom])
                    Text(self.eventModelController.formatDate(date: self.event.date!)).fixedSize().font(.system(size: 16, weight: .light, design: .default)).foregroundColor(self.colorScheme == .dark ? Color.white : Constants.darkGray)
                    Text(event.time).fixedSize().font(.system(size: 16, weight: .light, design: .default)).foregroundColor(self.colorScheme == .dark ? Color.white : Constants.darkGray).padding(.bottom, 5)
                Divider().background(self.colorScheme == .dark ? Color.white : Constants.darkGray).frame(width: 2*(Constants.screenSize.width/3), height: 10, alignment: .center)
                }
                HStack {
                    //Share
                    Button(action: {
                        self.eventModelController.haptic()
                        self.shareFill.toggle()
                        //if virtual, include url
                        //if cultural credit, include extra text
                        if self.event.mainLon == "0" || self.event.mainLon == "" || self.event.mainLat == "0" || self.event.mainLat == "" {
                            self.virtualEvent = true
                            self.linkText = self.eventModelController.makeLink(text: self.event.eventDescription)
                            if self.linkText == "" {self.virtualEvent = false}
                            print(self.linkText)
                            self.shareDetails = "Check out this event I found via StetsonScene! \(self.event.name!) is happening on \(self.event.date!) at \(self.event.time!)!"
                        } else {
                            self.shareDetails = "Check out this event I found via StetsonScene! \(self.event.name!), on \(self.event.date!) at \(self.event.time!), is happening at the \(self.event.location!)!"
                        }
                    }) {
                        if !shareFill {
                            ZStack {
                                Image(systemName: "square.fill").foregroundColor(self.colorScheme == .dark ? Color.white : Constants.medGray).opacity(0.2).scaleEffect(2.0)
                                Image(systemName: "square.and.arrow.up").foregroundColor(self.colorScheme == .dark ? Color.white : Constants.medGray).scaleEffect(1.0)
                            }
                        } else {
                            ZStack {
                                Image(systemName: "square.fill").foregroundColor(Color.green).scaleEffect(2.0).scaleEffect(shareFill ? 0.9 : 1.0)
                                Image(systemName: "square.and.arrow.up").foregroundColor(self.colorScheme == .dark ? Constants.darkGray : Color.white).scaleEffect(1.0).scaleEffect(shareFill ? 0.9 : 1.0)
                            }
                        }
                    }.sheet(isPresented: $shareFill, content: {
                        //Insert link to app/appstore
                        ShareView(activityItems: [/*"linktoapp.com"*/self.virtualEvent ? URL(string: self.linkText)!:"", self.event.hasCultural ? "\(self.shareDetails!) It’s even offering a cultural credit!" : "\(self.shareDetails!)"/*, self.virtualEvent ? URL(string: self.linkText)!:""*/], applicationActivities: nil)
                    }).padding([.horizontal])
                    
                    //Calendar
                    Button(action: {
                        self.eventModelController.haptic()
                        self.activeAlert = self.eventModelController.manageCalendar(event: self.event)
                        self.calendarAlert = true
                    }) {
                        if !self.event.isInCalendar {
                            ZStack {
                                Image(systemName: "square.fill").foregroundColor(self.colorScheme == .dark ? Color.white : Constants.medGray).opacity(0.2).scaleEffect(2.0)
                                Image(systemName: "calendar").foregroundColor(self.colorScheme == .dark ? Color.white : Constants.medGray).scaleEffect(1.0)
                            }
                        } else {
                            ZStack {
                                Image(systemName: "square.fill").foregroundColor(Constants.brightYellow).scaleEffect(2.0).scaleEffect(shareFill ? 0.9 : 1.0)
                                Image(systemName: "calendar").foregroundColor(self.colorScheme == .dark ? Constants.darkGray : Color.white).scaleEffect(1.0).scaleEffect(calendarFill ? 0.9 : 1.0)
                            }
                        }
                    }.actionSheet(isPresented: $calendarAlert, content: {
                        self.eventModelController.returnActionSheet(event: self.event, activeAlert: activeAlert)
                    }).padding([.horizontal])
                    
                    //Number attending
                    VStack {
                        // CHANGE THESE NUMBERS LATER- JUST FOR DEMO NOW
                        if (self.event.numAttending >= 0 && self.event.numAttending < 2) {
                            Image(systemName: "person.fill").foregroundColor(self.colorScheme == .dark ? Color.white : Constants.medGray).scaleEffect(1.0)//.padding(.bottom, 5)
                        } else if (self.event.numAttending >= 2 && self.event.numAttending < 4) {
                            Image(systemName: "person.2.fill").foregroundColor(self.colorScheme == .dark ? Color.white : Constants.medGray).scaleEffect(1.0)//.padding(.bottom, 5)
                        } else if (self.event.numAttending >= 4) {
                            Image(systemName: "person.3.fill").foregroundColor(self.colorScheme == .dark ? Color.white : Constants.medGray).scaleEffect(1.0)//.padding(.bottom, 5)
                        }
                        Text(String(self.event.numAttending!)).font(.system(size: 14, weight: .light, design: .default)).foregroundColor(self.colorScheme == .dark ? Color.white : Constants.medGray).scaleEffect(0.8)
                    }.padding([.horizontal])
                    
                    //Favorite
                    Button(action: {
                        self.eventModelController.manageFavorites(event: self.event)
                    }) {
                        if !self.event.isFavorite {
                            ZStack {
                                Image(systemName: "square.fill").foregroundColor(self.colorScheme == .dark ? Color.white : Constants.medGray).opacity(0.2).scaleEffect(2.0)
                                Image(systemName: "heart").foregroundColor(self.colorScheme == .dark ? Color.white : Constants.medGray).scaleEffect(1.0)
                            }
                        } else {
                            ZStack {
                                Image(systemName: "square.fill").foregroundColor(Color.pink).scaleEffect(2.0).scaleEffect(shareFill ? 0.9 : 1.0)
                                Image(systemName: "heart").foregroundColor(self.colorScheme == .dark ? Constants.darkGray : Color.white).scaleEffect(1.0).scaleEffect(isFavorite ? 0.9 : 1.0)
                            }
                        }
                    }.padding([.horizontal])
                    
                    //Navigate
                    Button(action: {
                        self.eventModelController.haptic()
                        if self.event.mainLon == "0" || self.event.mainLon == "" || self.event.mainLat == "0" || self.event.mainLat == "" {
                            self.linkText = self.eventModelController.makeLink(text: self.event.eventDescription)
                            if self.linkText != "" {
                                self.safariUrl = self.linkText
                                if self.eventModelController.verifyUrl(urlString: self.safariUrl) {self.safariView.toggle()}
                            } else {self.showNavAlert.toggle()}
                        } else {
                        self.navMap.toggle()
                        }
                    }) {
                        if !navigateFill {
                            ZStack {
                                Image(systemName: "square.fill").foregroundColor(self.colorScheme == .dark ? Color.white : Constants.medGray).opacity(0.2).scaleEffect(2.0)
                                Image(systemName: "location.fill").foregroundColor(self.colorScheme == .dark ? Color.white : Constants.medGray).scaleEffect(1.0)
                            }
                        } else {
                            ZStack {
                                Image(systemName: "square.fill").foregroundColor(Color.blue).scaleEffect(2.0).scaleEffect(shareFill ? 0.9 : 1.0)
                                Image(systemName: "location.fill").foregroundColor(self.colorScheme == .dark ? Constants.darkGray : Color.white).scaleEffect(1.0).scaleEffect(navigateFill ? 0.9 : 1.0)
                            }
                        }
                    }.sheet(isPresented: $safariView) {
                        SafariView(url:URL(string: self.linkText)!)
                    }.padding([.horizontal])
                }.padding([.horizontal])
                //Description
                VStack {
                Text(scrapeHTMLTags(text: event.eventDescription)).multilineTextAlignment(.leading).font(.system(size: 16, weight: .light, design: .default)).foregroundColor(self.colorScheme == .dark ? Color.white : Constants.medGray).padding([.horizontal]).padding(.vertical)
                //More details
                Button(action: {
                    self.showDetails.toggle()
                    self.linkText = self.eventModelController.makeLink(text: self.event.eventDescription)
                }) {
                    Text("Details").font(.system(size: 14, weight: .light, design: .default)).foregroundColor(Constants.brightYellow)
                }.actionSheet(isPresented: $showDetails, content: {
                    ActionSheet(title: Text("Details"),
                                message: Text("This event is located at \(event.location!), \(event.mainAddress!). It is being hosted by \(event.contactName!)."),
                    buttons: [.default(Text("Navigate to \(event.name)"), action: {
                         self.navMap.toggle()
                    }),
                              .default(Text("Email \(event.contactName!)"), action: {
                                if MFMailComposeViewController.canSendMail() {
                                    self.isShowingMailView.toggle()
                                } else {
                                    self.alertNoMail.toggle()
                                }
                              }),
                              .default(Text("Call \(event.contactName!)"), action: {
                                self.url = URL(string: "tel://" + self.event.contactPhone!.trimmingCharacters(in: CharacterSet(charactersIn: "-")))! as NSURL
                                UIApplication.shared.open(self.url as URL)
                              }),
                              .destructive(Text("Cancel"), action: {
                              })])
                })
                    .sheet(isPresented: $isShowingMailView) {MailView(result: self.$result, email: self.event.contactMail, eventName: self.event.name)}.alert(isPresented: self.$alertNoMail) {
                        Alert(title: Text("Mail not set up on this phone!"))
                    }
                } //end of description vstack
            }
        }.padding([.horizontal]).padding([.vertical])
        } //if end
        }.alert(isPresented: $showNavAlert, content: {self.navAlert})
    }
    
    ///Function removes carryover HTML tags & elements from the event descriptions
    func scrapeHTMLTags(text: String) -> String {
        let scrapeHTMLPattern = #"<[^>]+>"#
        let nbspPattern = #"&\w+;"#
        let paragraphPattern = #"</p>"#
        do {
            let scrapeHTMLRegex = try NSRegularExpression(pattern: scrapeHTMLPattern, options: [])
            let nbspRegex = try NSRegularExpression(pattern: nbspPattern, options: [])
            let paragraphRegex = try NSRegularExpression(pattern: paragraphPattern, options: [])
            var scrapedString = paragraphRegex.stringByReplacingMatches(in: text, options: [], range: NSRange(text.startIndex..., in: text), withTemplate: "\n")
            scrapedString = scrapeHTMLRegex.stringByReplacingMatches(in: scrapedString, options: [], range: NSRange(text.startIndex..., in: scrapedString), withTemplate: "")
            scrapedString = nbspRegex.stringByReplacingMatches(in: scrapedString, options: [], range: NSRange(scrapedString.startIndex..., in: scrapedString), withTemplate: " ")
            return scrapedString
        } catch { print("Regex error") }
        return text
    }
    
    func formatPhoneNumber(number: String) -> String {
        var chars = number.map() {
            String($0)
        }
        if chars.count != 10 {
            return number
        } else {
            chars.insert("(", at: 0)
            chars.insert(")", at: 4)
            chars.insert(" ", at: 5)
            chars.insert("-", at: 9)
            let phone:String = {
                var str:String = ""
                for i in chars {
                    str += i
                }
                return str
            }()
            return phone
        }
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {

    }
}

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

struct MailView: UIViewControllerRepresentable {

    @Environment(\.presentationMode) var presentation
    @Binding var result: Result<MFMailComposeResult, Error>?
    var email:String
    var eventName:String
    var mBody:String = ""

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {

        @Binding var presentation: PresentationMode
        @Binding var result: Result<MFMailComposeResult, Error>?

        init(presentation: Binding<PresentationMode>,
             result: Binding<Result<MFMailComposeResult, Error>?>) {
            _presentation = presentation
            _result = result
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            defer {
                $presentation.wrappedValue.dismiss()
            }
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            self.result = .success(result)
        }
    }

    func makeCoordinator() -> Coordinator {return Coordinator(presentation: presentation,
                           result: $result)}

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients([email])
        vc.setSubject(eventName)
        vc.setMessageBody(mBody, isHTML: true)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailView>) {}
}
