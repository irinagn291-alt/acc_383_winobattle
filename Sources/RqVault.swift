import SwiftUI
import WidgetKit
import UserNotifications
import UIKit

@MainActor final class RqVault:ObservableObject {
 @Published var box=RqArchive();@Published var alert="";@Published var busy=false;@Published var status="";@Published var share: RqShareItem?
 static weak var current:RqVault?
 private var n8=0
 private let disk:URL
 var active:RqS? {box.tournaments.first{$0.id == box.selected} ?? box.tournaments.first}
 var voter:String {box.voter}
 func dismissAlert(){let shown=alert;Task{@MainActor [weak self] in guard let self,self.alert == shown else{return};self.alert=""}}
 init() {
  let dir=FileManager.default.urls(for:.applicationSupportDirectory,in:.userDomainMask)[0]
  disk=dir.appendingPathComponent("neighborhood-v3.json")
  if FileManager.default.fileExists(atPath:disk.path) {
   do {box=try JSONDecoder().decode(RqArchive.self,from:Data(contentsOf:disk))}
   catch {alert=rqL("Saved data could not be opened. A recovery copy is kept on this device.");try? FileManager.default.copyItem(at:disk,to:dir.appendingPathComponent("recovery-\(Int(Date().timeIntervalSince1970)).json"))}
  }
  Self.current=self;write()
   box.identity="";box.cloud=false
 }
 func write() {
  do {try FileManager.default.createDirectory(at:disk.deletingLastPathComponent(),withIntermediateDirectories:true);try JSONEncoder().encode(box).write(to:disk,options:[.atomic,.completeFileProtectionUntilFirstUserAuthentication])}
  catch {alert=rqL("The device could not save changes. Free some storage and try again.")}
  if let a=active, !a.example {
   let cache=RqCache(title:a.title,knockout:a.knockout,date:a.next?.date,match:a.next.map{a.team($0.a)+" · "+a.team($0.b)} ?? rqL("Round complete"),rows:Array(a.table.prefix(6)),fixtures:Array(a.games.filter{!$0.done && $0.a != nil && $0.b != nil && $0.round == a.next?.round}.prefix(3).map{a.team($0.a)+" – "+a.team($0.b)+" · "+$0.date.formatted(.dateTime.hour().minute())}),bracket:Array(a.games.suffix(3).map{a.team($0.a)+" – "+a.team($0.b)}),updated:a.stamp)
   if let url=FileManager.default.containerURL(forSecurityApplicationGroupIdentifier:rqGroup)?.appendingPathComponent("round-cache.json") {try? JSONEncoder().encode(cache).write(to:url,options:.atomic)}
  } else if let url=FileManager.default.containerURL(forSecurityApplicationGroupIdentifier:rqGroup)?.appendingPathComponent("round-cache.json"){try? FileManager.default.removeItem(at:url)}
  WidgetCenter.shared.reloadAllTimelines()
 }
 func add(_ s:RqS){box.tournaments.append(s);box.selected=s.id;write();Task{await notifications()}}
 func replace(_ s:RqS){if let i=box.tournaments.firstIndex(where:{$0.id == s.id}){box.tournaments[i]=RqS.merge(box.tournaments[i],s)};write();Task{await notifications()}}
 func mayEdit(_ s:RqS)->Bool {box.links[s.id]?.writable ?? true}
 func owner(_ s:RqS)->Bool {!(box.links[s.id]?.shared ?? false)}
 func report(_ m:RqM,in s:RqS) {
  guard let live=box.tournaments.first(where:{$0.id == s.id}),let old=live.games.first(where:{$0.id == m.id}),old.a == m.a,old.b == m.b else{alert=rqL("This report no longer matches the bracket.");return}
  guard mayEdit(live) else{alert=rqL("Your invitation no longer allows changes. Ask the organizer to check access.");return}
  guard live.valid(m) else{alert=rqL("Check the score, penalties and scorers.");return}
  var t=live;var g=m;g.stamp=Date();g.author=voter
  if owner(live) {t.put(g)} else {t.proposals.append(RqN(match:g,author:voter));t.stamp=Date()}
  replace(t)
 }
 func review(_ n:RqN,accept:Bool,in s:RqS) {
  guard let live=box.tournaments.first(where:{$0.id == s.id}),owner(live),let i=live.proposals.firstIndex(where:{$0.id == n.id && $0.status == 0}) else{return};var t=live;let pending=live.proposals[i]
  if accept {guard !live.blocked.contains(pending.author),live.valid(pending.match) else{alert=rqL("This report no longer matches the bracket.");return};var m=pending.match;m.stamp=Date();t.put(m)}
  t.proposals[i].status=accept ? 1:2;t.proposals[i].stamp=Date();t.stamp=Date();replace(t)
 }
 func notifications() async {
  n8 += 1;let token=n8;let center=UNUserNotificationCenter.current();center.removeAllPendingNotificationRequests()
  guard box.reminders else{return}
  let settings=await center.notificationSettings();guard token == n8,box.reminders else{return};guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else{return}
  var count=0
  for t in box.tournaments where !t.example {
   for r in t.rounds {
    let g=t.games.filter{$0.round == r && !$0.done && $0.a != nil && $0.b != nil};guard let first=g.min(by:{$0.date<$1.date}),count<58 else{continue}
    for late in [false,true] {
     guard token == n8,box.reminders,box.tournaments.contains(where:{$0.id == t.id}) else{return}
     let date=first.date.addingTimeInterval(late ? 7200 : -86400);guard date>Date() else{continue}
     let content=UNMutableNotificationContent();content.title=t.title;content.body=rqL(late ? "A match report is waiting. Open the round to record the result.":"Your neighborhood round is coming up. Check the fixtures.");content.sound = .default
     let trigger=UNCalendarNotificationTrigger(dateMatching:Calendar.current.dateComponents([.year,.month,.day,.hour,.minute],from:date),repeats:false)
     let requestID="\(t.id)-\(r)-\(late)-\(token)";try? await center.add(UNNotificationRequest(identifier:requestID,content:content,trigger:trigger));if token != n8 || !box.reminders || !box.tournaments.contains(where:{$0.id == t.id}) {center.removePendingNotificationRequests(withIdentifiers:[requestID]);center.removeDeliveredNotifications(withIdentifiers:[requestID]);return};count += 1
    }
   }
  }
 }
 func reminders(_ on:Bool) async {
  if on {do{box.reminders=try await UNUserNotificationCenter.current().requestAuthorization(options:[.alert,.sound,.badge]);if !box.reminders{alert=rqL("Reminders are off in Settings. The calendar still works in the app.")}}catch{box.reminders=false;alert=rqL("Reminders are unavailable. Your schedule is saved locally.")}}
  else{box.reminders=false};write();await notifications()
 }
 func shareCup(_ s:RqS) async {
  do {
   guard !s.example else{throw CocoaError(.fileReadCorruptFile)}
   let u:URL
   if owner(s){var export=s;export.proposals=[];export.complaints=[];u=try CupSeal.export(export,group:s.id,kind:"host")}
   else{let entry=CupReturn(reports:s.proposals.filter{$0.author==voter && $0.status==0},votes:s.votes.filter{$0.voter==voter},flags:s.complaints);u=try CupSeal.export(entry,group:s.id,kind:"guest")}
   share=RqShareItem(url:u)
  }catch{alert=error.localizedDescription}
 }
 func acceptCup(_ u:URL) {
  do {
   let (c,key)=try CupSeal.open(u);let cache="cup."+c.group+"."+key
   guard c.version>UserDefaults.standard.integer(forKey:cache) else{return}
   if c.kind=="host" {
    var t=try JSONDecoder().decode(RqS.self,from:c.body)
    guard t.id==c.group,!t.example,!t.title.isEmpty,t.title.count<=100,t.teams.count<=128,t.games.count<=10000,Set(t.teams.map(\.id)).count==t.teams.count,Set(t.games.map(\.id)).count==t.games.count,
     t.games.allSatisfy({(1...10000).contains($0.round) && (0...999).contains($0.x ?? 0) && (0...999).contains($0.y ?? 0)}) else{throw CocoaError(.fileReadCorruptFile)}
    t.proposals=[];t.complaints=[]
    if let i=box.tournaments.firstIndex(where:{$0.id==t.id}){guard box.links[t.id]?.owner==key else{throw CocoaError(.fileReadNoPermission)};t.proposals=box.tournaments[i].proposals.filter{$0.author==voter};box.tournaments[i]=t}
    else{box.tournaments.append(t)}
    box.links[t.id]=RqLink(zone:"file",owner:key,shared:true,writable:true);box.selected=t.id
   }else{
    guard let idx=box.tournaments.firstIndex(where:{$0.id==c.group}),owner(box.tournaments[idx]) else{throw CocoaError(.fileReadNoPermission)}
    var t=box.tournaments[idx];let v=try JSONDecoder().decode(CupReturn.self,from:c.body);guard !t.blocked.contains(key),v.reports.count<2000,v.votes.count<1000,v.flags.count<1000 else{throw CocoaError(.fileReadNoPermission)}
    for var n in v.reports where t.valid(n.match) && t.games.contains(where:{$0.id==n.match.id && $0.a==n.match.a && $0.b==n.match.b}) {n.id=key+"/"+n.id;guard !t.proposals.contains(where:{$0.id==n.id}) else{continue};n.author=key;n.status=0;n.match.author=key;n.stamp=Date();t.proposals.append(n)}
    for vote in v.votes {t.ballot(round:vote.round,player:vote.player,voter:key)}
    for var flag in v.flags where flag.reason.count<=500{flag.id=key+"/"+flag.id;if !t.complaints.contains(where:{$0.id==flag.id}){t.complaints.append(flag)}}
    t.stamp=Date();box.tournaments[idx]=t
   }
   write();if alert.isEmpty{UserDefaults.standard.set(c.version,forKey:cache)}
  }catch{alert=error.localizedDescription}
 }
 func delete(_ s:RqS) async {
  guard !busy else{return};busy=true;defer{busy=false}
  box.tournaments.removeAll{$0.id == s.id};box.links.removeValue(forKey:s.id);if box.selected == s.id{box.selected=box.tournaments.first?.id};write();await notifications()
 }
 func erase() async {
  let cups=box.tournaments
  for s in cups {await delete(s);if box.tournaments.contains(where:{$0.id == s.id}){return}}
  do {let fm=FileManager.default;for (folder,prefix,suffix) in [(disk.deletingLastPathComponent(),"recovery-","json"),(fm.temporaryDirectory,"Certificate-","pdf")] {for u in try fm.contentsOfDirectory(at:folder,includingPropertiesForKeys:nil) where u.lastPathComponent.hasPrefix(prefix) && u.pathExtension == suffix {try fm.removeItem(at:u)}}}catch{alert=rqL("The device could not save changes. Free some storage and try again.");return}
  box=RqArchive();write();UNUserNotificationCenter.current().removeAllDeliveredNotifications();await notifications();status=rqL("Profile and tournament data deleted")
 }
}
struct CupReturn:Codable{let reports:[RqN];let votes:[RqV];let flags:[RqC]}

