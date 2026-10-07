from html import escape
from lxml import html
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import mm
from reportlab.platypus import BaseDocTemplate, PageTemplate, Frame, Paragraph, Spacer, PageBreak, Table, TableStyle, Flowable

SOURCE = "report/taskly_research_report.html"
OUTPUT = "report/taskly_research_report.pdf"
BLUE = colors.HexColor("#12345b")
MID = colors.HexColor("#45627f")
LINE = colors.HexColor("#cbd5e1")
styles = getSampleStyleSheet()
styles.add(ParagraphStyle(name="ReportTitle", parent=styles["Title"], fontName="Helvetica-Bold", fontSize=31, leading=36, textColor=BLUE, alignment=0, spaceAfter=12))
styles.add(ParagraphStyle(name="Subtitle", parent=styles["Normal"], fontSize=16, leading=22, textColor=MID, spaceAfter=20))
styles.add(ParagraphStyle(name="Kicker", parent=styles["Normal"], fontName="Helvetica-Bold", fontSize=10, leading=14, textColor=colors.HexColor("#3575a8"), spaceAfter=14))
styles.add(ParagraphStyle(name="H1Report", parent=styles["Heading1"], fontName="Helvetica-Bold", fontSize=18, leading=22, textColor=BLUE, spaceBefore=12, spaceAfter=7, keepWithNext=True))
styles.add(ParagraphStyle(name="H2Report", parent=styles["Heading2"], fontName="Helvetica-Bold", fontSize=12, leading=15, textColor=BLUE, spaceBefore=8, spaceAfter=4, keepWithNext=True))
styles.add(ParagraphStyle(name="BodyReport", parent=styles["BodyText"], fontName="Helvetica", fontSize=9.15, leading=12.2, textColor=colors.HexColor("#182230"), spaceAfter=6))
styles.add(ParagraphStyle(name="SmallReport", parent=styles["BodyText"], fontName="Helvetica", fontSize=7.6, leading=9.5, textColor=MID, spaceAfter=4))
styles.add(ParagraphStyle(name="CellReport", parent=styles["BodyText"], fontName="Helvetica", fontSize=7.5, leading=9, spaceAfter=0))
styles.add(ParagraphStyle(name="CellHeadReport", parent=styles["BodyText"], fontName="Helvetica-Bold", fontSize=7.7, leading=9.2, textColor=BLUE, spaceAfter=0))
styles.add(ParagraphStyle(name="CoverMeta", parent=styles["BodyText"], fontSize=10, leading=16, textColor=MID, spaceBefore=20))
styles.add(ParagraphStyle(name="CaptionReport", parent=styles["BodyText"], fontSize=7.5, leading=9, textColor=MID, spaceBefore=4, spaceAfter=9))

def node_text(node):
    return " ".join(" ".join(node.itertext()).split())

def paragraph(node, style="BodyReport"):
    chunks=[]
    if node.text: chunks.append(escape(node.text))
    for child in node:
        txt=escape(" ".join(" ".join(child.itertext()).split()))
        if child.tag in ("b","strong"): txt="<b>"+txt+"</b>"
        elif child.tag=="code": txt='<font name="Courier">'+txt+"</font>"
        elif child.tag in ("i","em"): txt="<i>"+txt+"</i>"
        chunks.append(txt)
        if child.tail: chunks.append(escape(child.tail))
    return Paragraph("".join(chunks).strip() or escape(node_text(node)), styles[style])

