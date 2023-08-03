//https://www.wyeditor.com   /[\r\n]/ 回车返行

//Ext.example.msg('', G("PubBillNoFind"), '');
var mynull = undefined;
var FClientUniqueCode = Math.floor(Math.random()*500+1);
var myWaintHandle;
var IsBillCall = true;
var AllCall_AddKey = "", AllClose_AddKey = "",  CodeBar_WZ_CODE = ""; //2016-01-22 add
function sleep(numberMillis) {
   var now = new Date();
   var exitTime = now.getTime() + numberMillis;
   while (true) {
       now = new Date();
       if (now.getTime() > exitTime)    return;
    }
}

//////////////////////////////////////////////////////////////////
function wrapText(context, text, x, y, maxWidth, lineHeight) {
  var lines = text.split("\n");

  for (var i = 0; i < lines.length; i++) {

  var words = lines[i].split(' ');
  var line = '';

  for (var n = 0; n < words.length; n++) {
   var testLine = line + words[n] + ' ';
   var metrics = context.measureText(testLine);
   var testWidth = metrics.width;
   if (testWidth > maxWidth && n > 0) {
    context.fillText(line, x, y);
    line = words[n] + ' ';
    y += lineHeight;
   }
   else {
    line = testLine;
   }
  }

  context.fillText(line, x, y);
  y += lineHeight;
 }
}
//////////////////////////////////////////////////////////////////

String.prototype.Trim = function()
{
return this.replace(/(^\s*)|(\s*$)/g, "");
}

String.prototype.LTrim = function()
{
return this.replace(/(^\s*)/g, "");
}

String.prototype.RTrim = function()
{
return this.replace(/(\s*$)/g, "");
}

function GetDeliPri(Text, Delimite, All)
{
  var rr;
  //2014-05-12 mod
  //if (All == true)
  if ((All == mynull) || (All == true))
    rr = Text
  else
    rr = '';
  //if Pos(Delimite, Text) > 0 then
  var index = Text.indexOf(Delimite);
  if(index > -1)                        //111@dd
    rr = Text.substring(0, index);
  return rr;
}

function length(Text){
  if(StrValueIsNull(Text)) {return 0}
  return Text.length;
}
function Length(Text){
  return length(Text);
}
function GetDeliBack(Text, Delimite, All)
{
  var rr;
  //2014-05-12 mod if (All == true) //2013-08-21 add
  if ((All == true) || (All == mynull))
    rr = Text
  else
    rr = '';
  var index = Text.indexOf(Delimite);
  if(index > -1)
    //Result = Copy(Text, Index + Length(Delimite), MaxInt);
    rr = Text.substring(index + Delimite.length, Text.length);
  return rr;
}

function Copy(Text, start, len)
{ //注意默认的自符串以1开始的
  if (Text == mynull)
    return ""
  else
    return Text.substring(start-1, len);
}


function FormatDate(now) //取当前日期, 格式如 2014-01-01
{
  y=now.getFullYear();
  m=now.getMonth()+1;
  d=now.getDate();
  m=m<10?"0"+m:m;
  d=d<10?"0"+d:d;
  return y+"-"+m+"-"+d;
}

function IncDate(InDate, addCount)
{
 var a = InDate;
 a = a.valueOf();
 a = a + addCount * 24 * 60 * 60 * 1000;
 a = new Date(a);
 return a;
}

function getdate() //取当前日期, 格式如 2014-01-01
{
  return FormatDate(new Date());
}

function getdatetime() //取当前日期, 格式如 2014-01-01
{
  var now = new Date();
  return now.format("yyyy-MM-dd hh:nn:ss");
}
function UpperCase(value)
{
  if (value == mynull)
    return value = ""
  else
    return value.toUpperCase();
}
function uppercase(value)
{
  return UpperCase(value)
}
function LowerCase(value)
{
  if (value == mynull)
    return value = ""
  else
    return value.toLowerCase();
}
function lowercase(value)
{
  return LowerCase(value)
}
function trim(value)
{
  if (value == mynull)
    return value = ""
  else
    return value.Trim();
}

function Trim(value)
{
  return trim(value);
}

//function PubGo(tag, name)
//{
  //return $("input[name='" + name + "']");
//  return $(tag + "[name='" + name + "']");
//}

//function alert(value)
//{
//  Ext.Msg.alert('提示信息', value);
//}
//function PubVisible(name, value)
//{ /
//  $(tag + "[name='" + name + "']").setVisible(true);
//}
//function PubSv(name, value)
//{
//  $(tag + "[name='" + name + "']").setValue(value);
//}

//function PubSd(name, value)
//{
//  $(tag + "[name='" + name + "']").setDisabled(value);
//}

//function PubSr(name, value)
//{
//  $(tag + "[name='" + name + "']").setReadOnly(value);
//}

//function PubGv(name)
//{
//  return $(tag + "[name='" + name + "']").value;
//}

function gb2utf8(data)
{

return data;

var glbEncode = [];
gb2utf8_data = data;
execScript("gb2utf8_data = MidB(gb2utf8_data,1)", "VBScript");
var t=escape(gb2utf8_data).replace(/%u/g,"").replace(/(.{2})(.{2})/g,"%$2%$1").replace(/%([A-Z].)%(.{2})/g,"@$1$2");
t=t.split("@");
var i=0,j=t.length,k;
while(++i<j) {  k=t[i].substring(0,4);
if(!glbEncode[k]) {   gb2utf8_char = eval("0x"+k);
execScript("gb2utf8_char = Chr(gb2utf8_char)", "VBScript");
glbEncode[k]=escape(gb2utf8_char).substring(1,6);
}  t[i]=glbEncode[k]+t[i].substring(4);
}
gb2utf8_data = gb2utf8_char = null;

var x = unescape(t.join("%"));

  return x;
}

function GetData(Value)
{
  var index = Value.indexOf("#start#@@@@#@@@@@#start#");
  if (index > -1)
  {
    Value = Value.substring(index + 24, Value.length);
    var index2 = Value.indexOf("#end#@@@@#@@@@@#end#");
    if (index2 > -1)
    {
      Value = Value.substring(0, index2);
    }
  }
  return Value;
}

function createXMLHttpRequest() {
var xmlHttp;
    if (window.ActiveXObject) {
        xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
    }
    else if (window.XMLHttpRequest) {
        xmlHttp = new XMLHttpRequest();
    }
   return xmlHttp;
}

function TOpenData()
{   var _this = this;
    _this.OpenResult = "";
    _this.FillPanel = "";
    _this.ResultEvent = mynull;
    function OpenhandleStateChange(xmlHttp)
    {
        //if(xmlHttp.readyState == 0) {}
        //if(xmlHttp.readyState == 1) {}
        //if(xmlHttp.readyState == 2) {}
        try
        {
           //var flag = xmlHttp.status == 200;
           var flag = (xmlHttp.status == 200)&&(xmlHttp.readyState == 4)||(xmlHttp.status == 404); ///var flag = (xmlHttp.status == 200)&&(xmlHttp.readyState == 4); //2014-08-20 add &&(xmlHttp.readyState == 4)

        } catch(_e) {var flag = false; }
        if(flag)
        {
           if(document.all){
              _this.OpenResult = gb2utf8(xmlHttp.responseBody);
           } else{
              _this.OpenResult = xmlHttp.responseText;
           }
           //_this.OpenResult = GetData(_this.OpenResult);

           if((_this.ResultEvent != mynull)&&(_this.ResultEvent != null)) //2022-04-22
             _this.ResultEvent(_this.OpenResult, xmlHttp.status);

           if(_this.FillPanel != "")
           {
             document.getElementById(fieldToFill).innerHTML = _this.OpenResult;
           }
        }
    }
    _this.Open = function(Url, params, syn)
    {
      try
      {   //Url = encodeURI(Url);
          var xmlHttp = createXMLHttpRequest();
          var randomRange1 = 600000;
          var randIndex1 = Math.floor(Math.random()*randomRange1);
          if (Pos('?', Url) < 1){
            Url = Url + '?';}
          Url = Url + "&ram" + randIndex1;
          xmlHttp.open("GET", Url, syn);
          //xmlHttp.withCredentials = true;
          xmlHttp.onreadystatechange = function ()
          {
            OpenhandleStateChange(xmlHttp);
          };
          xmlHttp.send(params);
      } catch(_e)
      {}
    }
}

function OpenData_syn(url, ResultEvent) { //异步
  var Open = new TOpenData();
  var params = null;
  Open.ResultEvent = ResultEvent
  Open.Open(url, params, true);
  return Open.OpenResult;
}

function OpenData(url) {
  var Open = new TOpenData();
  var params = null;
  Open.Open(url, params, false);
  return Open.OpenResult;
}

function OpenDataEx(url, params, FillPanel) {
  var Open = new TOpenData();
  Open.FillPanel = FillPanel;
  Open.Open(url, params, true);
}

function TPostData()
{   var _this = this;
    _this.PostResult = "";
    _this.ResultEvent = mynull;
    function PosthandleStateChange(xmlHttp)
    {
        //if(xmlHttp.readyState == 0) {}
        //if(xmlHttp.readyState == 1) {}
        //if(xmlHttp.readyState == 2) {}
        try
        {
           var flag = (xmlHttp.readyState == 4)&&(xmlHttp.status == 200)
        } catch(_e) {var flag = false; }
        if(flag)
        {
           if(document.all){
               _this.PostResult = gb2utf8(xmlHttp.responseBody);
           }else{
               _this.PostResult = xmlHttp.responseText;
           }
           //_this.PostResult = gb2utf8(xmlHttp.responseBody);
           _this.PostResult = xmlHttp.responseText;
           //_this.PostResult = GetData(_this.PostResult);

           if((_this.ResultEvent != mynull)&&(_this.ResultEvent != null)) //2022-04-22
           {
             //if(trim(_this.PostResult) != "")
             {
               _this.ResultEvent(_this.PostResult, xmlHttp.status);
             }
           }
        }
    }
    _this.Post = function(url, params, syn)
    {
      try
      {
          var xmlHttp = createXMLHttpRequest();
          xmlHttp.open("POST", url, syn);
          //xmlHttp.withCredentials = true;
          xmlHttp.onreadystatechange = function ()
          {
            PosthandleStateChange(xmlHttp);
          };
          xmlHttp.send(params);
      } catch(_e)
      {}
    }
}

function PostData_syn(url, params, ResultEvent) { //异步
  var Post = new TPostData();
  Post.ResultEvent = ResultEvent
  Post.Post(url, params, true);
  return Post.PostResult;
}

function PostData(url, params) {
  var Post = new TPostData();
  Post.Post(url, params, false);
  return Post.PostResult;
}

function TPostData_File()
{   var _this = this;
    _this.PostResult = "";
    _this.ResultEvent = mynull;
    function PosthandleStateChange(xmlHttp)
    {
        //if(xmlHttp.readyState == 0) {}
        //if(xmlHttp.readyState == 1) {}
        //if(xmlHttp.readyState == 2) {}
        try
        {
           var flag = (xmlHttp.readyState == 4)&&(xmlHttp.status == 200) //xmlHttp.status == 200;
        } catch(_e) {var flag = false; }
        if(flag)
        {
           if(document.all){
              _this.PostResult = gb2utf8(xmlHttp.responseBody);
           } else{
              _this.PostResult = xmlHttp.responseText;
           }
           //_this.PostResult = GetData(_this.PostResult);
           if((_this.ResultEvent != mynull)&&(_this.ResultEvent != null)) //2022-04-22
             _this.ResultEvent(_this.PostResult, xmlHttp.status);
        }
    }
    _this.Post = function(url, file, syn)
    {
      try
      {

          var reader = new FileReader(file);

          var xmlHttp = createXMLHttpRequest();
          xmlHttp.open("POST", url, syn);
          //xmlHttp.withCredentials = true;
          xmlHttp.onreadystatechange = function ()
          {
            PosthandleStateChange(xmlHttp);
          };
          xmlHttp.overrideMimeType("apolication/octet-stream");
          xmlHttp.send(reader.result);


          /////////////////////////////////////////////
          //JavaScript代码，其中reader = new FileReader(file)
          //    var xhr = new XMLHttpRequest();
          //    xhr.open("POST", "fileupload.jsp?fileName=" + file.name);
          //    xhr.overrideMimeType("apolication/octet-stream");
          //    xhr.send(reader.result);
          /////////////////////////////////////////////////////


      } catch(_e)
      {}
    }
}


function PostData_File_syn(url, file, ResultEvent) { //异步
  var Post = new TPostData_File();
  Post.ResultEvent = ResultEvent
  Post.Post(url, file, true);
  return Post.PostResult;
}

function PostData_File(url, file) {
  var Post = new TPostData_File();
  Post.Post(url, file, false);
  return Post.PostResult;
}

function AnsiQuotedStr(S, Quote)
{
  if (S == mynull) return Quote + "" + Quote;

  var AddCount = 0;
  //for lp = 1 to length(S) do
  for ( var lp=0 ; lp < S.length; ++ lp)
  {
    if (S.substr(lp,1) == Quote)
    {
      AddCount++;
    }
  };
  if (AddCount == 0)
  {
    return Quote + S + Quote;
  } else
  {


    var regS = new RegExp(Quote,'gi');
    //var v = StringReplace(S, '"', '""', [rfReplaceAll]);
    var v = S.replace(regS, Quote+Quote);

    v = Quote + v + Quote;

    return v;
  }
}

