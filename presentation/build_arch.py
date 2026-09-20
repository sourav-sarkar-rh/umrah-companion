import json, subprocess

PID = "1LHPbC5u4W7tcsBO0nCZ6LEBPy1EHBsLvKao4TcsuEFk"
PAGE = "p"

def rgb(h):
    h = h.lstrip('#')
    return {"red": int(h[0:2],16)/255, "green": int(h[2:4],16)/255, "blue": int(h[4:6],16)/255}

TEAL   = "#0A3D45"   # dark teal, poster heading colour
BRIGHT = "#00A896"   # bright teal accent
GOLD   = "#D4AD54"   # app gold
LIGHT  = "#EAF5F3"   # panel fill
BORDER = "#D7E4E3"   # box border
GREY   = "#8FA3A8"

create, style = [], []
def box(oid, x, y, w, h, shape="ROUND_RECTANGLE"):
    create.append({"createShape": {"objectId": oid, "shapeType": shape,
        "elementProperties": {"pageObjectId": PAGE,
            "size": {"width": {"magnitude": w, "unit": "PT"}, "height": {"magnitude": h, "unit": "PT"}},
            "transform": {"scaleX":1,"scaleY":1,"translateX":x,"translateY":y,"unit":"PT"}}}})

def text(oid, s):
    create.append({"insertText": {"objectId": oid, "text": s}})

def fill(oid, bg=None, line=None, dash="SOLID", weight=1, mid=True):
    sp, fields = {}, []
    if bg == "none":
        sp["shapeBackgroundFill"] = {"propertyState": "NOT_RENDERED"}; fields.append("shapeBackgroundFill")
    elif bg:
        sp["shapeBackgroundFill"] = {"solidFill": {"color": {"rgbColor": rgb(bg)}}}; fields.append("shapeBackgroundFill.solidFill.color")
    if line == "none":
        sp["outline"] = {"propertyState": "NOT_RENDERED"}; fields.append("outline")
    elif line:
        sp["outline"] = {"outlineFill": {"solidFill": {"color": {"rgbColor": rgb(line)}}},
                         "weight": {"magnitude": weight, "unit": "PT"}, "dashStyle": dash}; fields.append("outline")
    if mid:
        sp["contentAlignment"] = "MIDDLE"; fields.append("contentAlignment")
    style.append({"updateShapeProperties": {"objectId": oid, "shapeProperties": sp, "fields": ",".join(fields)}})

def txt(oid, size=15, color=TEAL, bold=False, align="CENTER"):
    style.append({"updateTextStyle": {"objectId": oid,
        "style": {"fontFamily":"Calibri","fontSize":{"magnitude":size,"unit":"PT"},"bold":bold,
                  "foregroundColor":{"opaqueColor":{"rgbColor":rgb(color)}}},
        "fields":"fontFamily,fontSize,bold,foregroundColor","textRange":{"type":"ALL"}}})
    style.append({"updateParagraphStyle": {"objectId": oid, "style":{"alignment":align},
        "fields":"alignment","textRange":{"type":"ALL"}}})

# ---- geometry (band y=52..346 inside a 720x405 slide) ----
X0, XW = 16, 688
COL = {"sense": (24,168), "decide": (216,246), "speak": (486,210)}

# on-device panel
box("panel_dev", X0, 52, XW, 196); fill("panel_dev", LIGHT, "none", mid=False)
box("lbl_dev", 28, 58, 380, 14, "TEXT_BOX"); text("lbl_dev","ON DEVICE  ·  everything safety-critical runs here")
fill("lbl_dev","none","none",mid=False); txt("lbl_dev", 11, TEAL, True, "START")

# column headers
for key,(x,w),name in [("sense",COL["sense"],"SENSE"),("decide",COL["decide"],"DECIDE"),("speak",COL["speak"],"SPEAK")]:
    box("h_"+key, x, 76, w, 14, "TEXT_BOX"); text("h_"+key, name)
    fill("h_"+key,"none","none",mid=False); txt("h_"+key, 12, BRIGHT, True)

SENSE  = ["ARKit pose","LiDAR depth 256 × 192","Camera · Core ML","Microphone · on-device STT"]
DECIDE = ["Circuit counter","Path guide","Obstacle ranker","Voice intent · fixed grammar"]
SPEAK  = ["Spoken guidance · EN/AR/UR","Spatial audio beacon","Haptics"]

for i,label in enumerate(SENSE):
    y = 96 + i*38; oid=f"sens{i}"
    box(oid, COL["sense"][0], y, COL["sense"][1], 32); text(oid,label); fill(oid,"#FFFFFF",BORDER); txt(oid,13)
for i,label in enumerate(DECIDE):
    y = 96 + i*38; oid=f"dcde{i}"
    box(oid, COL["decide"][0], y, COL["decide"][1], 32); text(oid,label); fill(oid,"#FFFFFF",BRIGHT); txt(oid,14,TEAL,True)
for i,label in enumerate(SPEAK):
    y = 96 + i*50; oid=f"outp{i}"
    box(oid, COL["speak"][0], y, COL["speak"][1], 46); text(oid,label); fill(oid,"#FFFFFF",BORDER); txt(oid,13)

# arrows between columns
for oid,x in [("arrow1",192),("arrow2",462)]:
    box(oid, x, 152, 22, 34, "RIGHT_ARROW"); fill(oid, BRIGHT, "none", mid=False)

# safety interrupt note
box("safety", 216, 252, 480, 16, "TEXT_BOX")
text("safety","▲  safety warnings interrupt all other audio")
fill("safety","none","none",mid=False); txt("safety", 12, GOLD, True, "START")

# network panel (dashed = optional)
box("panel_net", X0, 284, XW, 62); fill("panel_net","none", GREY, "DASH", 1.5, mid=False)
box("lbl_net", 28, 289, 460, 13, "TEXT_BOX")
text("lbl_net","NETWORK  ·  optional — every path has an on-device fallback")
fill("lbl_net","none","none",mid=False); txt("lbl_net", 11, GREY, True, "START")

NET = ["Scene description\n1 frame, on request","Relocalisation\nKaaba as anchor",
       "SOS +\nlocation share","Companion\nbooking"]
for i,label in enumerate(NET):
    x = 24 + i*134; oid=f"netw{i}"
    box(oid, x, 306, 124, 34); text(oid,label); fill(oid,"#FFFFFF",BORDER); txt(oid,11)

box("arrow3", 556, 314, 18, 18, "RIGHT_ARROW"); fill("arrow3", TEAL, "none", mid=False)
box("portal", 580, 306, 116, 34); text("portal","FAMILY PORTAL")
fill("portal", TEAL, "none"); txt("portal", 13, "#FFFFFF", True)

reqs = [{"deleteObject":{"objectId":"i0"}},{"deleteObject":{"objectId":"i1"}}] + create
for name, batch in [("create", reqs), ("style", style)]:
    out = subprocess.run(["gws","slides","presentations","batchUpdate",
        "--params", json.dumps({"presentationId": PID}),
        "--json", json.dumps({"requests": batch})],
        capture_output=True, text=True)
    body = "\n".join(l for l in out.stdout.splitlines() if not l.startswith("Using keyring"))
    print(name, "->", "OK" if out.returncode==0 else "FAIL", len(batch), "requests")
    if out.returncode != 0: print(body[:1200], out.stderr[:800])
