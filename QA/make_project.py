from pathlib import Path
import json, plistlib, uuid
root=Path(__file__).resolve().parents[1]
R=root/'Resources'
def plist(name,obj): (R/name).write_bytes(plistlib.dumps(obj,sort_keys=False))
common={'CFBundleDevelopmentRegion':'en','CFBundleExecutable':'$(EXECUTABLE_NAME)','CFBundleIdentifier':'$(PRODUCT_BUNDLE_IDENTIFIER)','CFBundleInfoDictionaryVersion':'6.0','CFBundleName':'$(PRODUCT_NAME)','CFBundleShortVersionString':'$(MARKETING_VERSION)','CFBundleVersion':'$(CURRENT_PROJECT_VERSION)'}
plist('Riacho.plist',dict(common,CFBundlePackageType='APPL',CFBundleDisplayName='Campeonato do Bairro',UILaunchScreen={},UIApplicationSupportsIndirectInputEvents=True,UIApplicationSceneManifest={'UIApplicationSupportsMultipleScenes':False,'UISceneConfigurations':{}},UIRequiresFullScreen=False,UISupportedInterfaceOrientations=['UIInterfaceOrientationPortrait','UIInterfaceOrientationLandscapeLeft','UIInterfaceOrientationLandscapeRight'],UIBackgroundModes=['remote-notification'],RqSignedCloud='$(CODE_SIGNING_ALLOWED)',CKSharingSupported=True,ITSAppUsesNonExemptEncryption=False,CFBundleURLTypes=[{'CFBundleURLName':'com.campeonatodobairro.app','CFBundleURLSchemes':['bairro']}]))
x=plistlib.loads((R/'Riacho.plist').read_bytes());x['UISupportedInterfaceOrientations~ipad']=['UIInterfaceOrientationPortrait','UIInterfaceOrientationPortraitUpsideDown','UIInterfaceOrientationLandscapeLeft','UIInterfaceOrientationLandscapeRight'];plist('Riacho.plist',x)
plist('Rounds.plist',dict(common,CFBundlePackageType='XPC!',CFBundleDisplayName='Neighborhood rounds',NSExtension={'NSExtensionPointIdentifier':'com.apple.widgetkit-extension'}))
plist('Riacho.entitlements',{'com.apple.security.application-groups':['group.org.courtyard.mosaicr7'],'com.apple.developer.icloud-container-identifiers':['iCloud.org.courtyard.mosaicr7'],'com.apple.developer.icloud-services':['CloudKit'],'com.apple.developer.applesignin':['Default'],'aps-environment':'development'})
plist('Rounds.entitlements',{'com.apple.security.application-groups':['group.org.courtyard.mosaicr7']})
plist('PrivacyInfo.xcprivacy',{'NSPrivacyTracking':False,'NSPrivacyTrackingDomains':[],'NSPrivacyCollectedDataTypes':[],'NSPrivacyAccessedAPITypes':[{'NSPrivacyAccessedAPIType':'NSPrivacyAccessedAPICategoryFileTimestamp','NSPrivacyAccessedAPITypeReasons':['C617.1']}]})
(R/'Localizable.xcstrings').write_text(json.dumps({'sourceLanguage':'en','strings':{},'version':'1.0'})) if not (R/'Localizable.xcstrings').exists() else None
(R/'InfoPlist.xcstrings').write_text(json.dumps({'sourceLanguage':'en','strings':{'CFBundleDisplayName':{'localizations':{l:{'stringUnit':{'state':'translated','value':'Campeonato do Bairro'}} for l in ['en','pt-BR','es','de','fr','it']}}},'version':'1.0'},ensure_ascii=False,indent=2))
obj={}
def new(body):
 k=uuid.uuid4().hex[:24].upper();obj[k]=body;return k
def quote(x):return json.dumps(str(x))
def arr(xs):return '('+', '.join(xs)+',)' if xs else '()'
def ref(path,typ):return new(f'isa = PBXFileReference; lastKnownFileType = {typ}; path = {quote(path)}; sourceTree = "<group>";')
files={}
for path in ['Sources/RqSeed02b143.swift','Sources/RqVault.swift','Sources/RqEntry.swift','Sources/RqCourts.swift','Widgets/RqTiles.swift','QA/RqProof.swift','Resources/Localizable.xcstrings','Resources/InfoPlist.xcstrings','Resources/PrivacyInfo.xcprivacy','Resources/CourtAssets.xcassets']:
 files[path]=ref(path,'sourcecode.swift' if path.endswith('.swift') else 'text.json.xcstrings' if path.endswith('xcstrings') else 'folder.assetcatalog' if path.endswith('xcassets') else 'text.xml')