function QuotedStr(S, Quote)
{
  if (Quote == mynull) Quote = "'";
  return AnsiQuotedStr(S, Quote);
}

function StrPlace(Text, Old, New)
{
  if (Text == mynull) return "";

  //var regS = new RegExp(Old,'gi');
  //var v = Text.replace(regS, New);

  var Result = "";
  var Index = Pos(Old, Text);
  while (Index > 0)
  {
    Result = Result + Text.substring(0, Index - 1) + New;
    Text = Text.substring(Index + Old.length - 1, Text.length);

    Index = Pos(Old, Text);
  }

  return Result + Text;
}

function StringReplace(Text, Old, New)
{
  return StrPlace(Text, Old, New);
}

function Length(value)
{
  if (value == mynull)
    return 0
  else
    return value.length;
}
String.prototype.remove = function(start, length) {
  var l = this.slice(0, start);
  var r = this.slice(start+length);
  return l+r;
}
function Delete(Text, start, count)
{
  if (Text == mynull) return "";
  Text = Text.remove(start, count);
  return Text;
}
function GetCommaText_Base(SL)
{
  var Delimiter = ',';
  var QuoteChar = '"';
  var v;

  var Count = SL.length;
  if ((Count == 1) && (SL[0] == ''))
  {  v = QuoteChar + QuoteChar }
  else
  {
    v = '';
    for ( var I=0 ; I < Count; ++I )
    {
      var S = SL[I];
      if (S == mynull) S = ""; //2014-04-14 add
      var a = "" + S; //alert(S);
      //for lp = Length(a) downto 1 do
      for ( var lp=a.length -1; lp > -1; --lp )
      {
        //if ((a[lp] >= #0) && (a[lp] <= ' ') || (a[lp] == QuoteChar) || (a[lp] == Delimiter))
        if ((a.substr(lp,1) >= String.fromCharCode(0)) && (a.substr(lp,1) <= ' ') || (a.substr(lp,1) == QuoteChar) || (a.substr(lp,1) == Delimiter))
        {
          break;
        } else
        {
         // delete(a, lp, 1) ;
         a = a.remove(lp, 1);
        }
      }
      if(a != '')
      {  S = AnsiQuotedStr(S, QuoteChar);
      };
      v = v + S + Delimiter;
    }
    //System.Delete(Result, Length(Result), 1);
    v = v.substring(0, v.length-1);
  }
  return v;
}

 function SetCommaText_Base(Value)
  { //   d
    //Value = "Windows socket error: 远程主机强迫关闭了一个现有的连接。 (10054), on API 'recv'----127.0.0.1:218"
    //alert('combse ' + Value)
      Value = String("" + Value);//2017-10-31 add
    if ((Value!= "")&&(Value!= null))
    {
      var S, POneChar;
      var P, P1;
      var QuoteChar, Delimiter;
      var lp = 0;
      var Qchar = 0;
      var regS = new RegExp('""','gi');
      var SL=[];
      var index = 0;

      Delimiter = ',';
      QuoteChar = '"';

      OneChar = Value.substr(lp,1);
      while ((OneChar >= String.fromCharCode(1))&&(OneChar <= ' '))
      { OneChar = Value.substr(lp,1);
        Value = Value.substring(1, Value.length);
        lp = lp + 1;
      }//alert('3333combse ' + Value)
      while(lp < Value.length)
      {   //alert(Value);
        //OneChar = Value.[lp];
          OneChar = Value.substr(lp,1);

        if (OneChar == QuoteChar)
        {
          P1 = lp;
          Qchar = 0;
          POneChar = "";
          while(lp < Value.length)
          {
            OneChar = Value.substr(lp,1);
            if(OneChar==QuoteChar)
            {
              Qchar++;
              if (Qchar == 3){Qchar = 1}
            }
            if((OneChar==QuoteChar)&&(Qchar == 2)&&(( (lp < Value.length - 1)&&(Value.substr(lp + 1,1)==Delimiter) ) || (lp == Value.length - 1)))
            {
              P = lp;
              S = Value.substring(P1 + 1, P - P1); //?????????????????????

              S = S.replace(regS, '"');
              //2014-01-08 mod Value = Value.substring(P - P1 + 2 , Value.length);
              Value = Value.substring(P - P1 + 1 , Value.length);

              lp = 0;
              break;
            } else
            {
              lp = lp + 1;
            }
          }

        } else
        {
            lp = 0;
            P1 = lp;
            Value = Value + "";
            //OneChar = Value[lp];
            OneChar = Value.substr(lp, 1); //[lp];

            //2014-08-22 mod while((OneChar > ' ') && (OneChar != Delimiter))
            var gg = false
            while((OneChar > '') && (OneChar != Delimiter))
            {
                OneChar = Value.substr(lp,1);
                lp = lp + 1;
                gg = true;
            }
            if(!gg) lp = lp + 1;
            P = lp;
            S = Value.substring(P1, P - P1 - 1); //?????????????????????
            Value = Value.substring(P - P1-1, Value.length);
            lp = 0;
        }

          //alert("S: " + S + "  Value:" + Value);
          //Add(S);
          SL[index] = S;
          index++;

          OneChar = Value.substr(lp,1);
          while (((OneChar >= String.fromCharCode(1))&&(OneChar <= ' ')) && (lp < Value.length))
          {
            OneChar = Value.substr(lp,1);
            lp = lp + 1;
          }


          //',000,,BTIMSG,,13120616205713703001,13121315154234704001,,,,,,,,发送消息,1,,,,回复：\'\'//\\,"2013-12-13 15:15:42"';
          OneChar = Value.substr(lp,1);

          if(OneChar == Delimiter)
          {
            P1 = lp;
            //if CharNext(P1)^ = #0 then
            //Add('');
            //2014-01-08 mod if(String.fromCharCode(0) == OneChar)

            //  if ( Value[lp + 1] == undefined)
            if (lp + 1 >= Value.length)
            {
             SL[index] = "";
             index++;
            }

            //repeat
            //P = CharNext(P);
            //until not (P^ in [#1..' ']);
            lp = -1;
            do{

              lp = lp + 1;
              OneChar = Value.substr(lp,1);
              if(lp > 3) { break}; //test
              Value = Value.substring(1, Value.length);
            }
            //while(!( (OneChar >= String.fromCharCode(1))&&(OneChar <= ' ') ));
            while((OneChar.charCodeAt() >= 1) && (OneChar.charCodeAt() <= 32) );
          }
      }
      //for ( var i=0 ; i < SL.length ; ++i )
      //{ alert(SL[i]);
      //}
      return SL;
    } else
    return []
  }

function SetCommaText_Base000(Value)
{ //   d
    //Value = "Windows socket error: Զ������ǿ�ȹر���һ�����е����ӡ� (10054), on API 'recv'----127.0.0.1:218"
    if ((Value!= "")&&(Value!= null))
    {
        var S, POneChar;
        var P, P1;
        var QuoteChar, Delimiter;
        var lp = 0;
        var Qchar = 0;
        var regS = new RegExp('""','gi');
        var SL=[];
        var index = 0;

        Delimiter = ',';
        QuoteChar = '"';

        OneChar = Value[lp];
        while ((OneChar >= String.fromCharCode(1))&&(OneChar <= ' '))
        { OneChar = Value[lp];
            Value = Value.substring(1, Value.length);
            lp = lp + 1;
        }
        while(lp < Value.length)
        {   //alert(Value);
            OneChar = Value[lp];

            if (OneChar == QuoteChar)
            {
                P1 = lp;
                Qchar = 0;
                POneChar = "";
                while(lp < Value.length)
                {
                    OneChar = Value[lp];
                    if(OneChar==QuoteChar)
                    {
                        Qchar++;
                        if (Qchar == 3){Qchar = 1}
                    }
                    if((OneChar==QuoteChar)&&(Qchar == 2)&&(( (lp < Value.length - 1)&&(Value[lp + 1]==Delimiter) ) || (lp == Value.length - 1)))
                    {
                        P = lp;
                        S = Value.substring(P1 + 1, P - P1); //?????????????????????

                        S = S.replace(regS, '"');
                        //2014-01-08 mod Value = Value.substring(P - P1 + 2 , Value.length);
                        Value = Value.substring(P - P1 + 1 , Value.length);

                        lp = 0;
                        break;
                    } else
                    {
                        lp = lp + 1;
                    }
                }

            } else
            {   lp = 0;
                P1 = lp;
                OneChar = Value[lp];
                //2014-08-22 mod while((OneChar > ' ') && (OneChar != Delimiter))
                while((OneChar > '') && (OneChar != Delimiter))
                {
                    OneChar = Value[lp];
                    lp = lp + 1;
                }
                P = lp;
                S = Value.substring(P1, P - P1 - 1); //?????????????????????
                Value = Value.substring(P - P1-1, Value.length);
                lp = 0;
            }

            //alert("S: " + S + "  Value:" + Value);
            //Add(S);
            SL[index] = S;
            index++;

            OneChar = Value[lp];
            while (((OneChar >= String.fromCharCode(1))&&(OneChar <= ' ')) && (lp < Value.length))
            {
                OneChar = Value[lp];
                lp = lp + 1;
            }


            //',000,,BTIMSG,,13120616205713703001,13121315154234704001,,,,,,,,������Ϣ,1,,,,�ظ���\'\'//\\,"2013-12-13 15:15:42"';
            OneChar = Value[lp];

            if(OneChar == Delimiter)
            {
                P1 = lp;
                //if CharNext(P1)^ = #0 then
                //Add('');
                //2014-01-08 mod if(String.fromCharCode(0) == OneChar)
                if ( Value[lp + 1] == undefined)
                {
                    SL[index] = "";
                    index++;
                }

                //repeat
                //P = CharNext(P);
                //until not (P^ in [#1..' ']);
                lp = -1;
                do{

                    lp = lp + 1;
                    OneChar = Value[lp];
                    if(lp > 3) { break}; //test
                    Value = Value.substring(1, Value.length);
                }
                    //while(!( (OneChar >= String.fromCharCode(1))&&(OneChar <= ' ') ));
                while((OneChar.charCodeAt() >= 1) && (OneChar.charCodeAt() <= 32) );
            }
        }
        //for ( var i=0 ; i < SL.length ; ++i )
        //{ alert(SL[i]);
        //}
        return SL;
    } else
        return []
}