class Diagram(Flowable):
    def __init__(self, kind):
        super().__init__(); self.kind=kind; self.width=174*mm; self.height=60*mm
    def box(self,c,x,y,w,h,title,sub,fill,dash=False):
        c.setFillColor(colors.HexColor(fill)); c.setStrokeColor(colors.HexColor("#6b879e")); c.setLineWidth(.8)
        if dash: c.setDash(3,2)
        c.roundRect(x*mm,y*mm,w*mm,h*mm,2.3*mm,fill=1,stroke=1); c.setDash()
        c.setFillColor(BLUE); c.setFont("Helvetica-Bold",7.6); c.drawCentredString((x+w/2)*mm,(y+h-7)*mm,title)
        c.setFillColor(MID); c.setFont("Helvetica",6.6); c.drawCentredString((x+w/2)*mm,(y+4)*mm,sub)
    def arrow(self,c,x1,y1,x2,y2):
        import math
        c.setStrokeColor(colors.HexColor("#55728f")); c.setFillColor(colors.HexColor("#55728f")); c.setLineWidth(1.2); c.line(x1*mm,y1*mm,x2*mm,y2*mm)
        ang=math.atan2(y2-y1,x2-x1); size=2.0; p=c.beginPath(); p.moveTo(x2*mm,y2*mm)
        p.lineTo((x2-size*math.cos(ang-.45))*mm,(y2-size*math.sin(ang-.45))*mm); p.lineTo((x2-size*math.cos(ang+.45))*mm,(y2-size*math.sin(ang+.45))*mm); p.close(); c.drawPath(p,fill=1,stroke=0)
    def label(self,c,x,y,text,size=7,color=MID):
        c.setFillColor(color); c.setFont("Helvetica",size); c.drawString(x*mm,y*mm,text)
    def draw(self):
        c=self.canv; c.saveState()
        if self.kind==0:
            boxes=[(5,34,37,19,"Flutter UI","screens + widgets","#e8f2fa"),(49,34,36,19,"Riverpod","providers + state","#eef5e9"),(92,34,36,19,"Repositories","feature operations","#fff3df"),(135,34,36,19,"Shared store","cache + Firestore","#f4eafa")]
            for b in boxes:self.box(c,*b)
            for x in (42,85,128):self.arrow(c,x,43,x+6,43)
            self.box(c,103,7,60,16,"Firebase services","Firestore · Core · FCM","#e9f5f5");self.arrow(c,153,33,148,24)
            self.box(c,5,7,65,16,"Supabase target","Postgres · RLS · RPC · Deno","#f4f4f5",True);c.setDash(3,2);c.setStrokeColor(colors.grey);c.line(70,15,89,30);c.setDash();self.label(c,72,19,"not wired to current repos",6,colors.grey)
        elif self.kind==1:
            boxes=[(5,27,37,18,"User action","screen / form","#e8f2fa"),(48,27,37,18,"Riverpod","notifier","#eef5e9"),(91,27,37,18,"Repository","operation","#fff3df"),(134,27,37,18,"Store + DB","cache / write","#f4eafa")]
            for b in boxes:self.box(c,*b)
            for x in (42,85,128):self.arrow(c,x,36,x+6,36)
            c.setStrokeColor(colors.HexColor("#438c8b"));c.setLineWidth(1.3);c.line(153*mm,26*mm,153*mm,10*mm);c.line(153*mm,10*mm,66*mm,10*mm);c.line(66*mm,10*mm,66*mm,25*mm);self.arrow(c,66,10,66,25);self.label(c,82,12,"snapshot → cache → provider refresh → UI",6.6,colors.HexColor("#286565"))
        else:
            self.box(c,4,26,32,19,"Mobile","not wired","#e8f2fa");self.box(c,48,26,35,19,"Supabase API","Auth + REST","#e8f2fa");self.box(c,96,26,35,19,"PostgreSQL","tables + RLS","#eef5e9");self.box(c,144,44,28,15,"send-push","Deno → FCM","#fff3df");self.box(c,144,7,28,15,"due-reminders","cron → RPC","#fff3df");self.arrow(c,36,35,47,35);self.arrow(c,83,35,95,35);self.arrow(c,131,39,143,48);self.arrow(c,131,31,143,15);self.label(c,52,13,"target client flow only",6,colors.grey)
        c.restoreState()

