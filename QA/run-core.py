from pathlib import Path
import subprocess,json,os
r=Path(__file__).resolve().parents[1]
body=r'''
@main struct RqChecks {
 static func main() throws {
 var matches=0;var checks=0
 func cup(_ n:Int,_ ko:Bool)->RqS{var s=RqS(title:"League",place:"Pitch",knockout:ko,start:Date(),interval:7,teams:(1...n).map{RqT(name:"Team \($0)")});s.generate();return s}
 for n in 2...32 {
  let s=cup(n,false);precondition(s.next?.date == s.start);precondition(s.games.count == n*(n-1)/2);let pairs=Set(s.games.map{[$0.a!,$0.b!].sorted().joined(separator:"/")});precondition(pairs.count == s.games.count)
  for r in s.rounds {let ids=s.games.filter{$0.round == r}.flatMap{[$0.a!,$0.b!]};precondition(ids.count == Set(ids).count)}
  var k=cup(n,true);precondition(k.next?.date == k.start);var played=0
  for i in k.games.indices {if k.games[i].a != nil && k.games[i].b != nil {var m=k.games[i];m.x=2;m.y=1;precondition(k.valid(m));k.put(m);played += 1}}
  precondition(played == n-1);precondition(k.champions.count == 1);matches += s.games.count+played;checks += 1
 }
 let savedZone=NSTimeZone.default;NSTimeZone.default=TimeZone(identifier:"Europe/Berlin")!;let dstStart=Calendar.current.date(from:DateComponents(year:2027,month:3,day:27,hour:10))!;var dst=RqS(title:"DST",place:"Pitch",knockout:false,start:dstStart,interval:7,teams:(1...4).map{RqT(name:"T\($0)")});dst.generate();for round in dst.rounds{let first=dst.games.filter{$0.round == round}.map(\.date).min()!;precondition(Calendar.current.component(.hour,from:first) == 10)};NSTimeZone.default=savedZone
 var k=cup(4,true)
 for i in k.games.indices {var m=k.games[i];m.x=2;m.y=0;k.put(m)}
 precondition(k.champions.count == 1);var m=k.games[0];m.x=0;m.y=2;k.put(m);precondition(k.games.last!.x == nil);precondition(k.champions.isEmpty)
 var a=cup(4,false),b=a;var x=a.games[0];x.x=2;x.y=1;x.stamp=Date(timeIntervalSince1970:100);a.put(x);var y=b.games[1];y.x=1;y.y=0;y.stamp=Date(timeIntervalSince1970:200);b.put(y);let merged=RqS.merge(a,b);precondition(merged.completed == 2)
 let restored=try JSONDecoder().decode(RqS.self,from:JSONEncoder().encode(merged));precondition(restored == merged)
 var v=cup(2,false);let p=RqP(name:"Alex",team:v.teams[0].id);v.teams[0].players=[p];v.ballot(round:1,player:p.id,voter:"participant");precondition(v.votes.isEmpty);var g=v.games[0];g.x=1;g.y=0;g.goals=[p.id:2];precondition(!v.valid(g));g.goals=[p.id:1];precondition(v.valid(g));v.put(g);v.ballot(round:1,player:p.id,voter:"participant");v.ballot(round:1,player:p.id,voter:"participant");precondition(v.votes.count == 1);v.blocked=["participant"];precondition(v.leaders(1).isEmpty)
 var e=cup(3,true);for i in e.teams.indices{e.teams[i].players=[RqP(name:"P\(i)",team:e.teams[i].id)]};var em=e.games.first{$0.a != nil && $0.b != nil}!;em.x=1;em.y=0;e.put(em);e.ballot(round:1,player:e.teams[0].players[0].id,voter:"one");precondition(e.votes.isEmpty);var ef=e.games.last!;ef.x=1;ef.y=0;e.put(ef);e.ballot(round:2,player:e.teams[2].players[0].id,voter:"one");precondition(e.votes.isEmpty);e.ballot(round:2,player:e.teams[0].players[0].id,voter:"one");precondition(e.votes.count == 1);em.x=0;em.y=1;e.put(em);precondition(e.votes.isEmpty);precondition(e.leaders(2).isEmpty)
 print("{\"status\":\"passed\",\"teamCounts\":31,\"generatedMatches\":\(matches),\"checks\":[\"round-robin uniqueness\",\"one game per team per round\",\"knockout byes and n-1 matches\",\"winner propagation\",\"correction invalidation\",\"parallel match merge\",\"Codable round-trip\",\"scorer validation\",\"voting gate and deduplication\",\"blocked votes\",\"calendar days across DST\",\"first kickoff with byes\",\"round-eligible players and reopened voting\"]}")
 }
}
'''
p=r/'Build/core-checks.swift';p.write_text((r/'Sources/RqSeed02b143.swift').read_text()+body)
env=dict(os.environ)
subprocess.run(['xcrun','swiftc','-parse-as-library',str(p),'-module-cache-path',str(r/'Build/SwiftCache'),'-o',str(r/'Build/core-checks')],check=True,env=env)
result=subprocess.run([str(r/'Build/core-checks')],capture_output=True,text=True,check=True)
(r/'Evidence/core-results.json').write_text(result.stdout);print(result.stdout)