function TStringList()
 {
   var _this = this;
   _this.SL = [];
   _this.SetCommaText = function(value)
   {
     _this.SL = SetCommaText_Base(value);
     return this;
   }
   _this.GetCommaText = function(value)
   {
     if (value == mynull)
       return GetCommaText_Base(_this.SL)
     else
       return GetCommaText_Base(value)
   }
    _this.CommaText = function(value)
   {
     return _this.GetCommaText(value)
   }
   _this.SetText = function(value, splitChar)
   {
     if (splitChar == mynull) splitChar = '\r\n';

     _this.SL.length = 0;
     if (splitChar != mynull)
     {
       var Index = Pos(splitChar, value);
       while (Index > 0)
       {
         _this.SL[_this.SL.length] = value.substring(0, Index - 1);
         value = value.substring(Index + splitChar.length - 1, value.length);
         Index = Pos(splitChar, value);
       }
     }
     _this.SL[_this.SL.length] = value
   }
   _this.GetText = function()
   {
     var Text = "";
     for(var lp = 0; lp < _this.SL.length; lp ++)
     {
       if (lp == 0)
         Text = _this.SL[lp]
       else
         Text = Text + '\r\n' + _this.SL[lp];
     }
     return Text;
   }
   _this.Count = function()
   {
     return _this.SL.length;
   }
   _this.items = function(Index)
   {
     return _this.SL[Index];
   }
   _this.Values = function(Name)
   {
     for(var lp = 0; lp < _this.SL.length; lp ++)
     {
       var Text = _this.SL[lp];
       if(StrValueIsNull(Text)) {Text=""}
       Name = Name.toLowerCase();
       Text = Text.toLowerCase();
       if(GetDeliPri(Text, "=") == Name)
       {
         return _this.SL[lp];
       }
     }
     return "";
   }
   _this.S = function(Value, Index)
   {
     if (Index == mynull) Index = _this.SL.length;
     _this.SL[Index] = Value;
   }
   _this.SV = function(Name,Value)
   {
        var f = false;
        for(var lp=0 ; lp < _this.Count(); ++ lp)
        {
          if (trim(GetDeliPri(_this.SL[lp], '=').toLowerCase()) == Name.toLowerCase()){
            _this.SL[lp] = Name + '=' + Value;
            f = true;
            break;
          }
        }
        if(!f){_this.Add(Name + '=' + Value)}
   }
   _this.SetValues = function(Name,Value)
   {
        _this.SV(Name,Value);
   }
   _this.Add = function(Value)
   {
     _this.SL[_this.SL.length] = Value;
   }
   _this.Delete = function(Value)
   {
     _this.SL.splice(Value,1);
   }
   _this.IndexOf = function(Value)
   {
     return _this.SL.indexOf(Value);
   }
   _this.indexOf = function(Value)
   {
     return _this.IndexOf(Value);
   }
   _this.Clear = function()
   {
     _this.SL.length = 0;
   }
   _this.Sort = function()
   {
     _this.SL.sort(function(a,b){ return (a+'').localeCompare(b+'');});
   }
   _this.Sort_Num = function() //按数字大小排
   {
     _this.SL.sort(function(a,b){return a-b;});
   }
 }

  function TMField()
  {
    var _this = this;
    _this.FSlList = [];
    _this.FieldName = "";
    _this.CurPos = -1;
    _this.DataType = "ftString";
    _this.AsString = function(index)
    {
      if (index == null)
      {index = _this.CurPos;}
      var v = _this.FSlList[index];
      if (v == mynull) v = "";
      return v;
    }
    _this.SetString = function(value)
    {
      _this.FSlList[_this.CurPos] = value;
    }
    _this.SetCommaText = function(value)
    {
      _this.FSlList = SetCommaText_Base(value);
    }
    _this.GetCommaText = function()
    {
      return GetCommaText_Base(_this.FSlList);
    }
    _this.Count = function()
    {
      return _this.FSlList.length;
    }
  }

  function TMFields()
  {
    var _this = this;
    var FList = [];
    this.list = FList;

    _this.Add = function(FieldName, DataType)
    {
      if(StrValueIsNull(DataType)){DataType='ftString'}
      MField = new TMField();
      MField.FieldName = FieldName;
      MField.DataType = DataType;
      FList[FList.length] = MField;
    }
    _this.Count = function()
    {
      return FList.length;
    }
  }

  function THjhMemoryDataSet()
  {
    var _this = this;
    var Fields = new TMFields();
    _this.Fields = Fields;
    _this.Bof = false;
    _this.Eof = false;

    _this.FieldByName = function(FieldName)
    {
      var Field = mynull;
      for ( var i=0 ; i < Fields.list.length; ++i )
      {
        if(Fields.list[i].FieldName.toUpperCase() == FieldName.toUpperCase())
        {
          Field = Fields.list[i];
          break;
        }
      }
      return Field;
    }
    _this.F = function(FieldName)
    {
      return _this.FieldByName(FieldName);
    }
    _this.Fv = function(FieldName)
    {
      var Field = _this.F(FieldName);
      if(Field != mynull)
      {
        return Field.AsString();
      }
      else
      {  return ""}
    }
    _this.V = function(FieldName)
    {
      return _this.Fv(FieldName);
    }
    _this.S = function(FieldName, value)
    {
      var Field = _this.F(FieldName);
      if(Field != mynull)
      {
        Field.SetString(value);
      }
    }
    _this.SetCommaText = function(value)
    {
      _this.Clear();
      var FTmpSL = SetCommaText_Base(value); //FTmpSL.CommaText = Value;

      for ( var i=0 ; i < FTmpSL.length / 2; ++i )
      {
        var FieldName = FTmpSL[2 * i];
        var dt = GetDeliPri(FieldName, '*');
        FieldName = GetDeliBack(trim(FieldName), '*');
        Fields.Add(FieldName, dt);
        _this.FieldByName(FieldName).SetCommaText(FTmpSL[2 * i + 1]);
      }
      _this.First();
    }
    _this.GetCommaText = function()
    {
      var v = '';
      var FTmpSL = [];
      //for lp = 0 to Fields.Count() - 1 do
      for ( var lp=0 ;lp < Fields.Count(); ++lp)
      {
        FTmpSL[lp * 2] = Fields.list[lp].DataType + '*' + Fields.list[lp].FieldName;
        FTmpSL[lp * 2 + 1] = Fields.list[lp].GetCommaText(); //FTmpSL.Add(FFields[lp].CommaText);
      }
      return GetCommaText_Base(FTmpSL);
    }
    _this.RecordCount = function()
    {
      var Count = 0;
      if(Fields.Count() > 0)
      {
        Count = Fields.list[0].Count();
      }
      return Count;
    }
    _this.First = function()
    {
      if(_this.RecordCount() < 1)
      {
        _this.Bof = true;
        _this.Eof = true;
      } else
        {
          for ( var i=0 ; i < Fields.Count(); ++i )
          {  Fields.list[i].CurPos = 0; }

          if(_this.RecordCount < 1)
          {
            _this.Bof = true;
            _this.Eof = true;
          } else {
            _this.Bof = false;
            _this.Eof = false;
          }
       }
    }

    _this.Prior = function()
    {
      if(_this.RecordCount() > 0)
      {
          if(Fields.Count() > 0)
            _this.Eof = false;
          if (Fields.list[0].CurPos == 0)
            _this.Bof = true;

          for ( var i=0; i < Fields.Count(); ++i )
          {
            Fields.list[i].CurPos = Fields.list[i].CurPos - 1;
            if(Fields.Count() < 0) Fields.list[i].CurPos = 0;
          }
      }
    }

    _this.Next = function()
    {
      if(_this.RecordCount() < 1)
      {
        _this.Eof = true;
      }
      else
      {
          _this.Bof = false;
          if (Fields.list[0].CurPos == Fields.list[0].Count() - 1)
          { _this.Eof = true;}

          for ( var i=0; i < Fields.Count(); ++i )
          {
            Fields.list[i].CurPos = Fields.list[i].CurPos + 1;
            if (Fields.list[i].CurPos > Fields.list[i].Count() - 1)
              Fields.list[i].CurPos = Fields.list[i].Count() - 1;
          }
      }
    }
    _this.Last = function()
    {
      if(_this.RecordCount() > 0)
      {
        for ( var i=0; i < Fields.Count(); ++i )
          Fields.list[i].CurPos  = Fields.list[i].Count() - 1;
      }
      if(_this.RecordCount() < 1)
      {
        _this.Bof = true;
        _this.Eof = true;
      } else
      {
        _this.Bof = false;
        _this.Eof = false;
      }
    }
    _this.GetCurRecordPos = function()
    {
      v = -1;
      if (Fields.Count() > 0)
      {
        v = Fields.list[0].CurPos;
      }
      return v;
    }
    _this.SetCurRecordPos = function(value)
    {
      for ( var i=0; i < Fields.Count(); ++i )
      {
        Fields.list[i].CurPos = value;
        if (Fields.list[i].CurPos > Fields.list[i].Count() - 1)
          Fields.list[i].CurPos = Fields.list[i].Count() - 1;
      }
    }
    _this.Go = function(value)
    {
      _this.SetCurRecordPos(value);
    }
    _this.ClearData = function()
    {
      _this.Bof = true;
      _this.Eof = true;
      _this.SetCurRecordPos(-1);

      for ( var lp=0 ;lp < Fields.Count(); ++lp) //清空值列表
      {
        Fields.list[lp].FSlList.length = 0; // alert("Fields.Count(): " + Fields.list[lp].Count());
      }
      //Fields.list.length = 0;
    }
    _this.Clear = function()
    {
      _this.ClearData();
      /*_this.Bof = true;
      _this.Eof = true;
      _this.SetCurRecordPos(-1);

      for ( var lp=0 ;lp < Fields.Count(); ++lp) //清空值列表
      {
        Fields.list[lp].FSlList.length = 0; // alert("Fields.Count(): " + Fields.list[lp].Count());
      }*/
      Fields.list.length = 0;
    }
    _this.Append = function()
    {
      //for lp = 0 to Fields.Count - 1 do
      for ( var lp=0;lp < Fields.Count(); ++lp)
      {
        Fields.list[lp].FSlList[Fields.list[lp].FSlList.length] = "";
        Fields.list[lp].CurPos = Fields.list[lp].FSlList.length - 1;
      }
      _this.Bof = false;
      _this.Eof = false;
    }

    _this.Delete = function(Pos)
    {
      if (Pos != null)
      {_this.SetCurRecordPos(Pos);}

      if(_this.RecordCount() > 0)
      {
          //for lp = 0 to Fields.Count - 1 do
          if(Fields.list[0].CurPos < Fields.Count())
          {
              for ( var lp=0;lp < Fields.Count(); ++lp)
              {//alert(lp)
                  //Fields.list[lp].FSlList.Delete(Fields.list[lp].CurPos);
                  Fields.list[lp].FSlList.splice(Fields.list[lp].CurPos,1);

                  if(Fields.list[lp].CurPos > Fields.list[lp].FSlList.Count - 1)
                  {  Fields.list[lp].CurPos = Fields.list[lp].CurPos - 1;}
                  if (Fields.list[lp].FSlList.Count == 0) {Fields.list[lp].CurPos = -1;}
              }
          }
          if (_this.RecordCount() > 0)
          {
            if (Fields.list[0].CurPos < 1)
            {  _this.Bof = true;}
          }
          if ((Fields.list[0].CurPos < 1)&&(_this.RecordCount() < 1))
          {  _this.Eof = true;}

          if (_this.RecordCount() > 0)
          {
            if (Fields.list[0].CurPos > _this.RecordCount() - 1)
            { _this.Eof = true;}
          }
       }else{
          /*if (_this.RecordCount() > 0)
          {
              if (Fields.list[0].CurPos < 1)
              {  _this.Bof = true;}
          }
          if ((Fields.list[0].CurPos < 1)&&(_this.RecordCount() < 1))
          {  _this.Eof = true;}
          if (_this.RecordCount() > 0)
          {
              if (Fields.list[0].CurPos > _this.RecordCount() - 1)
              { _this.Eof = true;}
          }*/
      }
    }
    _this.Insert = function(Pos)
    {
      var index;
      if (Pos != null)
      { if (Pos > _this.RecordCount() - 1)
        {
          if(_this.RecordCount() == 0)
          { index = 0;}
          else
          { index = _this.RecordCount(); }
        }
        else
        {index = Pos;}
      }
      else
      { index = Fields.list[0].CurPos;
        if (index == -1)
        {
          if(_this.RecordCount() == 0)
          { index = 0;}
          else
          { index = _this.RecordCount(); }
        }
      }
      for ( var lp=0;lp < Fields.Count(); ++lp)
      {
        if (Fields.list[lp].FSlList.Count < 1)
        {
          Fields.list[lp].FSlList[Fields.list[lp].FSlList.length] = "";
          index = 0;
        } else
        {
          Fields.list[lp].FSlList.splice(index,0,"");
        }
      }
      _this.SetCurRecordPos(index);
      _this.Bof = false;
      _this.Eof = false;
    }

    _this.SetFieldList = function(value)
    {
        var SL = SetCommaText_Base(value);
        _this.Clear();
        for ( var lp=0;lp < SL.length; ++lp)
        {
          FieldName = SL[lp];
          //if Pos('*', FieldName) < 1 then
          if (FieldName.indexOf('*') < 0)
          {
            Fields.Add(FieldName)
          }else
          {
            FieldName = FieldName.substring(FieldName, 0, FieldName.indexOf('*') - 1);
            Fields.Add(FieldName);
          }
        }
    }
    _this.GetFieldList = function()
    {
        var SL = [];
        for(var lp = 0; lp < Fields.list.length; lp ++)
        {
          SL[SL.length] = Fields.list[lp].FieldName;
        }
        return GetCommaText_Base(SL);
    }
    _this.CopyOneRecord = function(SourMds)
    {
        var FieldName, MField;
        _this.Append();
        for(var lp = 0; lp < Fields.list.length; lp ++)
        {
          FieldName = Fields.list[lp].FieldName;
          MField = SourMds.F(FieldName);
          if(MField != mynull)
          {
            Fields.list[lp].SetString(MField.AsString());
          }
        }
    }
  }

  String.format = function() {
    if( arguments.length == 0 )
        return null;

    var str = arguments[0];
    for(var i=1;i<arguments.length;i++) {
        var re = new RegExp('\\{' + (i-1) + '\\}','gm');
        str = str.replace(re, arguments[i]);
    }
    return str;
 }

function getDs(Comm)
{
  var ds = new THjhMemoryDataSet();
  if (Comm != mynull) ds.SetCommaText(Comm);
  ds.First();
  return ds;
}

function getDS(Comm)
{
  return getDs(Comm);
}
//用于SL
function getTStringList(Value)
{
  var sl = new TStringList();
  if (Value != mynull) sl.SetCommaText(Value);
  return sl;
}
function getSList(Value)
{
  return getTStringList(Value);
}
function getslt(Value)
{
  return getTStringList(Value);
}
function getSLT(Value)
{
  return getTStringList(Value);
}
function getSl(Value)
{
  return getTStringList(Value);
}
function getSL(Value)
{
  return getTStringList(Value);
}

/////
function getSlEx(Value)
{
  return SetCommaText_Base(Value);
}

function getSLEx(Value)
{
  return getSlEx(Value);
}
function SLS(Value)
{
  return SetCommaText_Base(Value);
}

function getCommaText(Value)
{
  return GetCommaText_Base(Value);
}

function getQueryString(name) {  //用于取URL中的项目
  var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");
  var r = window.location.search.substr(1).match(reg);
  if (r != null) return unescape(r[2]); return null;
}


function StrValueIsNull(value)
{ //字符串类型判断是否为空
  if ((value == null)||(value == mynull))
    return true
  else
    return ((trim(value.toString()) == ""));
}

function NValueIsNull(value)
{ //数值类型判断是否为空
  if (StrValueIsNull(value))
    return true
  else
  {
    try
    {
      //return (((trim(value.toString()) == "0")) || (value == 0));
      return (((trim(value.toString()) == "0"))||(Number(value) == 0));
    }
    catch(e)
    {
      return true;
    }
  }
}

