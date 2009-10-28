function CopySingle(char){
    if(char!=""){
        var element = document.getElementById('txt_bnd_'+char+'_tseries_file');
        var element2= parent.document.getElementById('txt_bnd_'+char+'_tseries_file');
        element2.value = element.value;
    }
    else{
        alert("char not set for CopySingle");
    }
}

function CheckBeforeCalc(formname){
        var inps   = document.body.getElementsByTagName("input");
        var err2   = new Array();
        var inputs = '';
        var amount = 0;
        var enabled=true;
        var id;
        var value;

        var signal_file_l = document.getElementById('txt_bnd_l_tseries_file').value;
        var signal_file_r = document.getElementById('txt_bnd_r_tseries_file').value;

        for(i=0;i < inps.length; i++){
                id = document.body.getElementsByTagName("input")[i].id;

                if(inStr('_errors',id)){
                        value = document.getElementById(id).value;
                        if(value!=""){
                             err = value.split(",");
                             for(a=0; a < err.length;a++){
                                 var par = document.getElementById(err[a]).alt;
                                 inputs += '- '+par+'\n';
                                 amount +=1;
                             }
                        }
                }
                else if(id=='txt_bot_filename' || id=='txt_bnd_lefttype' || id=='txt_bnd_righttype'){
                        value = document.getElementById(id).value;
                        par   = document.getElementById(id).alt;

                        <!-- BOTTOM FILE always needs to be uploaded. -->
                        if(id=='txt_bot_filename' && (value=="none" || value=="")){
                           inputs += '- Bottom file missing.\n';
                           amount +=1;
                        }

                        <!-- TIMESIGNAL must be set for left and right must have a filename -->
                        if((id=='txt_bnd_lefttype' || id=='txt_bnd_righttype') && (value=='' || value=='none')){
                           if(inStr('_left',id)){
                                inputs += '- '+par+' undefined.\n';
                           }
                           if(inStr('_right',id)){
                                inputs += '- '+par+' undefined.\n';
                           }
                           amount +=1;
                        }
                        if(id=='txt_bnd_lefttype' && value=='TIMESIGNAL' && signal_file_l==''){
                           inputs += '- Timesignal file missing. (left boundary)\n';
                           amount +=1;
                        }
                        if(id=='txt_bnd_righttype' && value=='TIMESIGNAL' && signal_file_r==''){
                           inputs += '- Timesignal file missing. (right boundary)\n';
                           amount +=1;
                        }
                }
        }
        if(amount > 0 && enabled){
           alert("Initiating calculation failed .\n"+amount+" input parameter(s) not correct.\nPlease check:\n" + inputs );
        }
        else{
           document.getElementById(formname).submit();
        }
}

function inStr(needle, haystack){
     myString = new String(haystack);
     var indice = myString.indexOf(needle);
     if(indice==-1){
       return false;
     }
     else{
       return true;
     }
}

function inputCheck(input_id, star, endr, maxchars){
   var lmnt = document.getElementById(input_id);
   var nr   = lmnt.value;
   $message = intCheck(nr,star,endr,maxchars);
   var page = document.getElementById('btn_page').value;

   if($message=='' || $message==null){
        lmnt.className = '';
   }
   else{
        lmnt.className = 'input_err';
        alert('Invalid inserts:\n'+$message);
   }
}

function isNumeric(sText)
{
   var ValidChars = "0123456789.-";
   var IsNumber=true;
   var Char;
   for (i = 0; i < sText.length && IsNumber == true; i++)
      {
      Char = sText.charAt(i);
      if (ValidChars.indexOf(Char) == -1)
         {
         IsNumber = false;
         }
      }
   return IsNumber;
}

function gt(nr,ch){
   var bl = false;
   nr = parseFloat(nr);
   ch = parseFloat(ch);
   if(nr > ch){
       bl = true;
   }
   return bl;
}

function lt(nr,ch){
   var bl = false;
   nr = parseFloat(nr);
   ch = parseFloat(ch);
   if(nr < ch){
       bl = true;
   }
   return bl;
}
function ge(nr,ch){
   var bl = false;
   nr = parseFloat(nr);
   ch = parseFloat(ch);
   if(nr >= ch){
       bl = true;
   }
   return bl;
}
function le(nr,ch){
   var bl = false;
   nr = parseFloat(nr);
   ch = parseFloat(ch);
   if(nr <= ch){
       bl = true;
   }
   return bl;
}


