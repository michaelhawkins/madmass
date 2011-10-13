//==============================================
// GUI
//==============================================

Core.Gui = new Class.Singleton({
  Extends: Core.Actor,

  options: {
    cssClass: 'gui'
  },

  /* Initialize and builds the gui based on the options. */
  initialize: function(options){
    this.parent();
    $log('Core.Gui: initializing...', {nest: 'open'});
    this.assign('<div>', {'class': this.options.cssClass});
    this.positionTo(0,0);
    Core.frame.appendChild(this);
    this.namespace = window[options.namespace]['Gui'];
    $log('Core.Gui: gui items namespace => ' + options.namespace + '.Gui');
    if(!this.namespace){
      $log('Core.Gui: invalid namespace for gui items: ' + this.namespace + '.Gui', {level:'error'});
      return;
    }
    this.buildGui(options.items);
    $log('Core.Gui: OK.', {nest: 'close'});
  },

  /* Istantiates every static gui item. */
  buildGui: function(items){
    var itemClass = '';
    items.each(function(item){
      item = $H(item);
      try{
        itemClass = item.getKeys()[0];
        $log('Core.Gui: istanciating item => ' + itemClass);
        var options = item.getValues()[0];
        var newItem = new this.namespace[itemClass](options);
        this.appendChild(newItem);
      } catch(err){
        $log('Core.Gui: error instantiating ' + itemClass, {level:'error'});
      }
    }, this);
  }

});

/********************************************************************************/
/* Base class for all GUI items. It follows some convention:
 *
 * - item template is assigned in the options.template variable.
 * - every item accumulates in the prefix variable (a string) the parents templates.
 *   For example: "bar-commons-" if its parents templates are "bar" and "commons".
 * - the item dom is get from a template. The template name is:
 *   > prefix + template + postfix, or if not found:
 *   > template + postfix
 *   The first form allows to personalize the template if inserted into an item.
 * - After all this initializations the init(options) method is called, where you put your
 *   initialization code.
 *
 * An item can have sub items ({..., items: {subitems definitios} })
 **/
Core.Gui.Item = new Class({
  Extends: Core.DynamicActor,
  Implements: Core.Dispatchable,

  options: {
    template: 'empty',
    postfix: "-template",
    nullTemplate: 'none'
  },
  

  initialize: function(options){
    options = options || {};

    if(options.template){
      this.options.template = options.template
    }
    if(options.anchor){
      this.anchor = $H(this.anchor).extend(options.anchor).getClean();
    }
    this.parent();
    this.build(options);
    this.init(options);
  },

  // Spawns the dom from the template and assigns it to the item
  build: function(options){
    this.fromTemplate(options.subs);

    // Positions the element
    options.x = options.x || 0;
    options.y = options.y || 0;
    this.positionTo(options.x, options.y);
  },

  /* Spawns the template.
   * If the template == nullTemplate the it will create an empty div without searching for a template.
   **/
  fromTemplate: function(substitution){
    var element = null;
    if(this.options.template == this.options.nullTemplate){
      element = jQuery('<div>');
    } else {
      element = $template(this.options.template + this.options.postfix, substitution)
      if(element == null){
        $log("Core.Gui.Item: no template found for " + this.options.template, {level:'error'});
        throw 'Core.Gui.Item: template error';
      }
    }
    this.assign(element);
  },

  // Override this function to initialize your gui item.
  init: function(options){
  }

});

/********************************************************************************/
// TEMPLATES Factory

/* Finds a tempalte with the passed element id and returns
 * the jquery-ized template with optionally substituted parts.
 * Returns null if no template was found.
 **/
Core.Gui.TemplateFactory = new function(){
  this.make = function(templateId, substitutions){
    var template = $("#" + templateId);

    // Returns null to indicate that no template was found
    if(template.length == 0){
      return null;
    }

    // Makes a clone of the template (like a new instance).
    var dom = template.clone().html();

    // Makes substitutions if needed
    if($defined(substitutions)){
      dom = dom.substitute(substitutions);
    }

    // Returns the jquery-ized template
    return $(dom);
  }
}
$template = Core.Gui.TemplateFactory.make;