def phase(kind,paths):
 builds=[new(f'isa = PBXBuildFile; fileRef = {files[p]};') for p in paths]
 return new(f'isa = PBX{kind}BuildPhase; buildActionMask = 2147483647; files = {arr(builds)}; runOnlyForDeploymentPostprocessing = 0;')
def conf(settings):
 cs=[]
 for name in ['Development','Distribution']:
  s=dict(settings);s['SWIFT_OPTIMIZATION_LEVEL']='-Onone' if name == 'Development' else '-O';s['DEBUG_INFORMATION_FORMAT']='dwarf'
  if name=='Development':s['SWIFT_ACTIVE_COMPILATION_CONDITIONS']='DEBUG';s['ENABLE_TESTABILITY']='YES'
  else:s.update(DEPLOYMENT_POSTPROCESSING='YES',STRIP_INSTALLED_PRODUCT='YES',STRIP_STYLE='non-global',SWIFT_SERIALIZE_DEBUGGING_OPTIONS='NO',OTHER_SWIFT_FLAGS=['$(inherited)','-debug-prefix-map','$(SRCROOT)=.','-file-prefix-map','$(SRCROOT)=.'])
  cs.append(new('isa = XCBuildConfiguration; name = '+quote(name)+'; buildSettings = {'+' '.join(k+' = '+(arr([quote(y) for y in v]) if isinstance(v,list) else quote(v))+';' for k,v in s.items())+'};'))
 return new(f'isa = XCConfigurationList; buildConfigurations = {arr(cs)}; defaultConfigurationIsVisible = 0; defaultConfigurationName = Distribution;')
base={'SWIFT_VERSION':'5.0','IPHONEOS_DEPLOYMENT_TARGET':'17.4','TARGETED_DEVICE_FAMILY':'1,2','SDKROOT':'iphoneos','SUPPORTED_PLATFORMS':'iphoneos iphonesimulator','SUPPORTS_MACCATALYST':'NO','SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD':'NO','MARKETING_VERSION':'1.3.7','CURRENT_PROJECT_VERSION':'143','CODE_SIGN_STYLE':'Automatic','CLANG_ENABLE_MODULES':'YES','SWIFT_EMIT_LOC_STRINGS':'YES','LOCALIZATION_PREFERS_STRING_CATALOGS':'YES','ENABLE_USER_SCRIPT_SANDBOXING':'YES'}
projectID=uuid.uuid4().hex[:24].upper();appID=uuid.uuid4().hex[:24].upper();widID=uuid.uuid4().hex[:24].upper();testID=uuid.uuid4().hex[:24].upper()
products=[new(f'isa = PBXFileReference; explicitFileType = {typ}; includeInIndex = 0; path = {name}; sourceTree = BUILT_PRODUCTS_DIR;') for name,typ in [('Riacho.app','wrapper.application'),('RiachoRounds.appex','wrapper.app-extension'),('RiachoProof.xctest','wrapper.cfbundle')]]
productGroup=new(f'isa = PBXGroup; children = {arr(products)}; name = Products; sourceTree = "<group>";')
mainGroup=new(f'isa = PBXGroup; children = {arr(list(files.values())+[productGroup])}; sourceTree = "<group>";')
proxy=new(f'isa = PBXContainerItemProxy; containerPortal = {projectID}; proxyType = 1; remoteGlobalIDString = {widID}; remoteInfo = RiachoRounds;')
dep=new(f'isa = PBXTargetDependency; target = {widID}; targetProxy = {proxy};')
embedBuild=new(f'isa = PBXBuildFile; fileRef = {products[1]}; settings = {{ATTRIBUTES = (RemoveHeadersOnCopy,);}};')
embed=new(f'isa = PBXCopyFilesBuildPhase; buildActionMask = 2147483647; dstPath = ""; dstSubfolderSpec = 13; files = ({embedBuild},); name = "Embed round widgets"; runOnlyForDeploymentPostprocessing = 0;')
res=['Resources/Localizable.xcstrings','Resources/InfoPlist.xcstrings','Resources/PrivacyInfo.xcprivacy','Resources/CourtAssets.xcassets']
for tid,name,idx,bid,paths,info,ent in [(appID,'Riacho',0,'com.campeonatodobairro.app',['Sources/RqSeed02b143.swift','Sources/RqVault.swift','Sources/RqEntry.swift','Sources/RqCourts.swift'],'Riacho.plist','Riacho.entitlements'),(widID,'RiachoRounds',1,'com.campeonatodobairro.app.rounds',['Sources/RqSeed02b143.swift','Widgets/RqTiles.swift'],'Rounds.plist','Rounds.entitlements'),(testID,'RiachoProof',2,'com.campeonatodobairro.app.proof',['Sources/RqSeed02b143.swift','Sources/RqVault.swift','QA/RqProof.swift'],None,None)]:
 s=dict(base,PRODUCT_NAME=name,PRODUCT_BUNDLE_IDENTIFIER=bid)
 if info:s.update(INFOPLIST_FILE='Resources/'+info,CODE_SIGN_ENTITLEMENTS='Resources/'+ent)
 else:s.update(GENERATE_INFOPLIST_FILE='YES',TEST_TARGET_NAME='Riacho')
 if idx==0:s['ASSETCATALOG_COMPILER_APPICON_NAME']='CourtMark'
 if idx==1:s.update(APPLICATION_EXTENSION_API_ONLY='YES',SKIP_INSTALL='YES')
 phases=[phase('Sources',paths),phase('Frameworks',[]),phase('Resources',res if idx<2 else [])]
 if idx==0:phases.append(embed)
 typ=['com.apple.product-type.application','com.apple.product-type.app-extension','com.apple.product-type.bundle.ui-testing'][idx]
 obj[tid]=f'isa = PBXNativeTarget; buildConfigurationList = {conf(s)}; buildPhases = {arr(phases)}; buildRules = (); dependencies = {arr([dep] if idx==0 else [])}; name = {name}; productName = {name}; productReference = {products[idx]}; productType = {quote(typ)};'