function intCheck(nr,star,endr,logtype,maxchars){
  var message = '';
  nr = parseFloat(nr);
  star = parseFloat(star);
  endr = parseFloat(endr);
  maxchars = parseFloat(maxchars);
    if(isNumeric(nr) && !(nr.length > maxchars)){
          switch(logtype){
                case 'gt':
                     if(!gt(nr,star)){
                         message += 'Value must be greater then '+star+'\n';
                     }
                break;
                case 'lt':
                     if(!lt(nr,star)){
                         message += 'Value must me lower then '+star+'\n';
                     }
                break;
                case 'ge':
                     if(!ge(nr,star)){
                         message += 'Value must be greater or equal to '+star+'\n';
                     }
                break;
                case 'le':
                     if(!le(nr,star)){
                         message += 'Value must be lower or equal to '+star+'\n';
                     }
                break;
                case 'gtlt':
                     if(!gt(nr,star) || !lt(nr,endr)){
                         message += 'Value not between '+star+' and '+endr+'\n';
                     }
                break;
                case 'gele':
                     if(!ge(nr,star) || !le(nr,endr)){
                         message += 'Value not between or equal '+star+' - '+endr+'\n';
                     }
                break;
                case 'gtle':
                     if(!gt(nr,star) || !le(nr,endr)){
                         message += 'Value must be greater then '+star+' and lower equal then '+endr+'\n';
                     }
                break;
          }
    }
    else{
        message += 'Must be numeric. or exceeded max. of '+maxchars+' chars \n';
    }
    return message;
}

// workaround getvalues, otherwise the filename would be overwritten blank after first time upload 
function GetValues_if(tri_filename, level_up) {
    
    var tri_but;
    if(level_up=='true'){
        tri_but = top.parent.tri_button.document.getElementById(tri_filename);
        if(tri_but==null){
            alert( tri_filename +" is not a element in tri_button");
        }
        else{
           if(tri_but.value!=""){
            GetValues();
            }
        }
    }
    else{
        tri_but = top.tri_button.document.getElementById(tri_filename);
        if(tri_but.value!=""){
            GetValues();
        }
    }

}

function in_array(stringToSearch, arrayToSearch) {
    for (s = 0; s < arrayToSearch.length; s++) {
        thisEntry = arrayToSearch[s].toString();
        if (thisEntry == stringToSearch) {
            return true;
        }
    }
    return false;
}

function isInt (str) //checks if its an integer
{
    var i = parseInt (str);
    if (isNaN (i)) return false;
    i = i . toString ();
    if (i != str) return false;
    return true;
}

function checkInputValue(inputid, value) //checks depending on first 4 chars of input id or name - like dbl_ int_ text
{
        //dbl,int,text,
      //change of input_style when true
      var err_class = "input_err";
      var def_class = "input_def";
      var element = document.getElementById(inputid);

      if(document.getElementById(inputid)!=null){
           //choose check by input name
           var inputprefix = inputid.substr(4);
           switch(inputprefix){
            case 'int_':
                   if(isInt(value)){ element.className = def_class;}
                   else{ element.className = err_class; }
            break;
            case 'dbl_':
                   if(value.match(".")==1){ element.className = def_class; element.value.toFixed(1);}
                   else{ element.className = err_class;  }
            break;
            case 'text':

            break;
           }


           //choose rangecheck by args

      }
      else{
        alert(inputid+" does not exsist in this document.");
      }
}

 function PutInList(listid, values, value){
    var subs_array = values.split(",");
    var opt = "";
    //x = document.getElementById(subs_array[0]).value;
    //y = document.getElementById(subs_array[1]).value;
    //single option
    if(value){
        opt = values;
    }else{
    //multi option
        for(i=0;i < subs_array.length;i++){
        opt += document.getElementById(subs_array[i]).value + ";";
        document.getElementById(subs_array[i]).value="";
        }
    }
    var List = document.getElementById(listid);
    var OptNew = document.createElement('option');
    OptNew.text = opt;
    OptNew.value = opt;
      try {
        List.add(OptNew, null); // standards compliant; doesn't work in IE
      }
      catch(ex){
        List.add(OptNew); // IE only
      }
 }

 function RemoveFromList(listid){
   var List = document.getElementById(listid);
   var i;
   for (i = List.length - 1; i>=0; i--) {
    if (List.options[i].selected) {
      List.remove(i);
    }
   }
 }

 function OnChangeInput(value1,value2,id_enable){
    if(value1!="" && value2!=""){
        document.getElementById(id_enable).disabled=false;
    }
    else{
        document.getElementById(id_enable).disabled=true;
    }

 }

 function ReplaceComma(element, value){
     new_value = value.replace(/,/,".");
     document.getElementById(element).value = new_value;
 }

