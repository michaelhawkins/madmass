/* Gamecore mini js library for js game programming
 * Based on moo4q (mootools for jQuery)
 * © Algorithmica 2010
 */

/*********************************************************************
 *          Mootools singleton class with lazy instantiation
 *********************************************************************/
/* Singleton class pattern for mootools. The class is instanciated
 * by the first call to getInstance(), so it's safe to use even if you
 * need to instanciate it only after a document ready event.
 * Use example:
 *
 *  var MySingleton = new Class.Singleton({... standard mootools class definition ...});
 *  var istance = MySingleton.getInstance();
 *
 * you can also create singleton that accepts parameters (options hash) in their initialize:
 *
 *  var MySingleton2 = new Class.Singleton({
 *    Implements: Options,
 *    options: {
 *      initialState: 23
 *    },
 *    state: 0,
 *    initialize: function(options){
 *      this.setOptions(options);
 *      this.state = this.options.initialState;
 *    },
 *    ...
 *  });
 *
 * so you can customize the instance providing options to the first getInstance call:
 *
 *  var istance2 = MySingleton2.getInstance({initialState: 11});
 **/
Class.Singleton = new Class({
  klass: null,
  instance: null,
  initialize: function(classDefinition){
    this.klass = new Class(classDefinition);
  },
  getInstance: function(options){
    if(this.instance == null){
      this.instance = new this.klass(options);
    }
    return this.instance;
  }
});

/*********************************************************************
 * Adds html escaping and unescaping to String (copied from prototype)
 *********************************************************************/
String.implement({
  escapeHTML: function() {
    return this.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
  },
  unescapeHTML: function() {
    return this.stripTags().replace(/&lt;/g,'<').replace(/&gt;/g,'>').replace(/&amp;/g,'&');
  }
});

/*********************************************************************
 *                            THE CORE
 *********************************************************************/
var Core = Core || {}; // Core namespace

/* Extensions can put specific initializing code callbacks here, they
 * will be called in the Core.init() function. Use Core.extensionInitializer to
 * provide the init function for the extension. Example:
 *
 * -------top of the page--------
 * Core.extensionInitializer(function(){
 *    // Your code goes here
 * });
 * 
 * ...
 * */
Core.initializers = [];
Core.extensionInitializer = function(callback){
  Core.initializers.push(callback);
}

/* Prepares the gloabl variable unrealCore and init core functions.
 * !!> Call it before using any core functions <!! */
Core.init = function(options) {
  // Used to assign unique objects id. Incremented on each instence.
  Core.nextObjectId = (new function(){
    var objectIdCounter = 0;
    this.get = function(){
      return objectIdCounter++;
    }
  }).get;

  options = options || {};
  if(options.debug) Konsole.enable(options.debug);
  Core.logger = Core.Logger.getInstance();
  $log = options.log ? Core.logger.log.bind(Core.logger) : function(){};
  $log('Core: initializing...', {nest: 'open'});
  Core.frame = Core.MainFrame.getInstance();
  Core.scheduler = Core.Scheduler.getInstance();
  Core.initializers.each(function(initExtension){
    initExtension();
  });
  $log('Core: OK.', {nest: 'close'});
}

/*********************************************************************/
// Predefined core events
Core.Events = {
  destroyed: 'destroyed'
}

/*********************************************************************
 *                            BASE CLASS
 *********************************************************************/
