$(document).ready(function(){
  // setup search
  $('#content_search input[type="search"]').focus();
  $('#content_search form').bind('submit', function(){
    $('#inventory table tbody').load('/inventory/?q='+$('#content_search input[type="search"]').val(), function(){
      buildTables();
      draggable_items();

      $("div#inventory > table tr td:nth-child(2)").css({width:"26px"});
      $("div#inventory > table tr td:nth-child(3)").css({width:"45%"});
    });
    return false;
  });
  // edit item dialog
  $('#item').dialog({
    autoOpen: false,
    resizable: false,
    modal: true,
    width: 600,
    height: 240,
    title: "Edit Item" 
  });
  // 
  $('tbody tr a').live('click', function(){
    $('#item').empty();
    $('#item').load('/inventory/'+$(this).parent().parent().attr('data-item-id'));
    $('#item').dialog('open');
  });
});