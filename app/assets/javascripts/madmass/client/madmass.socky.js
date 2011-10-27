/************************************************************************/
// Socky callbacks
Madmass.Socky = new Class.Singleton({
  Extends: Core.Base,

  initialize: function(){
    this.parent();
    this.ready = false;
    this.perceptor = Madmass.Perceptor.getInstance();
  },

  // Called after connection but before authentication confirmation is received
  // At this point user is still not allowed to receive messages
  onConnect: function(){
    $log('Socky: connected.');
  },

  // Called when connection is broken between client and server
  // This usually happens when user lost his connection or when Socky server is down.
  // Return a number of milliseconds before trying to reconnect. Return 0 to not reconnect.
  // you can also manually reconnect using thw socky instance: socky.connect()
  onDisconnect : function(socky){
    $log('Socky: disconnected, retrying in 1 sec...');
    this.ready = false;
    return 1000;
  },

  // Called when connection is opened
  onOpen: function(){
    $log('Socky: opened.');
  },

  // Called when socket connection is closed
  onClose: function(){
    $log('Socky: closed.');
    this.ready = false;
  },

  // Called when authentication confirmation is received.
  // At this point user will be able to receive messages
  onAuthSuccess: function(){
    $log('Socky: authenticated and ready.');
    this.ready = true;
  },

  // Called when authentication is rejected by server
  // This usually means that secret is invalid or that authentication server is unavailable
  // This method will NOT be called if connection with Socky server will be broken - see respond_to_disconnect
  onAuthError: function(){
    $log('Socky: authentication failure.');
  },

  // Called when new message is received
  // Note that msg (percepts) is not sanitized - it can be any script received.
  onMessage: function(percepts){
    $log('Socky: received message.');
    this.perceptor.manage(JSON.parse(percepts));
  }
})
