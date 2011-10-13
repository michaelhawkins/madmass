/* Debugging extension for Gamecore library
 * © Algorithmica 2010
 * */

/*********************************************************************
 *                            DEBUGGING
 *********************************************************************/
// Debug messages are written inside a draggable/resizable panel.
// TODO: Make/use a window > panel instead.
Konsole.Panel =  new Class({
  Extends: Core.StaticActor,
  Implements: Module.DragAndDrop,

  options: {
    panel: {cssClass: 'debug_panel'},
    title: {cssClass: 'title'},
    content: {cssClass: 'content'},
    debugs: {cssClass: 'debugs'},
    footer: {cssClass: 'footer'},
    clear: {cssClass: 'clear'}
  },

  initialize: function(panelTitle){
    this.parent();
    var panel = jQuery('<div>')
      .addClass(this.options.panel.cssClass);

    this.title = jQuery('<h4>')
      .addClass(this.options.title.cssClass)
      .html(panelTitle || 'Konsole');

    this.content = jQuery('<div>')
      .addClass(this.options.content.cssClass);

    this.debugs = jQuery('<div>')
      .addClass(this.options.debugs.cssClass);

    this.footer = jQuery('<div>')
      .addClass(this.options.footer.cssClass);

    this.clear = jQuery('<span>')
      .addClass(this.options.clear.cssClass)
      .html('Clear');
    this.clear.click(this.clearContent.bind(this));

    panel.append(this.title);
    panel.append(this.clear);
    this.content.append(this.debugs);
    panel.append(this.content);
    panel.append(this.footer);
    this.assign(panel);

    this.draggable({
      handle: 'h4',
      opacity: 0.7
    });
    this.element.resizable({
      minWidth: 150,
      minHeight: 100,
      alsoResize: '.' + this.options.panel.cssClass + ' .' + this.options.content.cssClass
    });
  },
  
  write: function(msg, type, escape){
    var stamp = '- ';
    if(Konsole.timestamp){
      var time = new Date;
      var hour = time.getHours() + "";
      var min = time.getMinutes() + "";
      var sec = time.getSeconds() + "";
      if(hour.length == 1) hour = "0" + hour;
      if(min.length == 1) min = "0" + min;
      if(sec.length == 1) sec = "0" + sec;
      stamp = '<span class="entry">' + hour + '.' + min + ':' + sec + '</span> ';
    }
    var message = (!$defined(escape) || escape) ? msg.escapeHTML() : msg;
    this.debugs.append('<div class="debug-message">' + stamp + "<span class='" + type + "'>" + message + '</span></div>');
    this.content.scrollTop(this.debugs.height());
  },

  clearContent: function(event){
    this.debugs.empty();
  }
});