//for the checkboxes which enables items
function EnableItems(thisid,items){
    var item;
    var item_array = items.split(",");
    var checked = document.getElementById(thisid).checked;
    for(i=0; i < item_array.length;i++){
        //alert("Enable items checker ("+thisid+") = "+checked);
        document.getElementById(item_array[i]).disabled = (checked) ? false : true;
    }
}

function UpdatePageError(page){
     var pages = new Array();
     var pages = {"gen":"General",
                  "grid":"Grid",
                  "bot":"Bottom",
                  "bnd":"Boundary",
                  "phys":"Physical Parameters",
                  "num":"Numerical Parameters",
                  "output":"Output"};

     var errors = document.getElementById(page+'_errors');
     var amount = errors.value;
     if(amount > 0){
        top.tri_tree.document.getElementById('img_'+pages[page]).src='img/text_err.gif';
     }
     else{
        top.tri_tree.document.getElementById('img_'+pages[page]).src='img/text.gif';
     }
}



<!-- Puts the values to the TRI BUTTON page -->
function CopyValues()
{
  //check values first
  var amount_selectC = document.body.getElementsByTagName("select").length;
  var vIDs;
  var vIDz;
  var slct;
  var vID;
  var vValue;
  var iType;
  var index;
  var n_options;
  var vClass;
  var errors;
  var do_errors = false;
  if(document.getElementById('btn_page')!=null && top.tri_button.document.getElementById(page+'_errors')!=null){
        var page = document.getElementById('btn_page').value;
        errors = top.tri_button.document.getElementById(page+'_errors').value;
        do_errors = true;
  }
  var errors2 = new Array();

  if(errors!="" && do_errors){
        errors2 = errors.split(",");
  }
  //process selects _____________________________________________________________________________
  for (z=0;z < amount_selectC;z++){
        index = document.body.getElementsByTagName("select")[z].selectedIndex;
        vIDz  = document.body.getElementsByTagName("select")[z].name;
        siType = vIDz.substr(0,5);

        //check if this element also exists in tri_button
        if(top.tri_button.document.getElementById(vIDz)!=null){
            if(siType!="listb"){
                //selected option value and -
                vValue = document.getElementById(vIDz).value;
            }else{
                //get all selectbox option values and -
                n_options = document.getElementById(vIDz).options.length;
                if(n_options > 0){
                    vValue = "";
                    for(i=0; i < n_options;i++){
                        vValue += document.getElementById(vIDz).options[i].value + ",";
                    }
                    var cut = vValue.length - 1;
                    vValue = vValue.substr(0,cut);
                }
                else{
                    vValue = "";
                }
            }
            //put in tri_button value
            top.tri_button.document.getElementById(vIDz).value = vValue;
        }
        else{
            alert("CopyValues reports - selectbox ("+vIDz+") is geen input in tri_button");
        }
  }
  //proces inputs _____________________________________________________________________________
  for (i=0;i<document.body.getElementsByTagName("input").length;i++) {
        vID    = document.body.getElementsByTagName("input")[i].name;
        vValue = document.body.getElementsByTagName("input")[i].value;
        iType  = vID.substr(0,3);
        vClass = document.body.getElementsByTagName("input")[i].className;

        //ignore button input types
        if(iType!="btn"){

          //_____________________Copy error input_ids
          if(!in_array(vID,errors2) && vClass=='input_err'){
               errors2.push(vID);
          }
          else if(in_array(vID,errors2) && vClass!='input_err'){
                var indice = errors2.indexOf(vID);
                errors2.splice(indice,1);
          }
          if(do_errors){
                top.tri_button.document.getElementById(page+'_errors').value = errors2.toString();
          }
          //___________________________________________

          if(top.tri_button.document.getElementById(vID)!=null){

            //checkbox is different then text
            if(iType=="cb_"){
                if(document.body.getElementsByTagName("input")[i].checked==false){
                    vValue="false";
                    //uitzondering op de regel
                    if( vID=="cb_num_inex_vorticity"){
                        vValue="0";
                    }
                }
                else{
                    vValue="true";
                    //uitzondering op de regel
                    if( vID=="cb_num_inex_vorticity"){
                        vValue="1";
                    }
                }
            }
            if(vValue!=""){
                top.tri_button.document.getElementById(vID).value = vValue;
            }
          }
          else{
            alert(vID+" is geen object in tri_button");
          }
        }
  }
}