function Pos(Sub, Text)
{
  //if (Text == mynull)
    if ((Text == mynull)) //||(Text = "")
  {
      return -1;
  } else
      if(Text == "")
      { //2017-10-31 add
          return -1;
      }else
  {
      var dd = "" + Text;
      var i = dd.indexOf(Sub);
      return i + 1;
  }
}
function UpperCase(value)
{
  if (!StrValueIsNull(value))
    return value.toUpperCase()
  else
    return value;
}

//math start

function DecimalDig(value)
{ //取小数位
  if(value != null && value != ''){
    var decimalIndex=value.indexOf('.');
    if(decimalIndex=='-1'){
        return 0;
    }else{
        var decimalPart = value.substring(decimalIndex+1, value.length);
        return decimalPart.length;
    }
  }
  return 0;
}

function IsNegative(value)
{  //判断是否是负数，小于零返回true
  if(value != null && value != '')
  {
    value = trim(value);
    return (value.indexOf('-') == 0);
  } else
    return false;
};

function IsPositive(Value)
{ //判断是否是正数，大于零返回true
  return (! IsNegative(Value)) && (! NValueIsNull(Value));
}

function GetF(DigCount)
{
  var ret = "";
  for(var lp = 1; lp <= DigCount; lp ++)
    ret = ret + '0';
  return ('0.' + ret + '5');
}

function _IsValidValueEx(Value, DigCount)
{
  var Result = Value;
  var Len = DecimalDig(Value);
  if (Len > DigCount)
  {
    if (IsNegative(Value))
      Result = ad(Value, GetF(DigCount))
    else
      Result = ad(Value, GetF(DigCount));
    Result = Result.toString();
    Len = DecimalDig(Result);
    if (Len > DigCount)
      Result = Result.substring(0, Result.length - (Len - DigCount));
  }

  return Result;
}

function IsValidValueEx(Value)
{
  var Result = _IsValidValueEx(Value, 16);
  return Result;
}

function Decimal(Value, DigCount)
{ //截断小数位
  if (DigCount == mynull) DigCount = 16;
  if (!StrValueIsNull(Value)) Value = Value.toString();
  var Result = _IsValidValueEx(Value, DigCount);

  if (Result == '-0') Result = '0'; //2009-08-24 add
  return Result;
}

function DecimalEx(Value, DigCount)
{ //截断小数位, 保存小数位
  var v = Decimal(Value, DigCount);
  var I = DecimalDig(v);

  var Flag = Pos('.', v) < 1;
  if ((I != DigCount) || Flag)
  {
    if(Flag)
    {
      I = 0;
      v = v + '.';
    }
    for (var lp = 1; lp <= DigCount - I; lp ++)
      v = v + '0';
  }
  return v;
}

function AddPric(value)
{ //增加精度
  if (value != mynull)
  {
    var count = DecimalDig(value);
    if ((count == 0)||(value.indexOf(".") < 0)) value = value + '.';
    for (var i = 0; i < 18 - count; i ++)
      value = value + '0';
  }
  return value;
}

function DecZero(value)
{ //去掉小数点后面多余的0
  if (value != mynull)
  {
    var count = DecimalDig(value);
    if (count > 0)
    {
      var ret = "";
      for (var i = value.length - 1; i > -1; i --)
      if ((value.substr(i,1) == '0')&&(ret == "")) {}
      else
        ret = value.substr(i,1) + ret;
      if (ret.substr(ret.length - 1,1) == '.') ret = ret.substring(0, ret.length - 1);
    }
  } else
    var ret = value;
  return ret;
}

function ad(one, two)
{ //加
  if (!StrValueIsNull(one)) {one = one.toString()} else one = "0";
  if (!StrValueIsNull(two)) {two = two.toString()} else two = "0";
  return (new BigDecimal(one).add(new BigDecimal(two))).toString();
}
function Ad(one, two)
{
  return ad(one, two);
}

function su(one, two)
{ //减
  if (!StrValueIsNull(one)) {one = one.toString()} else one = "0";
  if (!StrValueIsNull(two)) {two = two.toString()} else two = "0";
  return (new BigDecimal(one).subtract(new BigDecimal(two))).toString();
}
function Su(one, two)
{
  return su(one, two);
}

function mu(one, two)
{ //乘
  if (!StrValueIsNull(one)) {one = one.toString()} else one = "0";
  if (!StrValueIsNull(two)) {two = two.toString()} else two = "0";
  return (new BigDecimal(one).multiply(new BigDecimal(two))).toString();
}
function Mu(one, two)
{
  return mu(one, two);
}

function di(one, two)
{ //除
  if (!StrValueIsNull(one)) {one = one.toString()} else one = "0";
  if (!StrValueIsNull(two)) {two = two.toString()} else two = "0";
  one = AddPric(one);
  var Result = (new BigDecimal(one).divide(new BigDecimal(two))).toString();
  Result = DecZero(Result);
  return Result;
}
function Di(one, two)
{
  return di(one, two);
}

function IsEqual(Value1, Value2)
{ //Value1 = Value2 返回true
  return NValueIsNull(su(Value1, Value2));
}

function IsLess(Value1, Value2)
{ //Value1 < Value2 返回true
  var Result = IsNegative(su(Value1, Value2));
  return Result;
}

function IsLessEqual(Value1, Value2)
{ //Value1 <= Value2 返回true
  var Result = IsLess(Value1, Value2) || IsEqual(Value1, Value2);
  return Result;
}

function IsGreater(Value1, Value2)
{  //Value1 > Value2 返回true
  var Result = IsPositive(su(Value1, Value2));
  return Result;
}

function IsGreaterEqual(Value1, Value2)
{ //Value1 >= Value2 返回true
  var Result = IsGreater(Value1, Value2) || IsEqual(Value1, Value2);
  return Result;
}

function IsValNull(Value1)
{ ////判断一个数值是否为空，可能为0或''
  var Result = NValueIsNull(Value1);
  return Result;
}

function IsValNNull(Value)
{
  var Result = ! IsValNull(Value);
  return Result;
}

//math end

Date.prototype.format = function(format){
var o = {
/* "M+" : this.getMonth()+1, //month
"d+" : this.getDate(), //day
"h+" : this.getHours(), //hour
"m+" : this.getMinutes(), //minute
"s+" : this.getSeconds(), //second
"q+" : Math.floor((this.getMonth()+3)/3), //quarter
"S" : this.getMilliseconds() //millisecond
*/
"m+" : this.getMonth()+1, //month
"d+" : this.getDate(), //day
"h+" : this.getHours(), //hour
"n+" : this.getMinutes(), //minute
"s+" : this.getSeconds(), //second
"q+" : Math.floor((this.getMonth()+3)/3), //quarter
"z" : (1000 + this.getMilliseconds()).toString().substr(1) //this.getMilliseconds() //millisecond
}

if(/(y+)/.test(format)) {
format = format.replace(RegExp.$1, (this.getFullYear()+"").substr(4 - RegExp.$1.length));
}

for(var k in o) {
if(new RegExp("("+ k +")").test(format)) {
format = format.replace(RegExp.$1, RegExp.$1.length==1 ? o[k] : ("00"+ o[k]).substr((""+ o[k]).length));
}
}
return format;
}

function FillChar(Text, Sub, Len)
{
  if (Text == mynull) Text = "";
  var Result = Text;
  var l = Result.length;
  for (var lp = 1; lp <= Len - l; lp ++)
    Result = Sub + Result;
  return Result;
}

function FillCharRight(Text, Sub, Len)
{
  if (Text == mynull) Text = "";
  var Result = Text;
  var l = Result.length;
  for (var lp = 1; lp <= Len - l; lp ++)
    Result = Result + Sub;
  return Result;
}

function GetClientUniqueCode()
{
  FClientUniqueCode = FClientUniqueCode + 1;
  if (FClientUniqueCode > 999)
    FClientUniqueCode = 1;
  var Param1 = FillChar(FClientUniqueCode, '0', 3);

  var Param2 = Math.floor(Math.random()*89 + 10); // RandomRange(10, 99);

  var now = new Date();
  //var nowStr = now.format("yyyy-MM-dd hh:nn:ss");

  var Result = now.format('yymmddhhnnssz') +
    Param2 + Param1;
  return FillCharRight(Result, "0", 20);
}

function MyAlert(text){
      var type = "auto";

      layer.open({
        type: 1
        ,offset: type //具体配置参考：http://www.layui.com/doc/modules/layer.html#offset
        ,id: 'layerDemo'+type //防止重复弹出
        //,content: '<div style="padding: 20px 100px;">'+ text +'</div>'
        ,content: '<div style="padding: 10px 10px;">'+ text +'</div>'
        ,btn: '关闭'
        ,btnAlign: 'c' //按钮居中
        ,shade: 0 //不显示遮罩
        ,yes: function(){
          layer.closeAll();
        }
      });
}

function mymsg(text){
 layer.msg(text); //这种对话框不能在html初始化时弹出，一定要用延时方式才能正常执行
}
function MyMsg(text){
 layer.msg(text);
}

function mymsgex(text,runevent,time){ //延时执行弹出框，用于页面初始化
  if (StrValueIsNull(time)){time=800}
  var intervalId = setInterval(function(){
    clearInterval(intervalId);
    if (!StrValueIsNull(runevent)){runevent();}
    mymsg(text);
  },time);
}
function MyMsgEx(text,runevent,time){
  mymsgex(text,runevent,time);
}

function myalert(text){
  MyAlert(text);
}

//这种对话框不能在html初始化时弹出，一定要用延时方式才能正常执行
function myask(text, Myfunc, yesTitle, closeTitle){
  if (StrValueIsNull(yesTitle)) {yesTitle = '确认'}
  if (StrValueIsNull(closeTitle)) {closeTitle = '退出'}
        layer.open({
        type: 1
        //,title: '当你选择该窗体时，即会在最顶端'
        //,area: ['390px', '260px']
        ,shade: 0.8
        ,title: false //不显示标题栏
        ,closeBtn: false
        //,maxmin: true
        ,content: '<div style="padding: 10px; line-height: 22px; background-color: #393D49; color: #fff; font-weight: 300;">'  + text + '</div>'
        ,btn: [yesTitle, closeTitle]
        ,yes: function(){
          Myfunc();
        }
        ,btn2: function(){
          layer.closeAll();
        }

        ,zIndex: layer.zIndex //重点1
        ,success: function(layero){
          layer.setTop(layero); //重点2
        }
      });
}

function changeURLStatic(name, value) { //往当前地址栏URL增加一项
    var url = location.href;
    var reg = eval('/([\?|&]'+name+'=)[^&]*/gi');
    value = value.toString().replace(/(^\s*)|(\s*$)/g,"");  //移除首尾空格
    if(!value){
        var url2 = url.replace(reg , '');  //正则替换
    }else{
        if(url.match(reg)){
            var url2 = url.replace(reg , '$1' + value);  //正则替换
        }else{
            var url2 = url + (url.indexOf('?') > -1 ? '&' : '?') + name + '=' +value;  //没有参数添加参数
        }
    }
    if (Pos('?', url2) < 1)
      url2 = url2.replace('&', '?');
    history.replaceState(null,null, url2);  //替换地址栏
}

function AddOneItemToUrl(href,aname,value){ //往url添加一项，如果已有项则修改
  var old=decodeURIComponent(href);
  if (Pos('?', old) > 0){
    url = GetDeliBack(old, '?');
    var f = false;
    var sl=getSL();
    sl.SetText(StringReplace(url,'&','\r\n'));
    sl.SV(aname, value);

    url="";
    for(var lp=0 ; lp < sl.Count(); ++ lp){
      if(url==""){ url=sl.SL[lp]}else{ url=url+'&'+sl.SL[lp]}
    }

    url = GetDeliPri(old, '?')+'?'+url;
  }else{url=old+'?'+aname+'='+value}
  return url;
}

