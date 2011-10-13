/*********************************************************************
 *                           Madmass helpers
 *********************************************************************
 * Defines some global helper.
 **/

// Helpers that can be defined only after the whole initialization process
function madmassInitHelpers(){
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
// Utility method to translate message ids to message names
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
  var prefix = $msg ? "$msg." : "messages.";
  return ( prefix + findMessage(CONFIG.messages) );
}

/********************************************************************************
 * Utility method to define easily new percept strategies.
 * The callback can use this.send to dispatch events. If you need
 * to override initialize or to add more complex behavior, subclass
 * Madmass.PerceptStrategy. Example:
 *
 *  $perceptStrategy("message" , function(percept){
 *    $('.messages').append('<div>' + percept.data + '</div>');
 *  })
 **/
$perceptStrategy = function(name, callback){
  Madmass.PerceptStrategy[name] = new Class({
    Extends: Madmass.PerceptStrategy,
    onPercept: callback
  });
}

/********************************************************************************
 * Overwrites the default Dispatcher sniffer,
 * The sniffer allows to listen for dispatched messages.
 * It listens with a default priority of 1000. Instanciate it using the $snif util.
 * Examples:
 *
 *    1. snif = $snif(msg.event)
 *    2. snif = $snif([msg.event, msg.custom])
 *    3. snif = $snif([msg.event.click, msg.action], myReceiver)
 *    4. snif = $snif(msg, myReceiver)
 *    5. snif.destroy()
 *
 * Examples 1 and 2 show how you can snif for one or more messages at once.
 * Examples 3 and 4 show how you can pass your own receiver callback:
 *
 *    myReceiver = function(message, data){...}
 *
 * Your receive function has not to return true or false as the sniffer itself
 * always returns true so that dispatching can continue with lower priority
 * listeners.
 * Example 5 shows how to stop a sniffer, simply destroying it :)
 * - pretty: tells to use html to highlight the message
 * - formatted: tells to format the json data in an html <pre> tag
 **/
$snif = function(messages, myReceive, pretty, formatted){
  return (new Madmass.Sniffer(messages, myReceive, pretty, formatted));
}

/* Finds a tempalte with the passed element id and returns
 * the jquery-ized template with optionally substituted parts.
 * Returns null if no template was found.
 * Prams: (templateId, substitutions)
 * - templateId: string, the name of the template (without the postfix "-template")
 * - substitutions: hash of key values to replace in the template
 *                  ("... {key} ..."  key will be replaced with value)
 **/
$template = Core.Gui.TemplateFactory.make;