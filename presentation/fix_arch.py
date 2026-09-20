import json, subprocess
PID="1LHPbC5u4W7tcsBO0nCZ6LEBPy1EHBsLvKao4TcsuEFk"; PAGE="p"
def rgb(h):
    h=h.lstrip('#'); return {"red":int(h[0:2],16)/255,"green":int(h[2:4],16)/255,"blue":int(h[4:6],16)/255}
TEAL,BRIGHT,GREY="#0A3D45","#00A896","#8FA3A8"
def move(oid,x,y):
    return {"updatePageElementTransform":{"objectId":oid,"applyMode":"ABSOLUTE",
        "transform":{"scaleX":1,"scaleY":1,"translateX":x,"translateY":y,"unit":"PT"}}}

reqs=[{"deleteObject":{"objectId":"panel_net"}},{"deleteObject":{"objectId":"arrow2"}}]
# taller network panel so the label clears the boxes
reqs.append({"createShape":{"objectId":"panel_net","shapeType":"ROUND_RECTANGLE",
    "elementProperties":{"pageObjectId":PAGE,
        "size":{"width":{"magnitude":688,"unit":"PT"},"height":{"magnitude":72,"unit":"PT"}},
        "transform":{"scaleX":1,"scaleY":1,"translateX":16,"translateY":280,"unit":"PT"}}}})
# narrower arrow, clear of the DECIDE column edge
reqs.append({"createShape":{"objectId":"arrow2","shapeType":"RIGHT_ARROW",
    "elementProperties":{"pageObjectId":PAGE,
        "size":{"width":{"magnitude":18,"unit":"PT"},"height":{"magnitude":34,"unit":"PT"}},
        "transform":{"scaleX":1,"scaleY":1,"translateX":465,"translateY":152,"unit":"PT"}}}})
reqs.append(move("lbl_net",28,285))
for i in range(4): reqs.append(move(f"netw{i}",24+i*134,314))
reqs.append(move("arrow3",556,322)); reqs.append(move("portal",580,314))

style=[
 {"updateShapeProperties":{"objectId":"panel_net","shapeProperties":{
    "shapeBackgroundFill":{"propertyState":"NOT_RENDERED"},
    "outline":{"outlineFill":{"solidFill":{"color":{"rgbColor":rgb(GREY)}}},
               "weight":{"magnitude":1.5,"unit":"PT"},"dashStyle":"DASH"}},
    "fields":"shapeBackgroundFill,outline"}},
 {"updateShapeProperties":{"objectId":"arrow2","shapeProperties":{
    "shapeBackgroundFill":{"solidFill":{"color":{"rgbColor":rgb(BRIGHT)}}},
    "outline":{"propertyState":"NOT_RENDERED"}},
    "fields":"shapeBackgroundFill.solidFill.color,outline"}},
]
# send panel to back so it doesn't cover the boxes
style.append({"updatePageElementsZOrder":{"pageObjectIds":["panel_net"],"operation":"SEND_TO_BACK"}})

for name,batch in [("move",reqs),("style",style)]:
    r=subprocess.run(["gws","slides","presentations","batchUpdate","--params",json.dumps({"presentationId":PID}),
        "--json",json.dumps({"requests":batch})],capture_output=True,text=True)
    print(name,"->","OK" if r.returncode==0 else "FAIL")
    if r.returncode: print(r.stdout[:900],r.stderr[:600])
