/***************************************************************************
                                Madmass RPCs
***************************************************************************/

Core.Rpc = new Class.Singleton({
  Extends: Core.Base,
  Implements: Core.Dispatchable,

  callMaps: new Hash,

 /* The first time you request the instance of Rpc singleton you can pass a remotes array of remote call registrations.
  * Each array element is an hash with 2 keys, 'on' and 'call'.
  * - on: specifies the event that triggers the remote call (see event in registerCall)
  * - call: are the remote call params (see params in registerCall)
  *
  * Example:
  *
  * remotes = [
  *  { on: $msg.rpc.doThis, call: {agent: 'commands', cmd: 'actions::hello', success: function(){alert('success!');}} },
  *  { on: $msg.rpc.doThat, call: {agent: 'slave', cmd: 'actions::world', success: $msg.rpc.doThatSuccess, error: $msg.rpc.doThatError } }
  * ]
  **/
  initialize: function(remotes){
    this.parent();

    remotes.each(function(remote){
      this.registerCall(remote.on, remote.call)
    }, this);
    
//    this.mapListeners([
//      {map: $msg.rpc.acceptOffer, to: this.acceptOffer},
//    ]);
  },

  /* Registers a remote call for event.
   * - event: the event id that will trigger the remote call
   * - params: see remoteCall params. If you define data, they will be merged with data passed in the call.
   * - priority: (optional) a priority for this message. Higher priorities are served first by the dispatcher.
   *
   * Example:
   *    registerCall(1, {agent: 'commands', cmd: 'actions::hello'})
   *
   * now if we send from our object:
   *    send(1, {message: 'some message'}) // note that data must be a hash
   *
   * It will trigger a remoteCall with: {agent: 'commands', cmd: 'actions::hello', data: {message: 'some message'} }
   * */
  registerCall: function(event, params, priority){
    if(!(event && params && params.agent && params.cmd)){
      $log("Core.Rpc: wrong remote call registration for event: " + event + " with params: " + JSON.stringify(params), {level: 'error'});
      return;
    }
    if(this.callMaps[event]){
      $log("Core.Rpc: trying to register an already registered remote call for event: " + event, {level: 'warn'});
      return;
    }
    this.callMaps[event] = params;
    this.listen(event, priority);
  },

  // Unregisters call for event
  unregisterCall: function(event){
    this.unlisten(event);
    this.callMaps.erase(event);
  },

  receive: function(msgId, data){
    var callParams = this.callMaps[msgId];
    if(callParams){
      callParams.data = $H(callParams.data).extend(data)
      this.remoteCall(callParams);
    } else {
      $log("Core.Rpc: no registered call for event: " + msgId, {level: 'warn'});
    }
    return true;
  },

  /* Makes a remote call to an agent, sending optional data and setting optional
   * callbacks. Example:
   *    remoteCall({
   *      agent: agentName, cmd: command,
   *      success: successCallback, error: errorCallback,
   *      data: {param1: 23, param2: 'test',...}
   *    })
   *
   * Necessary parameters are only agent name and cmd, so a minimal coll will be:
   *    simpleCall({agent: agentName, cmd: command})
   *
   * Important: successCallback and errorCallback may be of 2 types:
   * - function: it will me called like a regular callback
   * - any other type (usually a number or string): it will be dispatched like an event
   **/
  remoteCall: function(params){
    var agentName = params.agent;
    var cmd = params.cmd;

    if(!(agentName && cmd)){
      $log("Core.Rpc: undefined agent call. Agent: " + agentName + ", call: " + JSON.stringify(params), {level: 'error'});
      return false;
    }

    var request = {agent: agentName, data: {'agent[cmd]': cmd}};
    $H(params.data).each(function(value, param){
      request.data[('agent[' + param + ']')] = value;
    })

    var successCallbackType = typeof params.success;
    if(successCallbackType != 'undefined'){
      if(successCallbackType == 'function'){
        request.success = this.call(params.success, {'request': params.data});
      } else {
        request.success = this.notify(params.success, {'request': params.data});
      }
    }
    var errorCallbackType = typeof params.error;
    if(errorCallbackType != 'undefined'){
      if(errorCallbackType == 'function'){
        request.error = this.call(params.error, {'request': params.data});
      } else {
        request.error = this.notify(params.error, {'request': params.data});
      }
    }

    AJAX.call(request);
    return true;
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