import CryptoKit
struct CupSeal:Codable {
 struct Contents:Codable {let format:String;let group:String;let kind:String;let body:Data;let version:Int}
 let signed:Data
 let key:Data
 let signature:Data
 static func keyForDevice() throws -> Curve25519.Signing.PrivateKey {
  let root=FileManager.default.urls(for:.applicationSupportDirectory,in:.userDomainMask)[0]
  try FileManager.default.createDirectory(at:root,withIntermediateDirectories:true)
  var url=root.appendingPathComponent("BairroCup.identity")
  if FileManager.default.fileExists(atPath:url.path){return try Curve25519.Signing.PrivateKey(rawRepresentation:Data(contentsOf:url))}
  let key=Curve25519.Signing.PrivateKey()
  try key.rawRepresentation.write(to:url,options:[.atomic,.completeFileProtection])
  var flags=URLResourceValues();flags.isExcludedFromBackup=true;try url.setResourceValues(flags);return key
 }
 static func export<T:Encodable>(_ item:T,group:String,kind:String) throws ->URL {
  let key=try keyForDevice()
  let counter="BairroCup.sequence";let version=UserDefaults.standard.integer(forKey:counter)+1
  let content=Contents(format:"BairroCup/1",group:group,kind:kind,body:try JSONEncoder().encode(item),version:version)
  let raw=try JSONEncoder().encode(content)
  let envelope=Self(signed:raw,key:key.publicKey.rawRepresentation,signature:try key.signature(for:raw))
  let url=FileManager.default.temporaryDirectory.appendingPathComponent("BairroCup-"+kind+"-"+String(version)+".json")
  try JSONEncoder().encode(envelope).write(to:url,options:[.atomic,.completeFileProtection]);UserDefaults.standard.set(version,forKey:counter);return url
 }
 static func open(_ url:URL)throws ->(Contents,String) {
  let scoped=url.startAccessingSecurityScopedResource();defer{if scoped{url.stopAccessingSecurityScopedResource()}}
  guard try url.resourceValues(forKeys:[.fileSizeKey]).fileSize.map({$0>0 && $0<=8_000_000})==true else{throw CocoaError(.fileReadTooLarge)}
  let envelope=try JSONDecoder().decode(Self.self,from:Data(contentsOf:url))
  let key=try Curve25519.Signing.PublicKey(rawRepresentation:envelope.key)
  guard key.isValidSignature(envelope.signature,for:envelope.signed) else{throw CocoaError(.fileReadCorruptFile)}
  let c=try JSONDecoder().decode(Contents.self,from:envelope.signed)
  guard c.format=="BairroCup/1",UUID(uuidString:c.group) != nil,c.version>0,["host","guest"].contains(c.kind) else{throw CocoaError(.fileReadCorruptFile)}
  return(c,envelope.key.base64EncodedString())
 }
}

