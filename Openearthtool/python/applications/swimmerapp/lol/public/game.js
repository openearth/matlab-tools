/* 

The animation of swimmers can be based on this game:
http://glimr.rubyforge.org/cake/missile_fleet.html 
*/

/*
Classes:

PersonNode: Represents a swimmer
CanvasNode: A visual node
*/
PersonNode = Klass(CanvasNode, {
    rotation : 0,
    targetAngle : 0,
    turningSpeed : 1,
    health : 100,
    movementSpeed : 20,
    trajectory: {0: [0.0]},
    id : 0,
    initialize : function() {
        this.id = PersonNode.id++;
        CanvasNode.initialize.apply(this, arguments)
	this.healthBar = new Rectangle(8, 20, {
            fill: 'green', 
	    stroke: 'white',
            centered: true, 
	    cx: 10,
	    cy: 10
        });
	var img = new Image();
	img.src = '/images/person-1-cool.png';

	this.face = new ImageNode(img, {x:10});


        this.addFrameListener(this.updateFace);
        this.addFrameListener(this.updateHealth);

    },
    updateHealth : function(t,dt) {
        if (this.healthBar) {
            this.healthBar.height = Math.max(0, parseInt(this.health /5.0));
            this.healthBar.opacity = this.opacity;
            this.healthBar.x = this.x;
            this.healthBar.y = this.y;
        }
	this.healthBar.removeSelf();
	if (this.healthBar.parent != this.parent) {
	    this.parent.append(this.healthBar);
	}


    },
    updateFace : function(t, dt) { 
	this.face.removeSelf();
	if (this.face.parent != this.parent) {
	    this.parent.append(this.face);
	}


    }
    
});
    

Game = Klass(CanvasNode, {
    initialize : function(overlay) {
        CanvasNode.initialize.call(this);
        this.canvas = new Canvas(overlay.canvas);
	this.canvas.append(this);
	this.append(new PersonNode());

    }
});

function initgame() {
    var latlng = new google.maps.LatLng(52.63,4.59);
    var myOptions = {
	zoom: 13,
	center: latlng,
	mapTypeId: google.maps.MapTypeId.HYBRID,
	disableDefaultUI: true
    };
    map = new google.maps.Map($('#game_canvas')[0], myOptions);
    var swBound = new google.maps.LatLng(52.61, 4.55);
    var neBound = new google.maps.LatLng(52.65, 4.63);
    var bounds = new google.maps.LatLngBounds(swBound, neBound);
    overlay = new CanvasOverlay(bounds, map);
    overlay.onDraw = function(overlay) {
	game = new Game(overlay);
    };
};
