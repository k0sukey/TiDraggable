Reconstruct adsorb propertie.

New feature "adsorb" support.

Customized maxLeft, minLeft, maxTop, minTop properties.
If you specify the coordinates, the DraggableView will not be able to move out.

And, "move" event listener added.
ex. draggableView.addEventListener('move', function(e){});

"adsorb" propertie is...
The adsorption to the top/left, max/min coordinates.

### example app.js ###
	var window = Ti.UI.createWindow({
	    navBarHidden: true
	});
	
	var draggable = require('ti.draggable');

	var view = draggable.createView({
	    top: window.height * 0.5 - 24,
	    left: window.width * 0.5 - 24,
	    width: 48,
	    height: 48,
	    minTop: 0,
	    minLeft: 0,
	    maxTop: window.height - 48,
	    maxLeft: window.width - 48,
	    adsorb: draggable.ADSORB_NONE, // ADSORB_NONE,ADSORB_CORNER,ADSORB_VERTICAL,ADSORB_HORIZONTAL,(ADSORB_SPECIFIED yet...)
	    backgroundColor: '#f00',
	    borderRadius: 24,
	    opacity: 0.9
	});
	window.add(view);
	
	view.addEventListener('end', function(e){
	    Ti.API.info(e);
	});
	
	window.open();




...Axis? I did not test :P


---

Demo Video:

http://www.screenr.com/S3as

---

## How to install the module:

1. Create a new property in tiapp.xml:
```
    <module version="1.0" platform="iphone">ti.draggable</module>
```
2. Copy the zip file to the root of your project.
3. require the module in your application:
```
Ti.Draggable = require('ti.draggable');
```
4. Clean your build directory
5. Build.

## How to use the module
To create a draggable view, simple create it like so:
```
   var view = Ti.Draggable.createView({ _props });
```

Treat this view as a normal Ti.UI.View, but keeping in mind that this view has the draggable properties already build in; if nothing is specified, it will be draggable all over the screen.

## Properties:

### These will make the view slide to their coresponding positions

* maxLeft: (int)
* minLeft: (int)
* maxTop: (int)
* minTop: (int)

### This will make the view stick to it's axis:

* axis: (String) "x" or "y"

## Event Listeners

1. start: will fire on touch start
2. top: will fire on when the view has finished moving

---

## TODOS
Let's add more functionality to this module. I don't have a list of "todos", but please, feel free to add to it. Be creative, have ideas, submit pull requests.