obj[projectID]=f'isa = PBXProject; attributes = {{LastUpgradeCheck = 2720; ORGANIZATIONNAME = "Riacho Civic Studio"; TargetAttributes = {{{appID} = {{SystemCapabilities = {{com.apple.Push = {{enabled = 1;}}; com.apple.iCloud = {{enabled = 1;}}; com.apple.SignInWithApple = {{enabled = 1;}}; com.apple.ApplicationGroups.iOS = {{enabled = 1;}};}};}};}};}}; buildConfigurationList = {conf({"CLANG_ENABLE_OBJC_ARC":"YES","ALWAYS_SEARCH_USER_PATHS":"NO"})}; compatibilityVersion = "Xcode 14.0"; developmentRegion = en; hasScannedForEncodings = 0; knownRegions = (en, "pt-BR", es, de, fr, it, Base); mainGroup = {mainGroup}; productRefGroup = {productGroup}; projectDirPath = ""; projectRoot = ""; targets = ({appID}, {widID}, {testID});'
p=root/'Riacho.xcodeproj';p.mkdir(exist_ok=True)
(p/'project.pbxproj').write_text('// !$*UTF8*$!\n{archiveVersion = 1; classes = {}; objectVersion = 56; objects = {\n'+'\n'.join(k+' = {'+v+'};' for k,v in obj.items())+'\n}; rootObject = '+projectID+';}\n')
scheme=p/'xcshareddata/xcschemes';scheme.mkdir(parents=True,exist_ok=True)
def buildRef(t,n):return f'<BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{t}" BuildableName="{n}.app" BlueprintName="{n}" ReferencedContainer="container:Riacho.xcodeproj"/>'
a=buildRef(appID,'Riacho');t=f'<BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{testID}" BuildableName="RiachoProof.xctest" BlueprintName="RiachoProof" ReferencedContainer="container:Riacho.xcodeproj"/>'
(scheme/'Riacho.xcscheme').write_text(f'''<?xml version="1.0" encoding="UTF-8"?><Scheme LastUpgradeVersion="2720" version="1.3"><BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES"><BuildActionEntries><BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">{a}</BuildActionEntry></BuildActionEntries></BuildAction><TestAction buildConfiguration="Development" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv="YES"><Testables><TestableReference skipped="NO">{t}</TestableReference></Testables></TestAction><LaunchAction buildConfiguration="Development" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" debugServiceExtension="internal" allowLocationSimulation="YES"><BuildableProductRunnable runnableDebuggingMode="0">{a}</BuildableProductRunnable></LaunchAction><ProfileAction buildConfiguration="Distribution" shouldUseLaunchSchemeArgsEnv="YES" useCustomWorkingDirectory="NO" debugDocumentVersioning="YES"><BuildableProductRunnable runnableDebuggingMode="0">{a}</BuildableProductRunnable></ProfileAction><AnalyzeAction buildConfiguration="Development"/><ArchiveAction buildConfiguration="Distribution" revealArchiveInOrganizer="YES"/></Scheme>''')
print('Generated Riacho project with',len(obj),'unique object IDs')
