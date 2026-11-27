import WidgetKit
import SwiftUI

private let rqWG=Color(red:0,green:0.47,blue:0.23)
struct RqMoment:TimelineEntry {var date:Date;var snapshot:RqCache?}
struct RqPulse:TimelineProvider {
 func placeholder(in context:Context)->RqMoment {RqMoment(date:Date(),snapshot:nil)}
 func getSnapshot(in context:Context,completion:@escaping(RqMoment)->Void){completion(read())}
 func getTimeline(in context:Context,completion:@escaping(Timeline<RqMoment>)->Void){completion(Timeline(entries:[read()],policy:.after(Date().addingTimeInterval(1800))))}
 func read()->RqMoment {let u=FileManager.default.containerURL(forSecurityApplicationGroupIdentifier:rqGroup)?.appendingPathComponent("round-cache.json");let s=u.flatMap{try? Data(contentsOf:$0)}.flatMap{try? JSONDecoder().decode(RqCache.self,from:$0)};return RqMoment(date:Date(),snapshot:s)}
}
struct RqTileBody:View {
 @Environment(\.widgetFamily) var family;var entry:RqMoment
 var body:some View {
  Group {if let s=entry.snapshot {
   switch family {
   case .accessoryCircular: VStack(spacing:2){Image(systemName:"soccerball");if let d=s.date{Text(d,format:.dateTime.day()).font(.headline)}else{Image(systemName:"checkmark")}}
   case .accessoryRectangular: VStack(alignment:.leading){Label(rqL(s.date.map{Calendar.current.isDateInWeekend($0)} == true ? "Weekend round":"Next round"),systemImage:"soccerball").font(.caption.bold());if let d=s.date{Text(d,format:.dateTime.weekday().day().month()).font(.caption)}else{Text(rqL("Round complete")).font(.caption)};Text(s.title).font(.caption2).lineLimit(1)}
   case .accessoryInline: Text(s.date.map{rqL("Next round")+" "+$0.formatted(.dateTime.day().month())} ?? rqL("Round complete"))
   case .systemSmall: VStack(alignment:.leading,spacing:9){HStack{Image(systemName:"soccerball");Spacer();Image(systemName:"trophy.fill").foregroundStyle(.yellow)}.foregroundStyle(rqWG);Text(rqL("Next round")).font(.caption.bold()).foregroundStyle(.secondary);if let d=s.date{Text(d,format:.dateTime.day().month()).font(.title2.bold())}else{Text(rqL("Round complete")).font(.headline)};Text(s.match).font(.caption).lineLimit(2);Text(s.title).font(.caption2).foregroundStyle(.secondary).lineLimit(1)}.frame(maxWidth:.infinity,alignment:.leading)
   default: VStack(alignment:.leading,spacing:family == .systemMedium ? 3:5){HStack{Label(s.title,systemImage:"trophy.fill").font(.headline).lineLimit(1);Spacer();if let d=s.date{Text(d,format:.dateTime.day().month()).font(.caption.bold())}};ForEach(Array(s.rows.prefix(6).enumerated()),id:\.element.id){i,r in HStack{Text("\(i+1)").font(.caption2).foregroundStyle(.secondary).frame(width:13);Text(r.name).font(.system(size:family == .systemMedium ? 11:12)).lineLimit(1);Spacer();Text("\(r.points)").font(.caption.bold().monospacedDigit()).foregroundStyle(rqWG)}};if family == .systemLarge {Divider();Text(rqL(s.knockout ? "Bracket":"Round fixtures")).font(.caption.bold()).foregroundStyle(rqWG);if s.knockout && s.bracket.count == 3 {HStack(spacing:7){VStack(alignment:.leading,spacing:4){Text(s.bracket[0]);Text(s.bracket[1])}.frame(maxWidth:.infinity,alignment:.leading);Image(systemName:"chevron.right").foregroundStyle(rqWG);Text(s.bracket[2]).frame(maxWidth:.infinity,alignment:.leading)}.font(.caption2).lineLimit(2)}else{ForEach(Array(s.bracket.enumerated()),id:\.offset){Text($0.element).font(.caption2).lineLimit(1)}};Divider();Text(rqL("Round calendar")).font(.caption.bold()).foregroundStyle(rqWG);ForEach(Array(s.fixtures.enumerated()),id:\.offset){Text($0.element).font(.caption2).lineLimit(1)};Text(rqL("Updated")+" "+s.updated.formatted(.dateTime.day().month().hour().minute())).font(.system(size:9)).foregroundStyle(.secondary)}}
   }
  }else{switch family {case .accessoryCircular:Image(systemName:"trophy").font(.title2).accessibilityLabel(rqL("Create tournament"));case .accessoryInline:Label(rqL("Create tournament"),systemImage:"trophy");case .accessoryRectangular:VStack(alignment:.leading,spacing:3){Label(rqL("Next round"),systemImage:"soccerball").font(.caption.bold());Text(rqL("Create a tournament in the app.")).font(.caption2).lineLimit(2)};default:VStack(alignment:.leading,spacing:8){Image(systemName:"trophy.fill").foregroundStyle(rqWG);Text(rqL("Your neighborhood cup")).font(.headline);Text(rqL("Create a tournament in the app.")).font(.caption).foregroundStyle(.secondary)}}}}
  .containerBackground(for:.widget){Color(red:0.95,green:0.98,blue:0.94)}.widgetURL(URL(string:"bairro://tournament"))
 }
}
@main struct RqTiles:Widget {
 var body:some WidgetConfiguration {StaticConfiguration(kind:"RqWeekendTiles",provider:RqPulse()){RqTileBody(entry:$0)}.configurationDisplayName(rqL("Neighborhood rounds")).description(rqL("Fixtures, local standings and the next round, available offline.")).supportedFamilies([.systemSmall,.systemMedium,.systemLarge,.accessoryCircular,.accessoryRectangular,.accessoryInline])}
}
