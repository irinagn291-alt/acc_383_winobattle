from pathlib import Path
from zipfile import ZipFile,ZIP_DEFLATED
import shutil,hashlib,json
r=Path(__file__).resolve().parents[1];d=r/'Delivery';d.mkdir(exist_ok=True)
with ZipFile(d/'Riacho-source.zip','w',ZIP_DEFLATED) as z:
 for name in ['Sources','Widgets','Resources','Metadata','QA','Riacho.xcodeproj']:
  for f in sorted((r/name).rglob('*')):
   if f.is_file() and not any(x in f.parts for x in ['xcuserdata','__pycache__']) and f.name!='.DS_Store':z.write(f,f.relative_to(r))
 for f in sorted((r/'Evidence').glob('*.json')):
  if f.name!='input-verification.json':z.write(f,f.relative_to(r))
 for name in ['REPORT.md','.gitignore']:
  f=r/name
  if f.exists():z.write(f,name)
app=r/'Build/DeviceDerived/Build/Products/Distribution-iphoneos/Riacho.app'
if app.exists():
 with ZipFile(d/'Riacho-unsigned-iphoneos.zip','w',ZIP_DEFLATED) as z:
  for f in sorted(app.rglob('*')):
   if f.is_file():z.write(f,Path('Riacho.app')/f.relative_to(app))
files={f.name:hashlib.sha256(f.read_bytes()).hexdigest() for f in sorted(d.glob('*.zip'))}
(d/'SHA256.json').write_text(json.dumps(files,indent=2));print(json.dumps(files,indent=2))
