import Foundation

let rqGroup = "group.org.courtyard.mosaicr7"
let rqCloud = "iCloud.org.courtyard.mosaicr7"
func rqL(_ s:String)->String { NSLocalizedString(s, comment: "") }
func rqF(_ s:String,_ n:Int)->String { String(format:rqL(s), n) }
struct RqP: Codable, Identifiable, Equatable { var id=UUID().uuidString; var name:String; var team:String }
struct RqT: Codable, Identifiable, Equatable { var id=UUID().uuidString; var name:String; var players:[RqP]=[] }
struct RqM: Codable, Identifiable, Equatable {
 var id=UUID().uuidString; var round:Int; var position:Int; var a:String?; var b:String?
 var left:Int?; var right:Int?; var date:Date; var x:Int?; var y:Int?; var px=0; var py=0
 var goals:[String:Int]=[:]; var note=""; var stamp=Date.distantPast; var author=""
 var done:Bool { x != nil && y != nil && a != nil && b != nil }
 var winner:String? { guard done,let x,let y else{return nil}; if x == y { return px == py ? nil : (px > py ? a:b) };return x > y ? a:b }
}
struct RqV:Codable,Identifiable,Equatable { var id:String;var round:Int;var player:String;var voter:String;var date:Date=Date() }
struct RqN:Codable,Identifiable,Equatable { var id=UUID().uuidString;var match:RqM;var author:String;var status=0;var stamp=Date() }
struct RqC:Codable,Identifiable,Equatable {var id=UUID().uuidString;var person:String;var reason:String;var date=Date()}
struct RqS:Codable,Identifiable,Equatable {
 var id=UUID().uuidString;var title:String;var place:String;var knockout:Bool;var start:Date;var interval:Int
 var teams:[RqT];var games:[RqM]=[];var votes:[RqV]=[];var proposals:[RqN]=[];var complaints:[RqC]=[];var blocked:[String]=[]
 var stamp=Date();var example=false
 var rounds:[Int] { Array(Set(games.map(\.round))).sorted() }
 func team(_ id:String?)->String {teams.first{$0.id == id}?.name ?? rqL("To be decided")}
 var completed:Int {games.filter(\.done).count}
 var next:RqM? { games.filter{ !$0.done && $0.a != nil && $0.b != nil }.sorted{$0.date < $1.date}.first }
 var players:[RqP] {teams.flatMap(\.players)}
 var champions:[RqT] {
  if knockout {guard let g=games.last,let w=g.winner else{return []}; return teams.filter{$0.id == w}}
  guard games.allSatisfy(\.done),let first=table.first else{return []}
  return table.filter{$0.points == first.points && $0.diff == first.diff && $0.gf == first.gf}.compactMap{r in teams.first{$0.id == r.id}}
 }
 var table:[RqRow] {
  var d=Dictionary(uniqueKeysWithValues:teams.map{($0.id,RqRow(id:$0.id,name:$0.name))})
  for g in games where g.done {guard let a=g.a,let b=g.b,let x=g.x,let y=g.y else{continue}
   d[a]?.played += 1;d[b]?.played += 1;d[a]?.gf += x;d[a]?.ga += y;d[b]?.gf += y;d[b]?.ga += x
   if x > y {d[a]?.wins += 1;d[b]?.losses += 1;d[a]?.points += 3}
   else if y > x {d[b]?.wins += 1;d[a]?.losses += 1;d[b]?.points += 3}
   else {d[a]?.draws += 1;d[b]?.draws += 1;d[a]?.points += 1;d[b]?.points += 1}
  }
  return d.values.sorted{ if $0.points != $1.points{return $0.points > $1.points};if $0.diff != $1.diff{return $0.diff > $1.diff};if $0.gf != $1.gf{return $0.gf > $1.gf};return $0.name.localizedStandardCompare($1.name) == .orderedAscending }
 }
 mutating func generate() {
  games=[]
  if knockout {
   var size=2;while size < teams.count{size *= 2}
   // Distribute byes over separate first-round fixtures.
   var seeds=teams.map{Optional($0.id)};let byes=size-teams.count
   for j in 0..<byes {seeds.insert(nil, at:min(j*2+1,seeds.count))}
   var count=size/2;var round=1;var previous:[Int]=[];var firstSlot=0
   while count > 0 {
    var current:[Int]=[]
    for j in 0..<count {
     let m:RqM
     if round == 1 {m=RqM(round:round,position:j,a:seeds[j*2],b:seeds[j*2+1],date:start.addingTimeInterval(Double(firstSlot)*5400));if seeds[j*2] != nil && seeds[j*2+1] != nil {firstSlot += 1}}
     else {m=RqM(round:round,position:j,left:previous[j*2],right:previous[j*2+1],date:(Calendar.current.date(byAdding:.day,value:(round-1)*interval,to:start) ?? start).addingTimeInterval(Double(j)*5400))}
     current.append(games.count);games.append(m)
    }
    previous=current;count /= 2;round += 1
   }
   advance()
  } else {
   var ids=teams.map{Optional($0.id)};if ids.count%2 == 1 {ids.append(nil)}
   let count=ids.count
   for round in 1..<count {
    var roundSlot=0
    for j in 0..<(count/2) {
     if let a=ids[j],let b=ids[count-1-j] {
      games.append(RqM(round:round,position:j,a:round%2 == 0 ? b:a,b:round%2 == 0 ? a:b,date:(Calendar.current.date(byAdding:.day,value:(round-1)*interval,to:start) ?? start).addingTimeInterval(Double(roundSlot)*5400)));roundSlot += 1
     }
    }
    let last=ids.removeLast();ids.insert(last,at:1)
   }
  }
 }
 mutating func advance() {
  guard knockout else{return}
  for i in games.indices {
   guard let l=games[i].left,let r=games[i].right else{continue}
   func resolved(_ j:Int)->String? {
    let m=games[j];if m.round == 1 && (m.a == nil || m.b == nil){return m.a ?? m.b};return m.winner
   }
   let a=resolved(l),b=resolved(r)
   if games[i].a != a || games[i].b != b {
    games[i].a=a;games[i].b=b;games[i].x=nil;games[i].y=nil;games[i].px=0;games[i].py=0;games[i].goals=[:];games[i].note="";games[i].author="";games[i].stamp=Date()
   }
  }
 }
 mutating func put(_ m:RqM) {guard let i=games.firstIndex(where:{$0.id == m.id}) else{return};games[i]=m;advance();let completedRounds=Set(rounds.filter{roundClosed($0)});let eligibleIDs=Dictionary(uniqueKeysWithValues:rounds.map{($0,Set(eligible($0).map(\.id)))});votes.removeAll{!completedRounds.contains($0.round) || !(eligibleIDs[$0.round]?.contains($0.player) ?? false)};stamp=Date()}
 func valid(_ m:RqM)->Bool {
  guard let original=games.first(where:{$0.id == m.id}), original.a == m.a,original.b == m.b,let x=m.x,let y=m.y,m.a != nil,m.b != nil,(0...99).contains(x),(0...99).contains(y),(0...99).contains(m.px),(0...99).contains(m.py) else{return false}
  if knockout && x == y && m.px == m.py {return false}
  let a=Set(players.filter{$0.team == m.a}.map(\.id)),b=Set(players.filter{$0.team == m.b}.map(\.id))
  return m.goals.allSatisfy{a.contains($0.key) || b.contains($0.key)} && m.goals.values.allSatisfy{$0 >= 0} && m.goals.filter{a.contains($0.key)}.values.reduce(0,+) <= x && m.goals.filter{b.contains($0.key)}.values.reduce(0,+) <= y && m.note.count <= 500
 }
 func roundClosed(_ r:Int)->Bool {let relevant=games.filter{$0.round == r && $0.a != nil && $0.b != nil};return !relevant.isEmpty && relevant.allSatisfy(\.done)}
 func eligible(_ r:Int)->[RqP] {let ids=Set(games.filter{$0.round == r && $0.a != nil && $0.b != nil}.flatMap{[$0.a!,$0.b!]});return players.filter{ids.contains($0.team)}}
 mutating func ballot(round:Int,player:String,voter:String) {guard roundClosed(round),eligible(round).contains(where:{$0.id == player}),!blocked.contains(voter) else{return};let v=RqV(id:"\(round):\(voter)",round:round,player:player,voter:voter);votes.removeAll{$0.id == v.id};votes.append(v)}
 func leaders(_ r:Int)->[(RqP,Int)] {guard roundClosed(r) else{return []};return eligible(r).map{p in (p,votes.filter{$0.round == r && $0.player == p.id && !blocked.contains($0.voter)}.count)}.filter{$0.1 > 0}.sorted{ $0.1 == $1.1 ? $0.0.name < $1.0.name : $0.1 > $1.1 }}
 static func merge(_ a:Self,_ b:Self)->Self {
  var r=a.stamp >= b.stamp ? a:b
  func union<T:Identifiable>(_ x:[T],_ y:[T],_ date:(T)->Date)->[T] where T.ID == String {var d=Dictionary(uniqueKeysWithValues:x.map{($0.id,$0)});for t in y {if d[t.id] == nil || date(t)>date(d[t.id]!){d[t.id]=t}};return d.values.sorted{$0.id < $1.id}}
  r.games=a.games.map{g in guard let other=b.games.first(where:{$0.id == g.id}) else{return g};return other.stamp>g.stamp ? other:g}
  r.votes=union(a.votes,b.votes,{$0.date});r.proposals=union(a.proposals,b.proposals,{$0.stamp});r.complaints=union(a.complaints,b.complaints,{$0.date});r.blocked=Array(Set(a.blocked+b.blocked))
  for i in r.teams.indices {let id=r.teams[i].id;let all=(a.teams.first{$0.id == id}?.players ?? [])+(b.teams.first{$0.id == id}?.players ?? []);r.teams[i].players=Array(Dictionary(all.map{($0.id,$0)},uniquingKeysWith:{$1}).values).sorted{$0.name < $1.name}}
  r.advance();return r
 }
 static func sample()->Self {
  var teams=["Vila Verde","Estrela do Sul","União da Praça","Jardim FC"].map{RqT(name:$0)}
  for i in teams.indices {teams[i].players=[RqP(name:["Alex","Sam","Dani","Luca"][i],team:teams[i].id)]}
  var s=RqS(title:rqL("Sample neighborhood cup"),place:rqL("Community pitch"),knockout:false,start:Calendar.current.nextDate(after:Date(),matching:DateComponents(hour:10,weekday:7),matchingPolicy:.nextTime) ?? Date(),interval:7,teams:teams,example:true);s.generate()
  for i in 0..<2 {var m=s.games[i];m.x=i+1;m.y=0;m.stamp=Date();m.goals=[teams.first{$0.id == m.a}!.players[0].id:i+1];s.put(m)}
  return s
 }
}
struct RqRow:Identifiable,Codable {var id:String;var name:String;var played=0;var wins=0;var draws=0;var losses=0;var gf=0;var ga=0;var points=0;var diff:Int{gf-ga}}
struct RqLink:Codable {var zone:String;var owner:String;var shared:Bool;var writable:Bool=true}
struct RqArchive:Codable {var tournaments:[RqS]=[];var links:[String:RqLink]=[:];var selected:String?;var reminders=false;var nickname="";var identity="";var voter=UUID().uuidString;var cloud=false}
struct RqCache:Codable {var title:String;var knockout:Bool;var date:Date?;var match:String;var rows:[RqRow];var fixtures:[String];var bracket:[String];var updated:Date}
