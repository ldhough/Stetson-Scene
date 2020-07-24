//
//  EventDetailView.swift
//  StetsonScene
//
//  Created by Madison Gipson on 7/15/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import SwiftUI

struct EventDetailView : View {
    @EnvironmentObject var config: Configuration
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var event: EventInstance
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 20).frame(width: Constants.width*0.25, height: 5, alignment: .center).foregroundColor(Color.secondaryLabel.opacity(0.2)).padding(.bottom, 10)
            
                //Event name
                Text(event.name).fontWeight(.medium).font(.system(size: 30)).frame(maxWidth: .infinity, alignment: .center).multilineTextAlignment(.center).foregroundColor(event.hasCultural ? config.accent : Color.label)
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
                    self.navigate.toggle()
                    //GIVE HAPTIC
            }.sheet(isPresented: $navigate, content: {
                NavigationIndicator(arFindMode: false, navToEvent: self.event).environmentObject(self.config)
                //MapView().environmentObject(self.config)
            })
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
