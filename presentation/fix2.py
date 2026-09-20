import json, subprocess
PID="1LHPbC5u4W7tcsBO0nCZ6LEBPy1EHBsLvKao4TcsuEFk"; PAGE="p"
def rgb(h):
    h=h.lstrip('#'); return {"red":int(h[0:2],16)/255,"green":int(h[2:4],16)/255,"blue":int(h[4:6],16)/255}
TEAL,BRIGHT,GOLD,BORDER,GREY="#0A3D45","#00A896","#D4AD54","#D7E4E3","#8FA3A8"
dead=["netw0","netw1","netw2","netw3","arrow3","portal","lbl_net"]
create=[{"deleteObject":{"objectId":o}} for o in dead]
style=[]
def box(oid,x,y,w,h,shape="ROUND_RECTANGLE"):
    create.append({"createShape":{"objectId":oid,"shapeType":shape,"elementProperties":{"pageObjectId":PAGE,
      "size":{"width":{"magnitude":w,"unit":"PT"},"height":{"magnitude":h,"unit":"PT"}},
      "transform":{"scaleX":1,"scaleY":1,"translateX":x,"translateY":y,"unit":"PT"}}}})
def text(oid,s): create.append({"insertText":{"objectId":oid,"text":s}})
def fill(oid,bg=None,line=None,mid=True):
    sp,f={},[]
    if bg=="none": sp["shapeBackgroundFill"]={"propertyState":"NOT_RENDERED"}; f.append("shapeBackgroundFill")
    elif bg: sp["shapeBackgroundFill"]={"solidFill":{"color":{"rgbColor":rgb(bg)}}}; f.append("shapeBackgroundFill.solidFill.color")
    if line=="none": sp["outline"]={"propertyState":"NOT_RENDERED"}; f.append("outline")
    elif line: sp["outline"]={"outlineFill":{"solidFill":{"color":{"rgbColor":rgb(line)}}},
        "weight":{"magnitude":1,"unit":"PT"},"dashStyle":"SOLID"}; f.append("outline")
    if mid: sp["contentAlignment"]="MIDDLE"; f.append("contentAlignment")
    style.append({"updateShapeProperties":{"objectId":oid,"shapeProperties":sp,"fields":",".join(f)}})
def txt(oid,size=13,color=TEAL,bold=False,align="CENTER"):
    style.append({"updateTextStyle":{"objectId":oid,"style":{"fontFamily":"Calibri",
      "fontSize":{"magnitude":size,"unit":"PT"},"bold":bold,
      "foregroundColor":{"opaqueColor":{"rgbColor":rgb(color)}}},
      "fields":"fontFamily,fontSize,bold,foregroundColor","textRange":{"type":"ALL"}}})
    style.append({"updateParagraphStyle":{"objectId":oid,"style":{"alignment":align},
      "fields":"alignment","textRange":{"type":"ALL"}}})

# label on one line, sitting above the boxes
box("lbl_net",28,286,560,13,"TEXT_BOX")
text("lbl_net","NETWORK  ·  optional — every path has an on-device fallback")
fill("lbl_net","none","none",mid=False); txt("lbl_net",11,GREY,True,"START")

NET=["Scene description\n1 frame, on request","Relocalisation\nKaaba as anchor",
     "SOS +\nlocation share","Companion\nbooking"]
for i,l in enumerate(NET):
    oid=f"netw{i}"; box(oid,24+i*134,308,124,34); text(oid,l); fill(oid,"#FFFFFF",BORDER); txt(oid,11)
box("arrow3",556,316,18,18,"RIGHT_ARROW"); fill("arrow3",TEAL,"none",mid=False)
box("portal",580,308,116,34); text("portal","FAMILY PORTAL"); fill("portal",TEAL,"none"); txt("portal",13,"#FFFFFF",True)

for n,b in [("create",create),("style",style)]:
    r=subprocess.run(["gws","slides","presentations","batchUpdate","--params",json.dumps({"presentationId":PID}),
        "--json",json.dumps({"requests":b})],capture_output=True,text=True)
    print(n,"->","OK" if r.returncode==0 else "FAIL")
    if r.returncode: print(r.stdout[:900])
