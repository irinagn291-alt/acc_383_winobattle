import json,re
from pathlib import Path
r=Path(__file__).resolve().parents[1];strings={}
for line in (r/'Resources/translations.txt').read_text().splitlines():
 parts=[x.replace('\\n','\n') for x in line.split('|')]
 assert len(parts)==6,(len(parts),parts[0])
 strings[parts[0]]={'localizations':{l:{'stringUnit':{'state':'translated','value':v}} for l,v in zip(['en','pt-BR','es','de','fr','it'],parts)}}
(r/'Resources/Localizable.xcstrings').write_text(json.dumps({'sourceLanguage':'en','strings':strings,'version':'1.0'},ensure_ascii=False,indent=2))
print(len(strings),'keys × 6 languages')
