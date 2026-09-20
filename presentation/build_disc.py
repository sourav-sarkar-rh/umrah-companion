import json, subprocess
PID="1LHPbC5u4W7tcsBO0nCZ6LEBPy1EHBsLvKao4TcsuEFk"; PAGE="discuss3"
def rgb(h):
    h=h.lstrip('#'); return {"red":int(h[0:2],16)/255,"green":int(h[2:4],16)/255,"blue":int(h[4:6],16)/255}
TEAL,BRIGHT,GREY="#0A3D45","#00A896","#8FA3A8"
create=[{"createSlide":{"objectId":PAGE,"slideLayoutReference":{"predefinedLayout":"BLANK"}}}]
style=[]
def box(oid,x,y,w,h,shape="ROUND_RECTANGLE"):
    create.append({"createShape":{"objectId":oid,"shapeType":shape,"elementProperties":{"pageObjectId":PAGE,
      "size":{"width":{"magnitude":w,"unit":"PT"},"height":{"magnitude":h,"unit":"PT"}},
      "transform":{"scaleX":1,"scaleY":1,"translateX":x,"translateY":y,"unit":"PT"}}}})
def text(oid,s): create.append({"insertText":{"objectId":oid,"text":s}})
def plain(oid):
    style.append({"updateShapeProperties":{"objectId":oid,"shapeProperties":{
      "shapeBackgroundFill":{"propertyState":"NOT_RENDERED"},"outline":{"propertyState":"NOT_RENDERED"}},
      "fields":"shapeBackgroundFill,outline"}})
def txt(oid,size,color,bold,space=100):
    style.append({"updateTextStyle":{"objectId":oid,"style":{"fontFamily":"Calibri",
      "fontSize":{"magnitude":size,"unit":"PT"},"bold":bold,
      "foregroundColor":{"opaqueColor":{"rgbColor":rgb(color)}}},
      "fields":"fontFamily,fontSize,bold,foregroundColor","textRange":{"type":"ALL"}}})
    style.append({"updateParagraphStyle":{"objectId":oid,"style":{"alignment":"START","lineSpacing":space},
      "fields":"alignment,lineSpacing","textRange":{"type":"ALL"}}})

def section(key, y, label):
    box("sq_"+key, 16, y+6, 11, 11, "RECTANGLE")
    style.append({"updateShapeProperties":{"objectId":"sq_"+key,"shapeProperties":{
      "shapeBackgroundFill":{"solidFill":{"color":{"rgbColor":rgb(BRIGHT)}}},
      "outline":{"propertyState":"NOT_RENDERED"}},
      "fields":"shapeBackgroundFill.solidFill.color,outline"}})
    box("lb_"+key, 34, y, 400, 18, "TEXT_BOX"); text("lb_"+key, label)
    plain("lb_"+key); txt("lb_"+key, 18, TEAL, True)

section("lim", 24, "Limitations")
box("t_lim",16,44,688,90,"TEXT_BOX")
text("t_lim",
"•  Outdoors and sunlit: time-of-flight depth degrades in direct sun.\n"
"•  At 5 m in a crowd of hundreds of thousands, depth returns a wall of people, not discrete obstacles.\n"
"•  Our course is 2 m radius; a real circuit is 100 m+ per lap, seven times, with no anchors and a crowd "
"breaking feature tracking. ARKit pose alone will not survive it — fixed anchors, UWB or Haram "
"infrastructure would.\n"
"•  Detection rides the COCO person class; there is no Hajj-specific dataset.")
plain("t_lim"); txt("t_lim",15,TEAL,False)

section("imp", 140, "Impact")
box("t_imp",16,160,688,56,"TEXT_BOX")
text("t_imp","~90,000 pilgrims who are blind perform Umrah each year; Vision 2030 targets 30 million "
"pilgrims by 2030. No new hardware and no per-pilgrim capex — it runs on the phone they already own. "
"The stack extends to other rituals, sites and disabilities.")
plain("t_imp"); txt("t_imp",15,TEAL,False)

section("eth", 222, "Ethics")
box("t_eth",16,242,688,74,"TEXT_BOX")
text("t_eth","Video never leaves the phone; at most one still frame, only on request. Location sharing "
"is off by default, pilgrim-granted, time-boxed and revocable, and the pilgrim is told when it is viewed. "
"Safety interrupts everything, including du'a. The app assists the ritual; it does not rule on its "
"validity — the pilgrim remains the authority.")
plain("t_eth"); txt("t_eth",15,TEAL,False)

box("t_ref",16,324,688,30,"TEXT_BOX")
text("t_ref","1. Saudi Vision 2030, Pilgrim Experience Program  ·  2. IAPB Vision Atlas, Magnitude of "
"Sight Loss  ·  3. Author estimate: 0.5% global blindness prevalence applied to 2025 Umrah volume  ·  "
"4. General Presidency for the Affairs of the Two Holy Mosques")
plain("t_ref"); txt("t_ref",13,GREY,False)

for n,b in [("create",create),("style",style)]:
    r=subprocess.run(["gws","slides","presentations","batchUpdate","--params",json.dumps({"presentationId":PID}),
        "--json",json.dumps({"requests":b})],capture_output=True,text=True)
    print(n,"->","OK" if r.returncode==0 else "FAIL")
    if r.returncode: print(r.stdout[:800])
