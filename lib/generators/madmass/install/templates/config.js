/**
 * Madmass Configuration. You can put here any parameters or method
 * that will be available through the global constant CONFIG.
 **/
Madmass.Config = new Class.Singleton({
  initialize: function(){

    // Enables debugging info from core. Use this flag freely for your purpose too.
    this.debug = true;

    /* Servers params used by ajax. This auto configuration should be enough.
     * Customize it if necessary. */
    var domain = window.location.host.split(':');
    this.server = {
      host: domain[0],
      port: domain[1],
      controller: 'default_agent'
    };

    /* Add here properties and methods */

  }
});