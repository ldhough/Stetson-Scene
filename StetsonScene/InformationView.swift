//
//  InformationView.swift
//  StetsonScene
//
//  Created by Madison Gipson on 7/15/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import SwiftUI
import MessageUI

enum AccentColors: String {
    case pink = "pink"
    case red = "red"
    case orange = "orange"
    case yellow = "yellow"
    case green = "green"
    case teal = "teal"
    case blue = "blue"
    case indigo = "indigo"
    case purple = "purple"
}

func setColor(_ color: String) -> (Color, UIColor) {
    switch color {
    case "pink":
        return (Color(UIColor.systemPink), UIColor.systemPink)
    case "red":
        return (Color(UIColor.systemRed), UIColor.systemRed)
    case "orange":
        return (Color(UIColor.systemOrange), UIColor.systemOrange)
    case "yellow":
        return (Color(UIColor.systemYellow), UIColor.systemYellow)
    case "green":
        return (Color(UIColor.systemGreen), UIColor.systemGreen)
    case "teal":
        return (Color(UIColor.systemTeal), UIColor.systemTeal)
    case "blue":
        return (Color(UIColor.systemBlue), UIColor.systemBlue)
    case "indigo":
        return (Color(UIColor.systemIndigo), UIColor.systemIndigo)
    case "purple":
        return (Color(UIColor.systemPurple), UIColor.systemPurple)
    default:
        return (Color(UIColor.systemPink), UIColor.systemPink)
    }
}

struct InformationView: View {
    @EnvironmentObject var config: Configuration
    @State var overview: Bool = true
    @State var alertNoMail = false
    @State var bugReport = false
    @State var feedback = false
    @State var result: Result<MFMailComposeResult, Error>? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Information").fontWeight(.heavy).font(.system(size: 50)).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(Color.label).padding([.top]).padding(.bottom, 10)
            if overview {
                InformationRow(accentColor: self.config.accent, title: "Change Theme", description: "Choose a new accent color to use throughout the application.", image: "slider.horizontal.below.rectangle").onTapGesture { self.overview = false }
                InformationRow(accentColor: self.config.accent, title: "Submit Bug Report", description: "Let us know if you find something weird or broken so we can fix it!", image: "ant.fill").onTapGesture {
                            MFMailComposeViewController.canSendMail() ? self.bugReport.toggle() : self.alertNoMail.toggle()
                        }.sheet(isPresented: $bugReport) {
                            MailView(result: self.$result, email: "stetsonscene@gmail.com", eventName: "StetsonScene Bug Report", mBody: "<p> </p>")
                        }
                InformationRow(accentColor: self.config.accent, title: "Give Us Feedback", description: "Suggestions are encouraged! We want to make this app the best it can, so let us know if you have any ideas for improvements.", image: "ellipses.bubble.fill").onTapGesture {
                        MFMailComposeViewController.canSendMail() ? self.feedback.toggle() : self.alertNoMail.toggle()
                    }.sheet(isPresented: $feedback) {
                        MailView(result: self.$result, email: "stetsonscene@gmail.com", eventName: "StetsonScene Feedback", mBody: "<p> </p>")
                    }
                InformationRow(accentColor: self.config.accent, title: "Switch to \(config.appEventMode ? "Tour" : "Event") Mode", description: "Use the app to \(config.appEventMode ? "tour campus and explore buildings." : "find events.")", image: config.appEventMode ? "house.fill" : "calendar").onTapGesture { self.config.appEventMode.toggle() }
            } else {
                InformationRow(accentColor: self.config.accent, title: "Change Theme", description: "Choose a new accent color to use throughout the application.", image: "slider.horizontal.below.rectangle").onTapGesture { self.overview = true }
                ColorPicker(overview: $overview).environmentObject(config).padding(.vertical, 20)
            }
            Spacer()
        }.alert(isPresented: self.$alertNoMail) {
                Alert(title: Text("Mail not set up on this phone!"))
        }.padding([.horizontal])
    }
}

struct InformationRow: View {
    var accentColor: Color
    var title: String
    var description: String
    var image: String
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: image).resizable().frame(width: 25, height: 25).foregroundColor(accentColor).padding()
            VStack(alignment: .leading) {
                Text(title).font(.headline).foregroundColor(Color.label)
                Text(description).font(.body).foregroundColor(Color.secondaryLabel)
            }
        }.padding([.horizontal]).padding(.vertical, 5)
    }
}

struct ColorPicker: View {
    @EnvironmentObject var config: Configuration
    @Binding var overview: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 50) {
            HStack(alignment: .center, spacing: 50) {
                Circle().fill(Color(UIColor.systemPink)).frame(width: 50, height: 50)
                .onTapGesture{
                    color = "pink"
                    let res = setColor(color)
                    self.config.accent = res.0
                    self.config.accentUIColor = res.1
                    self.overview = true
                }
                Circle().fill(Color(UIColor.systemRed)).frame(width: 50, height: 50)
                .onTapGesture{
                    color = "red"
                    let res = setColor(color)
                    self.config.accent = res.0
                    self.config.accentUIColor = res.1
                    self.overview = true
                }
                Circle().fill(Color(UIColor.systemOrange)).frame(width: 50, height: 50)
                .onTapGesture{
                    color = "orange"
                    let res = setColor(color)
                    self.config.accent = res.0
                    self.config.accentUIColor = res.1
                    self.overview = true
                }
            }
            HStack(alignment: .center, spacing: 50) {
                Circle().fill(Color(UIColor.systemYellow)).frame(width: 50, height: 50)
                .onTapGesture{
                    color = "yellow"
                    let res = setColor(color)
                    self.config.accent = res.0
                    self.config.accentUIColor = res.1
                    self.overview = true
                }
                Circle().fill(Color(UIColor.systemGreen)).frame(width: 50, height: 50)
                .onTapGesture{
                    color = "green"
                    let res = setColor(color)
                    self.config.accent = res.0
                    self.config.accentUIColor = res.1
                    self.overview = true
                }
                Circle().fill(Color(UIColor.systemTeal)).frame(width: 50, height: 50)
                .onTapGesture{
                    color = "teal"
                    let res = setColor(color)
                    self.config.accent = res.0
                    self.config.accentUIColor = res.1
                    self.overview = true
                }
            }
            HStack(alignment: .center, spacing: 50) {
                Circle().fill(Color(UIColor.systemBlue)).frame(width: 50, height: 50)
                .onTapGesture{
                    color = "blue"
                    let res = setColor(color)
                    self.config.accent = res.0
                    self.config.accentUIColor = res.1
                    self.overview = true
                }
                Circle().fill(Color(UIColor.systemIndigo)).frame(width: 50, height: 50)
                .onTapGesture{
                    color = "indigo"
                    let res = setColor(color)
                    self.config.accent = res.0
                    self.config.accentUIColor = res.1
                    self.overview = true
                }
                Circle().fill(Color(UIColor.systemPurple)).frame(width: 50, height: 50)
                .onTapGesture{
                    color = "purple"
                    let res = setColor(color)
                    self.config.accent = res.0
                    self.config.accentUIColor = res.1
                    self.overview = true
                }
            }
        }.frame(maxWidth: .infinity, alignment: .center).padding([.horizontal])
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
