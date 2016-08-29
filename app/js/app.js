$(function(){
  $.ajaxSetup({
    beforeSend: function(xhr) {
      xhr.setRequestHeader('X-PJAX', true);
    }
  });

  var Router = Backbone.Router.extend({
    initialize : function(){
      if(history && history.pushState) {
        Backbone.history.start({pushState: true, root: "/"});
      } else {
        Backbone.history.start();
      }
    }
  });

  var View = Backbone.View.extend({
    events : {
      'click a' : 'getPjax'
    },
    el : $('body'),
    initialize : function(){
      $('a').bind('click', function (e) {
        e.preventDefault();
        router.navigate($(this).attr("href").substr(1), true);
      });
    },
    getPjax : function(e){
      var path = $(e.currentTarget).attr("href").substr(1);
      $("#content").load(path);
    }
  });

  window.view = new View();
  window.router = new Router;
  $(window).bind("popstate", function(e){
    var id = location.pathname;
    $('#content').text('');
    //if('/' !== id) 
    $('#content').load(id);
  });
});
