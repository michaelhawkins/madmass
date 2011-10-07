/***************************************************************************
                                Madmass RPCs
***************************************************************************/

Core.Rpc = new Class.Singleton({
  Extends: Core.Base,
  Implements: Core.Dispatchable,

  initialize: function(){
    this.parent();
    
//    this.mapListeners([
//      {map: $msg.rpc.acceptOffer, to: this.acceptOffer},
//    ]);
  },

  /* Call method intended to be used by a direct call, without using
   * dispatching facility. Example:
   *
   * simpleCall('hello', {cmd: 'actions::hello', param: 'world'}, successCallback, errorCallback)
   *
   * Necessary parameters are only agent name and cmd, so a minimal coll will be:
   *
   * simpleCall(agentName, {cmd: command})
   **/

  simpleCall: function(agentName, data, success, error){
    if(!(agentName && data && data.cmd)){
      $log("Core.Rpc: undefined agent call. Agent: " + agentName + ", data: " + JSON.stringify(data));
      return;
    }
    var request = {agent: agentName, data: {}};
    $H(data).each(function(value, param){
      request.data[('agent[' + param + ']')] = value;
    })
    if(success) request.success = this.call(success, {'request': data});
    if(error) request.error = this.call(error, {'request': data});

    AJAX.call(request);
  },

  /* Use this method in ajax success and error callbacks to fire
   * success or error dispatcher messages. Complete example:
   *
   * executeCommand: function(data){
   *   AJAX.call({
   *     controller: 'commands',
   *     data: {
   *       'agent[cmd]': 'actions::command',
   *       'agent[param1]': data.first,
   *       'agent[param2]': data.second,
   *      ...
   *     },
   *     success: this.notify($msg.success.command, {params: data}),
   *     error: this.notify($msg.error.command, {params: data})
   *   });
   * }
   *
   * Params:
   * - msg: the message id sent to the dispatcher for this notification
   * - data: a data hash. This hash will be extended with xhr result (data.xhr).
   **/
  notify: function(msg, data){
    data = ($type(data) == "object") ? data : {};
    var notifier = function(p1, status, p2){

      /* jQuery success and error parameters:
       * success(data, textStatus, jqXHR)
       * error(jqXHR, textStatus, errorThrown)
       * see http://api.jquery.com/jQuery.ajax/
       **/

      // Sends only the jqXHR object
      data.xhr = ($type(p2) == "string") ? p1 : p2;
      this.send(msg, data);
    }
    return notifier.bind(this);
  },

  /* Use this method in ajax success and error callbacks to fire
   * success or error callbacks with parameters. Example:
   *
   * executeCommand: function(data){
   *   AJAX.call({
   *     controller: 'commands',
   *     data: {
   *       'agent[cmd]': 'actions::command',
   *       'agent[param1]': data.first,
   *       'agent[param2]': data.second,
   *      ...
   *     },
   *     success: this.call(successCallback, {params: data}),
   *     error: this.call(errorCallback, {params: data})
   *   });
   * }
   * 
   * Params:
   * - call: the callback to be invoked
   * - data: a data hash. This hash will be extended with xhr result (data.xhr).
   *
   * The callback will receive 2 parameters (data, xhr):
   * - data: will be equal to the parameters hash passed to notify function with
   *   the additional property .result that will contain the data returned by the
   *   server in case of success, or an error string if error.
   * - xhr: is the ajax result object.
   **/
  call: function(call, data){
    data = ($type(data) == "object") ? data : {};
    var notifier = function(p1, status, p2){

      /* jQuery success and error parameters:
       * success(data, textStatus, jqXHR)
       * error(jqXHR, textStatus, errorThrown)
       * see http://api.jquery.com/jQuery.ajax/
       **/

      // Adds to data only the jqXHR object
      var xhr = p2;
      data.result = p1;
      if($type(p2) == "string"){
        xhr = p1;
        data.result = p2;
      }
      call(data, xhr);
    }
    return notifier.bind(this);
  }

});

/* Invokes the Core.Rpc.simpleCall method. Example of a minimal call:
 *
 *  $agentCall(agentName, {cmd: command})
 *
 * Full example:
 *
 *  $agentCall(agentName, {cmd: command, param1: 23, param2: 'test',...} successCallback, errorCallback)
 */
$agentCall = Core.Rpc.getInstance().simpleCall.bind(Core.Rpc.getInstance());