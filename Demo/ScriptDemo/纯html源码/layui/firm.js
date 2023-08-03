/**
 
 @Name: layuiNetCompany - 大气风格的网络公司企业模版
 @Author: xuxingyu
 @Copyright: layui.com
 
 */

layui.define(['jquery', 'element', 'carousel', 'laypage'], function(exports){
  var $ = layui.jquery
  ,element = layui.element
  ,carousel = layui.carousel
  ,laypage = layui.laypage;

  $(window).scroll(function() {
    var scr=$(document).scrollTop();
    //scr > 0 ? $(".nav").addClass('scroll') : $(".nav").removeClass('scroll');
  });

  $(function(){
    $('.banner').children('.title').addClass('active');
  })

  var btn = $('.nav').find('.nav-list').children('button')
  ,spa = btn.children('span')
  ,ul = $('.nav').find('.nav-list').children('.layui-nav');
  btn.on('click', function(){
    if(!$(spa[0]).hasClass('spa1')){
      spa[0].className = 'spa1';
      spa[1].style.display = 'none';
      spa[2].className = 'spa3'; /*;overflow: visible*/
      $('.nav')[0].style.height = 90 + ul[0].offsetHeight + 'px';
      $('.nav')[0].style.overflow = 'visible!important';
      //$('.nav')[0].css("cssText","overflow:visible!important");
      $('.nav').removeClass('Laytopmenupanel') //hjh 2022-08-26 add
      $('.nav').addClass('visiblehidden')//hjh 2022-08-26 add
    }else{
      $('.nav').addClass('Laytopmenupanel') //hjh 2022-08-26 add
      $('.nav').removeClass('visiblehidden')//hjh 2022-08-26 add
      spa[0].className = '';
      spa[1].style.display = 'block';
      spa[2].className = '';
      $('.nav')[0].style.height = 60 + 'px';
      //$('.nav').css("cssText","overflow:hidden");
    }
  });

  $('.main-about').find('.aboutab').children('li').each(function(index){
    $(this).on('click', function(){
      $(this).addClass('layui-this').siblings().removeClass('layui-this');
      $('.aboutab').siblings().fadeOut("fast");
      $('.aboutab').siblings().eq(index).fadeIn("");
    });
  });

  laypage.render({
    elem: 'newsPage'
    ,count: 50
    ,theme: '#2db5a3'
    ,layout: ['page', 'next']
  });

  laypage.render({
    elem: 'casePage'
    ,count: 50
    ,theme: '#2db5a3' 
    ,layout: ['page', 'next']
  });

  $(function(){
    $(".main-news").find(".content").each(function(){
      var span = $(this).find(".detail").children("span")
      ,spanTxt = span.html();
      if(document.body.clientWidth > 463){
        span.html(spanTxt);
      }else{
        span.html(span.html().substring(0, 42)+ '...')
      };
      $(window).resize(function(){   
        if(document.body.clientWidth > 463){
          span.html(spanTxt);
        }else{
          span.html(span.html().substring(0, 42)+ '...')
        };
      });
    });
  });  

  exports('firm', {}); 
});