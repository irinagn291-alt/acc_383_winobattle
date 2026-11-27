import math,zlib,struct,json
from pathlib import Path
n=1024; data=bytearray(n*n*3)
for y in range(n):
 for x in range(n):
  t=y/n;stripe=((x+y)//160)%2;rgb=(int(3+stripe*2),int(85-45*t+stripe*5),int(43-18*t))
  o=(y*n+x)*3;data[o:o+3]=bytes(rgb)
def rect(x0,y0,x1,y1,c):
 for y in range(max(0,int(y0)),min(n,int(y1))):
  a=(y*n+max(0,int(x0)))*3;b=(y*n+min(n,int(x1)))*3;data[a:b]=bytes(c)*((b-a)//3)
def circle(cx,cy,r,c):
 for y in range(max(0,int(cy-r)),min(n,int(cy+r))):
  dx=math.sqrt(max(0,r*r-(y-cy)**2));rect(cx-dx,y,cx+dx,y+1,c)
def poly(points,c):
 for y in range(max(0,int(min(p[1] for p in points))),min(n,int(max(p[1] for p in points))+1)):
  xs=[]
  for a,b in zip(points,points[1:]+points[:1]):
   if (a[1]<=y<b[1]) or (b[1]<=y<a[1]):xs.append(a[0]+(y-a[1])*(b[0]-a[0])/(b[1]-a[1]))
  xs.sort()
  for a,b in zip(xs[::2],xs[1::2]):rect(a,y,b,y+1,c)
yellow=(255,223,0);light=(255,241,118);green=(2,78,39);pale=(172,219,157)
# Fine pitch lines and a bracket tree beneath the cup.
for y in [158,858]:rect(135,y,890,y+3,(55,119,73))
rect(135,158,138,861,(55,119,73));rect(887,158,890,861,(55,119,73))
for x in [224,800]:circle(x,696,16,pale)
for x in [224,800]:rect(x-5,696,x+5,752,pale)
rect(224,746,800,756,pale);rect(507,692,517,755,pale)
# Trophy handles, distinct open silhouette.
circle(324,356,108,yellow);circle(324,348,66,green)
circle(700,356,108,yellow);circle(700,348,66,green)
poly([(342,244),(682,244),(665,426),(631,485),(574,525),(450,525),(393,485),(359,426)],yellow)
poly([(365,260),(393,414),(425,455),(452,468),(429,420),(408,260)],light)
rect(482,505,542,625,yellow);poly([(432,619),(592,619),(628,667),(396,667)],yellow)
rect(387,664,637,693,light)
# Small community spark.
poly([(512,300),(531,339),(575,345),(543,375),(551,419),(512,398),(473,419),(481,375),(449,345),(493,339)],green)
def chunk(t,b):return struct.pack('!I',len(b))+t+b+struct.pack('!I',zlib.crc32(t+b)&0xffffffff)
p=Path('Resources/CourtAssets.xcassets');(p/'Contents.json').write_text(json.dumps({'info':{'author':'xcode','version':1}}))
a=p/'CourtMark.appiconset'
raw=b''.join(b'\x00'+data[y*n*3:(y+1)*n*3] for y in range(n))
(a/'CourtMark.png').write_bytes(b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('!IIBBBBB',n,n,8,2,0,0,0))+chunk(b'IDAT',zlib.compress(raw,9))+chunk(b'IEND',b''))
(a/'Contents.json').write_text(json.dumps({'images':[{'filename':'CourtMark.png','idiom':'universal','platform':'ios','size':'1024x1024'}],'info':{'author':'xcode','version':1}}))
