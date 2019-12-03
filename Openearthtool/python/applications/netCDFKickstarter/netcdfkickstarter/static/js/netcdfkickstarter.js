(function( $, undefined ) {

    var thisObject = this;

    $.widget( "ui.netcdfKickstarter", {
	version: "0.0.1",
	options: {
	    jsonHost: "/",
	},

	_objTemplateSelector:  null,
	_objDimensionSelector: null,
	_objVariableSelector:  null,
	_objOutputSelector:    null,

	_create: function() {
	    var thisObject = this;

	    objClr = '<div style="clear:both;">';

	    $(window)
		.bind("load",   function() { thisObject._resize(); })
                .bind("resize", function() { thisObject._resize(); });

	    $(this.element).addClass("netcdfkickstarter");

	    this._objTemplateSelector  = this._getTemplateSelector ();
	    this._objDimensionSelector = this._getDimensionSelector();
	    this._objVariableSelector  = this._getVariableSelector ();
	    this._objOutputSelector    = this._getOutputSelector   ();

	    $("<form>")
		.attr("action","#")
		.attr("method","post")
		.bind("submit", function() { thisObject._setFormAction(); })
		.append(this._objTemplateSelector )
		.append(this._objDimensionSelector)
		.append(this._objVariableSelector )
		.append(this._objOutputSelector   )
		.appendTo(this.element)

	    this._resize();
	},

	_resize: function() {
	    w = $(this.element).width();
	    h = $(this.element).height();

	    $(".netcdfkickstarter-column").css("height",parseInt(h));
	    $(".netcdfkickstarter-template .netcdfkickstarter-block").css("height",parseInt(h/2-2));
	},

	/*****************************************************************************
	 ** PUBLIC FUNCTIONS                                                        **
	 *****************************************************************************/



	/*****************************************************************************
	 ** GUI CONSTRUCTORS                                                        **
	 *****************************************************************************/

	_getTemplateSelector: function() {
	    var thisObject = this;

	    var obj1 = $("<div>")
		.addClass("netcdfkickstarter-block");

	    /*************************************************
	     * <input> filename                              *
	     *************************************************/

	    $("<div class=\"label\">")
		.text("Filename:")
		.appendTo(obj1);

	    $("<input>")
		.attr("name","filename")
		.attr("value","kickstarter.nc")
		.attr("title","Filename of the netCDF file to be created")
		.tooltip({position:{my:"left",at:"right+10px"}})
		.appendTo(obj1);

	    /*************************************************
	     * <select> template                             *
	     *************************************************/

	    var objTemp = $("<div class=\"label\">")
        .text("Template:")
        .append("<div style=\"display:inline-block;vertical-align: bottom;\"><a href=\"https://www.nodc.noaa.gov/data/formats/netcdf/v2.0/\" title=\"Information and examples of NCEI NetCDF Templates v2.0\" target=\"_blank\"><span class=\"ui-icon ui-icon-info\"></span></a></div>")
		.appendTo(obj1);

	    var objSelect = $("<select>")
		.attr("name","template")
		.attr("title","Template to be used as basis for the netCDF file to be created. Choose a template that corresponds best to your data. \"Orthogonal\" templates are used for data that share the same time/space discretization, so share the same axes. Data in these formats may contain NaN's. Data that does not share axes may use templates with \"Incomplete\" in the name.")
		.tooltip({position:{my:"left",at:"right+10px"}})
		.bind("change", function() {
		    thisObject._getDimensions($(this).val());
		    thisObject._getUserData($(this).val()); })
		.appendTo(obj1);

	    var json_url = this.options.jsonHost + "json/templates?callback=?";
	    $.getJSON(json_url, function(data) {
		for (var i=0; i<data.length; i++) {
		    $("<option>")
			.val(data[i][0] + '.cdl')
            .text(data[i][0])
            .attr('title', data[i][1])
			.appendTo(objSelect);
		};

		if (data.length>0) {
		    thisObject._getDimensions(data[0][0] + '.cdl');
		    thisObject._getUserData(data[0][0] + '.cdl');
		}
	    });

	    /*************************************************
	     * <select> coordinate reference system          *
	     *************************************************/

        // $("<div class=\"label\">")
        // .text("Coordinate reference system:")
        // .appendTo(obj1);
        //
        // var objSelectCRS = $("<select>")
        // .attr("name","crs")
        // .attr("title","Coordinate reference system that is used for your data")
        // .tooltip({position:{my:"left",at:"right+10px"}})
        // .appendTo(obj1);
        //
        // var json_url = this.options.jsonHost + "json/coordinatesystems?callback=?";
        // $.getJSON(json_url, function(data) {
        // for (var i=0; i<data.length; i++) {
		 //    $("<option>")
			// .val(data[i]["epsg_code"])
        //                 .text(data[i]["_name"])
			// .appendTo(objSelectCRS);
        // };
        // });

	    var obj2 = $("<div>")
		.addClass("netcdfkickstarter-block");

	    return $("<div>")
		.addClass("netcdfkickstarter-column")
		.addClass("netcdfkickstarter-template")
		.append(obj1)
		.append(obj2);
	},

	_getDimensionSelector: function() {
	    var thisObject = this;

	    var obj = $("<div>")
		.addClass("netcdfkickstarter-block");

	    var objMenu = $("<div>")
		.addClass("netcdfkickstarter-menubar")
		.appendTo(obj);

	    $("<div>")
		.text("Add dimension")
		.button({
		    text:true,
		    disabled:true,
		    icons: { primary: "ui-icon-plus" }})
		.bind('click', function() { })
//		.attr("title","Add a new dimension to your netCDF file")
//		.tooltip()
		.appendTo(objMenu);

	    $("<div>")
		.addClass("netcdfkickstarter-content-block")
		.appendTo(obj);

	    return $("<div>")
		.addClass("netcdfkickstarter-column")
		.addClass("netcdfkickstarter-dimension")
		.append(obj);
	},

	_getVariableSelector: function() {
	    var thisObject = this;

	    var obj = $("<div>")
		.addClass("netcdfkickstarter-block");

	    var objMenu = $("<div>")
		.addClass("netcdfkickstarter-menubar")
		.appendTo(obj);

	    $("<div>")
		.text("Add variable")
		.button({
		    text:true,
		    icons: { primary: "ui-icon-plus" }})
		.bind('click', function() { thisObject._addVariable(); })
		.attr("title","Add a new variable to your netCDF file")
		.tooltip()
		.appendTo(objMenu);

	    $("<div>")
		.addClass("netcdfkickstarter-content-block")
		.accordion({
		    header: "> div > h3",
		    heightStyle: "content"
		}).sortable({
		    axis: "y",
		    handle: "h3",
		}).appendTo(obj);

	    return $("<div>")
		.addClass("netcdfkickstarter-column")
		.addClass("netcdfkickstarter-variable")
		.append(obj);
	},

	_getOutputSelector: function() {
	    var thisObject = this;

	    var obj = $("<div>")
		.addClass("netcdfkickstarter-block")
		.addClass("netcdfkickstarter-content-block");

	    var objFormats = $("<div>")
		.appendTo(obj);

	    var output_formats = new Array();
        output_formats[0] = {value:"cdl",       label:"CDL",            title:"text representation of netCDF structure (network Common Data form Language)"};
        output_formats[1] = {value:"ncml",      label:"ncML",            title:"netCDF Markup Language, an XML representation of netCDF metadata"};
        output_formats[2] = {value:"netcdf",    label:"netCDF",            title:"Network Common Data Form"};
        output_formats[3] = {value:"python",    label:"Python",            title:"Python script to create netCDF"};
        output_formats[4] = {value:"rncdf4",      label:"R",            title:"R language (ncdf4)"};
        output_formats[5] = {value:"matlab", label:"Matlab",            title:"Matlab script to create netCDF, using native Matlab functions"};
        output_formats[6] = {value:"c",      label:"C",            title:"C code to create netCDF"};
        output_formats[7] = {value:"java",      label:"Java",            title:"Java code to create netCDF"};
        output_formats[8] = {value:"f77",      label:"F77",            title:"Fortran 77 code to create netCDF"};


	    var default_value = "matlab";
	    if($.cookie("format") !== undefined) {
		default_value = $.cookie("format");
	    }

	    for (var i=0; i<output_formats.length; i++) {

		$("<input>")
		    .attr("type","radio")
		    .attr("name","format")
		    .attr("id","r" + i)
		    .attr("value",output_formats[i]["value"])
		    .prop("checked",output_formats[i]["value"]==default_value)
		    .bind("change", function() {
			$.cookie("format", $(this).val()); })
		    .appendTo(objFormats);

		$("<label>")
		    .attr("for","r" + i)
            .attr("title",output_formats[i]["title"])
		    .text(output_formats[i]["label"])
		    .appendTo(objFormats);

	    }

	    objFormats.buttonsetv();

	    $("<input>")
		.attr("type","checkbox")
		.attr("name","download")
		.attr("value",1)
		.attr("id","chk_download")
		.appendTo(obj);

	    $("<label>")
		.attr("for","chk_download")
		.text("download as file")
		.appendTo(obj);

	    $("<input>")
		.attr("type","submit")
		.attr("value","Kickstart!")
		.button()
		.appendTo(obj);

	    return $("<div>")
		.addClass("netcdfkickstarter-column")
		.addClass("netcdfkickstarter-output")
		.append(obj);
	},

	/*****************************************************************************
	 ** ACTION HANDLERS                                                         **
	 *****************************************************************************/

	_getDimensions: function(tmpl) {
	    var thisObject = this;

	    var obj = $(this._objDimensionSelector).find(".netcdfkickstarter-content-block");

	    obj.html("");

	    var json_url = this.options.jsonHost + "json/templates/" + tmpl + "?category=dim&callback=?";
	    $.getJSON(json_url, function(data) {
		for (var i=0; i<data.length; i++) {
		    $("<div class=\"label\">")
			.text(data[i]["key"] + ":")
			.appendTo(obj);

		    var objInput = $("<input>")
			.attr("name","m[dim." + data[i]["key"] + "]")
			.attr("value",data[i]["default"])
			.attr("title",data[i]["description"])
			.tooltip({position:{my:"left",at:"right+10px"}})
			.appendTo(obj);

		    objInput.spinner({
			min:0,
			step:1,
			page:10,
			spin:function(event,ui) {
			    if (ui["value"]==0) {
				$(this).val("UNLIMITED");
				return false;
			    }
			},
		    });
		}
	    });
	},

	_getUserData: function(tmpl) {
	    var thisObject = this;

	    var obj = $(this._objTemplateSelector).find(".netcdfkickstarter-block:last");

	    obj.html("");

	    var json_url = this.options.jsonHost + "json/templates/" + tmpl + "?category=user&callback=?";
	    $.getJSON(json_url, function(data) {
		for (var i=0; i<data.length; i++) {

		    if($.cookie(data[i]["key"]) !== undefined) {
			data[i]["default"] = $.cookie(data[i]["key"]);
		    }

		    $("<div class=\"label\">")
			.text(data[i]["key"] + ":")
			.appendTo(obj);

		    var objInput = $("<input>")
			.attr("name","m[user." + data[i]["key"] + "]")
			.attr("value",data[i]["default"])
			.attr("title",data[i]["description"])
			.attr("key",data[i]["key"])
			.tooltip({position:{my:"left",at:"right+10px"}})
			.bind("change", function() { $.cookie($(this).attr("key"),
							      $(this).val()); })
			.appendTo(obj);
		}
	    });
	},

	_addVariable: function() {
	    var thisObject = this;

	    $("<div>")
		.append($("<div class=\"label\">")
			.text("Variable name:"))
		.append($("<input>")
			.attr("type","text")
			.attr("name","var_name")
			.attr("value","")
			.css("width","100%")
			.bind("keypress",function(event){
			    if (event.keyCode == 13) {
				thisObject._createVariable($(this).parent().find("input[name='var_name']").val());
				$(this).parent().dialog("close");
			    }}))
		.dialog({
		    title:"Create new variable",
		    autoOpen:true,
		    width:300,
		    height:130,
		    modal:true,
		    close:function() {
			$(this).dialog("destroy"); },
		    buttons:{
			"Create variable":function() {
			    thisObject._createVariable($(this).find("input[name='var_name']").val());
			    $(this).dialog("close"); },
			"Cancel":function() {
			    $(this).dialog("close"); }}});
	},

	_removeVariable: function(var_name) {
	    $(this._objVariableSelector).find("div.group[variable='" + var_name + "']").remove();
	    $(this._objVariableSelector).find(".ui-accordion").accordion("refresh");
	},

	_createVariable: function(long_name) {
	    var thisObject = this;

	    var obj = $(this._objVariableSelector).find(".ui-accordion");

	    var var_name = long_name.replace(/\W+/g,"_");

	    var objHeader = $("<h3>").text("VARIABLE: ");
	    var objBody   = $("<div>");

	    $("<input>")
		.attr("type","text")
		.attr("name","m[var.name]")
		.attr("value",var_name)
		.attr("title","Name of netCDF variable. Do not use any spaces of special characters in this name. Only letters, numbers and underscores (_) are allowed.")
		.tooltip({position:{my:"left",at:"right+10px"}})
		.css("border","0px")
		.css("background-color","transparent")
		.appendTo(objHeader);

	    $("<div>")
		.button({
		    text:false,
		    icons: { primary: "ui-icon-trash" }})
		.attr("title","Remove this variable from your netCDF file")
		.tooltip()
		.bind('click', function() { thisObject._removeVariable(var_name); })
		.appendTo(objHeader);

	    $("<div class=\"label\">")
		.text("Long name:")
		.appendTo(objBody);

	    $("<input>")
		.attr("type","text")
		.attr("name","m[var.long_name]")
		.attr("value",long_name)
		.attr("title","Descriptive name of netCDF variable. Any characters are allowed in this field")
		.tooltip({position:{my:"left",at:"right+10px"}})
		.appendTo(objBody);

	    $("<div class=\"label\">")
		.text("Standard name:")
		.appendTo(objBody);

	    $("<input>")
		.attr("type","text")
		.attr("name","m[var.standard_name]")
		.attr("for",var_name)
		.attr("value","")
		.attr("title","Standard name for netCDF variable from the CF convention list of standard names. Suggestions from this list are given while you type. Please select a name from the list most appropriate for your data")
		.tooltip({position:{my:"left",at:"right+10px"}})
		.autocomplete({
		    minLength:2,
		    select: function(event, ui) {
			thisObject._objVariableSelector
			    .find("input[name='m[var.units]'][for='" + $(this).attr("for") + "']")
			    .val(ui["item"]["units"]); },
		    source: function(request, response) {
			var json_url = thisObject.options.jsonHost + "json/standardnames/?search=" + request.term + "&callback=?";
			$.getJSON(json_url, function(data) {
			    response($.map(data, function(item) {
				return {
				    label: item["standard_name"] + " [" + item["units"] + "]",
				    units: item["units"],
				    value: item["standard_name"]}})); })}})
		.appendTo(objBody);

	    $("<div class=\"label\">")
		.text("Units:")
		.appendTo(objBody);

	    $("<input>")
		.attr("type","text")
		.attr("name","m[var.units]")
		.attr("for",var_name)
		.attr("value","")
		.attr("title","Units for netCDF variable. The units should correspond to the standard name chosen from the CF convention list of standard names. This field is automatically filled when choosing a standard name")
		.tooltip({position:{my:"left",at:"right+10px"}})
		.appendTo(objBody);

 	    $("<div>")
		.addClass("group")
		.attr("variable",var_name)
		.append(objHeader)
		.append(objBody)
		.appendTo(obj);

	    $(obj)
		.accordion("refresh")
		.accordion("option","active",$(obj).find("div.group").length-1);
	},

	_setFormAction: function() {
	    var thisObject = this;

	    var format = $(this._objOutputSelector).find("input:radio:checked").val();
	    var tmpl   = $(this._objTemplateSelector).find("select[name='template']").val();
	    var epsg   = $(this._objTemplateSelector).find("select[name='crs']").val();

	    var objDownload = $(this._objOutputSelector).find("input[name='download']:checkbox");

	    if (!objDownload.prop("checked") && format != "netcdf") {
		$("<div>")
		    .append($("<iframe name=\"output\">")
			    .css("border","0px")
			    .css("width","100%")
			    .css("height","100%"))
		    .dialog({
			title:"Kickstarter output " + format,
			autoOpen:true,
			width:800,
			height:500,
			modal:true,
			close: function() {
			    $(this).dialog("destroy"); },
			buttons:{
			    "Download as file":function() {
				objDownload.prop("checked",true);
				$(thisObject.element).find("form").submit();
				objDownload.prop("checked",false); },
			    "Close":function() {
				$(this).dialog("close"); }}});

		$(this.element)
		    .find("form")
		    .attr("target","output")
		    .attr("action", this.options.jsonHost + format + "/" + tmpl + "?epsg_code=" + epsg);
	    } else {
		$(this.element)
		    .find("form")
		    .attr("action", this.options.jsonHost + format + "/" + tmpl + "?epsg_code=" + epsg);
	    }
	}

	/*****************************************************************************
	 ** HELPER FUNCTIONS                                                        **
	 *****************************************************************************/


    });

})( jQuery );

(function($){
    //plugin buttonset vertical
    $.fn.buttonsetv = function() {
	$(':radio, :checkbox', this).wrap('<div style="margin:-1px;"/>');
	$(this).buttonset();
	$('label:first', this).removeClass('ui-corner-left').addClass('ui-corner-top');
	$('label:last', this).removeClass('ui-corner-right').addClass('ui-corner-bottom');
    };
})( jQuery );
