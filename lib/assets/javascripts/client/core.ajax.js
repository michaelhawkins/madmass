/* Ajax extension for Gamecore library
 * © Algorithmica 2010
 **/

/*********************************************************************
 *         COMMUNICATION (Client <=> Server communications)
 *********************************************************************/

Core.Ajax = new Class.Singleton({
  Extends: Core.Base,
  Implements: Options,

  options: {
    // Server parameters
    protocol: 'http',
    host: 'undefined',
    port: false,
    path: false,
    agent: 'commands',

    // Ajax options
    ajax: {
      method: "POST",
      type: "json",
      traditional: false //rails needs false, grails needs true
    }
  },

  // Use the options hash to configure the right server parameters (protool, host, port, path, controller)
  initialize: function(options){
    this.parent();
    this.setOptions(options);
  },

  /* Makes an ajax call to the server.
   *    request: {urlFor params [,data: jsonData, success: function]}
   * example:
   *    request = {agent: 'myagent', data: {param: 3}, success: callback}
   */
  call: function(request){
    var ajaxParams = $H({
      url: this.urlFor(request),
      traditional: this.options.ajax.traditional,
      type: this.options.ajax.method
    });
    if(request.data){
      ajaxParams.extend({
        data: request.data,
        dataType: this.options.ajax.type
      })
    }
    if(request.success){
      ajaxParams.extend({success: request.success})
    }
    if(request.error){
      ajaxParams.extend({error: request.error})
    }
    jQuery.ajax(ajaxParams);
  },

  /* params is a hash of url specifiers. Example:
   * {
   *  protocol: 'http',
   *  host: 'localhost',
   *  port: 9090,
   *  path: 'multi-channel-chat',
   *  agent: 'commands'
   * }
   */
  urlFor: function(params){
    var protocol = params.protocol || this.options.protocol;
    var server = params.host || this.options.host;
    var port = params.port || this.options.port;
    var portSpec = (port ? ':' + port : '');
    var path = params.path || this.options.path;
    var pathSpec = path ? '/' + path : '';
    var agent = params.agent || this.options.agent;
    return (protocol + '://' + server + portSpec + pathSpec + '/' + agent)
  }
});
