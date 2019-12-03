<!DOCTYPE html><!--[if lt IE 7]><html class="no-js ie ie6 lt-ie7 lt-ie8 lt-ie9 lt-ie10"><![endif]-->
<!--[if IE 7]>   <html class="no-js ie ie7 lt-ie8 lt-ie9 lt-ie10"><![endif]-->
<!--[if IE 8]>   <html class="no-js ie ie8 lt-ie9 lt-ie10"><![endif]-->
<!--[if IE 9]>   <html class="no-js ie ie9 lt-ie10"><![endif]-->
<!--[if gt IE 9]><html class="no-js ie ie10"><![endif]-->
<!--[if !IE]><!-->
<html class="no-js"><!--<![endif]-->
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1">
    <title>Sea level monitor</title>
    <!-- Modernizr -->
    <script src="${request.static_url('sealevel:static/js/libs/modernizr-2.6.2.min.js')}"></script>
    <!-- jQuery-->
    <script type="text/javascript" src="${request.static_url('sealevel:static/js/libs/jquery-1.10.2.min.js')}"></script>
    <link rel="stylesheet" href="${request.static_url('sealevel:static/css/ui-lightness/jquery-ui-1.10.3.custom.min.css')}" />
    <script src="${request.static_url('sealevel:static/js/libs/jquery-ui-1.10.3.custom.min.js')}"></script>
    <!-- framework css -->
    <!--[if gt IE 9]>
        <!-->
        <link type="text/css" rel="stylesheet" href="${request.static_url('sealevel:static/css/groundwork.css')}">
        <!--<![endif]-->
        <!--[if lte IE 9]>
            <link type="text/css" rel="stylesheet" href="${request.static_url('sealevel:static/css/groundwork-core.css')}">
            <link type="text/css" rel="stylesheet" href="${request.static_url('sealevel:static/css/groundwork-type.css')}">
            <link type="text/css" rel="stylesheet" href="${request.static_url('sealevel:static/css/groundwork-ui.css')}">
            <link type="text/css" rel="stylesheet" href="${request.static_url('sealevel:static/css/groundwork-anim.css')}">
            <link type="text/css" rel="stylesheet" href="${request.static_url('sealevel:static/css/groundwork-ie.css')}">
            <![endif]-->
    <link rel="stylesheet" href="${request.static_url('sealevel:static/css/main.css')}" type="text/css" media="screen" />