Core.Base = new Class({
  objectId: -1, // Unique object identifier,set in the initialize

  // Assigns an unique object id to every instance
  initialize: function(){
    this.objectId = Core.nextObjectId();
  },

  // Called on object destruction
  destroy: function(){
    // First removes all observed objects
    this.observed.each(function(obj){
      obj.observers.erase(this);
    }, this);
    this.observed = null;

    // Then removes me from observers observed array :) I don't need to be observed anymore as I'm dying
    this.observers.each(function(obj){
      obj.observed.erase(this);
    }, this);

    // Finally notifies my destruction to observers
    this.notifyObservers(Core.Events.destroyed);
    this.observers = null;
  },

  /***************************************/
  //  Core objects implement by default  //
  //      the observer pattern!          //
  /***************************************/

  // Observers collection (to notify with notifyObservers()
  observers: [],
  // Objects observed by me. I need it because I have to unobserve them if I'm destroyed.
  observed: [],

  /**************************************/
  // Observe an observable object (that implements Module.Observer)
  observe: function(observable){
    if(!observable.observers.contains(this)){
      observable.observers.push(this);
      this.observed.push(observable);
    }
  },
  // Stop observing an observable object (that implements Module.Observer)
  unobserve: function(observable){
    observable.observers.erase(this);
    this.observed.erase(observable);
  },

  /**************************************/
  /* Called by the observed object, override this method.
   * - observed: observed object that executed notifyObsevers
   * - event: optional parameter that specifies the type of notification (es: destroy, change, ...) */
  notify: function(observed, event){
    // Override me and do something useful ^_^
  },

  /* Notifies observers
   * - event: optional parameter to make a specific notification */
  notifyObservers: function(event){
    this.observers.each(function(observer){
      observer.notify(this, event);
    }, this);
  }

});

/*********************************************************************
 *                            CORE CLASSES
 *********************************************************************/

/***************************** Scheduler *****************************/
// Used to fire any kind of timed tasks. For now it only manages animations.
Core.Scheduler = new Class.Singleton({
  Extends: Core.Base,
  Implements: Options,

  options: {
    /* Animation frame per seconds. Don't rise it more than 1000/guard. */
    fps: 60,

    /* If an animation frame cannot be done within 1/fps, we could end up calling the tick
     * functions continuously freezing the browser. This guard is the minimum delay
     * that we assure between frames so that the browser can remain still responsive even if the
     * animation requires teoretically 100% cpu to try to keep the fps. */
    guard: 10
  },

  initialize: function(options){
    this.parent();
    $log('Core.Scheduler: initializing...', {nest: 'open'});
    this.setOptions(options);
    /* Delay between animation frames in ms. Note: rounding introduces a 'small' error in
     * the frame rate. Error increases with higher frame rates because the error is always ±0.5,
     * and delay decrease with fps so error/delay increases. */
    this.animationDelay = (1000 / this.options.fps).round();
    this.toAnimate = new Hash; // Dynamic Actors that needs to be animated and are called at every frame.
    this.running = false;
    $log('Core.Scheduler: OK.', {nest: 'close'});
  },

  // Call animate to add a dynamic actor to be animated. Static actors are ignored.
  animate: function(dynamicActor){
    if( (dynamicActor instanceof Core.DynamicActor) && (!this.toAnimate.get(dynamicActor.objectId)) ){
      this.toAnimate.set(dynamicActor.objectId, {
        actor: dynamicActor,
        time: (new Date).getTime()
        });
      if(!this.running){
        this.running = true;
        this.nextFrame(this.animationDelay);
      }
    }
  },

  /* Removes a dynamic actor from the animation queue, if there. Even If the scheduler is running
   * with this only dynamic actor it will automatically stop on the next schedule call. So it's safe
   * to remove any animated actor. */
  remove: function(dynamicActor){
    this.toAnimate.erase(dynamicActor.objectId);
  },
  
  // Performs scheduling
  schedule: function(){
    var start = (new Date).getTime();
    // animateActors() returns true if there are still actors that needs to be animated.
    this.running = this.animateActors();
    
    if(this.running){
      var nextDelay = this.animationDelay - ((new Date).getTime() - start);
      this.nextFrame(Math.max(this.options.guard, nextDelay));
    }
  },

  // Animates all the registered actors (in the animated hash)
  animateActors: function(){
    var time = 0;
    var dynamic = null;
    var animate = false;
    Core.scheduler.toAnimate.each(function(dynamic, id){
      time = (new Date).getTime();
      if(dynamic.actor.tick(time - dynamic.time)){
        dynamic.time = time;
        animate  = true;
      }else{
        // id actor's tick function returned false than we remove it from animated actors
        Core.scheduler.toAnimate.erase(id);
      }
    });
    return animate;
  },

  // Schedule next frame after delay time
  nextFrame: function(delay){
    setTimeout(Core.scheduler.schedule.bind(this), delay)
  }
});

