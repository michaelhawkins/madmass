/***************************************************************************
                                Madmass RPCs
***************************************************************************/

Core.Rpc = new Class.Singleton({
  Extends: Core.Base,
  Implements: Core.Dispatchable,

  initialize: function(){
//    this.mapListeners([
//      {map: $msg.rpc.acceptOffer, to: this.acceptOffer},
//    ]);
  },

  /* Use this method in ajax success and error callbacks to fire
   * success or error dispatcher messages. Complete example:
   *
   * executeCommand: function(data){
   *   AJAX.call({
   *     action: 'execute',
   *     data: {
   *       'game[cmd]': 'actions::command',
   *       'game[param1]': data.first,
   *       'game[param2]': data.second,
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
   *     action: 'execute',
   *     data: {
   *       'game[cmd]': 'actions::command',
   *       'game[param1]': data.first,
   *       'game[param2]': data.second,
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