function PubGoEx(myname,oweridOrname,mytag,att){
  if(StrValueIsNull(att)){att=""}
  if(StrValueIsNull(mytag)){mytag=""}
  var o
  if(StrValueIsNull(oweridOrname)){
    //if(StrValueIsNull(mytag)){
    //  o = $("[name='" + myname + "']");
    //  if(o.length<1){o = $("[id='" + myname + "']");}
    //}else{
      o = $(mytag + "[name='" + myname + "']" + att);
      if(o.length<1){o = $(mytag + "[id='" + myname + "']" + att);
    //}
    }
  } else{
    o = $("[id='" + oweridOrname + "'] [name='" + myname + "']" + att);
    if(o.length<1){o = $("[id='" + oweridOrname + "'] [id='" + myname + "']" + att);}
    if(o.length<1){o = $("[name='" + oweridOrname + "'] [name='" + myname + "']" + att);}
    if(o.length<1){o = $("[name='" + oweridOrname + "'] [id='" + myname + "']" + att);}
  }
  return o;
}
function PubGo(myname,oweridOrname,mytag,addstr){ //取对象
  if(StrValueIsNull(addstr)){addstr=""}
  var o = PubGoEx(myname,oweridOrname,mytag,addstr);
  var t = o.attr("type");
  if((t=="radio")||(t=="checkbox")){
    o = PubGoEx(myname,oweridOrname,mytag,addstr+":checked");
  }
  return o;
}
function pubgo(myname,oweridOrname,mytag,addstr){
  return PubGo(myname,oweridOrname,mytag,addstr);
}
function PubGv(myname,oweridOrname,mytag,addstr){ //取值
  var o = PubGo(myname,oweridOrname,mytag,addstr);
  var t = getType(o)
  if(needval_tag(t)||(t=="radio")||(t=="checkbox")){
    v=o.val()
  }else
  {
    v=o.text();
  }
  if(StrValueIsNull(v)){v=""}
  return v;
}
function pubgv(myname,oweridOrname,mytag,addstr){ //取值
  return PubGv(myname,oweridOrname,mytag,addstr);
}
function PubSv(myname,mysetvalue,oweridOrname,mytag,attr,rowid){ //赋值  对于radio,mysetvalue为value值, 因是单选，只需要设置true值，不需要false
                   //PubSv_Cell(mysetvalue,gridid,rowid,FieldName,attr)
  if(trim(rowid)!="")
  {
    return PubSv_Cell(mysetvalue,oweridOrname,rowid,myname,attr);//增加表格单元格赋值，方便调用
  }
  if(StrValueIsNull(attr)){attr=""}
  var o = PubGoEx(myname,oweridOrname,mytag,attr + "");
  //alert(myname + '=' + mysetvalue + '=' + oweridOrname + '=' + o.val())
  //alert($("form[id='Form_983525_Form'] [name='note']").val())
  //var t = o.attr("type");
  t=getType(o);
  if((t=="radio")||(t=="checkbox")){
    if(t=="radio"){
       o = PubGoEx(myname,oweridOrname,mytag,'[value="' + mysetvalue +'"]');
       o.next('div').click();//layui专用
       o.prop("checked",true);//普通的radiobox专用
    } else
    { //checkbox
       if(StrValueIsNull(mysetvalue)) {mysetvalue=true}
       var v = PubGv(myname,oweridOrname,mytag);
       if(((v=='1')||(v=='on'))){
         if(!mysetvalue){
           o.next('div').click();//layui专用
         }
       } else{
         if(mysetvalue){
           o.next('div').click();//layui专用
         }
       }
       o.prop("checked",mysetvalue);//普通的checkbox专用
    }
  } else {
    if(needval_tag(t)){
      o.val(mysetvalue)
    }else
      o.text(mysetvalue);
  }
}
/*function pubsv2(myname,value,oweridOrname,mytag,att,rowid){ //赋值
  alert(value+'《-,grid:'+oweridOrname+'--,--rowid:'+rowid+'--,f:'+myname)
  return PubSv(myname,value,oweridOrname,mytag,att,rowid);
}*/

function pubsv(myname,value,oweridOrname,mytag,att,rowid){ //赋值
  return PubSv(myname,value,oweridOrname,mytag,att,rowid);
}

//////////////、、、、、
function PubVisible(myname,value,oweridOrname,mytag,addstr) //不可见
{
  var o=PubGoEx(myname,oweridOrname,mytag,addstr); //PubGo(myname,oweridOrname,mytag)
  if(value){
    o.show();
  }else{
    o.hide();
  }
}
function PubSd(myname,value,oweridOrname,mytag,addstr) //不能够用
{
  var o=PubGoEx(myname,oweridOrname,mytag,addstr);
  o.prop("disabled", value);
}
function PubSr(myname,value,oweridOrname,mytag,addstr) //只读取
{
  var o=PubGoEx(myname,oweridOrname,mytag,addstr);
  o.attr("readonly",value);
}

function layrender(atag){ //lay专用，重新刷新界面
  //layui.form.render('select');
  layui.form.render(atag);
}
function NoParseHTML(Text){//把语句的 <%  %>转义 //<	= &lt;  >	= &gt;
  var Result = Text;

  Result = StringReplace(Result, '<', '&lt;');
  Result = StringReplace(Result, '>', '&gt;');
  return Result;
}
function ReplaceText_ReturnToHtml_BR(Value){
  if (Pos('<%', trim(Value)) == 1){return Value}; //2020-02-27 add
  var Result = Value;
  Result = StringReplace(Result, '\r\n', '<br>');
  Result = StringReplace(Result, '\r', '<br>');
  Result = StringReplace(Result, '\n', '<br>');

  Result = StringReplace(Result, '\r\n', '<br>');
  //Result := PubString.StrPlace(Result, ' ', '&nbsp;');
  return Result;
}

//需要引用 https://cdnjs.cloudflare.com/ajax/libs/big-integer/1.6.32/BigInteger.min.js
 var Snowflake = /** @class */ (function() {
    function Snowflake(_workerId, _dataCenterId, _sequence) {
        // this.twepoch = 1288834974657;
        this.twepoch = 0;
        this.workerIdBits = 5;
        this.dataCenterIdBits = 5;
        this.maxWrokerId = -1 ^ (-1 << this.workerIdBits); // 值为：31
        this.maxDataCenterId = -1 ^ (-1 << this.dataCenterIdBits); // 值为：31
        this.sequenceBits = 12;
        this.workerIdShift = this.sequenceBits; // 值为：12
        this.dataCenterIdShift = this.sequenceBits + this.workerIdBits; // 值为：17
        this.timestampLeftShift = this.sequenceBits + this.workerIdBits + this.dataCenterIdBits; // 值为：22
        this.sequenceMask = -1 ^ (-1 << this.sequenceBits); // 值为：4095
        this.lastTimestamp = -1;
        //设置默认值,从环境变量取
        this.workerId = 1;
        this.dataCenterId = 1;
        this.sequence = 0;
        if (this.workerId > this.maxWrokerId || this.workerId < 0) {
            throw new Error('config.worker_id must max than 0 and small than maxWrokerId-[' + this.maxWrokerId + ']');
        }
        if (this.dataCenterId > this.maxDataCenterId || this.dataCenterId < 0) {
            throw new Error('config.data_center_id must max than 0 and small than maxDataCenterId-[' + this.maxDataCenterId + ']');
        }
        this.workerId = _workerId;
        this.dataCenterId = _dataCenterId;
        this.sequence = _sequence;
    }
    Snowflake.prototype.tilNextMillis = function(lastTimestamp) {
        var timestamp = this.timeGen();
        while (timestamp <= lastTimestamp) {
            timestamp = this.timeGen();
        }
        return timestamp;
    };
    Snowflake.prototype.timeGen = function() {
        //new Date().getTime() === Date.now()
        return Date.now();
    };
    Snowflake.prototype.nextId = function() {
        var timestamp = this.timeGen();
        if (timestamp < this.lastTimestamp) {
            throw new Error('Clock moved backwards. Refusing to generate id for ' +
                (this.lastTimestamp - timestamp));
        }
        if (this.lastTimestamp === timestamp) {
            this.sequence = (this.sequence + 1) & this.sequenceMask;
            if (this.sequence === 0) {
                timestamp = this.tilNextMillis(this.lastTimestamp);
            }
        } else {
            this.sequence = 0;
        }
        this.lastTimestamp = timestamp;
        var shiftNum = (this.dataCenterId << this.dataCenterIdShift) |
            (this.workerId << this.workerIdShift) |
            this.sequence; // dataCenterId:1,workerId:1,sequence:0  shiftNum:135168
        var nfirst = new bigInt(String(timestamp - this.twepoch), 10);
        nfirst = nfirst.shiftLeft(this.timestampLeftShift);
        var nnextId = nfirst.or(new bigInt(String(shiftNum), 10)).toString(10);
        return nnextId;
    };
    return Snowflake;
}());

function GetSnowID(){ //console.time(); console.timeEnd();
  var tempSnowflake = new Snowflake(1, 1, 0);
  return tempSnowflake.nextId() + "" + Math.floor(Math.random()*10);
}

//专为初始check或radio
var mds_check_radio=getDS();
mds_check_radio.Fields.Add("rowid");
mds_check_radio.Fields.Add("name");
mds_check_radio.Fields.Add("atype");
mds_check_radio.Fields.Add("formid");
mds_check_radio.Fields.Add("value");
mds_check_radio.Fields.Add("myvalue");

function IniCheckOrRadio(){
  mds_check_radio.First();
  while (!mds_check_radio.Eof){
    if(mds_check_radio.V("atype") == '1'){ //checkbox
      if(('1' == mds_check_radio.V("value"))||('on' == mds_check_radio.V("value"))){
        PubSv_Cell(true,mds_check_radio.V("formid"),mds_check_radio.V("rowid"),mds_check_radio.V("name"))
      }else{
        PubSv_Cell(false,mds_check_radio.V("formid"),mds_check_radio.V("rowid"),mds_check_radio.V("name"));//pubsv(mds_check_radio.V("name"),false,mds_check_radio.V("formid"),"","[rowid='" + mds_check_radio.V("rowid") + "']");
      }
    } else
    if(mds_check_radio.V("atype") == '3'){ //checkbox
       PubSv_Cell(mds_check_radio.V("value"),mds_check_radio.V("formid"),mds_check_radio.V("rowid"),mds_check_radio.V("name"))
    }else
    ////' $("' + FForm_Type + '[id=''' + FForm_id +  '''] [name=''' + FName + ''']").attr("src", mds.V("' + FN + '"));';
    if(mds_check_radio.V("atype") == '4'){ //checkbox
       //PubGo_Cell(gridid,rowid,FieldName,addstr)
       if(trim(mds_check_radio.V("value")) != "")
       PubGo_Cell(mds_check_radio.V("formid"),mds_check_radio.V("rowid"),mds_check_radio.V("name")).attr("src", mds_check_radio.V("value"));
    }else{
      if(mds_check_radio.V("myvalue") == mds_check_radio.V("value")){
        PubSv_Cell(mds_check_radio.V("myvalue"),mds_check_radio.V("formid"),mds_check_radio.V("rowid"),mds_check_radio.V("name"))
      };
    }
    mds_check_radio.Next();
  }
}

function b64Encode(str) {
    return btoa(str);
}
function b64Decode(text) {
  if((Pos(',',text)<1)||(Pos('=', text) == length(text)))
  {
    text = StringReplace(text,'\r\n','');
    text = decodeURIComponent(escape(window.atob(text)));//atob(text);
    return text;
  }else{
    return text;
  }
}
function base64Decode(str){
  return b64Decode(str);
}
 function getFieldSize(one){
   one = GetDeliBack(one, '@3#');
   return GetDeliPri(one, '@4#');
 }
 function getMustInput(one){
   one = GetDeliBack(one, '@4#');
   return GetDeliPri(one, '@5#');
 }
 function getMustInputHint(one){
   one = GetDeliBack(one, '@5#');
   return GetDeliPri(one, '@6#');
 }
 function GetRField(F)
 {
   F = GetDeliPri(F, '=');
   return GetDeliBack(F, '*');
 }
 function GetCField(F)
 {
   F = GetDeliBack(F, '@0#');
   return GetDeliPri(F, '@1#');
 }
 function GetDataType(F){
   F = GetDeliBack(F, '=');
   return GetDeliPri(F, '@0#');
 }
 function IsIntFloat(DataType)
 {
   DataType = GetDataType(DataType);
   return ( (DataType == 'ftInteger') || (DataType == 'ftCurrency') || (DataType == 'ftFMTBcd') ||
      (DataType == 'ftSmallint') || (DataType == 'ftShortint') ||
      (DataType == 'ftLargeint') || (DataType == 'ftBCD') || (DataType == 'ftFloat') );
 }
 function IsDatetime(DataType)
 {
   DataType = GetDataType(DataType);
   return ( (DataType == 'ftDate') || (DataType == 'ftTime') || (DataType == 'ftDateTime') );
 }
function getType(o){
  //(*
  var t=o.attr("type")//||(o.attr("tagName"))
  if((t=="radio")||(t=="checkbox")){
  }else{
    if(o!=mynull)
    {
      try{
        t=o[0].tagName
      }catch(e){}
    }
  }
  if(StrValueIsNull(t))t=""
    t=t.toLowerCase()
  return t; //*)
}

 ///////////////////////////////////////////
 function PubGoEx_Cell(gridid,rowid,FieldName,att){
  if(StrValueIsNull(att)){att=""}
  //var o = $("[id='"+gridid+"'] [rowid='"+rowid+"'] [fieldname='" + FieldName + "']" + att);
  //if(o.length<1){o = $("[name='"+gridid+"'] [rowid='"+rowid+"'] [name='" + FieldName + "']" + att);}

  var o = $("[id='"+gridid+"'] [rowid='"+rowid+"'] [name='" + FieldName + "']" + att);
  if(o.length<1){o = $("[id='"+gridid+"'] [rowid='"+rowid+"'] [fieldname='" + FieldName + "']" + att)};
  if(o.length<1){o = $("[name='"+gridid+"'] [rowid='"+rowid+"'] [name='" + FieldName + "']" + att);}
  return o;
}
function PubGo_Cell(gridid,rowid,FieldName,addstr){ //取对象
  if(StrValueIsNull(addstr)){addstr=""}
  var o = PubGoEx_Cell(gridid,rowid,FieldName,addstr);
  var t = o.attr("type");
  if((t=="radio")||(t=="checkbox")){
    o = PubGoEx_Cell(gridid,rowid,FieldName,addstr+":checked");
  }
  return o;
}

function PubGv_Cell(gridid,rowid,FieldName,addstr){ //取值
  var o = PubGo_Cell(gridid,rowid,FieldName,addstr);
  t=getType(o);
  var v = "";
  if(needval_tag(t)||(t=="radio")||(t=="checkbox")){
    v=o.val()
  }else
  {
    v=o.text();
  }
  if(StrValueIsNull(v)){v=""}
  return v;
}