</head>
<body>
  <header class="padded">
    <div class="container">
      <div class="row">
        <div class="one third">
          <h2 class="logo"><a href="/" target="_parent"><img src="${request.static_url('sealevel:static/images/deltares.gif')}" alt="Deltares"></a></h2>
        </div>
        <div class=" bounceInRight animated one third">
          <h1 class="zero">${_("Sea level monitor")}</h1>
          <p class="quicksand">${_("Sea level trends for")} ${station}</p>
        </div>
        <div class="one third">
          <p class="small double pad-top no-pad-small-tablet align-right align-left-small-tablet"> <a href="http://www.openearth.nl">Source</a> </p>
        </div>
      </div>
      <nav role="navigation" class="nav gap-top">
        <ul role="menubar">
          <li><a href="/"><i class="icon-home"></i> Home</a></li>
          <li role="menu">
            <button>Analysis</button>
            <ul>
              <li><a href="${request.route_url('map')}">World</a></li>
              <li><a href="${request.route_url('map')}">Europe</a></li>
              <li><a href="${request.route_url('main', _query=dict(station='DUTCH MEAN'))}">The Netherlands</a></li>
            </ul>
          </li>
          <li role="menu">
            <button>Background</button>
            <ul>
              <li><a href="${request.static_url('sealevel:static/reports/report.pdf')}" title="Report">Report</a></li>
              <li><a href="${request.static_url('sealevel:static/reports/method.pdf')}" title="Method">Method description</a></li>
            </ul>
          </li>
        </ul>
      </nav>
    </div>
  </header>
  <div class="container">
    <hr>
    <article class="row">
      <section class="three fourths padded bounceIn animated">
        <img  id="plot" src="${request.route_url('plot')}" alt="">
        <div class="padded">
        <div id="slider-range"></div>
        </div>
        <p class="padded">
          <button id="downloadplot" form="form" >Download plot</button>
          <button id="downloadscript" form="form">Download R script</button>
          <button id="downloaddata" form="form">Download data</button>
        </p>
        <hr>
      </section>
      <aside class="one fourth padded border-left bounceInRight animated">
        <div class="row">
          <div class="one whole two-up-small-tablet one-up-mobile">
            <form action="#" method="post" id="form">
              <fieldset>
                <legend>General</legend>
                <div class="pad-bottom">
                  <label for="station">Station <a href="#" rel="help" title="extra info"></a></label>
                  <input class="noenter" id="station" type="text" name="station" value="${station}">
                </div>
                <ul class="unstyled zero">
                <li>
                  <input id="observed" type="checkbox" name="observed" checked="on">
                  <label for="observed" class="inline">${_("Observations ")}</label> <a href="#" rel="help" title="${_("Observed sea level, as recorded by the PSMSL")}"></a>
                </li>
                <li>
                  <input id="fit" type="checkbox" name="fit" checked="">
                  <label for="fit" class="inline">${_("Fit")}</label><a href="#" rel="help" title="${_("Predicted value of the model in use")}"></a>
                </li>
                <li>
                  <input id="confidence" type="checkbox" name="confidence" >
                  <label for="confidence" class="inline">${_("Confidence interval")}</label><a href="#" rel="help" title="${_("interval that includes the parameter of interest 95% of the time if the model is applied again on a new sample")}"></a>
                </li>
                <li>
                  <input id="prediction" type="checkbox" name="prediction" >
                  <label for="prediction" class="inline">${_("Prediction interval")}</label><a href="#" rel="help" title="extra info"></a>
                </li>
                </ul>
                <div class="pad-bottom">
                  <label for="startyear">${_("Start year")}</label>
                  <input id="startyear" type="text" placeholder="1906" name="startyear">
                </div>
                <div class="pad-bottom">
                  <label for="endyear">${_("End year")}</label>
                  <input id="endyear" type="text" placeholder="2012" name="endyear">
                </div>

                <span class="select-wrap">
                  <select id="model" name="model">
                    <option>linear</option>
                    <option>loess</option>
                  </select>
                </span>

              </fieldset>
              <fieldset id="linear">
                <legend>Linear model</legend>
                <ul class="unstyled zero">
                <li>
                  <input id="nodal" type="checkbox" name="nodal" checked="">
                  <label for="nodal" class="inline">${_("Nodal cycle")}</label><a href="#" rel="help" title="extra info"></a>
                </li>
                <li>
                  <input id="wind" type="checkbox" name="wind" >
                  <label for="wind" class="inline">${_("Wind components")}</label><a href="#" rel="help" title="${_("Pressure as independent variable")}"></a>
                </li>
                </ul>
                <div class="pad-bottom">
                  <label for="polynomial">${_("Polynomial")} <a href="#" rel="help" title="${_("Polynomial degree of the linear terms in the model.")}"></a></label>
                  <input id="polynomial" type="number" placeholder="1" min="0" max="10" name="polynomial">
                </div>
              </fieldset>
              <fieldset id="loess">
                <legend>Loess model</legend>
                <div class="pad-bottom">
                  <label for="polynomial_loess">${_("Polynomial")} <a href="#" rel="help" title="${_("Polynomial degree of the linear terms in the model.")}"></a></label>
                  <input id="polynomial_loess" type="number" placeholder="1" min="0" max="2" name="polynomial_loess">
                </div>
                <div class="pad-bottom">
                  <label for="span">${_("Span")} <a href="#" rel="help" title="${_("Span for loess")}"></a></label>
                  <input id="span" type="number" step="0.05" placeholder="0.25" min="0.05" max="3" name="span">
                </div>
              </fieldset>
              <fieldset id="corrections">
                <legend>Corrections</legend>
                <div>
                  <input id="ib" type="checkbox" name="ib" >
                  <label for="ib" class="inline">${_("Inverse barometer")}</label><a href="#" rel="help" title="${_("Inverse barometer correction")}"></a>
                </div>
                <div>
                  <input id="gia" type="checkbox" name="gia">
                  <label for="gia" class="inline">${_("Glacio-isostatic adjustment")}</label><a href="#" rel="help" title="${_("Glacia-isostatic adjustment as computed by Peltier 2004.")}"></a>
                </div>
              </fieldset>


            </form>
          </div>
        </div>
        <hr>
      </aside>

    </article>
    <article>
      <section>
        <h1>Model description</h1>
        <p>Using these settings the estimated sea level is:</p>
        <code class="block">
          <pre id="output"></pre>
        </code>
        <p>
          <button class="asphalt">Read more</button>
        </p>
      </section>
    </article>

  </div>
  <footer class="gap-top bounceInUp animated">
    <div class="box square charcoal">
      <div class="container padded">
        <div class="row">
          <div class="one small-tablet fourth padded">
            Footer
          </div>
        </div>
      </div>
    </div>
  </footer>
  <!-- javascript-->
  <script type="text/javascript" src="${request.static_url('sealevel:static/js/groundwork.all.js')}"></script>
  <!-- google analytics-->
  <script type="text/javascript">
    updateplot = function() {

    params = $("#form").serialize();
    $("#plot").attr("src", "${request.route_url('plot')}?" + params);
    $("#downloadplot").attr("formaction", "${request.route_url('plot', _query=dict(format='pdf'))}&" + params);
    $("#downloadscript").attr("formaction", "${request.route_url('rscript')}?" + params);
    $("#downloaddata").attr("formaction", "${request.route_url('data', _query=dict(format='csv'))}&" + params);


    $('.noenter').keypress(function(e){
       if ( e.which == 13 ) e.preventDefault();
    });

    $.get("${request.route_url('description')}", $("#form").serializeArray()).done(
          function(data) {
             $("#output").text(data);
    });

    if ($("#model option:selected").text() == 'loess') {
    $('#loess').slideDown();
    } else {
    $('#loess').slideUp();
    };
    if ($("#model option:selected").text() == 'linear') {
    $('#linear').slideDown();
    } else {
    $('#linear').slideUp();

    };


    };

    $(document).ready(updateplot);
    $("#form").change(updateplot);

    $( "#slider-range" ).slider({
      range: true,
      min: 1800,
      max: 2050,
      values: [ 1890, 2012 ],
      slide: function( event, ui ) {
           $( "#startyear" ).val( ui.values[ 0 ] );
           $( "#endyear" ).val( ui.values[ 1 ] );
      },
      stop: function(event, ui) {
       updateplot();
    }

    });


  </script>
</body>
</html>