struct RqShareItem: Identifiable{let id=UUID();let url:URL}
struct RqShareItemPanel:UIViewControllerRepresentable{
 let item:RqShareItem
 func makeUIViewController(context:Context)->UIActivityViewController{UIActivityViewController(activityItems:[item.url],applicationActivities:nil)}
 func updateUIViewController(_ vc:UIActivityViewController,context:Context){}
}
struct RqPaper {
 @MainActor static func make(_ s:RqS,_ winner:RqT)throws->URL {
  let url=FileManager.default.temporaryDirectory.appendingPathComponent("Certificate-\(UUID().uuidString.prefix(8)).pdf")
  let render=UIGraphicsPDFRenderer(bounds:CGRect(x:0,y:0,width:842,height:595))
  try render.writePDF(to:url){ctx in ctx.beginPage();let g=ctx.cgContext
   UIColor(red:0.035,green:0.165,blue:0.102,alpha:1).setFill();g.fill(CGRect(x:0,y:0,width:842,height:595))
   UIColor(red:1,green:0.875,blue:0,alpha:1).setStroke();g.setLineWidth(2);g.stroke(CGRect(x:28,y:28,width:786,height:539))
   func text(_ s:String,_ y:CGFloat,_ size:CGFloat,_ color:UIColor,_ bold:Bool=false){let p=NSMutableParagraphStyle();p.alignment = .center;var z=size;while z>11 && (s as NSString).size(withAttributes:[.font:bold ? UIFont.boldSystemFont(ofSize:z):UIFont.systemFont(ofSize:z)]).width>720 {z -= 1};s.draw(in:CGRect(x:60,y:y,width:722,height:110),withAttributes:[.font:bold ? UIFont.boldSystemFont(ofSize:z):UIFont.systemFont(ofSize:z),.foregroundColor:color,.paragraphStyle:p])}
   text("✦",58,42,.systemYellow);text(rqL("Champions of the neighborhood"),125,28,.white,true);text(winner.name,200,42,.systemYellow,true);text(s.title,290,24,.white,true);text(s.place,339,17,.white)
   text(Date().formatted(date:.long,time:.omitted),408,16,.white);text("Winobattle · "+rqL("Community football, together"),490,13,.white)
  };return url
 }
}
struct RqShareFile:UIViewControllerRepresentable {let url:URL;func makeUIViewController(context:Context)->UIActivityViewController{UIActivityViewController(activityItems:[url],applicationActivities:nil)};func updateUIViewController(_ uiViewController:UIActivityViewController,context:Context){}}