//赋值  对于radio,mysetvalue为value值, 因是单选，只需要设置true值，不需要false
function PubSv_Cell(mysetvalue,gridid,rowid,FieldName,attr){
  if(StrValueIsNull(attr)){attr=""}
  var o = PubGoEx_Cell(gridid,rowid,FieldName,attr + "");
  var t = getType(o)

  if((t=="radio")||(t=="checkbox")){
    if(t=="radio"){
       o = PubGoEx_Cell(gridid,rowid,FieldName,'[value="' + mysetvalue +'"]');
       o.next('div').click();//layui专用
       o.prop("checked",true);//普通的radiobox专用
    } else
    { //checkbox

       if(StrValueIsNull(mysetvalue)) {mysetvalue=true}
       //var v = PubGv(myname,oweridOrname,mytag);
       var v = PubGv_Cell(gridid,rowid,FieldName,attr)
       if(((v=='1')||(v=='on'))){
         if(!mysetvalue){
           o.next('div').click();//layui专用
         }
       } else{
         if(mysetvalue){
           o.next('div').click();//layui专用
         }
       }
       o.prop("checked",mysetvalue);//普通的checkbox专用
    }
  } else {
    if(needval_tag(t)){
      o.val(mysetvalue)
    }else
      o.text(mysetvalue);
  }
}
function needval_tag(t){
  return (t=="input")||(t=="select")||(t=="textarea");
}
//赋值 通过rowid
function pubsv_cell(mysetvalue,gridid,rowid,FieldName,attr){
  return PubSv_Cell(mysetvalue,gridid,rowid,FieldName,attr)
}
//同pubsv_cell
function pubsv_cell_rowid(mysetvalue,gridid,rowid,FieldName,attr){
  return pubsv_cell(mysetvalue,gridid,rowid,FieldName,attr)
}
//赋值 通过rowindex
function pubsv_cell_index(mysetvalue,gridid,index,FieldName,attr){
  var rowid=getgridrowid(gridid,index);
  return PubSv_Cell(mysetvalue,gridid,rowid,FieldName,attr)
}
//同pubsv_cell_index
function pubsv_cell_row(mysetvalue,gridid,index,FieldName,attr){
  return pubsv_cell_index(mysetvalue,gridid,index,FieldName,attr)
}
// function MyGetValue(Text,Form_id,rowid)
// {
//   var F = GetRField(Text)
//   if(StrValueIsNull(rowid)){
//     return pubgv(F, Form_id);
//   }else{
//     return pubgv(F,Form_id,"","[rowid='" + rowid + "']");
//   }
// }

function MyGetValue(Text,gridid,rowid)
 {
   var F = GetRField(Text)
   if(StrValueIsNull(rowid)){
     return pubgv(F, gridid);
   }else{
     return PubGv_Cell(gridid,rowid,F);//pubgv(F,Form_id,"","[rowid='" + rowid + "']");
   }
 }
 ///////////////////////////////////////////

 //获取一个表格的数据
 function GetOneGridData(fnew_data, gridid, IsMain){       /////alert(IsMain);
  if(StrValueIsNull(gridid)) gridid = mxgrid_id; //2022-07-27 add
  if(StrValueIsNull(gridid)){
    mymsg("绑定对象为空，不能继续！{01}");
    return false;
  }
  var SL = getSLEx(b64Decode($("[id='" + gridid + "'] input[name='Fields']").val()));
  if(SL.length==0){
    SL = getSLEx(b64Decode($("[name='" + gridid + "'] input[name='Fields']").val()));
  }
  var Count = SL.length;
  var mds=getDS();
  var AllFields2 = "";
  for ( var I=0 ; I < Count; ++I )
  {
   var F = trim(GetRField(SL[I]).toLowerCase())
   if(Pos("," + F + ",", AllFields2) < 1) {
      mds.Fields.Add(F);
   }
   AllFields2 = AllFields2 + "," + F + ","
  }
  mds.Fields.Add("fnew_data");
  if(IsMain){
    var RecordCount = 1;//getSLEx(pubgv('RowCount',gridid));
  }else{
    var RecordCount = getgridrowcount(gridid); //getSLEx(pubgv('RowCount',gridid));
  }
  var rows=$("[id='" + gridid + "'] [isgridrow='true'][need='true']");
  for ( var R=1; R <= RecordCount; ++R )
  {
     var rowid='';
     if(!IsMain){rowid=$(rows[R-1]).attr('rowid');}
     mds.Append();
     for(var lp = 0; lp < mds.Fields.list.length; lp ++)
     {
      var FieldName = mds.Fields.list[lp].FieldName;
      var V=GetGridOneCellValue(gridid,rowid,FieldName,IsMain);//pubgv(FieldName,gridid,"","[rowid='" + R + "']");
      mds.S(FieldName,V);

     }
     if(IsMain){ //注意，当前只给表头的fnew_data赋值，明细表不赋值
       mds.S("fnew_data", fnew_data);
     }
  }
  //if(IsMain){     //alert(fnew_data);
  //  mds.S("fnew_data", fnew_data);
  //}
  return mds;
}
//记录当前页面的全部信息，与GetOneGridAllData基本相同，不同的是不取表格数据
var DsArea;
var maindataarea_id="";
var mxgrid_id="";
function GetOneDataArea(fnew_data, formid, CName, IsMain){ //获取一个表格的所有数据，包括所有关键字，字段属性，调用方法 var ds = GetOneGridAllData(ds,'yyyyyyyy');
  if(StrValueIsNull(DsArea)){
    DsArea=getDS();
    DsArea.Fields.Add('Name');
    DsArea.Fields.Add('CName');
    DsArea.Fields.Add('ismx');
    DsArea.Fields.Add('mxmainkeys');
    DsArea.Fields.Add('Fields');
    DsArea.Fields.Add('db_form_info');
    //ds.Fields.Add('Data');
    DsArea.Fields.Add('AType');
  }
  //var mds = GetOneGridData(fnew_data, formid, IsMain);
  DsArea.Append();
  //if(StrValueIsNull(ismx)){ismx=""}
  //if(StrValueIsNull(mxmainkeys)){mxmainkeys=""}
  if(StrValueIsNull(CName)){CName=""}

  DsArea.S('Name',formid);
  DsArea.S('CName',CName);
  DsArea.S('Fields',b64Decode(pubgv("Fields",formid)));
  DsArea.S('db_form_info',pubgv("db_form_info",formid));
  DsArea.S('ismx',pubgv("ismx",formid));
  DsArea.S('mxmainkeys',pubgv("mxmainkeys",formid));
  //DsArea.S('Data',mDsArea.GetCommaText());     //mainform_Form_Read_ini
  //alert(DsArea.RecordCount() + '=' + formid)   //Formid + 'mainform_Form  _Read_ini();  '
  if(IsMain){
    maindataarea_id=formid;
    DsArea.S('AType','1')
  } else
  { mxgrid_id=formid;}
  //return ds;
}

//获取一个表格的数据 var mds = GetOneGridData('yyyyyyyy');
function GetOneGridAllData(fnew_data, ds, formid, CName, IsMain){ //获取一个表格的所有数据，包括所有关键字，字段属性，调用方法 var ds = GetOneGridAllData(ds,'yyyyyyyy');
  if(StrValueIsNull(ds)){
    ds=getDS();
    ds.Fields.Add('Name');
    ds.Fields.Add('CName');
    ds.Fields.Add('ismx');
    ds.Fields.Add('mxmainkeys');
    ds.Fields.Add('Fields');
    ds.Fields.Add('db_form_info');
    ds.Fields.Add('Data');
    ds.Fields.Add('AType');
  }
  var mds = GetOneGridData(fnew_data, formid, IsMain);
  ds.Append();
  //if(StrValueIsNull(ismx)){ismx=""}
  //if(StrValueIsNull(mxmainkeys)){mxmainkeys=""}
  if(StrValueIsNull(CName)){CName=""}

  ds.S('Name',formid);
  ds.S('CName',CName);
  ds.S('Fields',b64Decode(pubgv("Fields",formid)));
  ds.S('db_form_info',pubgv("db_form_info",formid));
  ds.S('ismx',pubgv("ismx",formid));
  ds.S('mxmainkeys',pubgv("mxmainkeys",formid));
  ds.S('Data',mds.GetCommaText());
  //alert(ds.GetCommaText())
  if(IsMain){
    maindataarea_id=formid;
    ds.S('AType','1')
  }
  return ds;
}

function CheckMainKeyValueIsNull(gridid){
  if(!StrValueIsNull(gridid)){
    var SL = getSLEx($("[id='" + gridid + "'] input[name='KeyWords']").val());
    var Count = SL.length;
    for ( var I=0 ; I < Count; ++I ){
      if (trim($("[id='" + maindataarea_id + "'] [name='" + SL[I] + "']").val()) ==''){
        mymsg("请先新建！");
        return false;
      };
    }
  }
  return true;
}

function CheckOneGrid(gridid,CName,IsMain){

  if(IsMain){if(!CheckMainKeyValueIsNull(gridid)) return false;}

  $("[id='" + gridid + "'] [need='false']").attr("need","true").show();
  SetGridRow_background_color(gridid)

  var SL = getSLEx(b64Decode($("[id='" + gridid + "'] input[name='Fields']").val()));
  if(SL.length==0){
    SL = getSLEx(b64Decode($("[name='" + gridid + "'] input[name='Fields']").val()));
  }
  var Count = SL.length;
  var AllErr = "";
  if(IsMain){
    var RecordCount = 1;
  }else{
    var RecordCount = getgridrowcount(gridid); //getSLEx(pubgv('RowCount',gridid));
  }
  var rows=$("[id='" + gridid + "'] [isgridrow='true'][need='true']");
  for ( var R=1; R <= RecordCount; R ++)
  {
     var rowid='';
     if(!IsMain){rowid=$(rows[R-1]).attr('rowid');}
     //alert(rowid + '->' + R);
     for ( var I=0 ; I < Count; ++I )
     {
       if (getMustInput(SL[I]) == '1')
       {
         if(IsMain){
           var val = MyGetValue(SL[I],gridid);
           var rowhint=""
         }else{
           var val = MyGetValue(SL[I],gridid,rowid);
           var rowhint="第[" + R + "]行"
         }
         var size = getFieldSize(SL[I]);
         if((size > '0')&&(Length(val) > size))
         {
            AllErr = AllErr + '<br>' + CName + rowhint + '[' + GetCField(SL[I]) + ']值长度为[' + Length(val) + ']超[' + size + ']，不能保存！';
         }
         if(IsIntFloat(SL[I]))
         {
           if (NValueIsNull(val))
           {
             if(trim(getMustInputHint(SL[I])) != "") {
               AllErr = AllErr + '<br>' + CName + rowhint + getMustInputHint(SL[I]);
             } else {
               AllErr = AllErr + '<br>' + CName + rowhint + '[' + GetCField(SL[I]) + ']值为空，不能保存！';
             }
           }
         } else{
           if (StrValueIsNull(val))
           {
           if(trim(getMustInputHint(SL[I])) != "") {
               AllErr = AllErr + '<br>' + CName + rowhint + getMustInputHint(SL[I]);
             } else {
               AllErr = AllErr + '<br>' + CName + rowhint + '[' + GetCField(SL[I]) + ']值为空，不能保存！';
             }
           }
         }
       }
     }
  }
 if (trim(AllErr) != "")
 {
   MyAlert(AllErr);
   return false;
 }
 return true;
}

function DeReplaceText_Jsreturn(js){
  js = StringReplace(js, "[@@@@]", '\r\n');
  return js
}

