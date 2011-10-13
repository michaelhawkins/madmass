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
