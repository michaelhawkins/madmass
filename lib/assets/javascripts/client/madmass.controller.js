/***************************************************************************
                               Madmass Classes
***************************************************************************/
var Madmass = Madmass || {} // Madmass namespace

Madmass.initialize = function(options){

  CONFIG = Madmass.Config.getInstance();          // Configurable parameters
  Core.init({
    debug: CONFIG.debug,
    log : CONFIG.log
  });
  AJAX = Core.Ajax.getInstance(CONFIG.server);    // Client <=> Server communications
  RPC = Core.Rpc.getInstance(CONFIG.remoteCalls);
  GUI = Core.Gui.getInstance({
    namespace: CONFIG.guiNamespace,
    items: CONFIG.gui
  });

  /**
   * Invokes the Core.Rpc.simpleCall method. Example of a minimal call:
   *    $agentCall({agent: agentName, cmd: command})
   * Full example:
   *    $askAgent({
   *      agent: agentName, cmd: command,
   *      success: successCallback, error: errorCallback,
   *      data: {param1: 23, param2: 'test',...}
   *    })
   */
  $askAgent = RPC.remoteCall.bind(RPC);

}

/********************************************************************************/
// Utility method to revert message ids to message names
$msgName = function(msgId){
  var findMessage = function(msg){
    var msgName = null;
    $H(msg).some(function(value, name){
      if($type(value) == "number"){
        if(value == msgId){
          msgName = name;
          return true;
        } else {
          return false;
        }
      }
      var sub = findMessage(value);
      if(sub){
        msgName = name + '.' + sub;
        return true;
      } else {
        return false
      }
    }, this);
    return msgName;
  }
  var prefix = $msg ? "$msg." : "Madmass.messages.";
  return ( prefix + findMessage(CONFIG.messages) );
}

/********************************************************************************/
/* Abstract percept strategy. All percept trategies must derive from this. */
Madmass.PerceptStrategy = new Class({
  Extends: Core.Base,
  Implements: Core.Dispatchable,

  /* Override this method in your subclass. */
  onPercept: function(percept){
    Konsole.info('Received percept: ' + JSON.stringify(percept));
  }
});

/**
 * Utility method to define easily new percept strategies.
 * The callback can use this.send to dispatch events. If you need
 * to override initialize or to add more complex behavior, subclass
 * Madmass.PerceptStrategy.
 **/
$perceptStrategy = function(name, callback){
  Madmass.PerceptStrategy[name] = new Class({
    Extends: Madmass.PerceptStrategy,
    onPercept: callback
  });
}

/************************************************************************/
/* Dynamic perception strategy. */
Madmass.Perceptor = new Class.Singleton({
  Extends: Core.Base,

  /* Percepts is an array of percepts.
   * A single percept is for example:
   * {"data":{"message":"Hello World!"},
   *  "header":{"action":"Actions::HelloAction","topics":"all","agent_id":"2174236340","clients":"1"},
   *  "status":{"code":"100"}
   * }
   **/
  manage: function(percepts){
    percepts.each(function(percept){
      var blindPercept = {
        status: percept.status,
        header: percept.header
      }
      $H(percept.data).each(function(perception, name){
        try {
          strategy = new Madmass.PerceptStrategy[name];
          $log('Madmass.Perceptor: found strategy for "' + name + '"');
          blindPercept.data = perception;
          strategy.onPercept(blindPercept);
        } catch(err){
          $log('Madmass.Perceptor: no percept strategy for: "' + name + '"', {level: 'warn'});
        }
      }, this);
    }, this)
    var strategy = null;
    return strategy;
  }
});

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

/*********************************************************************
 *                Personalized Madmass Message Sniffer
 *********************************************************************/
// This sniffer translates message ids back to strings :)
Madmass.Sniffer = new Class({
  Extends: Core.Dispatcher.Sniffer,

  options: {
    colors: ["#00A000", "#A52A2A", "#000000"]
  },

  initialize: function(messages, myReceive){
    this.parent(messages, myReceive);
    this.msgMap = new Hash;
    this.messages.each(function(msg){
      this.msgId = msg;
      this.msgMap.set(msg, this.nameDecorator("$msg", 0) + "." + this.findMessage($msg, 1));
    }, this);
    if(this.customReceive){
      this.proxedReceive = this.customReceive;
      this.customReceive = this.proxyCustomReceive;
    }
  },

  receive: function(msg, data){
    this.msgId = msg;
    return this.parent(this.msgMap[msg], data);
  },

  proxyCustomReceive: function(msg, data){
    // msg is the translated msgId, we need to pass the original message to the callback
    this.proxedReceive(this.msgId, data);
  },

  findMessage: function(msg, depth){
    var msgName = null;
    $H(msg).some(function(value, name){
      if($type(value) == "number"){
        if(value == this.msgId){
          msgName = this.nameDecorator(name, depth);
          return true;
        } else {
          return false;
        }
      }
      var sub = this.findMessage(value, depth + 1);
      if(sub){
        msgName = this.nameDecorator(name, depth) + '.' + sub;
        return true;
      } else {
        return false
      }
    }, this);
    return msgName;
  },

  nameDecorator: function(name, depth){
    depth = Math.min(this.options.colors.length - 1, depth);
    return ('<span style="color:' + this.options.colors[depth] + ';">' + name + '</span>');
  },

  msgDecorator: function(msg){
    return ("<b>" + msg + "</b> => ");
  }

});

/* Overwrites the default Dispatcher sniffer,
 * see Core.Dispatcher.Sniffer for more info. */
$snif = function(messages, myReceive){
  return (new Madmass.Sniffer(messages, myReceive));
}

/*********************************************************************************/
/*                                   STARTUP                                     */
/*********************************************************************************/
jQuery(document).ready(function () {

 /**
  * When making an ajax call, rails 3 needs to receive the CSRF token otherwise it will not authenticate
  * the user. The token is set in the layout by the csrf_meta_tag helper. Prototype, provided by default
  * with rails, already sends the token as an header to the server, but jquery does not. So this little
  * piece of code adds that functionality to jquery. It grabs the token and puts it in an header on every
  * ajax request.
  * Reference: http://weblog.rubyonrails.org/2011/2/8/csrf-protection-bypass-in-ruby-on-rails
  **/
  $(document).ajaxSend(function(e, xhr, options) {
    var token = $("meta[name='csrf-token']").attr("content");
    xhr.setRequestHeader("X-CSRF-Token", token);
  });

  Madmass.initialize();

});
