unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, ExtCtrls, Buttons, math, Clipbrd, Gauges;

type
  TCharInfo = record
    width:integer;
    okwidth:Integer;
    okheight:integer;
    bytesperline:Integer;
    charvalue:Word;
    c:string;
    charname:string;
    c_string:string;
  end;

  TCharInfoArray = array of TCharInfo;

  TForm1 = class(TForm)
    Memo1: TMemo;
    Label1: TLabel;
    Button1: TButton;
    Memo2: TMemo;
    Button2: TButton;
    Label2: TLabel;
    Label3: TLabel;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    Label4: TLabel;
    Button3: TButton;
    Image1: TImage;
    BitBtn1: TBitBtn;
    FontDialog1: TFontDialog;
    CheckBox1: TCheckBox;
    Button4: TButton;
    CheckBox2: TCheckBox;
    Splitter1: TSplitter;
    Panel1: TPanel;
    Panel2: TPanel;
    Label5: TLabel;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Timer1: TTimer;
    StatusPanel: TPanel;
    Gauge1: TGauge;
    StatusLabel: TLabel;
    GroupBox1: TGroupBox;
    Button8: TButton;
    Panel3: TPanel;
    Left_Top_Panel: TPanel;
    Edit1: TEdit;
    Edit2: TEdit;
    Label6: TLabel;
    Panel4: TPanel;
    left_bottom_txt: TLabel;
    Edit3: TEdit;
    Label7: TLabel;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure Edit3Change(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure SpinEdit2Change(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    fontname:string;
    progress:Integer;
    step:integer;
    procedure SwapCInfo(var c1,c2:TCharInfo);
    procedure SortCharInfo(var cArr:TCharInfoArray);
    procedure StrToImg(s:string;w,h:integer; var cInfo:TCharInfo);
  end;

var
  offsetx:integer;
  offsety:integer;
  Form1: TForm1;
  tempImg:TBitmap;
  const PROGRAMNAME='ucGUI字体生成器v8.0 ';



  function ClearSame(str:string):string;
  procedure translate();

implementation


{$R *.dfm}

procedure TForm1.Button2Click(Sender: TObject);
var s:string;
begin
  s:=ClearSame(memo1.Text);
  Memo1.Clear;
  Memo1.Text:=s;
end;


function ClearSame(str:string):string;
var i,j,k,len, len2:integer;
  teshu:Word;
  c:byte;
  hanzi:word;
  temphz:word;
  msg:string;
begin
  result:=str;
  len:=Length(str);
  teshu:=$FFFD;
  i:=1;
  while (i<=len) do
  begin
    c:=Byte(Result[i]);

    if c>127 then
    begin
      //比较汉字
      len2:=len;
      j:=1;
      hanzi:=c shl 8;
      c:=Byte(Result[i+1]);
      hanzi:=hanzi+c;
      //msg:=Format('现在查找的是:%x',[hanzi]);
      //ShowMessage(msg);
      while j<len2 do
      begin

          c:=byte(Result[j]);

          //只比汉字
          if c<128 then begin Inc(j); Continue; end;

          //如果是汉字
          temphz:=c shl 8;
          c:=Byte(Result[j+1]);
          temphz:=temphz+c;

          //跳过自己
          if (j=i) then
          begin
            j:=j+2;
            continue;
          end;

          //发现重复的了, 就从副本中删掉，再下次又从头开始
          if (temphz=hanzi) then
          begin
            Delete(Result,j,2);
            len2:=Length(Result);
            j:=1;
            Continue;
          end;

          j:=j+2;
      end;

      i:=i+2;
      Continue;
    end;  //end > 127

    //否则比较英文
    len2:=len;
    j:=1;
    while j<=len2 do
    begin
      if j<>i then
      begin
        if c=Byte(result[j]) then
        begin
          Delete(Result,j,1);
          len2:=Length(Result);
          j:=1;
          Continue;
        end;
      end;
      Inc(j);
    end;

    Inc(i);
    len:=Length(Result);
  end;
end;

function getFontStyle(fs:TFontStyles):string;
begin
  if (fs=[]) then begin result:='常规'; exit; end;

  result := '';
  if (fsBold in fs) then
    result := result+'粗体';
  if (fsItalic in fs) then
    result := result+'斜体';

end;

procedure TForm1.Button1Click(Sender: TObject);
var s:string;
  threadid:Cardinal;
begin
  if (Memo1.Text='') and (CheckBox2.checked=false) then exit;

  try
    offsetx := strtoint(edit1.Text);
  except
    offsetx := 0;
  end;

  try
    offsety := strtoint(edit2.Text);
  except
    offsety := 0;
  end;

  Memo2.Clear;
  memo2.Lines.Add('/*');
  memo2.Lines.Add('**********************************************************************');
  memo2.Lines.Add('*                        UcGUI Font');
  memo2.Lines.Add('*                   Chinese GB2312 library');
  memo2.Lines.Add('*           (c) Copyright 19xx-20xx, company name');
  memo2.Lines.Add('*');
  //memo2.Lines.Add('*   作者: ______      email:xxxxxxxxx');
  memo2.Lines.Add('*  ');
  memo2.Lines.Add('* 注：本字体文件由 '+PROGRAMNAME+' 生成，作者:馋嘴猫(qq:602426967)');
  memo2.Lines.Add(Format('* 字体:%s,字形:%s,大小:%d,宽:%d,高:%d,水平偏移:%d,垂直偏移:%d',
    [Memo1.Font.Name,getFontStyle(Memo1.Font.Style),Memo1.Font.Size,SpinEdit1.Value,SpinEdit2.Value,offsetx,offsety]));
  memo2.Lines.Add('*');
  memo2.Lines.Add('**********************************************************************');
  memo2.Lines.Add('*/');
  memo2.Lines.Add('');

  fontname:=Format('GUI_FontHZ%dx%d',[SpinEdit1.Value, SpinEdit2.Value]);
  Memo2.Lines.Add('#include "GUI.H"');
  //Memo2.Lines.Add('#ifndef GUI_FLASH');
  //Memo2.Lines.Add('#  define GUI_FLASH');
  //Memo2.Lines.Add('#endif');
  //Memo2.Lines.Add('extern GUI_FLASH const GUI_FONT '+fontname+';');
  Memo2.Lines.Add(' ');
  Memo2.Lines.Add(' ');

  Form1.step:=1;
  Form1.Timer1.Enabled:=true;
  form1.StatusPanel.Visible:=true;

  translate;

  {
  CreateThread(0,
               0,
               @translate,
               0,
               0,
               threadid);
               }
  //WaitForSingleObject(threadid,1000*500);

end;

procedure translate;
var w,h:integer;
  i,j,k,len:integer;
  hanzi:Word;
  c:byte;
  s:string;
  outStr:string;
  cInfo:array of TCharInfo;
  startc, endc:integer;
  temps:string;
  tempslist:TStringList;
begin
  w:=Form1.SpinEdit1.Value;
  h:=Form1.SpinEdit2.Value;

  temps:='';
  if (Form1.CheckBox2.Checked) then
  begin
//form1.Caption:=inttostr(i);
    for i:=$20 to 127 do
      temps:=temps+format('%s',[ Char(i) ]);

    s:=temps+Form1.memo1.Text;
  end
  else
    s:=Form1.memo1.Text;

  len:=Length(s);
  SetLength(cInfo,len);

  for i:=0 to len-1 do
    cInfo[i].width:=0;

  form1.step:=1;

  j:=0;
  i:=1;
  while (i<=len) do
  begin
    outStr:='';
    c:=Byte(s[i]);

    if c<128 then //英文
    begin
      outStr:=Char(c);
      //Memo2.Lines.Add(outStr);
      Form1.StrToImg(outStr,w,h,cInfo[j]);
      Inc(j);
    end else
    begin   //中文
      outStr:=Char(c)+s[i+1];
      //Memo2.Lines.Add(outStr);
      Form1.StrToImg(outStr,w,h,cInfo[j]);
      //cInfo[j].okwidth := w;   //中文下强制为w
      Inc(j);
      Inc(i);
    end;
    Inc(i);
    Form1.progress:=100*i div len;
    Application.ProcessMessages;
  end;

  //正在优化排序
  if Form1.CheckBox1.Checked then
  begin
    Form1.step:=2;
    Form1.SortCharInfo(TCharInfoArray(cInfo));
  end;

  Form1.Memo2.Visible:=False;

  //把空的去掉.
  j:=0;
  for i:=0 to len-1 do
  begin
    if cInfo[i].width=0 then Continue;
    cInfo[j] := cInfo[i];
    Inc(j);
    Application.ProcessMessages;
  end;
  form1.progress:=100;

  //所有字符显示
  Form1.step:=3;
  len:=j;
  for i:=0 to len-1 do
  begin
    if (cInfo[i].width=0) then Continue;
    Form1.Memo2.Lines.Add(Format('/* char: %s   code:0x%0.4x */',
      [cInfo[i].c,cInfo[i].charvalue]));
    Form1.Memo2.Lines.Add(Format('static GUI_CONST_STORAGE unsigned char %s[%d] = { ',
      [
       cInfo[i].charname,
       h * cInfo[i].bytesperline
       //h*((cInfo[i].okwidth+7) div 8)
      ]));
    Form1.memo2.lines.Add(cInfo[i].c_string+'};');
    Form1.Memo2.lines.Add('');
    form1.progress:=100*i div len;
    Application.ProcessMessages;
  end;

  //所有字符加入数组
  Form1.step:=4;
  Form1.Memo2.lines.Add(Format('static GUI_CONST_STORAGE GUI_CHARINFO Cinfo[%d] = {',
    [j]));
  for i:=0 to len-1 do
  begin
    if cInfo[i].width=0 then Continue;
    Form1.Memo2.Lines.Add(Format('  { %d, %d, %d, (unsigned char *)&%s }, /*%d: %s*/',
      [cInfo[i].okwidth,
       cInfo[i].okwidth,
      //h, //cInfo[i].okheight,
      cInfo[i].bytesperline, cInfo[i].charname,i,cInfo[i].c]));
    Form1.progress:=100*i div len;
    Application.ProcessMessages;
  end;
  Form1.Memo2.Lines.Add('};');
  Form1.Memo2.lines.Add('');

  //生成字体索引表
  //先保存到临时变量,再反序加入到 Memo2
  i:=0;
  j:=0;
  Form1.step:=5;
  tempslist:=TStringList.Create;
  while i<len do
  begin
    Application.ProcessMessages;
    startc:=i;
    endc:=i;

    k:=i+1;
    while k<len do
    begin
      if cInfo[k].charvalue=cInfo[i].charvalue+1 then
      begin
        inc(endc);
        Inc(i);
      end else
        Break;
      Inc(k);
    end;

    temps:='';

    temps:=Format('static GUI_CONST_STORAGE GUI_FONT_PROP Prop%d = {'#13#10,
      [j+1]);
    temps:=temps+Format('  0x%0.4x, /*start :%s*/'#13#10,
      [cInfo[startc].charvalue, cInfo[startc].c ]);
    temps:=temps+Format('  0x%0.4x, /*end   :%s,  len=%d*/'#13#10,
      [cInfo[endc].charvalue, cInfo[endc].c, endc-startc+1]);
    temps:=temps+Format('  &Cinfo[ %d ],'#13#10,
      [startc]);   //GUI_FontHZ_12x12_CharInfo的名字

    if (endc=len-1) then
      temps:=temps+'  (void*)0'#13#10
    else
      temps:=temps+Format('  &Prop%d'#13#10, [j+2]);

    temps:=temps+'};'#13#10#13#10;

    tempslist.Add(temps);

    Inc(j);
    i:=endc+1;
  end;

  Form1.step:=5;
  for i:=tempslist.Count-1 downto 0 do
  begin
    Form1.Memo2.Lines.Add(tempslist.Strings[i]);
    Form1.progress:=100 - (100*i div tempslist.count);
    Application.ProcessMessages;
  end;

  //最后生成 字体描述
  //  GUI_FontHZ12x12
  Form1.Memo2.Lines.Add(Format('GUI_CONST_STORAGE GUI_FONT %s = {',
    [Form1.fontname]));
  Form1.Memo2.Lines.Add('  GUI_FONTTYPE_PROP_SJIS,');
  Form1.Memo2.Lines.Add(Format('  %d, /* height of font  */',[h]));
  Form1.Memo2.Lines.Add(Format('  %d, /* space of font y */',[h]));
  Form1.Memo2.Lines.Add(Format('  %d,',[1]));
  Form1.Memo2.Lines.Add(Format('  %d,',[1]));
  Form1.Memo2.Lines.Add(Format('  &Prop1',[w,h]));
  Form1.Memo2.Lines.Add('};');
  Form1.Memo2.lines.Add('');

  SetLength(cInfo,0);
  tempslist.Free;
  //Memo2.Text:=outStr;
  Form1.Memo2.Visible:=true;
  Form1.step:=6;
end;

procedure TForm1.StrToImg(s: string;w,h:integer; var cInfo:TCharInfo);
var 
  rc:TRect;
  align,i,j,pix,len8:integer;
  temps:string;
  sline:string;
  hanzi:Word;
  c:byte;
  okchrlen:Integer;
  charname:string;
  cvs:TCanvas;
begin
  //ShowMessage(s);
  //ShowMessage('aaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  if (s='') then exit;

  cvs:=TCanvas.create;
  cvs.Handle:=GetDC(0);
  cvs.Font.Name:=FontDialog1.Font.Name;
  cvs.Font.Size:=FontDialog1.Font.Size;
  cvs.Font.Height:=FontDialog1.Font.Height;
  cvs.Font.Style:=FontDialog1.Font.Style;
  i:=cvs.TextWidth(s);
  cvs.Free;

  cInfo.okwidth:=0;
  cInfo.okheight:=0;

  //i:=tempImg.Canvas.TextWidth(s);//Form1.Canvas.TextWidth(s); //
  if i<8 then i:=8;
  if i<w then
    tempImg.Width:=i
  else
    tempImg.Width:=w;

  tempImg.Height:=h;
  SetRect(rc,0,0,w,h);
  tempImg.Canvas.Brush.Color:=clWhite;
  tempImg.Canvas.FillRect(rc);
  align:=DT_SINGLELINE or DT_LEFT or DT_TOP;

  rc.left := rc.left + offsetx;
  //rc.Right := rc.right + offsetx;
  rc.Top := rc.top + offsety;
  //rc.Bottom := rc.bottom + offsety;


  //align:=DT_VCENTER or DT_SINGLELINE or DT_CENTER;


  tempImg.Canvas.Font.Name:=FontDialog1.Font.Name;
  tempImg.Canvas.Font.Size:=FontDialog1.Font.Size;
  tempImg.Canvas.Font.Height:=FontDialog1.Font.Height;
  tempImg.Canvas.Font.Style:=FontDialog1.Font.Style;
  tempImg.Canvas.Font.Color:=clBlack;

  if (s='&') then
    DrawText(tempImg.Canvas.Handle, PChar('&&'), -1, rc, align)
  else
    DrawText(tempImg.Canvas.Handle, PChar(s), -1, rc, align);
  Sleep(10);
  c:=Byte(s[1]);
  if (c<128) then
  begin
    cInfo.charvalue:=c;
    cInfo.charname:=Format('ac%0.4x',[c]);
  end else
  begin
    hanzi:=(Byte(s[1]) shl 8) + Byte(s[2]);
    cInfo.charvalue:=hanzi;
    cInfo.charname:=Format('ac%0.4x',[hanzi]);
  end;
  cInfo.bytesperline := (tempImg.Width+7) div 8;
  cInfo.c_string:='';
  cInfo.c:=s;
  cInfo.width:=w;

  for i:=0 to h-1 do
  begin
    temps:='  ';
    sline:='';
    for j:=0 to tempImg.Width-1 do
    begin
      pix:=tempImg.Canvas.Pixels[j,i];
      if (pix<>0) then
      begin
        temps:=temps+'_';
      end
      else
      begin
        temps:=temps+'X';
        cInfo.okwidth:=Max(j+1, cInfo.okwidth);  //有效长度 - 英文使用.中文固定为w
        cInfo.okheight:=Max(i+1, cInfo.okheight);
      end;

      if (j+1) mod 8 = 0 then
      begin
        sline:=sline+temps+',';
        temps:='';
      end;
    end;
    len8 := Length(temps);
    if (len8>0) then
    begin
      while (len8<8) do
      begin
        temps:=temps+'_';
        inc(len8);
      end;
      sline:=sline+temps;
      if i<>h-1 then sline:=sline+',';
    end;
    cInfo.c_string:=cInfo.c_string+sline+#13+#10;
  end;

  //if (c=$20 .... /w/2

  Image1.Picture.Bitmap.Assign(tempImg);
  Image1.Refresh;
  //tempImg.Free;
end;

procedure TForm1.Button3Click(Sender: TObject);
var i,j,k,len, len2:integer;
  teshu:Word;
  c:byte;
  hanzi:word;
  temphz:word;
  msg:string;
  str:string;
begin
  str:=Memo1.text;
  len:=Length(str);
  teshu:=$FFFD;
  i:=1;
  while (i<=len) do
  begin
    c:=Byte(str[i]);

    if c>127 then
    begin
      i:=i+2;
      Continue;
    end;

    //否则比较英文
    Delete(str,i,1);

    //从头开始，i=1, len重新算
    i:=1;
    len:=Length(str);
  end;
  memo1.Text:=str;
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
  if FontDialog1.Execute then
    Memo1.Font:=FontDialog1.Font;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Clipboard.Clear;

  Clipboard.SetTextBuf(PChar(Memo2.Text));
//  Memo2.CopyToClipboard;
end;

procedure TForm1.SortCharInfo(var cArr: TCharInfoArray);
var i,j:Integer;
  len:integer;
begin
  len:=Length(cArr);
  for i:=0 to len-1 do
  begin
    for j:=len-1 downto i+1 do
    begin
      if cArr[j].charvalue<cArr[i].charvalue then
        SwapCInfo(cArr[j], cArr[i]);
    end;
    Form1.progress:=100*i div len;
  end;
end;

procedure TForm1.SwapCInfo(var c1, c2: TCharInfo);
var tempInfo:TCharInfo;
begin
  tempInfo:=c2;
  c2:=c1;
  c1:=tempInfo;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Memo1.Font.Charset:=GB2312_CHARSET;
  Caption:=PROGRAMNAME;
  Application.Title:=self.Caption;

  tempImg:=TBitmap.Create;
  tempImg.PixelFormat:=pf1bit;
end;

procedure TForm1.Button5Click(Sender: TObject);
var s:string;
  i, j:integer;
begin
  Memo1.Clear;
  s:='';

  for i:=$b0 to $f7 do
  begin
    for j:=$a1 to $fe do
    begin
      s:=s+char(i);
      s:=s+char(j);
    end;
  end;

  Memo1.Text:=s;
end;

procedure TForm1.Button6Click(Sender: TObject);
var s:string;
  i, j:integer;
begin
  Memo1.Clear;
  s:='';

  for i:=$b0 to $d7 do
  begin
    for j:=$a1 to $fe do
    begin
      if (i=$d7) and (j>$f9) then Break;
      s:=s+char(i);
      s:=s+char(j);
    end;
  end;

  Memo1.Text:=s;
end;

procedure TForm1.Button7Click(Sender: TObject);
var s:string;
begin
  ShowMessage('步骤1:  拷贝或输入一段汉字放在左边的文本框内.'+#13+#13+
              '步骤2:  按 开始转换 按钮得到转换后的 c 语言文件.'+#13+#13+
              '步骤3:  按 拷贝到剪贴板 拷贝后供其他程序使用.'+#13+#13+
              ''+#13+#13+
              '(注意:如果英文小写有些显示不全的, 比如: _,g,y,{} 等,'+#13+
              '      那么,请将文字垂直位置对齐改为靠下对齐试试；'+#13+
              '      如果显示范围不够，调整大小多试几次。'
  );
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if (progress>=100) then
  begin
    StatusPanel.Visible:=false;
    Timer1.Enabled:=false;
  end else
  begin
    case step of
    0:begin  end;
    1:begin StatusLabel.Caption:='正在提取字符像素...'; end;
    2:begin StatusLabel.Caption:='正在优化字符表...'; end;
    3:begin StatusLabel.Caption:='正在生成单个字符结构体...'; end;
    4:begin StatusLabel.Caption:='正在总字符结构体...'; end;
    5:begin StatusLabel.Caption:='正在生成索引表...'; end;
    6:begin StatusPanel.Visible:=false; end;
    end;
    gauge1.Progress:=form1.progress;
    gauge1.Refresh;
  end;
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
  Memo1.Text:='';
end;

procedure TForm1.Memo1Change(Sender: TObject);
var t:string;
begin
  t :=  Memo1.Text;
  left_bottom_txt.caption := '长度:'+IntToStr(Length(t))+'字节';
end;

procedure TForm1.Edit3Change(Sender: TObject);
var w,h:integer;
  s:string;
  cInfo:TCharInfo;
begin
  //预览
  s :=  edit3.Text;
  try
    w:=Form1.SpinEdit1.Value;
  except
    w:=12;
  end;

  try
    h:=Form1.SpinEdit2.Value;
  except
    h:=12;
  end;

  try
    offsetx := strtoint(edit1.Text);
  except
    offsetx := 0;
  end;

  try
    offsety := strtoint(edit2.Text);
  except
    offsety := 0;
  end;

  StrToImg(s,w,h,cInfo);
end;

//去除中文的标点
procedure TForm1.Button9Click(Sender: TObject);
var i,j,k,len, len2:integer;
  teshu:Word;
  c:byte;
  hanzi:word;
  temphz:word;
  msg:string;
  str:string;
begin
  str:=Memo1.text;
  len:=Length(str);
  teshu:=$FFFD;
  i:=1;
  while (i<=len) do
  begin
    c:=Byte(str[i]);

    if c<=127 then
    begin
      i:=i+1;
      Continue;
    end;

    //中文标点在第1取到15区
    if (c-$a0<15) then
    begin
       //否则比较英文
      Delete(str,i,2);

      //从头开始，i=1, len重新算
      i:=1;
      len:=Length(str);

      continue;
    end;

    //其他情况:不是中文标点
    i:=i+2;

  end;
  memo1.Text:=str;
end;

procedure TForm1.Edit1Change(Sender: TObject);
begin
  Edit3Change(Sender);
end;

procedure TForm1.Edit2Change(Sender: TObject);
begin
  Edit3Change(Sender);
end;

procedure TForm1.SpinEdit1Change(Sender: TObject);
begin
  Edit3Change(Sender);
end;

procedure TForm1.SpinEdit2Change(Sender: TObject);
begin
  Edit3Change(Sender);
end;

function MAKELANGID(p,s:integer):WORD;
begin
  result:= (s shl 10) or p;
end;

function MAKELCID(srtid,lgid:integer):WORD;
begin
  result:= (srtid shl 16) or lgid;
end;

//简体 -> 繁体
procedure TForm1.Button10Click(Sender: TObject);
  var buf:pchar;
      l      : integer;
      wLangID: WORD;
      Locale : LCID;
      iRet   : integer;
      s      : string;
begin
  if (Memo1.Text='') then exit;

  if (IDOK = MessageBox(0,'简体  --> 繁体后，内码仍是 GBK, 只是显示的字体变成繁体！','请注意', MB_OKCANCEL + MB_ICONINFORMATION) ) then
  begin
    wLangID := MAKELANGID(LANG_CHINESE, SUBLANG_CHINESE_SIMPLIFIED);
    Locale := MAKELCID(wLangID, SORT_CHINESE_PRCP);
    l := Length(Memo1.Text);
    l := l*2+8;
    GetMem(buf,l);
    ZeroMemory(buf, l);
    iRet := LCMapString(Locale,LCMAP_TRADITIONAL_CHINESE, PChar(Memo1.Text), -1, buf, l*2);
    Memo1.Text := buf;
    FreeMem(buf);
  end;
end;

//繁体 -> 简体
procedure TForm1.Button11Click(Sender: TObject);
  var buf:pchar;
      l      : integer;
      wLangID: WORD;
      Locale : LCID;
      iRet   : integer;
      s      : string;
begin
  if (Memo1.Text='') then exit;

  if (IDOK = MessageBox(0,'繁 --> 简后，内码仍是 GBK, 只是显示的字体变成简体！','请注意', MB_OKCANCEL + MB_ICONINFORMATION) ) then
  begin
    wLangID := MAKELANGID(LANG_CHINESE, SUBLANG_CHINESE_SIMPLIFIED);
    Locale := MAKELCID(wLangID, SORT_CHINESE_PRCP);
    l := Length(Memo1.Text);
    l := l*2+8;
    GetMem(buf,l);
    ZeroMemory(buf, l);
    iRet := LCMapString(Locale,LCMAP_SIMPLIFIED_CHINESE, PChar(Memo1.Text), -1, buf, l*2);
    Memo1.Text := buf;
    FreeMem(buf);
  end;
end;

end.
