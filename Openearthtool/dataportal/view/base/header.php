<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed'); 

// Default page title
$pageTitle =  'Deltares Data portal';
?>
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title><?php echo $pageTitle; ?></title>

    <!-- STYLES -->
    <link href="<?php echo BASE_URL . "lib/bootstrap/css/bootstrap.min.css"; ?>" rel=stylesheet />
    <link href="<?php echo BASE_URL . "css/portal.css"; ?>" rel=stylesheet />
    
    <!-- SCRIPTS -->
    <script src="<?php echo BASE_URL . "lib/jquery/jquery-1.11.0.min.js"; ?>"></script>
    <script src="<?php echo BASE_URL . "lib/bootstrap/js/bootstrap.min.js"; ?>"></script>
    <script src="<?php echo BASE_URL . "js/portal.js"; ?>"></script>
    <link rel="icon" type="image/png" href="<?php echo  BASE_URL . "img/favicon.ico"; ?>">
    
</head>
    <body>
    	<div class="header">
    		
    		<div class="deltaresLogo">
    			<a href='http://intranet.deltares.nl/' target='_blank' ><img src="<?php echo BASE_URL . 'img/DELTARES_WOORDBEELDMERK_RGB_200x115.png';?>" alt="Navigate to deltares intranet"></a>
    		</div>
    		<div class="oetLogo">
	    		<a href="http://openearth.nl/" target='_blank'>
	    			<img src="<?php echo BASE_URL . 'img/logo_OET.png';?>" alt='Open earth'>
	    		</a>
    		</div>
    		<div class="headerText">Deltares Data Portal</div>
    	</div>
        <div class="content container-fluid">
            <div class="row">