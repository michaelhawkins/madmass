/***************************************************************************
                               Madmass Classes
***************************************************************************/
var Madmass = Madmass || {} // Madmass namespace

Madmass.initialize = function(options){

  CONFIG = Madmass.Config.getInstance();          // Configurable parameters

  Core.init({debug: CONFIG.debug});

  AJAX = Core.Ajax.getInstance(CONFIG.server);    // Client <=> Server communications
  
}

/* Every page have this controller. Options are:
 *
 * factory: the factory strategies for the page.
 * debug: [false | true | Konsole object] debugging options
 *
 **/
var ClientController = new Class.Singleton({
  Extends: Core.Base,

  initialize: function(options){
    this.parent();
    this.strategyFactory = options.factory;
    if(options.debug) Konsole.enable(options.debug);
  },

  event: function(eventId, eventData){
    if(!this.strategyFactory){
      Konsole.error("GameController: no strategy factory supplied!");
      return;
    }
    var strategy = this.strategyFactory.make(eventId);
    if(strategy){
      try{
        strategy.crunch(eventData);
      } catch(err){
        var msg = "There was an error executing: " + strategy.options.name + " Strategy\n"
        msg += err.stack + "\n";
        Konsole.error(msg);
      }
    }
  }
  
});

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

// EXAMPLE => DELETE ME
$perceptStrategy('message', function(percept){
  Konsole.info('Message: ' + JSON.stringify(percept));
})

/************************************************************************/
/* Game action strategy factory (must be here, after strategies) */
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
        headers: percept.headers
      }
      $H(percept.data).each(function(perception, name){
        try {
          strategy = new Madmass.PerceptStrategy[name];
          blindPercept.data = perception;
          strategy.onPercept(blindPercept);
        } catch(err){
          Konsole.error("No percept strategy for event: " + name);
        }
      }, this);
    }, this)
    var strategy = null;
    return strategy;
  }
});

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
