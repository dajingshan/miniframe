//******<<>>（https://www.wyeditor.com，免费软件欢迎下载使用） JS库文件*******
var imgs = document.querySelectorAll('img'); 
         function getTop(e) { 
             var T = e.offsetTop; 
             while(e = e.offsetParent) { 
                 T += e.offsetTop; 
             } 
             return T; 
         } 
         function lazyLoad(imgs) { 
             var H = document.documentElement.clientHeight;//获取可视区域高度 
             var S = document.documentElement.scrollTop || document.body.scrollTop; 
             for (var i = 0; i < imgs.length; i++) { 
                 if (H + S > getTop(imgs[i])) { 
                     var myscr = imgs[i].getAttribute('data-src');
                    if((String(myscr).length != 0)&&(String(imgs[i].src).length == 0 )){ imgs[i].src = myscr;} 
                 } 
             } 
         } 
         window.onload = window.onscroll = function () { //onscroll()在滚动条滚动的时候触发 
             lazyLoad(imgs); 
         }
 layui.use(['form', 'layedit', 'laydate'], function(){ 
   var form = layui.form 
   ,layer = layui.layer 
   ,layedit = layui.layedit 
   ,laydate = layui.laydate; 
});
 layui.use('element', function(){ 
   var $ = layui.jquery 
   var element = layui.element; 
  
 });

 GetOneDataArea(fnew_data, "div_863438", "",true);
function NewAllBill(){
  var ds=DsArea; 
  ds.First(); 
  while (!ds.Eof) 
  {    
    if(ds.V("AType")=='1'){//这是主表新增 
      eval(ds.V("Name")+'_Read_ini();'); 
    }else{//这是明细表新增 
      ClearGrid(ds.V("Name")); 
      startsumvent(ds.V("Name")); 
    } 
    ds.Next(); 
  } 
}
function GetAllDelete(){
  myask("确认要删除吗", function(){ 
     layer.closeAll() 
     var ds=DsArea; 
     ds.First(); 
     while(!ds.Eof) 
     { 
       if(trim(ds.V("AType"))=='1') 
       {    
         var SL = getSLEx($("[id='" + ds.V("Name") + "'] input[name='KeyWords']").val());   
         var addurl = location.search;  
         var Count = SL.length;       
         for ( var I=0 ; I < Count; ++I ){  
           addurl = AddOneItemToUrl(addurl, SL[I], $("[id='" + ds.V("Name") + "'] input[name='" + SL[I] + "']").val())  
         }  
         PostData_syn("THjhMemoryDataSet内存数据集_delete_all.html" + addurl + "&del=1", ds.GetCommaText(),function(r,status){ 
           if(status==200)  
           {  
             fnew_data = false; pubsv('fnew_data',"",''); 
   if(r == '[200ok]'){     mymsg("删除成功！"); var intervalId = setInterval(function(){ clearInterval(intervalId); location=location;},3000);    }else{myalert(r)};
           }  
        
         }); 
         return true; 
       } 
       ds.Next();   
     }  
  })  
 }
 function ReadOneMain(areaid){ 
   fnew_data = false; pubsv('fnew_data',"",areaid);
   var url = location.search; 
   if(Pos("?", url) < 1){url="?" + url}
   var f= "THjhMemoryDataSet内存数据集_" + areaid + "_read.html" 
   OpenData_syn(f + url + "&readtype=1",function(r,status){ 
     if(status==200) 
     { 
       r = GetDeliBack(r, "@");  var ds = getDs(r); ds.First(); 
       var fun= areaid + "_Read(ds)";
       eval(fun); mymsg("数据已读取！");
     } 
   });  
}
function ReadOnGrid(areaid){
  if(StrValueIsNull(areaid)||(maindataarea_id==areaid)) areaid = mxgrid_id; 
  var url = location.search;  
  var f= "THjhMemoryDataSet内存数据集_" + areaid + "_read.html" 
  if(Pos("?", url) < 1){url="?" + url} 
  OpenData_syn(f + url + "&readtype=2",function(r,status){  
     if(status==200)  
     {   
       pubgo(areaid).html(r); 
  
       IniCheckOrRadio() 
       layrender() 
       bindgridevent(areaid); 
     }  
   });   
}
function ReadAllBill(){
  var ds=DsArea; 
  mds_check_radio.ClearData(); 
  ds.First(); 
  while (!ds.Eof) 
  {    
    if(ds.V("AType")=='1'){//这是主表读取 
      ReadOneMain(ds.V("Name")); 
    }else{//这是明细表读取 
      ReadOnGrid(ds.V("Name")); 
    } 
    ds.Next(); 
  } 
}
function SaveAllData(){
 if(pubgv('fnew_data',maindataarea_id)=="true"){fnew_data=true};
if(!CheckOneGrid("div_863438", "", true)){return false}
var ds = GetOneGridAllData(fnew_data, ds,"div_863438", "",true);
  
   PostData_syn("THjhMemoryDataSet内存数据集_saveall.html" + "?" + "savetype=1", ds.GetCommaText(),function(r,status){  
     if(status==200)  
     {  
       if(trim(r) != ""){ 
       if (trim(r)!=""){if(Pos("成功",r)>0){mymsg("保存成功！")} else {myalert(r);} } 
      if(Pos("成功", r) > 0){AfterSaveAddKeyToURL();fnew_data = false;pubsv('fnew_data',"",maindataarea_id);}
       } 
     }  
   });  
}
