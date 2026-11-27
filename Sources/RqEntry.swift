import SwiftUI
import UniformTypeIdentifiers

@main struct RqLaunch:App {
 @StateObject private var q=RqVault()
 @Environment(\.scenePhase) private var phase
 var body:some Scene{WindowGroup{RqRoot().environmentObject(q).tint(RqPaint.green).preferredColorScheme(.light).task{await q.notifications()}.onChange(of:phase){_,x in if x == .active{Task{await q.notifications()}}}}}
}
enum RqPaint {
 static let green=Color(red:0,green:0.49,blue:0.27)
 static let yellow=Color(red:1,green:0.875,blue:0)
 static let ink=Color(red:0.04,green:0.165,blue:0.10)
 static let mist=Color(red:0.94,green:0.96,blue:0.935)
}
struct RqSettings:View {
 @EnvironmentObject var q:RqVault;@Environment(\.dismiss) var dismiss
 @State private var erase=false;@State private var notification=false;@State private var picking=false
 var body:some View {NavigationStack{Form{
  Section(rqL("Organizer profile")) {
   TextField(rqL("Display name"),text:$q.box.nickname).onChange(of:q.box.nickname){_,_ in q.write()}
  }
  Section(rqL("Round reminders")) {
   Toggle(rqL("Upcoming rounds and missing reports"),isOn:Binding(get:{q.box.reminders},set:{on in Task{await q.reminders(on)}}))
   Text(rqL("A reminder one day before each round and a report reminder two hours after kickoff. Changes are checked when the app opens.")).font(.footnote).foregroundStyle(.secondary)
   Button(rqL("Open notification settings")){if let u=URL(string:UIApplication.openNotificationSettingsURLString){UIApplication.shared.open(u)}}
  }
  Section{Text(rqL("Choose a file to open, or send a copy directly to someone. Changes stay on this device until you share again."));Button(rqL("Open a shared file")){picking=true}
  }
  Section(rqL("Privacy and help")) {
   Text(rqL("The owner of a shared tournament keeps its results when you leave. Ask the owner to remove personal information from their copy.")).font(.footnote).foregroundStyle(.secondary)
   Button(rqL("Delete profile and all tournaments"),role:.destructive){erase=true}.disabled(q.busy)
  }
 }.navigationTitle(rqL("Settings")).toolbar{ToolbarItem(placement:.confirmationAction){Button(rqL("Done")){dismiss()}}}
  .fileImporter(isPresented:$picking,allowedContentTypes:[.json]){if case let .success(u)=$0{q.acceptCup(u)}}.confirmationDialog(rqL("Delete profile and all tournaments?"),isPresented:$erase,titleVisibility:.visible){Button(rqL("Delete everything"),role:.destructive){Task{await q.erase()}}}
 .alert(rqL("Please check"),isPresented:Binding(get:{!q.alert.isEmpty},set:{if !$0{q.dismissAlert()}})){Button(rqL("OK")){q.alert=""}}message:{Text(q.alert)}
 }}
}
