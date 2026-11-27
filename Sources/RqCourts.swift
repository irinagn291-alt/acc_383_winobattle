import SwiftUI

struct RqRoot:View {
 @EnvironmentObject var q:RqVault
 @State private var create=false;@State private var settings=false;@State private var tab=0
 var body:some View {NavigationStack{
  Group {
   if let s=q.active {TabView(selection:$tab){
    RqOverview(s:s).tag(0).tabItem{Label(rqL("Overview"),systemImage:"trophy")}
    RqFixtures(s:s).tag(1).tabItem{Label(rqL("Fixtures"),systemImage:s.knockout ? "point.3.connected.trianglepath.dotted":"calendar")}
    RqStandings(s:s).tag(2).tabItem{Label(rqL("Standings"),systemImage:"list.number")}
    RqCommunity(s:s).tag(3).tabItem{Label(rqL("Community"),systemImage:"person.3")}
   }.id(s.id).safeAreaInset(edge:.top,spacing:0){if s.example{Label(rqL("Sample data · not a real tournament"),systemImage:"info.circle.fill").font(.caption.bold()).frame(maxWidth:.infinity).padding(7).background(RqPaint.yellow.opacity(0.23))}}
   }else{empty}
  }.background(RqPaint.mist).navigationTitle(q.active?.title ?? "Winobattle").navigationBarTitleDisplayMode(.inline)
  .toolbar{
   ToolbarItem(placement:.topBarLeading){Button{settings=true}label:{Image(systemName:"slider.horizontal.3")}.accessibilityLabel(rqL("Settings"))}
   ToolbarItem(placement:.topBarTrailing){Menu{
    ForEach(q.box.tournaments){s in Button(s.title){q.box.selected=s.id;q.write()}}
    Button(rqL("New tournament"),systemImage:"plus"){create=true}
   }label:{Image(systemName:"square.stack.3d.up")}.accessibilityLabel(rqL("Tournaments"))}
  }
  .onChange(of:q.box.selected){_,_ in tab=0}.sheet(isPresented:$create){RqNew()}.sheet(isPresented:$settings){RqSettings()}
  .sheet(item:$q.share){RqShareItemPanel(item:$0)}
  .alert(rqL("Please check"),isPresented:Binding(get:{!q.alert.isEmpty && !settings},set:{if !$0 && !settings{q.dismissAlert()}})){Button(rqL("OK")){q.alert=""}}message:{Text(q.alert)}
 }}
 var empty:some View {ScrollView{VStack(alignment:.leading,spacing:25){
  ZStack(alignment:.bottomLeading){RqPitch().frame(height:280);VStack(alignment:.leading,spacing:12){Image(systemName:"trophy.fill").font(.system(size:55)).foregroundStyle(RqPaint.yellow);Text(rqL("Your pitch.\nYour championship.")).font(.system(.largeTitle,design:.rounded,weight:.heavy)).foregroundStyle(.white);Text(rqL("Bring the neighborhood together, one round at a time.")).font(.subheadline).foregroundStyle(.white.opacity(0.85))}.padding(25)}.clipShape(RoundedRectangle(cornerRadius:25))
  Text(rqL("A whole league in your pocket")).font(.title2.bold()).foregroundStyle(RqPaint.ink)
  HStack(alignment:.top,spacing:18){RqFeature(icon:"point.3.connected.trianglepath.dotted",title:rqL("Smart brackets"));RqFeature(icon:"list.number",title:rqL("Live tables"));RqFeature(icon:"doc.richtext",title:rqL("Match reports"))}
  Button{create=true}label:{Label(rqL("Create tournament"),systemImage:"plus.circle.fill").frame(maxWidth:.infinity).padding(10)}.buttonStyle(.borderedProminent).controlSize(.large).accessibilityIdentifier("createCup")
  Button(rqL("Explore a sample tournament")){q.add(RqS.sample())}.frame(maxWidth:.infinity)
  Label(rqL("Free, offline, made for your community"),systemImage:"checkmark.shield").font(.footnote).foregroundStyle(.secondary).frame(maxWidth:.infinity)
 }.padding(22).frame(maxWidth:760).frame(maxWidth:.infinity)}}
}
struct RqFeature:View {var icon:String;var title:String;var body:some View {VStack(alignment:.leading,spacing:9){Image(systemName:icon).font(.title2).foregroundStyle(RqPaint.green);Text(title).font(.subheadline.bold())}.frame(maxWidth:.infinity,alignment:.leading)}}
struct RqPitch:View {var body:some View {GeometryReader{g in ZStack{RqPaint.ink;HStack(spacing:0){ForEach(0..<8){i in Color.white.opacity(i%2 == 0 ? 0.025:0)}};RoundedRectangle(cornerRadius:5).stroke(.white.opacity(0.14),lineWidth:1).padding(18);Circle().stroke(.white.opacity(0.12),lineWidth:1).frame(width:130,height:130).offset(x:g.size.width*0.27);Rectangle().fill(.white.opacity(0.12)).frame(width:1).offset(x:g.size.width*0.27)}}}}
struct RqNew:View {
 @EnvironmentObject var q:RqVault;@Environment(\.dismiss) var dismiss
 @State private var title="";@State private var place="";@State private var names="";@State private var ko=false;@State private var start=Date().addingTimeInterval(86400);@State private var gap=7
 var list:[String] {names.split(separator:"\n").map{String($0).trimmingCharacters(in:.whitespaces)}.filter{!$0.isEmpty}}
 var valid:Bool {!title.trimmingCharacters(in:.whitespaces).isEmpty && title.count<=80 && place.count<=100 && (2...32).contains(list.count) && Set(list.map{$0.lowercased()}).count == list.count && list.allSatisfy{$0.count<=50}}
 var body:some View {NavigationStack{Form{
  Section(rqL("Tournament details")){TextField(rqL("Tournament name"),text:$title).accessibilityIdentifier("cupName");TextField(rqL("Pitch or neighborhood"),text:$place);Picker(rqL("Format"),selection:$ko){Text(rqL("Round robin")).tag(false);Text(rqL("Knockout")).tag(true)}.pickerStyle(.segmented);Text(rqL(ko ? "Single elimination. Byes advance automatically; tied matches require penalties.":"Each team meets every other team once. A win earns 3 points; a draw earns 1.")).font(.footnote).foregroundStyle(.secondary)}
  Section{TextEditor(text:$names).frame(minHeight:160).accessibilityLabel(rqL("Teams, one per line")).accessibilityIdentifier("teamNames");Text(rqL("2–32 unique teams, one per line. First-listed teams receive any byes. Team order fixes the draw.")).font(.footnote).foregroundStyle(.secondary);Text(rqF("%d teams",list.count)).font(.caption.bold())}header:{Text(rqL("Teams, one per line"))}
  Section(rqL("Schedule")){DatePicker(rqL("First kickoff"),selection:$start);Stepper(rqF("%d days between rounds",gap),value:$gap,in:1...30);Text(rqL("Matches in the same round start 90 minutes apart. Kickoff times can be edited in each report.")).font(.footnote).foregroundStyle(.secondary)}
 }.navigationTitle(rqL("New tournament")).toolbar{ToolbarItem(placement:.cancellationAction){Button(rqL("Cancel")){dismiss()}};ToolbarItem(placement:.confirmationAction){Button(rqL("Create")){var s=RqS(title:title.trimmingCharacters(in:.whitespacesAndNewlines),place:place,knockout:ko,start:start,interval:gap,teams:list.map{RqT(name:$0)});s.generate();q.add(s);dismiss()}.disabled(!valid).accessibilityIdentifier("saveCup")}}
 }}
}
struct RqOverview:View {
 @EnvironmentObject var q:RqVault;var s:RqS
 @State private var roster=false;@State private var deletion=false;@State private var file:URL?;@State private var paper=false
 var body:some View {ScrollView{VStack(alignment:.leading,spacing:22){
  ZStack(alignment:.leading){RqPitch();VStack(alignment:.leading,spacing:15){HStack{Label(rqL(s.knockout ? "KNOCKOUT":"NEIGHBORHOOD LEAGUE"),systemImage:"soccerball").font(.caption.weight(.heavy));Spacer();Image(systemName:"trophy.fill").font(.title).foregroundStyle(RqPaint.yellow)};Text(s.title).font(.system(.largeTitle,design:.rounded,weight:.heavy));if !s.place.isEmpty{Label(s.place,systemImage:"mappin.and.ellipse").font(.subheadline)};HStack{RqMetric(n:"\(s.teams.count)",label:rqL("Teams"));Spacer();RqMetric(n:"\(s.completed)/\(s.games.filter{$0.a != nil && $0.b != nil}.count)",label:rqL("Played"));Spacer();RqMetric(n:"\(s.rounds.count)",label:rqL("Rounds"))}}.padding(25).foregroundStyle(.white)}.frame(minHeight:235).clipShape(RoundedRectangle(cornerRadius:25))
  if let next=s.next {VStack(alignment:.leading,spacing:12){RqEyebrow(text:rqL("NEXT KICKOFF"));Text(next.date.formatted(date:.abbreviated,time:.shortened)).font(.title3.bold());HStack{RqBadge(name:s.team(next.a));Spacer();Text("×").foregroundStyle(.secondary);Spacer();RqBadge(name:s.team(next.b))}}.padding(20).rqCard()}
  else if !s.champions.isEmpty {VStack(alignment:.leading,spacing:12){RqEyebrow(text:rqL("CHAMPIONS"));ForEach(s.champions){t in Text(t.name).font(.title2.bold());Button{do{file=try RqPaper.make(s,t);paper=true}catch{q.alert=rqL("The certificate could not be created. Try again.")}}label:{Label(rqL("Share winner certificate"),systemImage:"doc.richtext")}}}.padding(20).rqCard()}
  HStack(alignment:.top,spacing:15){VStack(alignment:.leading,spacing:9){RqEyebrow(text:rqL("ROUND BY ROUND"));Text(rqL("Every result counts.")).font(.title3.bold());Text(rqL("Record a match, update the table, celebrate your players.")).font(.subheadline).foregroundStyle(.secondary)};Spacer();Image(systemName:"sportscourt.fill").font(.system(size:40)).foregroundStyle(RqPaint.green)}.padding(20).rqCard()
  Button{roster=true}label:{Label(rqL("Teams and player rosters"),systemImage:"person.2.fill").frame(maxWidth:.infinity)}.buttonStyle(.bordered).controlSize(.large)
  Button{Task{await q.shareCup(s)}}label:{Label(rqL("Share a copy"),systemImage:"person.crop.circle.badge.plus").frame(maxWidth:.infinity)}.buttonStyle(.borderedProminent).controlSize(.large).disabled(q.busy || s.example)
  Text(rqL("Invitation-only. Shared edits are checked when the app opens or you sync. Offline changes are kept on this device.")).font(.footnote).foregroundStyle(.secondary)
  Button(rqL(q.owner(s) ? "Delete tournament":"Leave shared tournament"),role:.destructive){deletion=true}.font(.footnote).frame(maxWidth:.infinity).disabled(q.busy)
 }.padding(20).frame(maxWidth:1000).frame(maxWidth:.infinity)}.background(RqPaint.mist)
 .sheet(isPresented:$roster){RqRoster(s:s)}.sheet(isPresented:$paper){if let file{RqShareFile(url:file)}}
 .confirmationDialog(rqL("Remove this tournament?"),isPresented:$deletion,titleVisibility:.visible){Button(rqL("Remove"),role:.destructive){Task{await q.delete(s)}}}message:{Text(rqL("Owned iCloud data is removed for all invited people. This cannot be undone."))}
 }
}
struct RqMetric:View {var n:String;var label:String;var body:some View{VStack(alignment:.leading,spacing:3){Text(n).font(.title2.bold());Text(label).font(.caption).opacity(0.75)}}}
struct RqEyebrow:View {var text:String;var body:some View{Text(text).font(.caption.weight(.heavy)).tracking(1.2).foregroundStyle(RqPaint.green)}}
struct RqBadge:View {var name:String;var body:some View{HStack(spacing:9){Text(String(name.prefix(2)).uppercased()).font(.caption.bold()).frame(width:34,height:38).background(RqPaint.green.opacity(0.1),in:RoundedRectangle(cornerRadius:10));Text(name).font(.subheadline.bold()).lineLimit(3)}}}
extension View{func rqCard()->some View{self.frame(maxWidth:.infinity,alignment:.leading).background(.white,in:RoundedRectangle(cornerRadius:20)).overlay(RoundedRectangle(cornerRadius:20).stroke(RqPaint.ink.opacity(0.05),lineWidth:1))}}
struct RqFixtures:View {
 @EnvironmentObject var q:RqVault;var s:RqS;@State private var edit:RqM?
 var body:some View {ScrollView{VStack(alignment:.leading,spacing:19){
  HStack{VStack(alignment:.leading){RqEyebrow(text:rqL(s.knockout ? "THE ROAD TO THE CUP":"THE MATCH CALENDAR"));Text(rqL(s.knockout ? "Tournament bracket":"Round fixtures")).font(.title.bold())};Spacer();Text("\(s.completed)").font(.largeTitle.bold()).foregroundStyle(RqPaint.green)}
  if s.knockout {Text(rqL("Swipe across the bracket. Results advance winners automatically. Changing an earlier winner clears dependent results.")).font(.footnote).foregroundStyle(.secondary)
   ScrollView(.horizontal){HStack(alignment:.top,spacing:18){ForEach(s.rounds,id:\.self){r in VStack(alignment:.leading,spacing:14){Text(rqF("Round %d",r)).font(.headline);ForEach(s.games.filter{$0.round == r}){g in match(g)}}.frame(width:280)}}.padding(.bottom,10)}
  } else {ForEach(s.rounds,id:\.self){r in VStack(alignment:.leading,spacing:12){HStack{Text(rqF("Round %d",r)).font(.title3.bold());Spacer();if s.roundClosed(r){Image(systemName:"checkmark.seal.fill").foregroundStyle(RqPaint.green)}};ForEach(s.games.filter{$0.round == r}){g in match(g)}}}}
 }.padding(20).frame(maxWidth:s.knockout ? .infinity:1000).frame(maxWidth:.infinity)}.background(RqPaint.mist).sheet(item:$edit){RqProtocol(s:s,m:$0)}}
 func match(_ g:RqM)->some View {Button{edit=g}label:{VStack(alignment:.leading,spacing:12){HStack{Text(g.date.formatted(date:.abbreviated,time:.shortened)).font(.caption).foregroundStyle(.secondary);Spacer();Image(systemName:g.done ? "checkmark.circle.fill":"pencil.circle").foregroundStyle(RqPaint.green)};HStack{Text(s.team(g.a)).font(.headline);Spacer();Text(g.x.map(String.init) ?? "–").font(.title2.monospacedDigit().bold())};HStack{Text(s.team(g.b)).font(.headline);Spacer();Text(g.y.map(String.init) ?? "–").font(.title2.monospacedDigit().bold())};if s.knockout && g.done && g.x == g.y {Text(rqL("Penalties")+" \(g.px) : \(g.py)").font(.caption).foregroundStyle(.secondary)};if g.round == 1 && (g.a == nil || g.b == nil){Text(rqL("Bye · advances automatically")).font(.caption).foregroundStyle(RqPaint.green)}}.padding(18).rqCard().foregroundStyle(RqPaint.ink)}.buttonStyle(.plain).disabled(g.a == nil || g.b == nil).accessibilityIdentifier("match-\(g.round)-\(g.position)")}
}
struct RqProtocol:View {
 @EnvironmentObject var q:RqVault;@Environment(\.dismiss) var dismiss;var s:RqS
 @State var m:RqM;@State private var confirm=false
 var readOnly:Bool {!q.mayEdit(s)}
 init(s:RqS,m:RqM){self.s=s;var g=m;if g.x == nil {g.x=0;g.y=0};_m=State(initialValue:g)}
 var body:some View {NavigationStack{Form{
  Section(rqF("Round %d",m.round)){
   Stepper(s.team(m.a)+": \(m.x ?? 0)",value:Binding(get:{m.x ?? 0},set:{m.x=$0}),in:0...99).accessibilityIdentifier("homeScore")
   Stepper(s.team(m.b)+": \(m.y ?? 0)",value:Binding(get:{m.y ?? 0},set:{m.y=$0}),in:0...99).accessibilityIdentifier("awayScore")
   if s.knockout && m.x == m.y {Stepper(rqL("Home penalties")+": \(m.px)",value:$m.px,in:0...99);Stepper(rqL("Away penalties")+": \(m.py)",value:$m.py,in:0...99);Text(rqL("A tied knockout match needs a penalty winner.")).font(.footnote).foregroundStyle(.secondary)}
   DatePicker(rqL("Kickoff"),selection:$m.date)
  }.disabled(readOnly)
  Section(rqL("Goalscorers")) {
   let players=s.players.filter{$0.team == m.a || $0.team == m.b}
   if players.isEmpty{Text(rqL("Add players in Teams and player rosters to record goalscorers.")).font(.footnote).foregroundStyle(.secondary)}
   ForEach(players){p in Stepper(p.name+" · \(m.goals[p.id] ?? 0)",value:Binding(get:{m.goals[p.id] ?? 0},set:{m.goals[p.id]=$0}),in:0...99)}
   Text(rqL("Scorers are optional. Recorded goals cannot exceed the team score.")).font(.footnote).foregroundStyle(.secondary)
  }.disabled(readOnly)
  Section(rqL("Match notes")){TextEditor(text:$m.note).frame(minHeight:90);Text("\(m.note.count)/500").font(.caption).foregroundStyle(.secondary)}.disabled(readOnly)
  if !m.author.isEmpty {Section(rqL("Report author")){Text(String(m.author.suffix(12))).font(.caption.monospaced())}}
  if !q.owner(s){Text(rqL("Your report will wait for the tournament owner’s approval.")).font(.footnote)}
  if s.knockout{Text(rqL("Changing a winner clears results in later dependent matches.")).font(.footnote).foregroundStyle(.secondary)}
 }.navigationTitle(rqL("Match report")).toolbar{ToolbarItem(placement:.cancellationAction){Button(rqL("Close")){dismiss()}};if !readOnly {ToolbarItem(placement:.confirmationAction){Button(rqL("Save")){if s.knockout && s.games.first(where:{$0.id == m.id})?.done == true{confirm=true}else{save()}}.disabled(!s.valid(m)).accessibilityIdentifier("saveReport")}}}
 .confirmationDialog(rqL("Update this result?"),isPresented:$confirm,titleVisibility:.visible){Button(rqL("Save result")){save()}}message:{Text(rqL("Dependent results may be cleared if the winner changes."))}
 }}
 func save(){q.report(m,in:s);dismiss()}
}
struct RqStandings:View {
 var s:RqS
 var scorers:[(RqP,Int)] {s.players.map{p in (p,s.games.filter(\.done).reduce(0){$0+($1.goals[p.id] ?? 0)})}.filter{$0.1>0}.sorted{$0.1 == $1.1 ? $0.0.name < $1.0.name:$0.1>$1.1}}
 var body:some View {ScrollView{VStack(alignment:.leading,spacing:22){
  RqEyebrow(text:rqL("THE NEIGHBORHOOD TABLE"));Text(rqL("Every team. Every goal.")).font(.title.bold())
  ScrollView(.horizontal){VStack(spacing:0){HStack{Text(rqL("Team")).frame(width:190,alignment:.leading);ForEach(["P","W","D","L","GF","GA","GD","PTS"],id:\.self){Text(rqL($0)).frame(width:38)}}.font(.caption.bold()).foregroundStyle(.secondary).padding(14)
   ForEach(Array(s.table.enumerated()),id:\.element.id){i,r in HStack{HStack{Text("\(i+1)").font(.caption.bold()).foregroundStyle(RqPaint.green).frame(width:18);Text(r.name).font(.subheadline.bold())}.frame(width:190,alignment:.leading);ForEach(Array([r.played,r.wins,r.draws,r.losses,r.gf,r.ga,r.diff,r.points].enumerated()),id:\.offset){j,n in Text("\(n)").font(.subheadline.monospacedDigit().weight(j == 7 ? .heavy:.regular)).frame(width:38).foregroundStyle(j == 7 ? RqPaint.green:RqPaint.ink)}}.padding(14).background(i%2 == 0 ? RqPaint.mist:Color.white)}
  }.background(.white,in:RoundedRectangle(cornerRadius:20))}
  Text(rqL("3 points for a win, 1 for a draw. Ties: goal difference, then goals scored. Exact ties share the championship. Penalties do not count as goals in the table. Knockout tables are statistical summaries; the final decides the champion.")).font(.footnote).foregroundStyle(.secondary)
  Text(rqL("Goalscorers")).font(.title2.bold())
  if scorers.isEmpty {Label(rqL("Record player goals in match reports to see the scoring chart."),systemImage:"soccerball").font(.subheadline).foregroundStyle(.secondary).padding(20).rqCard()}
  ForEach(scorers,id:\.0.id){p,n in HStack{RqBadge(name:p.name);Spacer();Text(s.team(p.team)).font(.caption).foregroundStyle(.secondary);Text("\(n)").font(.title3.monospacedDigit().bold()).foregroundStyle(RqPaint.green)}.padding(18).rqCard()}
 }.padding(20).frame(maxWidth:1000).frame(maxWidth:.infinity)}.background(RqPaint.mist)}
}
struct RqRoster:View {
 @EnvironmentObject var q:RqVault;@Environment(\.dismiss) var dismiss
 @State var s:RqS;@State private var inputs:[String:String]=[:]
 var body:some View {NavigationStack{Form{ForEach(s.teams){t in Section(t.name){ForEach(t.players){p in Text(p.name)};TextField(rqL("Player name"),text:Binding(get:{inputs[t.id] ?? ""},set:{inputs[t.id]=$0}));Button(rqL("Add player")){let n=(inputs[t.id] ?? "").trimmingCharacters(in:.whitespacesAndNewlines);guard !n.isEmpty,n.count<=60,let i=s.teams.firstIndex(where:{$0.id == t.id}),s.teams[i].players.count<30,!t.players.contains(where:{$0.name.lowercased() == n.lowercased()}) else{return};s.teams[i].players.append(RqP(name:n,team:t.id));inputs[t.id]="";s.stamp=Date();q.replace(s)}.disabled(!q.owner(s))}}
 Text(rqL("Up to 30 players per team. The owner maintains rosters; names already used in reports stay in the record.")).font(.footnote).foregroundStyle(.secondary)
 }.navigationTitle(rqL("Player rosters")).toolbar{ToolbarItem(placement:.confirmationAction){Button(rqL("Done")){dismiss()}}}}}
}
struct RqCommunity:View {
 @EnvironmentObject var q:RqVault;var s:RqS
 @State private var round=1;@State private var player="";@State private var flagged="";@State private var reason="";@State private var flag=false
 var body:some View {ScrollView{VStack(alignment:.leading,spacing:20){RqEyebrow(text:rqL("PEOPLE MAKE THE LEAGUE"));Text(rqL("Player of the round")).font(.title.bold())
  VStack(alignment:.leading,spacing:16){Picker(rqL("Round"),selection:$round){ForEach(s.rounds,id:\.self){r in Text(rqF("Round %d",r)).tag(r)}}.pickerStyle(.menu)
   if s.roundClosed(round) {
    if s.eligible(round).isEmpty{Text(rqL("Add player rosters before opening the vote."))}
    else {Picker(rqL("Choose a player"),selection:$player){Text(rqL("Choose a player")).tag("");ForEach(s.eligible(round)){p in Text(p.name+" · "+s.team(p.team)).tag(p.id)}}
     Button(rqL("Save my vote")){var t=s;t.ballot(round:round,player:player,voter:q.voter);q.replace(t)}.buttonStyle(.borderedProminent).disabled(player.isEmpty || !q.mayEdit(s) || s.blocked.contains(q.voter))
     if s.votes.contains(where:{$0.round == round && $0.voter == q.voter}){Label(rqL("Your vote is saved. You may change it."),systemImage:"checkmark.circle.fill").font(.footnote).foregroundStyle(RqPaint.green)}
    }
   }else{Label(rqL("Voting opens after every match in this round is complete."),systemImage:"lock.fill").font(.subheadline).foregroundStyle(.secondary)}
   Text(rqL("One vote per device per round.")).font(.footnote).foregroundStyle(.secondary)
   ForEach(s.leaders(round),id:\.0.id){p,n in HStack{Text(p.name).font(.headline);Spacer();Text(rqF("%d votes",n)).foregroundStyle(RqPaint.green)}}
  }.padding(20).rqCard()
  if !s.proposals.isEmpty {Text(rqL("Reports awaiting review")).font(.title2.bold());ForEach(s.proposals.filter{$0.status == 0 && !s.blocked.contains($0.author)}){n in VStack(alignment:.leading,spacing:12){Text(s.team(n.match.a)+" \(n.match.x ?? 0) : \(n.match.y ?? 0) "+s.team(n.match.b)).font(.headline);Text(n.match.note).font(.subheadline);Text(rqL("Author")+": "+String(n.author.suffix(12))).font(.caption.monospaced());if q.owner(s){HStack{Button(rqL("Approve")){q.review(n,accept:true,in:s)}.buttonStyle(.borderedProminent);Button(rqL("Reject"),role:.destructive){q.review(n,accept:false,in:s)}}};Button(rqL("Flag author")){flagged=n.author;flag=true}}.padding(20).rqCard()}}
  Text(rqL("Fair play and access")).font(.title2.bold())
  Text(rqL("Choose a file to open, or send a copy directly to someone. Changes stay on this device until you share again.")).font(.subheadline).foregroundStyle(.secondary)
  ForEach(Array(Set(s.proposals.map(\.author)+s.games.map(\.author)+s.votes.map(\.voter))).filter{!$0.isEmpty && $0 != q.voter}.sorted(),id:\.self){id in HStack{Text(String(id.suffix(12))).font(.caption.monospaced());Spacer();Button(rqL("Flag")){flagged=id;flag=true};if q.owner(s){Button(rqL(s.blocked.contains(id) ? "Blocked":"Block"),role:.destructive){var t=s;t.blocked.append(id);t.stamp=Date();q.replace(t)}.disabled(s.blocked.contains(id))}}.padding(15).rqCard()}
  if q.owner(s){ForEach(s.complaints){c in VStack(alignment:.leading,spacing:8){Text(rqL("Flagged participant")+": "+String(c.person.suffix(12))).font(.caption.bold());Text(c.reason).font(.subheadline)}.padding(16).rqCard()}}
  Button{Task{await q.shareCup(s)}}label:{Label(rqL("Share a copy"),systemImage:"person.badge.key.fill")}.disabled(q.busy || s.example)
 }.padding(20).frame(maxWidth:1000).frame(maxWidth:.infinity)}.background(RqPaint.mist)
 .onChange(of:round){_,_ in player=""}.sheet(isPresented:$flag){NavigationStack{Form{TextField(rqL("Reason for review"),text:$reason,axis:.vertical);Text(rqL("The tournament owner can review this flag. To remove access, the owner must also remove the person in Manage invitations.")).font(.footnote)}.navigationTitle(rqL("Flag participant")).toolbar{ToolbarItem(placement:.cancellationAction){Button(rqL("Cancel")){flag=false}};ToolbarItem(placement:.confirmationAction){Button(rqL("Submit")){var t=s;t.complaints.append(RqC(person:flagged,reason:String(reason.prefix(500))));t.stamp=Date();q.replace(t);reason="";flag=false}.disabled(reason.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty || !q.mayEdit(s))}}}}
 }
}
