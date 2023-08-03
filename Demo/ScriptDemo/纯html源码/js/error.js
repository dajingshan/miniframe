//******<<>>（https://www.wyeditor.com，免费软件欢迎下载使用） JS库文件*******
function AutoResizeImage(OldWidth, objImg,Size_Right,Size_Bottom,DecW,DecH){ 
 var hRatio = objImg.getBoundingClientRect().width/objImg.getBoundingClientRect().height; 
 var wRatio = objImg.getBoundingClientRect().height/objImg.getBoundingClientRect().width; 
 var w = objImg.getBoundingClientRect().width - DecW; 
 var h = objImg.getBoundingClientRect().height - DecH;  
 var pw = objImg.parentNode.getBoundingClientRect().width; 
 var ph = objImg.parentNode.getBoundingClientRect().height;  
 if( (ph==0)) {
   var pw = document.documentElement.clientWidth || document.body.clientWidth; 
   var ph = document.documentElement.clientHeight || document.body.clientHeight;  
 }
 var w = objImg.getBoundingClientRect().width - DecW; 
 var h = objImg.getBoundingClientRect().height - DecH;  
var Change = false;  
 if ((pw < w + 3) || (OldWidth > w + 3) ){ 
 w = pw; if(w > OldWidth) w=OldWidth;
 h = objImg.getBoundingClientRect().height - (objImg.getBoundingClientRect().width - w)*wRatio; 
 Change = true;
} 
 if (ph < h + 3){ 
 h = ph;
 w = objImg.getBoundingClientRect().width - (objImg.getBoundingClientRect().height - h)*hRatio; 
 Change = true;
} 


 objImg.style.setProperty('width', w + "px", 'important');  
 objImg.style.setProperty('height', h + "px", 'important'); 
var centerleft = (- (w/2)) + 'px'; 
 objImg.style.setProperty('margin-left', centerleft, 'important');  
  
} 

 $(document).ready(function(){ 
 $(window).resize(function(){ 
  AutoResizeImage(664,document.getElementById("img_663778"),0,0,0,0);
       }); 
 });