//用于表格行计算，如某个单元格的数等于别的单元格计算而为来
function startrowcaljs(gridid,f,value){
  if(StrValueIsNull(gridid)) gridid = mxgrid_id; //2022-07-27 add
  if(StrValueIsNull(gridid)){
    mymsg("绑定对象为空，不能继续！{02}");
    return false;
  }
  if(StrValueIsNull(f)) f=""
  if(StrValueIsNull(value)) value=""

  var js=PubGv('onrowcaljs',gridid);
  js=DeReplaceText_Jsreturn(js)
  if(trim(js)!="") eval(js);
}
//汇总事件，注意，只有是单元格输入时 FieldName、value才有值，其他可能是初始化、删除行、插入行等发生
function startsumvent(gridid,FieldName,value){
  if(StrValueIsNull(gridid)) gridid = mxgrid_id; //2022-07-27 add
  if(StrValueIsNull(gridid)){
    mymsg("绑定对象为空，不能继续！{04}");
    return false;
  }
  if(StrValueIsNull(FieldName)) FieldName=""
  if(StrValueIsNull(value)) value=""

  //自动汇总
  var SLType = getSLEx(b64Decode($("[id='" + gridid + "'] input[name='Fields']").val()));
  if(SLType.length==0){
    SLType = getSLEx(b64Decode($("[name='" + gridid + "'] input[name='Fields']").val()));
  }

  var fields=PubGv('sumfields',gridid);
  fields=StringReplace(fields,';','\r\n');
  fields=StringReplace(fields,'；','\r\n');
  fields=StringReplace(fields,',','\r\n');
  fields=StringReplace(fields,'，','\r\n');
  var sl=getSL("");
  sl.SetText(fields);
  var slnum=getSL("");
  var slnumdata=getSL("");
  for(var lp=0 ; lp < sl.Count(); ++ lp){
    fields=sl.SL[lp];
    if(IsNumfromSL(SLType,GetDeliBack(fields, '='))){
      slnum.Add(sl.SL[lp])
      slnumdata.Add("0")
    }else{//是字符类型的字段，只显示记录数
      //暂不要gridid pubsv(GetDeliPri(fields, '='),getgridrowcount(gridid),gridid);
      pubsv(GetDeliPri(fields, '='),getgridrowcount(gridid));
    }
  }
  //计算
  var RecordCount = getgridrowcount(gridid)
  var rows=$("[id='" + gridid + "'] [isgridrow='true'][need='true']");
  for ( var R=1; R <= RecordCount; ++R )
  {
     var rowid=rowid=$(rows[R-1]).attr('rowid');

     for(var lp=0 ; lp < slnum.Count(); ++ lp){
       fields=slnum.SL[lp];
       var f=GetDeliBack(fields, '=')
       slnumdata.SL[lp]=ad(slnumdata.SL[lp],PubGv_Cell(gridid,rowid,f)); // alert(fields)
     }
  }
  for(var lp=0 ; lp < slnum.Count(); ++ lp){
    var fields=slnum.SL[lp];
    var f=GetDeliPri(fields, '=')
    //暂不要gridid pubsv(f,slnumdata.SL[lp],gridid);
    pubsv(f,slnumdata.SL[lp]);
  }

  var js=PubGv('onsumjs',gridid);
  js=DeReplaceText_Jsreturn(js)
  if(trim(js)!="") eval(js);
}

function startsetrowid(gridid,obj)
{
    if((trim($(obj).attr('rowid'))!="")|| (trim($(obj).attr('rowid'))!=getgridselrowid(gridid)) ){
      setgridselrowid(gridid,$(obj).attr('rowid'));
      SetGridRow_background_color(gridid,false);
    }
}

function bindgridevent(gridid,needsum){
  if(StrValueIsNull(gridid)) gridid = mxgrid_id; //2022-07-27 add
  if(StrValueIsNull(gridid)){
    mymsg("绑定对象为空，不能继续！{05}");
    return false;
  }
  $("[id='" + gridid + "'] [isgridrow='true']").click(function() {
    startsetrowid(gridid,this)
    //SetGridSelectRow_background_color(gridid);
  })
  $("[id='" + gridid + "'] [isgridrow='true']").keyup(function() {
    startsetrowid(gridid,this)
    //SetGridSelectRow_background_color(gridid);
  })

  $("[id='" + gridid + "'] [isgridcell='true']").click(function() {
    if(trim($(this).attr('fieldname'))!="") setgridselfieldname(gridid,$(this).attr('fieldname'));
    var js=PubGv('onclickjs',gridid);
    js=DeReplaceText_Jsreturn(js)
    if(trim(js)!="") eval(js);
  })

  $("[id='" + gridid + "'] [isgridrow='true']").mousedown(function() {
    //setgridselfieldname(gridid,$(this).attr('fieldname'));
    //SetGridRow_background_color(gridid,false);
    startsetrowid(gridid,this)
  })

  $("[id='" + gridid + "'] [isgridcell='true']").keyup(function() {
    setgridselfieldname(gridid,$(this).attr('fieldname'));

    var js=PubGv('onkeyupjs',gridid);
    js=DeReplaceText_Jsreturn(js)
    if(trim(js)!="") eval(js);
  })
  $("[id='" + gridid + "'] [isgridcell='true']").on("input",function(e){
    //获取input输入的值console.log(e.delegateTarget.value);
    if(trim($(this).attr('fieldname'))!="") setgridselfieldname(gridid,$(this).attr('fieldname'));
    var f=$(this).attr('fieldname') || getgridselfieldname(gridid)
    var value=e.delegateTarget.value
    var js=PubGv('onchangejs',gridid);
    js=DeReplaceText_Jsreturn(js)
    if(trim(js)!=""){
      if(trim(f) == "") msg("注意：取到的字段名称为空，不能执行计算！请重试！")
      eval(js);
    }

    startrowcaljs(gridid,f,value)

    //如果是输入的话 是数值类型才要计算
    if(IsIntFloat(GetFieldType(gridid,f)))startsumvent(gridid,f,value);
  });

  //在SetGridRow_background_color中执行 startsumvent(gridid);
  SetGridRow_background_color(gridid,needsum)
}

function gridinsertrow(gridid,rowid,pos,needsetpos,needsum,needautofillsno){
  if(StrValueIsNull(gridid)) gridid = mxgrid_id; //2022-07-27 add
  if(StrValueIsNull(gridid)){
    mymsg("绑定对象为空，不能继续！{06}");
    return false;
  }
    var html = b64Decode(pubgv(gridid + 'Grid_1_Script'));
    var newrowid=GetClientUniqueCode();
    html = StringReplace(html,'@rowid@',newrowid)

    //2023-04-24 @z-index@
    var RecordCount = getgridrowcount(gridid)
    html = StringReplace(html,'@z-index@',10000-RecordCount)

    //选择行设置为当前插入rowid
    if(needsetpos){setgridselrowid(gridid,newrowid)};
    var el = $(html);
    if(pos==0)
    {
      getgridrowobj(gridid,rowid).before(el)
    }else
    if(pos==1)
    {
      getgridrowobj(gridid,rowid).after(el)
    }else{
      if( $("[id='" + gridid + "'] [isgridfooter='true']").length > 0){
        $("[id='" + gridid + "'] [isgridfooter='true']").before(el);
      }else{
        PubGo(gridid).append(el);
      }
    }
    layrender();
    bindgridevent(gridid);
    //设置默认值 '_ini();
    var js=gridid + '_Read_ini("' + newrowid + '",1)';
    eval(js);
    SetGridRow_background_color(gridid,needsum)
    if(needautofillsno) autofillsno(gridid)
    //在SetGridRow_background_color中执行  startsumvent(gridid);
}
//在当标位置前插入一行
function gridinsertrow_before(gridid,needsetpos,needsum,needautofillsno){
  if (StrValueIsNull(needautofillsno)){needautofillsno=true}
  if (StrValueIsNull(needsetpos)){needsetpos=true}
  if(GetGridRowCount(gridid)==0){
    return gridinsertrow_last(gridid,needsetpos,needsum,needautofillsno)
  }
  if(getgridselrowid(gridid)==""){mymsg('请选择插入的行！');return false}
  gridinsertrow(gridid,getgridselrowid(gridid),0,needsetpos,needsum,needautofillsno)
  return true;
}
//在当标位置前插入一行2，最后一行在最后追加
function gridinsertrow_before2(gridid,needsetpos,needsum,needautofillsno){
  if(getgridrowindex(gridid,getgridselrowid(gridid))==GetGridRowCount(gridid))
    gridinsertrow_last(gridid,needsetpos,needsum,needautofillsno)
  else
    gridinsertrow_before(gridid,needsetpos,needsum,needautofillsno);
}
//在当标位置后插入一行
function gridinsertrow_after(gridid,needsetpos,needsum,needautofillsno){
  if (StrValueIsNull(needautofillsno)){needautofillsno=true}
  if (StrValueIsNull(needsetpos)){needsetpos=true}
  if(GetGridRowCount(gridid)<2){
    return gridinsertrow_last(gridid,needsetpos,needsum,needautofillsno)
  }
  if(getgridselrowid(gridid)==""){mymsg('请选择插入的行！');return false}
  gridinsertrow(gridid,getgridselrowid(gridid),1,needsetpos,needsum,needautofillsno)
  return true;
}
//在当标位置后插入一行2，第一行在当前前面插入
function gridinsertrow_after2(gridid,needsetpos,needsum,needautofillsno){
  if(getgridrowindex(gridid,getgridselrowid(gridid))==1)
    gridinsertrow_before(gridid,needsetpos,needsum,needautofillsno)
  else
    gridinsertrow_after(gridid,needsetpos,needsum,needautofillsno);
}
//在表格最后插入一行
function gridinsertrow_last(gridid,needsetpos,needsum,needautofillsno){
  if (StrValueIsNull(needsetpos)){needsetpos=true}
  if (StrValueIsNull(needautofillsno)){needautofillsno=true}
  gridinsertrow(gridid,'',2,needsetpos,needsum,needautofillsno)
  return true;
}
//删除表格一行
function griddeleterow(gridid,rowid,needsum){
  if(StrValueIsNull(gridid)) gridid = mxgrid_id; //2022-07-27 add
  if(StrValueIsNull(gridid)){
    mymsg("绑定对象为空，不能继续！{07}");
    return false;
  }
  getgridrowobj(gridid,rowid).remove();
  //在SetGridRow_background_color中执行  startsumvent(gridid);
  return true;
}
//删除光标所行
function griddeleteselrow(gridid,needsum){
  if(StrValueIsNull(gridid)) gridid = mxgrid_id; //2022-07-27 add
  if(StrValueIsNull(gridid)){
    mymsg("绑定对象为空，不能继续！{08}");
    return false;
  }
  var rowid=getgridselrowid(gridid);
  if(rowid==""){mymsg('请选择待删除的行！');return false}
  var rowindex=getgridrowindex(gridid,rowid);
  //开始删除
  griddeleterow(gridid,rowid);

  if(getgridrowcount(gridid) < rowindex)
  {  rowindex=rowindex-1;}

  rowid=getgridrowid(gridid,rowindex);

  if(trim(rowid)==''){
    setgridselrowid(gridid,"");
    setgridselfieldname(gridid,"");
  }else{
    setgridselrowid(gridid,rowid);
  }
  autofillsno(gridid)
  SetGridRow_background_color(gridid,needsum)
  return true;
}
//设置表格选择中行和字段
function setgridselrowid(gridid,value){
  PubSv(gridid + 'selrowid',value)
}
//设置表格某行某单元格选择
function setgridrowindexsel(gridid,rowindex,fieldname){
  var rowid=getgridrowid(gridid,rowindex)
  if(!StrValueIsNull(fieldname)) setgridselfieldname(gridid,fieldname)
  setgridselrowid(gridid,rowid);
  SetGridRow_background_color(gridid,false);
}

function setgridselfieldname(gridid,value){
  PubSv(gridid + 'selfieldname',value)
}
//获取表格选中的行
function getgridselrowid(gridid){
  if(StrValueIsNull(gridid)) gridid = mxgrid_id; //2022-07-27 add
  if(StrValueIsNull(gridid)){
    mymsg("绑定对象为空，不能继续！{09}");
    return false;
  }
  return PubGv(gridid+'selrowid')
}
//获取表格选中的字段
function getgridselfieldname(gridid){
  if(StrValueIsNull(gridid)) gridid = mxgrid_id; //2022-07-27 add
  if(StrValueIsNull(gridid)){
    mymsg("绑定对象为空，不能继续！{10}");
    return false;
  }
  return PubGv(gridid+'selfieldname')
}
//清空表格
function ClearGrid(gridid){
  if(StrValueIsNull(gridid)) gridid = mxgrid_id; //2022-07-27 add
  if(StrValueIsNull(gridid)){
    mymsg("绑定对象为空，不能继续！{11}");
    return false;
  }
  var rows=$("[id='" + gridid + "'] [isgridrow='true']");
  rows.remove();
  startsumvent(gridid)
}
//获取表格的行数
function GetGridRowCount(gridid){
  if(StrValueIsNull(gridid)) gridid = mxgrid_id; //2022-07-27 add
  if(StrValueIsNull(gridid)){
    mymsg("绑定对象为空，不能继续！{12}");
    return false;
  }
  var rows=$("[id='" + gridid + "'] [isgridrow='true'][need='true']");
  return rows.length;
  //return PubGo('gridrow',gridid).length;
}
function getgridrowcount(gridid){
  return GetGridRowCount(gridid);
}
 //根据行号获取rowid
