// make inventory items draggable
function draggable_items(){
  // $(".item").hover(function(){
  //   $(this).children().children('img').removeClass('hide');
  // }, function(){
  //   $(this).children().children('img').addClass('hide');    
  // });
  // $(".item img").bind('mousedown', function(){
  //   $(this).removeClass('hide');
  // })
  $(".item img").draggable({
    cursorAt: { left: 0 },
    helper: 'clone',
    opacity: 1.0
  });   
}

$(document).ready(function(){

  // setup add item to location dialog
  $('#quantity').dialog({
    autoOpen: false,
    resizable: false,
    modal: true
  });
  // location dialog
  $('#location').dialog({
    autoOpen: false,
    modal: true,
    width: 600,
    height: 400
  });
  $('[data-location-url]').click(function() {
    var $item = $(this),
        title = $item.attr('data-location-title'),
        url   = $item.attr('data-location-url');
    $('#location').dialog('option', 'title', title).html('Loading...').load(url).dialog('open');
  });

  // make locations droppable
  $(".droppable").droppable({
    accept: '.item img',
    over: function(){
      $(this).addClass('selected');
    },
    out: function(){
      $(this).removeClass('selected');
    },
    drop: function(event, ui){
      $(this).removeClass('selected');
      var url = '/locations/'+$(this).attr('data-location-id')
      $('#quantity').dialog('option', 'buttons', { 
        "Add Item": function() { 
          $.ajax({
            url: url,
            type: "POST",
            data: '_method=put&type=add_item&item_id='+ui.draggable.attr('data-item-id')+'&quantity='+$('#quantity input').val(),
            success: function(){
              flash('Successfully added the item.')
            },
            error: function(){
              flash('Was not able to add the item.')
            }
          });
          $('#quantity input').val('')
          $(this).dialog('close');
        }
      });
      $('#quantity').dialog('open');
      $('#quantity input').focus();
    }
  });
});
