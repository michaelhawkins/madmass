$perceptStrategy("message" , function(percept){
  $('.messages').append('<div>' + percept.data + '</div>');
})