class ReportDoc(BaseDocTemplate):
    def __init__(self,path):
        super().__init__(path,pagesize=A4,rightMargin=16*mm,leftMargin=16*mm,topMargin=16*mm,bottomMargin=17*mm,title="Taskly Research Report",author="Taskly project review")
        frame=Frame(self.leftMargin,self.bottomMargin,self.width,self.height,id="normal");self.addPageTemplates(PageTemplate(id="main",frames=frame,onPage=self.footer))
    def footer(self,canvas,doc):
        if doc.page>1:
            canvas.saveState();canvas.setStrokeColor(LINE);canvas.line(16*mm,12*mm,194*mm,12*mm);canvas.setFont("Helvetica",7);canvas.setFillColor(MID);canvas.drawString(16*mm,8*mm,"Taskly Research Report · Static implementation review");canvas.drawRightString(194*mm,8*mm,str(doc.page));canvas.restoreState()

tree=html.parse(SOURCE);body=tree.find(".//body");story=[];cover=body.find("section")
for el in cover:
    cl=el.get("class","")
    if cl=="kicker":story.append(paragraph(el,"Kicker"))
    elif el.tag=="h1":story.append(paragraph(el,"ReportTitle"))
    elif cl=="subtitle":story.append(paragraph(el,"Subtitle"))
    elif cl=="meta":story.append(paragraph(el,"CoverMeta"))
    elif el.tag=="p":story.extend([Spacer(1,22*mm),paragraph(el,"SmallReport")])
story.append(PageBreak()); diagram_idx=0
for el in body:
    if el is cover:continue
    tag=el.tag;cl=el.get("class","")
    if tag=="h2":story.append(paragraph(el,"H1Report"))
    elif tag=="h3":story.append(paragraph(el,"H2Report"))
    elif tag=="p":story.append(paragraph(el))
    elif tag=="div" and cl=="abstract":
        for p in el.findall("p"):story.append(paragraph(p))
    elif tag=="div" and cl=="figure":
        story.append(Diagram(diagram_idx));diagram_idx+=1;cap=el.find("div")
        if cap is not None:story.append(paragraph(cap,"CaptionReport"))
    elif tag=="table":
        data=[]
        for row in el.findall(".//tr"):
            data.append([Paragraph(escape(node_text(cell)),styles["CellHeadReport" if cell.tag=="th" else "CellReport"]) for cell in row])
        if data:
            n=max(map(len,data));widths=[178*mm/n]*n
            if n==2:widths=[42*mm,136*mm]
            elif n==3:widths=[33*mm,58*mm,87*mm]
            elif n==4:widths=[28*mm,45*mm,47*mm,58*mm]
            tab=Table(data,colWidths=widths,repeatRows=1,hAlign="LEFT");tab.setStyle(TableStyle([("BACKGROUND",(0,0),(-1,0),colors.HexColor("#eaf1f8")),("GRID",(0,0),(-1,-1),.45,LINE),("VALIGN",(0,0),(-1,-1),"TOP"),("LEFTPADDING",(0,0),(-1,-1),4),("RIGHTPADDING",(0,0),(-1,-1),4),("TOPPADDING",(0,0),(-1,-1),4),("BOTTOMPADDING",(0,0),(-1,-1),4)]));story.extend([tab,Spacer(1,5)])
    elif tag in ("ol","ul"):
        for i,li in enumerate(el.findall("li"),1):story.append(Paragraph(escape((str(i)+".") if tag=="ol" else "•")+" "+escape(node_text(li)),styles["BodyReport"]))
    elif tag=="div" and cl=="callout":
        style=ParagraphStyle("Callout",parent=styles["BodyReport"],backColor=colors.HexColor("#fff8e8"),borderColor=colors.HexColor("#d79621"),borderWidth=2,borderPadding=7,spaceBefore=4,spaceAfter=8);story.append(Paragraph(escape(node_text(el)),style))
    elif tag=="div" and cl=="end":story.extend([Spacer(1,10),paragraph(el,"SmallReport")])
ReportDoc(OUTPUT).build(story)
print(OUTPUT)
