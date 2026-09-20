import json, subprocess
PID="1LHPbC5u4W7tcsBO0nCZ6LEBPy1EHBsLvKao4TcsuEFk"; PAGE="results2"
def rgb(h):
    h=h.lstrip('#'); return {"red":int(h[0:2],16)/255,"green":int(h[2:4],16)/255,"blue":int(h[4:6],16)/255}
TEAL,BRIGHT,GOLD,LIGHT,BORDER,GREY="#0A3D45","#00A896","#D4AD54","#EAF5F3","#D7E4E3","#8FA3A8"

create=[{"createSlide":{"objectId":PAGE,"slideLayoutReference":{"predefinedLayout":"BLANK"}}}]
style=[]
def box(oid,x,y,w,h,shape="ROUND_RECTANGLE"):
    create.append({"createShape":{"objectId":oid,"shapeType":shape,"elementProperties":{"pageObjectId":PAGE,
      "size":{"width":{"magnitude":w,"unit":"PT"},"height":{"magnitude":h,"unit":"PT"}},
      "transform":{"scaleX":1,"scaleY":1,"translateX":x,"translateY":y,"unit":"PT"}}}})
def text(oid,s): create.append({"insertText":{"objectId":oid,"text":s}})
def fill(oid,bg=None,line=None,dash="SOLID",mid=True):
    sp,f={},[]
    if bg=="none": sp["shapeBackgroundFill"]={"propertyState":"NOT_RENDERED"}; f.append("shapeBackgroundFill")
    elif bg: sp["shapeBackgroundFill"]={"solidFill":{"color":{"rgbColor":rgb(bg)}}}; f.append("shapeBackgroundFill.solidFill.color")
    if line=="none": sp["outline"]={"propertyState":"NOT_RENDERED"}; f.append("outline")
    elif line: sp["outline"]={"outlineFill":{"solidFill":{"color":{"rgbColor":rgb(line)}}},
        "weight":{"magnitude":1,"unit":"PT"},"dashStyle":dash}; f.append("outline")
    if mid: sp["contentAlignment"]="MIDDLE"; f.append("contentAlignment")
    style.append({"updateShapeProperties":{"objectId":oid,"shapeProperties":sp,"fields":",".join(f)}})
def txt(oid,size=15,color=TEAL,bold=False,align="START",space=0):
    style.append({"updateTextStyle":{"objectId":oid,"style":{"fontFamily":"Calibri",
      "fontSize":{"magnitude":size,"unit":"PT"},"bold":bold,
      "foregroundColor":{"opaqueColor":{"rgbColor":rgb(color)}}},
      "fields":"fontFamily,fontSize,bold,foregroundColor","textRange":{"type":"ALL"}}})
    st={"alignment":align}; fl="alignment"
    if space: st["lineSpacing"]=space; fl+=",lineSpacing"
    style.append({"updateParagraphStyle":{"objectId":oid,"style":st,"fields":fl,"textRange":{"type":"ALL"}}})

# 1. Method
box("m_lbl",16,8,688,18,"TEXT_BOX"); text("m_lbl","Method")
fill("m_lbl","none","none",mid=False); txt("m_lbl",18,TEAL,True)

box("m_par",16,30,688,96,"TEXT_BOX")
text("m_par","The Kaaba was simulated as an ARKit world anchor placed on a physical object, and testers "
 "walked a 2 m proxy course indoors. Approximately 20 trials across friends and co-workers on iPhone 16 Pro, "
 "plus 44 headless assertions across four ritual-logic simulations. Obstacle detection runs YOLOv8n "
 "(80 COCO classes) converted to Core ML, with Apple's Vision human detector as fallback; each detection "
 "is ranged by the LiDAR depth map.")
fill("m_par","none","none",mid=False); txt("m_par",15,TEAL,False,"START",100)

# 2. Verified on device
box("v_lbl",16,134,688,18,"TEXT_BOX"); text("v_lbl","Verified on device")
fill("v_lbl","none","none",mid=False); txt("v_lbl",18,TEAL,True)

box("v_panel",16,154,688,173); fill("v_panel",LIGHT,"none",mid=False)

ROWS=["Tawaf circuit counting","Circle guidance — drift inward / outward",
      "Obstacle detection + LiDAR range","Voice command layer — EN / AR / UR",
      "Sa'i mode and guidance","Du'a with safety interrupt"]
for i,label in enumerate(ROWS):
    y=160+i*27
    box(f"rrow{i}",28,y,664,26); fill(f"rrow{i}","#FFFFFF",BORDER)
    box(f"rlab{i}",44,y,540,26,"TEXT_BOX"); text(f"rlab{i}",label)
    fill(f"rlab{i}","none","none"); txt(f"rlab{i}",15,TEAL)
    box(f"rtik{i}",612,y,64,26,"TEXT_BOX"); text(f"rtik{i}","✓")
    fill(f"rtik{i}","none","none"); txt(f"rtik{i}",16,BRIGHT,True,"CENTER")

# 3. Pilot pending row
box("pilot",16,335,688,26); fill("pilot","none",GREY,"DASH")
box("pilot_t",32,335,656,26,"TEXT_BOX")
text("pilot_t","Web portal · caregiver matching · SOS  —  pilot pending: needs a larger cohort and resources beyond the hackathon")
fill("pilot_t","none","none"); txt("pilot_t",14,GREY,False)

# 4. Closing
box("close",16,367,688,18,"TEXT_BOX")
text("close","Still to run: a pilot with pilgrims who have visual impairment.")
fill("close","none","none",mid=False); txt("close",15,TEAL,True)

for n,b in [("create",create),("style",style)]:
    r=subprocess.run(["gws","slides","presentations","batchUpdate","--params",json.dumps({"presentationId":PID}),
        "--json",json.dumps({"requests":b})],capture_output=True,text=True)
    print(n,"->","OK" if r.returncode==0 else "FAIL",len(b))
    if r.returncode: print(r.stdout[:900])
