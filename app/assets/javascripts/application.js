// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//



//= require jquery
//= require jquery-ui
//= require bundle

Math.log2 = Math.log2 || function(x) {
  return Math.log(x) / Math.LN2;
};


var ready;
ready = (function() {
  $('a[href="' + this.location.pathname + '"]').parent().addClass('active');
  $("#gene-search-input").autocomplete({
    source: '/genes/autocomplete.json',
  });
   $("#gene-search-compare").autocomplete({
    source: '/genes/autocomplete.json',
  });

  $("#gene").autocomplete({
    source: '/genes/autocomplete.json',
  });
  $("#compare").autocomplete({
    source: '/genes/autocomplete.json',
  });

  $("#gene_set_selector").on("change", function(event){
    $.ajax({
    type: 'get',
    url: '/gene_sets/set_gene_set_session.json',

    data: {
        gene_set_selector:$("#gene_set_selector").val()
    },
    success: function (response) {
        document.getElementById("kalb"+parseInt(subcategory_id.match(/[0-9]+/)[0], 10)).innerHTML=response;
    }
    });
  });  

  $(".alert-error").on("click", function(event) { 
    $(this).hide();
  });
  $(".alert-info").on("click", function(event) { 
    $(this).hide();
  });
  $( "#about_studies" ).dialog({
      autoOpen: false,
      minWidth: 1000,
      maxHeight: 500,
      resizable: false,
      position: { at: "center top" },
      show: {
        effect: "fade",
        duration: 500
      },
      hide: {
        effect: "fade",
        duration: 500
      }
    });

  $( "#about" ).dialog({
      autoOpen: false,
      minWidth: 1000,
      maxHeight: 500,
      resizable: false,
      position: { at: "center top" },
      show: {
        effect: "fade",
        duration: 500
      },
      hide: {
        effect: "fade",
        duration: 500
      }
    });

  $( "#studies_button" ).click(function() {
      $( "#about_studies" ).dialog( "open" );
  });

   $( "#cite_button" ).click(function() {
      $( "#about" ).dialog( "open" );
  });
  
  //*************************************SEQUENCESERVER - START*************************************
  var search_right = $('#search_right');
  var search_left = $('#search_left');
  var introblurb = $('#introblurb');
   $('#sequenceserver').load(function(){

    // SHALL BE REMOVED LATER - THIS IS JUST FOR DEVELOPMENT SAKE
    $(this).contents().find('textarea.text-monospace').html('TCCCTATCTGTTTCCTTGGCAGCTCCCTGATCCAATCGATCCATCAGGGCTCGACTAACTTCTTCCAGCGCCTCTTCAGCGCGGGAGATCTACCAGCGTCGGCGGAGGGGCGTAGGTGCAGGCGTGCAGCCCAAGTCCGCACCCGGCTCTAGGTTTCTGCTAATCTTCTTCCACCTGTGATACGCGCTCCGGGGCTAGGAGCACTCGTTGCCGGCTGCCTCGTGCTCGGAATGGCGGATGGGGACTCGTCCGACTTCACCTTCTGCAAGGTTGACTATGCTGAAAATGATGGTCGTTTGGACTCCCCTAATTCCATCGCTGTGGCAAGTATGACACTGGAGGATGTTGCCGGTGATGGTGAGACTAAGAAGGTTCAGGATGACAAGCAAACAGTCAATCCAGTTACTGATGAAAAATCTAGTTCCATATCTAGTCGCACCAATGGTGTATCGCTTCGAGAGTCCAATATAAAAGAACCAGTTGTACCAACCAGTAGTGGAGAGTCTGTGCAGTCAAATGTGTCAGCTCAACCAAAACCTTTAAAGAAATCTGCTGTACGTGCAAAGGTTCCTTTTGAGAAGGGCTTTAGCCCAATGGACTGGCTTAAGCTGACTCGTACACATCCAGATCT')

    var parent = $(this).contents();
    var node = $(this).contents().find('body').find('.navbar');
    var self = $(this);
    node.html('<h4>BLAST Scaffold</h4>');
    $(this).contents().find('#footer').html('');          
    // Changing the checkbox input under the textarea to a radio button  
    $(this).contents().find('#blast').find('input').eq(0).attr('type', 'radio');;

    $($(this).contents()).click(function(event) {
      all_downloads = parent.find(".mutation_link");
      all_downloads.attr('target','_top');
    });

    // Removing the form after the BLAST button has been clicked
    search_btn = $(this).contents().find('#method');    
    search_btn.click(function(){
      search_right.width('100%')
      self.width('950px');
      search_left.hide();
      introblurb.hide();             

      // Adding a new column to the results table (with a time delay to let the content to be generated first and then changed)  
      $(document).ready(function($) {
        setTimeout(function(){

          // Adding the header of the column
          $('#sequenceserver').contents().find('thead').eq(0).find('th').eq(1).after('<th class="text-left">Expression search</th>')

          // Adding the data of the column
          // ***Constructing the link(adding the gene set)
          var geneSet = '';
          var testPath = $('#sequenceserver').contents().find('#blast').find('.databases-container').find('input').each(function(index, el) {
            if($(this).prop("checked", true)){
              geneSet = $(this).parent().text();
              geneSet = $.trim(geneSet).replace(/\s+/g, '');              
            }else{
              // ***If no gene set has been selected
              alert("Weird Stuff!\nPlease select a gene set");
            }
          });;
                    
          $('#sequenceserver').contents().find('tbody').eq(0).find('tr').each(function(index, el) {                         
            // ***Constructing the link(adding the gene name)
            var geneName = $(this).find('td').eq(1).children().text();   
            var link = "genes/forward?submit=Search&gene=" + geneName + "&gene_set=" + geneSet;

            var secondColResTable = $(this).find('td').eq(1);            
            secondColResTable.after("<td> <a href=" + link + " target=\"_top\">Expression</a> </td>");            
          });          
        }, 3000);        
      });

    });
  });
  //*************************************SEQUENCESERVER - END*************************************  
  
  //*************************************SELECTED STUDIES SESSION STORAGE - START*************************************
  if(sessionStorage.bar_expression_viewer_selectedFactors){    // If bar_expression_viewer_selectedFactors exists    
    console.log("Don't need to Make the session storage");
    var expBarSelectedStudies = sessionStorage.bar_expression_viewer_selectedFactors;
    var expBarSelectedStudiesObj = JSON.parse(expBarSelectedStudies);
    var studies = expBarSelectedStudiesObj.study;    

    for (var key in studies) {    // Checking the studies based on their value in the session
      if (studies.hasOwnProperty(key)) {        
        if(studies[key]){          
          $("[value='" + key + "']").prop('checked', true);
        } else {
          $("[value='" + key + "']").prop('checked', false);
        }
      }
    }

    $("[name='studies[]']").click(function(){   // Store the study in the session if it has been checked
      var selectedStudy = $(this).val();      
      studies[selectedStudy] = true;      
      sessionStorage.setItem('bar_expression_viewer_selectedFactors', JSON.stringify(expBarSelectedStudiesObj));      
    });    

  } else {    // If bar_expression_viewer_selectedFactors doesn't exist
    console.log("Making the session storage");
    var defaultStudies = {};
    var value;
    $(":checkbox").each(function(index, el) {   // Setting the default studies if they are checked 
      value = $(this).val();      
      if($(this).prop("checked")){                
        defaultStudies[value] = true;
      } else {
        defaultStudies[value] = false;
      }      
    });
    var defaultFactors = {"study":defaultStudies,
    "Age":{"7d":true,"see":true,"14d":true,"3_lea":true,"24d":true,"till":true,"5_lea":true,"1_sp":true,"2_no":true,"f_lea":true,"anth":true,"2dpa":true,"4dpa":true,"6dpa":true,"8dpa":true,"9dpa":true,"10dpa":true,"11dpa":true,"12dpa":true,"4+dpa":true,"14dpa":true,"15dpa":true,"20dpa":true,"25dpa":true,"30dpa":true,"35dpa":true},
    "High level age":{"see":true,"veg":true,"repr":true},"High level stress-disease":{"none":true,"dis":true,"abio":true,"trans":true},
    "High level tissue":{"spike":true,"grain":true,"le+sh":true,"roots":true},"High level variety":{"CS":true,"other":true,"N_CS":true},
    "Stress-disease":{"none":true,"mo30h":true,"mo50h":true,"fu30h":true,"fu50h":true,"sr24h":true,"sr48h":true,"sr72h":true,"sr6+d":true,"pm24h":true,"pm48h":true,"pm72h":true,"st4d":true,"st10d":true,"st13d":true,"ds1h":true,"ds6h":true,"hs1h":true,"hs6h":true,"dhs1h":true,"dhs6h":true,"P-10d":true,"GPC-":true},
    "Tissue":{"grain":true,"w_en":true,"s_en":true,"al_e":true,"e_sc":true,"sc":true,"al":true,"tc":true,"pist":true,"ps":true,"sta":true,"spike":true,"s_let":true,"see":true,"shoot":true,"lea":true,"2_lea":true,"f_lea":true,"stem":true,"root":true},
    "Variety":{"CS":true,"Hold":true,"TAM":true,"Banks":true,"Avoc":true,"Sevin":true,"Bobw":true,"GPC":true,"P271":true,"CSNIL":true,"HTS-1":true,"N9134":true,"synth":true,"CM":true,"CM_1":true,"CM_2":true,"CM_3":true,"CM_4":true,"Baxt":true,"Chara":true,"Westo":true,"Yipti":true,"0362+":true,"0807+":true,"1038+":true,"1275+":true,"1516+":true,"0807-":true,"1038-":true,"1275-":true,"0362-":true,"1516-":true,"N1ATB":true,"N1ATD":true,"N1BTA":true,"N1BTD":true,"N1DTA":true,"N1DTB":true,"N5ATB":true,"N5ATD":true,"N5BTA":true,"N5BTD":true,"N5DTA":true,"N5DTB":true}}    
    var jsonObj = JSON.stringify(defaultFactors);
    sessionStorage.setItem('bar_expression_viewer_selectedFactors', jsonObj);
  }  
  //*************************************SELECTED STUDIES SESSION STORAGE - END*************************************

});

$(document).ready(ready);
$(document).on('page:load', ready);