function getgridrowid(gridid,rowindex){
  if(StrValueIsNull(gridid)) gridid = mxgrid_id; //2022-07-27 add
  var rows=$("[id='" + gridid + "'] [isgridrow='true'][need='true']");
  var v=$(rows[rowindex-1]).attr('rowid');
  if (StrValueIsNull(v)){v=''}
  return v;
}
//根据行id取行号
function getgridrowindex(gridid,rowid){
  if(StrValueIsNull(gridid)) gridid = mxgrid_id; //2022-07-27 add
  var rows=$("[id='" + gridid + "'] [isgridrow='true'][need='true']");
  for(var i = 0; i < rows.length; i++) {
    if($(rows[i]).attr('rowid')==rowid){return i+1;}
  }
  return -1;
}
//根据行id取行对象
function getgridrowobj(gridid,rowid){
  if(StrValueIsNull(gridid)) gridid = mxgrid_id; //2022-07-27 add
  var rows=$("[id='" + gridid + "'] [isgridrow='true'][need='true']");
  for(var i = 0; i < rows.length; i++) {
    if($(rows[i]).attr('rowid')==rowid){return $(rows[i]);}
  }
  return mynull;
}
//通过行号rowindex读取表格一个单元格的值
function GetGridOneCellData_Index(gridid,rowindex,FieldName, IsMain){
  if(IsMain){
    return pubgv(FieldName,gridid,"");
  }else{
    if(StrValueIsNull(gridid)) gridid = mxgrid_id; //2022-07-27 add
    //return pubgv(FieldName,gridid,"","[rowid='" + rowid + "']");
    return PubGv_Cell(gridid,getgridrowid(gridid,rowindex),FieldName); // ($("[id='"+gridid+"'] [rowid='"+rowid+"'] [name='" + FieldName + "']").val())
  }
}
//通过表格单元格rowid读取表格一个单元格的值
function GetGridOneCellValue(gridid,rowid,FieldName, IsMain){
  if(IsMain){
    return pubgv(FieldName,gridid,"");
  }else{
    if(StrValueIsNull(gridid)) gridid = mxgrid_id; //2022-07-27 add
    //return pubgv(FieldName,gridid,"","[rowid='" + rowid + "']");
    return PubGv_Cell(gridid,rowid,FieldName); // ($("[id='"+gridid+"'] [rowid='"+rowid+"'] [name='" + FieldName + "']").val())
  }
}
//取光标所在单元格的值
function GetGridSelCellValue(gridid){
  return GetGridOneCellValue(gridid,getgridselrowid(gridid),$(this).attr('fieldname') || getgridselfieldname(gridid), false);
}
function GetJQueryChildren(a,f)
{ //递归算法
  var crs=$($(a).children())
  var Count = crs.length;
  for ( var lp=0 ; lp < Count; ++lp){
    var t=$(crs[lp]);
    //alert(Count + '--' + 'lp:' + lp + '|' + t.length + '==' + t.attr('fieldname') + '->' + f)
    if(t.attr('fieldname')==f){
        return t.val();
    }
    if(t.length > 0)
     GetJQueryChildren(t,f)
  }
}

//知道父元素，再找子元素对应字段的值
function GetOneSortValueEx(a,o, FieldName,tagname){
    var valveNumOfa
    var t=getType(o)

    if((t=="radio")||(t=="checkbox")){
      valveNumOfa =  $(a).find('[' + tagname + '="' + FieldName + '"]:checked').val()
    }else{
      if(needval_tag(t)){
        valveNumOfa = o.val()
      }else
        //if(o.val())
        //  valveNumOfa = o.val()
        //else
          valveNumOfa = o.text();
    }
    if(StrValueIsNull(valveNumOfa))valveNumOfa=""
    return valveNumOfa;
}
function GetOneSortValue(a, FieldName){
   var o=$(a).find('[name="' + FieldName + '"]')

   if(o.length > 0){
     if(o.length>1) mymsg('name为['+FieldName+']有多个元素，不符合排序规则，请修改后继续！');
     return GetOneSortValueEx(a, o, FieldName,'name')
   }else{
     var o=$(a).find('[fieldname="' + FieldName + '"]')
     if(o.length>1) mymsg('fieldname为['+FieldName+']有多个元素，不符合排序规则，请修改后继续！');
     return GetOneSortValueEx(a, o, FieldName,'fieldname')
   }
}

function IsNumfromSL(SLType,FieldName){
   var isNum = false
   var Count = SLType.length;
   for ( var I=0 ; I < Count; ++I ){
      var F = trim(GetRField(SLType[I]).toLowerCase())
      if(F==FieldName.toLowerCase()){
        isNum = IsIntFloat(SLType[I]);
        break;
      }
   }
   return isNum;
}

//获取一个字段的数据类型
function GetFieldType(gridid,FieldName){
    var SLType = getSLEx(b64Decode($("[id='" + gridid + "'] input[name='Fields']").val()));
    if(SLType.length==0){
      SLType = getSLEx(b64Decode($("[name='" + gridid + "'] input[name='Fields']").val()));
    }
    var Count = SLType.length;
    for ( var I=0 ; I < Count; ++I ){
      var F = trim(GetRField(SLType[I]).toLowerCase())
      if(F==FieldName.toLowerCase()){
        return GetDataType(SLType[I]);
      }
    }
}

//排序，把持多字段多种方式  GridSort('yyyyyyyy','sel,count desc')
function GridSort(gridid,FieldName,desc,isNum){
  if(StrValueIsNull(gridid)) gridid = mxgrid_id; //2022-07-27 add
  if(StrValueIsNull(gridid)){
    mymsg("绑定对象为空，不能继续！{14}");
    return false;
  }
    var SL=getSL();
    var t=StringReplace(FieldName,',','\r\n')
    t=StringReplace(t,'，','\r\n')
    SL.SetText(t);

    var SLType = getSLEx(b64Decode($("[id='" + gridid + "'] input[name='Fields']").val()));
    if(SLType.length==0){
      SLType = getSLEx(b64Decode($("[name='" + gridid + "'] input[name='Fields']").val()));
    }
    if (StrValueIsNull(isNum)&&(SL.Count()==1)) isNum=IsNumfromSL(SLType,FieldName);
    if (StrValueIsNull(desc)){desc=false}
    var $trs = $("[id='" + gridid + "'] [isgridrow='true'][need='true']")

    var valveNumOfa=""
    var valveNumOfb=""
    $trs.sort(function(a,b){
      valveNumOfa=""
      valveNumOfb=""

      ////////////////////////////////
      if((SL.Count()>1)||(SL.Count()==1)&&(Pos(' ', SL.SL[0])>0) ){

          for(var lp=0 ; lp < SL.Count(); ++ lp)
          {
            var at = "";
            FieldName=SL.SL[lp];
            if(Pos(' ', FieldName)>0){
              at = GetDeliBack(FieldName, ' ').toLowerCase();
              FieldName = GetDeliPri(FieldName, ' ');
            }
            var onea=GetOneSortValue(a, FieldName)
            var oneb=GetOneSortValue(b, FieldName)
            isNum=IsNumfromSL(SLType,FieldName);
            if(isNum){
              var tail=''
              var zs=''
              if(Pos('.')>onea){
                zs=GetDeliPri(onea, '.');
                tail=GetDeliBack(onea, '.');
              }else{zs=onea}
              onea=FillChar(zs, '0', 16)+'.'+tail

              tail=''
              zs=''
              if(Pos('.')>oneb){
                zs=GetDeliPri(oneb, '.');
                tail=GetDeliBack(oneb, '.');
              }else{zs=oneb}
              oneb=FillChar(zs, '0', 16)+'.'+tail
            }

            //if(onea=='')onea= ' '
            //if(oneb=='')oneb= ' '
            if(Pos('desc', at)>0){
              var tmp=onea
              onea=oneb
              oneb=tmp
            }

            valveNumOfa=valveNumOfa+'@#*@' + onea
            valveNumOfb=valveNumOfb+'@#*@' + oneb
          }
          desc = false;
          isNum = false;
      }else{
        valveNumOfa=GetOneSortValue(a, FieldName)
        valveNumOfb=GetOneSortValue(b, FieldName)
      }
      ////////////////////////////////
      if(isNum){
          if(desc){
            if(Number(valveNumOfa) > Number(valveNumOfb))
              return -1;
          }else{
            if(Number(valveNumOfa) < Number(valveNumOfb))
              return -1;
          }
          return 1;
      }else{
          if(desc){
            if((valveNumOfa) > (valveNumOfb))
              return -1;
          }else{
            if((valveNumOfa) < (valveNumOfb))
              return -1;
          }
          return 1;
      }
    });
    $trs.detach();
    if( $("[id='" + gridid + "'] [isgridhead='true']").length > 0){
      $("[id='" + gridid + "'] [isgridhead='true']").after($trs);
    }else
    if( $("[id='" + gridid + "'] [isgridfooter='true']").length > 0){
      $("[id='" + gridid + "'] [isgridfooter='true']").before($trs);
    }else{
      $trs.detach().appendTo("[id='" + gridid + "']");
    }
    SetGridRow_background_color(gridid,false)
}     //*/

function SetGridRow_background_color(gridid,needsum,oddcolor,evencolor){
  if(StrValueIsNull(gridid)) gridid = mxgrid_id; //2022-07-27 add
  if(StrValueIsNull(gridid)){
    mymsg("绑定对象为空，不能继续！{05}");
    return false;
  }
  if(StrValueIsNull(needsum)) needsum=true;
  //#000000
  if(StrValueIsNull(oddcolor)){
    oddcolor=$(PubGoEx('oddcolor',gridid)).attr("value");
  }
  if(StrValueIsNull(evencolor)){
    evencolor=$(PubGoEx('evencolor',gridid)).attr("value");
  }
  if(!((evencolor=='#000000')||(oddcolor=='#000000'))){
    if(!(StrValueIsNull(evencolor)))
      $("[id='" + gridid + "'] [isgridrow='true'][need='true']").filter(":even").css("background-color",evencolor);
    if(!(StrValueIsNull(oddcolor)))
      $("[id='" + gridid + "'] [isgridrow='true'][need='true']").filter(":odd").css("background-color",oddcolor);
    //$("[id='" + gridid + "'] [isgridrow='true'][need='true']").not(":even").css("background-color","white");
  }
  SetGridSelectRow_background_color(gridid);
  if(needsum)startsumvent(gridid)
}

//动态引用js文件
function addScript(url){
    var script = document.createElement('script');
    script.setAttribute('type','text/javascript');
    script.setAttribute('src',url);
    document.getElementsByTagName('head')[0].appendChild(script);
}

function Getmainvalue_mx(mainformid,fieldname){
 ///alert(pubgv(fieldname,mainformid))
 return pubgv(fieldname,mainformid);
}

//填充表格序号
function fillsno(gridid,snofield){
  if(StrValueIsNull(gridid)) gridid = mxgrid_id; //2022-07-27 add
  if(StrValueIsNull(gridid)){
    mymsg("绑定对象为空，不能继续！{16}");
    return false;
  }
  var rowcount=getgridrowcount(gridid)
  for(var i=0;i<rowcount;i++)
  {
    pubsv_cell_row(i+1,gridid,i+1,snofield)
  }
}

//自动填充表格序号
function autofillsno(gridid){
  if(StrValueIsNull(gridid)) gridid = mxgrid_id; //2022-07-27 add
  if(StrValueIsNull(gridid)){
    mymsg("绑定对象为空，不能继续！{17}");
    return false;
  }
  var snofield=pubgv('snoinfo',gridid);
  if(GetDeliPri(snofield, '@')!='1') return false;
  snofield = GetDeliBack(snofield, '@');
  fillsno(gridid,snofield)
}

function AfterSaveAddKeyToURL(){
  if(!StrValueIsNull(maindataarea_id)){
    var SL = getSLEx($("[id='" + maindataarea_id + "'] input[name='KeyWords']").val());
    var Count = SL.length;
    for ( var I=0 ; I < Count; ++I ){
      changeURLStatic(SL[I], $("[id='" + maindataarea_id + "'] input[name='" + SL[I] + "']").val());
    }
  }
}

function GridMoveRow(gridid, rowid, IsDown, needfillsno){
  if(StrValueIsNull(gridid)) gridid = mxgrid_id; //2022-07-27 add
  if(StrValueIsNull(gridid)){
    mymsg("绑定对象为空，不能继续！{18}");
    return false;
  }
  if(StrValueIsNull(rowid)) rowid=getgridselrowid(gridid);
  if(StrValueIsNull(rowid)){
    mymsg("请先选择要移动的行！");
    return false;
  }
  var $trs = $("[id='" + gridid + "'] [isgridrow='true'][need='true']")
  for ( var R=1; R <= $trs.length; ++R )
  {
     if(rowid==$($trs[R-1]).attr('rowid')){
       if(IsDown)
       {
         if(R==$trs.length){mymsg("已是最底！"); return false;}
       }else{
         if(R==1){mymsg("已是最顶！"); return false;}
       }

       if(IsDown){
         var tmp = $trs[R];
         $trs[R] = $trs[R-1];
         $trs[R-1] = tmp;
       }else{
         var tmp = $trs[R-1];
         $trs[R-1] = $trs[R-2];
         $trs[R-2] = tmp;
       }
       break;
     }
  }

  $trs.detach();
  if( $("[id='" + gridid + "'] [isgridhead='true']").length > 0){
    $("[id='" + gridid + "'] [isgridhead='true']").after($trs);
  }else
  if( $("[id='" + gridid + "'] [isgridfooter='true']").length > 0){
    $("[id='" + gridid + "'] [isgridfooter='true']").before($trs);
  }else{
    $trs.detach().appendTo("[id='" + gridid + "']");
  }
  if((needfillsno)||(StrValueIsNull(needfillsno)))
  {
    autofillsno(gridid);
  }
  SetGridRow_background_color(gridid,false);
}

function SetGridSelectRow_background_color(gridid,selcolor){
  if(StrValueIsNull(gridid)) gridid = mxgrid_id; //2022-07-27 add
  if(StrValueIsNull(gridid)){
    mymsg("绑定对象为空，不能继续！{19}");
    return false;
  }
  if(StrValueIsNull(selcolor)){
    selcolor=$(PubGoEx('selcolor',gridid)).attr("value");
  }

  if((selcolor=='#000000')) return false;
  if((trim(selcolor)=='')) selcolor="#e3e793"//"rgb(206, 255, 231)";
  //alert(gridid+'=' + getgridselrowid(gridid));
  $("[id='" + gridid + "'] [isgridrow='true'][need='true'][rowid='" + getgridselrowid(gridid) + "']").css("background-color",selcolor);
}
