/************************************************************************/
// Stilts Stomp callbacks
Madmass.Stomp = new Class.Singleton({
  Extends: Core.Base,

  initialize: function(connectionOptions){
    this.parent();
    this.ready = false;
    this.perceptor = Madmass.Perceptor.getInstance();
    this.webSocketClient = null;
    this.messageCount = 0;
    this.connectionOptions = connectionOptions;
  },

  // Register the client in order to receive perceptions from the public channels (topics)
  // and from the private channel (client id).
  register: function() {
    this.connect();
    setTimeout(this.reconnect.bind(this), 10000);
//    setTimeout((function() {
//      this.reconnect();
//    }).bind(this), 10000);
  },

  // Open the connection with the server side Stomplet.
  connect: function() {
    var url = "ws://" + this.connectionOptions['host'] + ":" + this.connectionOptions['port'];
    $log("Web Socket Client url: " + url);
    this.webSocketClient = Stomp.client( url );
    this.webSocketClient.connect( null, null, this.subscribe.bind(this));
//    this.webSocketClient.connect( null, null, (function() {
//      this.subscribe();
//    }).bind(this));
  },

  subscribe: function() {
    _topic = "/madmass/domain";
    $log('Web Socket Client connected ...');
    $log('Web Socket Client subscribed on topic ' + this.connectionOptions['topic'] + ' ...');
    this.webSocketClient.subscribe( this.connectionOptions['topic'], this.onMessage.bind(this));
//    this.webSocketClient.subscribe( this.connectionOptions['topic'], (function(percepts) {
//      this.onMessage(percepts);
//    }).bind(this));
  },

  // Called when new message is received
  // Note that msg (percepts) is not sanitized - it can be any script received.
  onMessage: function(percepts) {
    this.messageCount++;
    $log('Web Socket Client received message: ' + percepts.body);
    this.perceptor.manage(JSON.parse(percepts.body));
  },

  disconnect: function() {
    this.webSocketClient.unsubscribe(this.connectionOptions['topic']);
    this.webSocketClient.disconnect();
    $log('Web Socket Client unsubscribed and disconnected from topic ' + this.connectionOptions['topic'] + ' ...');
  },

  reconnect: function() {
    $log("Reconnect messages " + this.messageCount + ": " + this.connectionOptions['host'] + " - " + this.connectionOptions['port'] + " - " + this.connectionOptions['topic']);
    // empirical condition :(
    if(this.messageCount < 2) {
      $log('Web Socket Client reconnecting ...');
      this.disconnect();
      this.register();
    } else {
      $log("Web Socket Client connected!");
    }
  }

})