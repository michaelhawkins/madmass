/* Versioning logic. Use:
 *
 *    Madmass.Versioning.isNewPercept(percept));
 *
 * where percept has the attribute 'version'.
 * It returns true if the game
 * or player message sent by the server is new.
 * It maintains the player and game message version
 * in private variables.
 **/
Core.Versioning = new function(){
  var perceptVersion = -1;

  this.isNewPercept = function(percept){
    if(percept.version > perceptVersion){
      perceptVersion = percept.version;
      return true;
    }
    Konsole.warn('Old percept. Current version: ' + perceptVersion + ', received: ' + percept.version);
    return false;
  };
}