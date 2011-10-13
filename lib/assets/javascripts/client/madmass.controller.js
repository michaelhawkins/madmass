/***************************************************************************
                               Madmass Classes
***************************************************************************/
var Madmass = Madmass || {} // Madmass namespace

Madmass.initialize = function(options){

  CONFIG = Madmass.Config.getInstance();          // Configurable parameters
  Core.init({
    debug: CONFIG.debug,
    log : CONFIG.log
  });
  AJAX = Core.Ajax.getInstance(CONFIG.server);    // Client <=> Server communications
  RPC = Core.Rpc.getInstance(CONFIG.remoteCalls);
  GUI = Core.Gui.getInstance({
    namespace: CONFIG.guiNamespace,
    items: CONFIG.gui
  });

  madmassInitHelpers(); // setups some global helper
}

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