/***************************** Actor *****************************/
// The Actor is a DOM element and it's Scene Graph is the DOM itself
Core.Actor = new Class({
  Extends: Core.Base,

  /* Anchor defines the coordinate system of the Actor. It tells what means
   * x and y and wheather the coordinate system is: ['relative'|'absolute'].
   * - relative and absolute: are the css values for position style
   * If you specify a different pos then no position style will be added and x and y coordinates will
   *   not be used but the pos will be added as class to the element.
   **/
  anchor: {x: 'left', y: 'top', type: 'absolute'},
  element: null,  // The dom element used to represent this actor in the browser.
  x: 0,           // In pixels. The coordinate system depends on the anchor (see anchor property)
  y: 0,           // In pixels. The coordinate system depends on the anchor (see anchor property)
  children: [],   // My children (Actors)
  parentActor: null, // My parent.
  dirty : true,   // Dirty flag is true when the Actor needs to be redrawn, false if not.
  propagatedDestroy: false, // used to handle correctly child destruction.

  initialize: function(){
    this.parent();
  },

  /* Called by the subclasses to create the dom element for this actor.
   *  obj:
   *    1) '<div>', '<img>' or other tags
   *    2) a standard dom element
   *    3) a jQuery element
   *  options: {..} attributes used to create the element if obj specifies a tag (1)
   * Example:
   *  this.assign('<div>', {id: 'elementID'});
   **/
  assign: function(obj, options){
    switch($type(obj)){
      case 'string':
        this.element = jQuery(obj, options);
        break;
      case 'element':
        this.element = jQuery(obj);
        break;
      case 'object':
        if(obj.jquery){
          this.element = obj
          break;
        }
      default:
        $log('Core.Actor: Invalid element assigned to the actor ' + this.objectId, {level: 'error'});
        throw 'Core.Actor: Invalid element';
    }
    if(this.element){
      this.element.attr({
        id: this.objectId
      });
      this.element.addClass(this.anchor.type); // Configures coordinate system to absolute positining
    }
    return this.element;
  },

  // Removes the dom element and removes this istance from parent children.
  // When no one references this istance anymore it will be garbage collected.
  destroy: function(){
    this.children.each(function(child){
      child.propagatedDestroy = true;
      child.destroy();
    });
    if(!this.propagatedDestroy){
      if(this.element) this.element.empty().remove(); // all events are also unbound
      if(this.parentActor) this.parentActor.children.erase(this);
    }
    this.children = null;
    this.parent();
  },

  /* Setta le coordinate dell'Actor senza ridisegnarlo.
   * Il sitema di coordinate dipende dallo stile css. Usando absolute
   * x ed y sono relative al primo parent che ha definito lo stile 'position'. */
  positionTo: function(x, y){
    this.x = x;
    this.y = y;
    this.dirty = true;
  },

  // Come il positionTo ma in aggiunta ridisegna l'oggetto
  moveTo: function(x, y){
    this.positionTo(x, y);
    this.draw();
  },

  moveRelativeTo: function(dX, dY){
    this.x += dX;
    this.y += dY;
    this.dirty = true;
    this.draw();
  },

  /* Appends an Actor to this one.
   * The actor will be pushed in this actor children, its' element will be appended
   * to this actor element, will be drawn and finally it's afterAppend will be called.
   * Parameters:
   *
   * - child: the child to append
   * - selector: optional selector string that defines where to append the child.
   *
   * If you do not specify a selector, the child element will be (jquery) appended to this
   * actor element, so it will appear as a direct child in last position. If you specify
   * a selector, it will be used to select a precise element node where to append the child
   * element.
   **/
  appendChild: function(child, selector){
    this.children.push(child);
    if(selector){
      this.element.find(selector).append(child.element);
    } else {
      this.element.append(child.element);
    }
    child.parentActor = this;
    child.dirty = true;
    child.draw();
    child.afterAppend();
    return this;
  },

  afterAppend: function(){
  // Use it in subclasses to execute actions after the Actor was added to the dom.
  },

  /* Il  draw di default imposta le coordinate correnti (il sistema di riferimento dipende dal css)
   * e ridisegna se stesso e tutti i figli.
   * Ogni attore poi può aggiungere o personalizzare la funzione di draw. */
  draw: function(){
    // Not the best way to implement dirty flag, should be in the logic of the calling method
    // not in the draw itself, but here we need to propagate draw to children
    if(this.dirty){
      if(this.anchor.type == "absolute" || this.anchor.type == "relative"){
        var pos = {};
        pos[this.anchor.x] = this.x +'px';
        pos[this.anchor.y] = this.y +'px';
        this.element.css(pos);        
      }
      this.dirty = false;
    }

    this.children.each(function(child){
      child.draw();
    });
  }

});