<!-- Gets the values out of the TRI BUTTON page-->
function GetValues(){
 var amount = document.body.getElementsByTagName("input").length;
 var amount_select = document.body.getElementsByTagName("select").length;
 var vIDs;
 var slct;
 var vID;
 var vValue;
 var iType;
 var opts;
 var list;
 var adds;
 if(document.getElementById('btn_page')!=null){
        var page = document.getElementById('btn_page').value;
 }
 var errors;
 var errors2 = new Array();
 errors = top.tri_button.document.getElementById(page+'_errors').value;
 if(errors!=""){
        errors2 = errors.split(",");
 }

 //process select inputs
 for (s=0;s < amount_select; s++){
     vIDs = document.body.getElementsByTagName("select")[s].name;
     siType = vIDs.substr(0,5);

     if(document.getElementById(vIDs)!=null){
        if(siType!="listb"){
            //from value to selected option of list

            slct = top.tri_button.document.getElementById(vIDs).value;
            if(!isNumeric(slct)){
                        if(document.getElementById(vIDs).options[slct]!=null){
                        document.getElementById(vIDs).options[slct].selected=true;
                       }
                   }
            else{
                slct = slct - 1;
                document.getElementById(vIDs).selectedIndex = slct;
            }

        }
        else{
        //from array of values |comma separated| to a set of options
        opts = top.tri_button.document.getElementById(vIDs).value;
            if(opts!=""){
               adds = opts.split(",");
               for(i=0;i < adds.length;i++){
                    PutInList(vIDs, adds[i], true);
               }
            }
        }
     }
     else{
        alert("GetValues reports - selectbox ("+vIDs+") does not exist on this page");
     }
 }

 //process inputs _____________________________________________________________________________
 for(a=0;a < amount;a++){
     vID    = document.body.getElementsByTagName("input")[a].name;
     iType = vID.substr(0,3);

     if(iType!="btn"){
        if(in_array(vID,errors2)){
                document.getElementById(vID).className='input_err';
        }

     if (iType=="cb_"){
            //alert(vID+" = "+top.tri_button.document.getElementById(vID).value);

            if(top.tri_button.document.getElementById(vID).value=="true" || top.tri_button.document.getElementById(vID).value=="1") {
                document.getElementById(vID).checked = true;
                //alert("checking :"+vID);
            }
            else{
                document.getElementById(vID).checked = false;
                //alert("unchecking :"+vID);
            }

            if(top.tri_button.document.getElementById("dis_"+vID)!=null){
                var names = top.tri_button.document.getElementById("dis_"+vID).value;
                //alert("enabling "+names);
                EnableItems(vID,names);
            }
        }
        else{
            var go = true;
            if(document.getElementById(vID)==null){
                alert(vID+" is geen object in deze pagina.");
                go = false;
            }
            if(top.tri_button.document.getElementById(vID)==null){
                alert(vID+" is geen object in de tri_button.");
                go = false;
            }
            if(go){
                document.getElementById(vID).value = top.tri_button.document.getElementById(vID).value;
            }

        }
     }
  }
}
