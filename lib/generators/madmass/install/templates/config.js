/**
 * Madmass Configuration. You can put here any parameters or method
 * that will be available through the global constant CONFIG.
 **/
Madmass.Config = new Class.Singleton({
  initialize: function(){

    // Enables debugging info from core. Use this flag freely for your purpose too.
    this.debug = true;
    // Enables logging. Use this flag freely for your purpose too.
    this.log = true;

    /* Servers params used by ajax. This auto configuration should be enough.
     * Customize it if necessary. */
    var domain = window.location.host.split(':');
    this.server = {
      host: domain[0],
      port: domain[1],
      agent: 'commands'
    };

    /* Add here properties and methods */

  }
});

/* Here you can define your application messages. Use them to
 * dispatch messages and map you message listeners.
 *
 *  Madmass.Messages = {
 *    event: {
 *      click: $newMsgId(),
 *      mousemove: $newMsgId(),
 *      ...
 *    },
 *    action: {
 *      compute: $newMsgId(),
 *      save: $newMsgId(),
 *      ...
 *    },
 *    custom: {
 *      my1: $newMsgId(),
 *      my2: $newMsgId(),
 *      ...
 *    }
 *  }
 *
 *  where $newMsgId() returns an unique message id (number).
 *  Note: $msg is a shortcut for Madmass.Messages, so you can
 *  dispatch an event like:
 *
 *  this.send($msg.event.click, [optional data])
 **/
Madmass.Messages = {
  // myMessage1: $newMsgId(),
  // myMessage2: $newMsgId()
}