/***************************** StaticActor *****************************/
// Static actors cannot be animated
Core.StaticActor = new Class({
  Extends: Core.Actor,

  initialize: function(){
    this.parent();
  }
});

/***************************** DynamicActor *****************************/
// Dynamic actors can be animated
Core.DynamicActor = new Class({
  Extends: Core.Actor,

  initialize: function(){
    this.parent();
  },

  destroy: function(){
    Core.scheduler.remove(this);
    this.parent(); // excecutes Actor's remove
  },

  // Schedules this actor for animation. Animation stops when tick returns false.
  animate: function(){
    Core.scheduler.animate(this);
  },

  // delta: ms passed since last call
  tick: function(delta){
    return false;
  }
});

/***************************** MainFrame *****************************/
// The browser content frame (body)
Core.MainFrame = new Class.Singleton({
  Extends: Core.StaticActor,

  anchor: {x: 'left', y: 'top', type: 'relative'},

  initialize: function(){
    $log('Core.MainFrame: initializing...', {nest: 'open'});
    this.parent();
    this.assign(document.body);
    $log('Core.MainFrame: OK', {nest: 'close'});
  },

  getActor: function(id){
    var privateFinder = function(id){
      this.actor = null;
      var actorId = id;

      this.traverse = function(actor){
        if(actor.objectId == actorId){
          this.actor = actor;
          return true;
        }
        return actor.children.some(function(child){
          return this.traverse(child);
        }, this);
      }
    }

    var finder = new privateFinder(parseInt(id));
    finder.traverse(this);
    return finder.actor;
  },

  countActors: function(){
    var privateCounter = function(){
      this.count = 0;

      this.traverse = function(actor){
        actor.children.each(function(child){
          this.traverse(child);
        }, this);
        this.count++;
      }
    }

    var counter = new privateCounter;
    counter.traverse(this);
    return counter.count;
  }
});

/*********************************************************************
 *                             LOGGER
 *********************************************************************/
Core.Logger = new Class.Singleton({
  Extends: Core.Base,

  options: {
    indentChar: ' ',
    indentTab: 2
  },

  initialize: function(){
    this.parent();
    this.log('Logger active.');
    this.nestLevel = 0;
  },

  /* params:
   * - time: [true | false] include or not timestamp
   * - level: ['info' | 'warn' | 'error'] log level
   * - nest: ['open' | 'close'] when a nest is open, subsequesnt logs are indented by nesting level.
   *   */
  log: function(msg, options){
    options = options || {};
    options = $H(options).combine({time: true, level: 'info'});
    var indentDepth = this.nestLevel;
    switch(options.nest){
      case 'open':
        this.nestLevel++;
        break;
      case 'close':
        this.nestLevel = Math.max(0, this.nestLevel - 1);
        indentDepth = this.nestLevel;
        break;
    }
    var out = '';
    if(options.time){
      var time = new Date;
      var hour = time.getHours() + "";
      var min = time.getMinutes() + "";
      var sec = time.getSeconds() + "";
      if(hour.length == 1) hour = "0" + hour;
      if(min.length == 1) min = "0" + min;
      if(sec.length == 1) sec = "0" + sec;
      out += '[' + hour + '.' + min + ':' + sec + ']';
    }
    if( !(typeof Konsole[options.level] === 'function' ) ){
      options.level = 'info';
    }
    out += msg;
    var indent='';
    while(indent.length < (indentDepth * this.options.indentTab)) indent += this.options.indentChar;
    Konsole[options.level](indent + out);
  }
});


