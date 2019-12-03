/*global $ */
/*global alert */
/*global document */
var SAVE_FORM_BUTTON_ID = "save_form_button";
var CANCEL_FORM_BUTTON_ID = "cancel_form_button";
var EDIT_FORM_BUTTON_ID = "edit_form_button";

var LOGIN_MENU_ID = "dt-login-menu";
var VIEW_MENU_ID = "dt-view-menu";
var EDIT_MENU_ID = "dt-edit-menu";

var HASH = "#";
var DOT = ".";

var Deltares = Deltares || {};
var MESSAGE_CANCEL_BUTTON = "Are you sure you want to cancel? All your changes will be lost.";
/**
 * http://stackoverflow.com/questions/1271503/hide-options-in-a-select-list-using-jquery
 */
$.expr[':'].icontains = function(obj, index, meta, stack){
	return (obj.textContent || obj.innerText || jQuery(obj).text() || '').toLowerCase().indexOf(meta[3].toLowerCase()) >= 0;
};
/**
 * http://stackoverflow.com/questions/646628/how-to-check-if-a-string-startswith-another-string
 */
if (typeof String.prototype.startsWith != 'function') {
  String.prototype.startsWith = function (str){
    return this.slice(0, str.length) == str;
  };
}
/**
 * http://stackoverflow.com/questions/2308134/trim-in-javascript-not-working-in-ie
 * */
if(typeof String.prototype.trim !== 'function') {
	String.prototype.trim = function() {
		return this.replace(/^\s+|\s+$/g, ''); 
	};
}
	
Deltares.setParentId = function(id) {
    var obj = document.scripts[document.scripts.length - 1].parentNode;
    obj.id = id;
};

Deltares.enterViewMode = function() {
    $(HASH + LOGIN_MENU_ID).show();
    $(HASH + VIEW_MENU_ID).show();
    $(HASH + EDIT_MENU_ID).hide();
	
	// Let user leave the page
	window.onbeforeunload = null;
};

Deltares.enterEditMode = function() {
    $(HASH + LOGIN_MENU_ID).hide();
    $(HASH + VIEW_MENU_ID).hide();
    $(HASH + EDIT_MENU_ID).show();
	
	// Warn user changes will not be saved
	window.onbeforeunload = function (event) {
		var e = event || window.event;
		if (e) e.returnValue = MESSAGE_CANCEL_BUTTON;
		return MESSAGE_CANCEL_BUTTON;
	};
};

$(document).on("ready",function() {
	$(HASH + EDIT_FORM_BUTTON_ID).on("click",function(){
        Deltares.enterEditMode();
    });

    $(HASH + CANCEL_FORM_BUTTON_ID).on("click",function(e){
		if( confirm(MESSAGE_CANCEL_BUTTON) ){
			// Go to the view mode
			Deltares.enterViewMode();
		}else{
			// Continue editing
			e.stopImmediatePropagation();
		}
    });

    $(HASH +SAVE_FORM_BUTTON_ID).on("click",function(){
        Deltares.enterViewMode();
    });

});
