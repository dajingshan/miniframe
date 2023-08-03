//******<<>>（https://www.wyeditor.com，免费软件欢迎下载使用） JS库文件*******
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

   layui.config({ 
     base: 'layui/'  
   }).use('firm');
     wow = new WOW( 
       { 
         animateClass: 'animated', 
         offset:       100, 
         mobile: true, 
         live: true, 
         callback:     function(box) { 
           console.log("WOW: animating <" + box.tagName.toLowerCase() + ">") 
         } 
       } 
     ); 
     wow.init()