/*********************************************************************
 *                         DEBUGGING CORE
 *********************************************************************/
/* The Konsole is the basic debugger output.
 * You create one calling:
 *
 *    - Konsole.enable()
 * or
 *    - Konsole.enable(myCustomKonsoleObj)
 *
 * where myCustomKonsoleObj can be any object that implements the following method:
 *
 *    wirte(msg, type, escape)
 *
 * where:
 *    - msg: is the text to write to the console
 *    - type: ['info' | 'warn' | 'error' | 'log'] specifies the text type so different styles can be applied
 *    - escape: [true | false] specifies if the text must be escaped or no (typically it means html escaping
 *              but it's up to you)
 *
 * If you do not specify a myCustomKonsoleObj, Konsole out will be redirected to the standard console
 * using the default Konsole.Base.
 * 
 * You write to the output using these methods:
 *
 *    - Konsole.info(msg, escape)
 *    - Konsole.warn(msg, escape)
 *    - Konsole.error(msg, escape)
 *    - Konsole.log(msg, escape)
 *
 * Konsole.out refers to the Konsole object used so you have always a reference to it.
 **/
var Konsole = Konsole || { // Standard javascript
  out: null, // Any object that has write(msg, type, escape) function.
  info: function(msg, escape){
    if(Konsole.out) Konsole.out.write(msg, 'info', escape);
  },
  warn: function(msg, escape){
    if(Konsole.out) Konsole.out.write(msg, 'warn', escape);
  },
  error: function(msg, escape){
    if(Konsole.out) Konsole.out.write(msg, 'error', escape);
  },
  log: function(msg, escape){
    if(Konsole.out) Konsole.out.write(msg, 'log', escape);
  },

  /* Enables or disables the console.
   * consoleObj: [true|false|Konsole.* instance]
   * If true, makes a Konsole.Base or uses the specific Konsole object if provided.
   * If false disables the console. */
  enable: function(consoleObj){
    if(consoleObj == undefined) consoleObj = true;

    // Removes an already existing Konsole if any.
    if(Konsole.out){
      if(Konsole.out.element){
        Konsole.out.destroy(); // It's an Actor, so we must call it's destroy() function that removes the DOM element.
      } else {
        delete Konsole.out; // It's a non Actor object and we can simply delete it
      }
      Konsole.out = null;
    }

    // Creates a Konsole if requested and if the debugging module is included.
    if(consoleObj && Konsole.Base){
      // Deletes an existing console if any
      // Creates the requested console (NOTE Konsole.Base is not in the Core)
      Konsole.out = (consoleObj == true ? new Konsole.Base : consoleObj);
      // If the console is an Actor, attaches it to the MainFrame
      if(Konsole.out.element) Core.frame.appendChild(Konsole.out);
    }

    return Konsole.out;
  }
};

/* Base debugging facility. Messages are shown in the javascript console. */
Konsole.Base = new Class({
  write: function(msg, type){
    switch (type) {
      case 'info':
        console.info(msg)
        break;
      case 'warn':
        console.warn(msg)
        break;
      case 'error':
        console.error(msg)
        break;
      default:
        console.log(msg)
        break;
    }
  }
});
