/********************************************************************************/
// Notifies infos from server
Game.InfoMechanicsStrategy = new Class({
  Extends: GameController.Strategy,

  options:{
    name: "Info Mechanics"
  },

  crunch: function(message){
    this.send($msg.info.mechanics, message);
  }

});

/************************************************************************/
/* Game action strategy factory (must be here, after strategies) */
Game.StrategyFactory = new Class.Singleton({
  Extends: Core.Base,

  options: {
    'info_mechanics' : Game.InfoMechanicsStrategy
  },

  /* Returns the strategy capable of handling the event identified by eventId. */
  make: function(eventId){
    var strategy = null;
    try {
      strategy = new this.options[eventId];
    } catch(err){
      Konsole.error("No strategy for event: " + eventId);
    }
    return strategy;
  }
});
