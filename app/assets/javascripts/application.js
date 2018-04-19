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
//= require bootstrap-sprockets
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

  $("select[name*='gene_set_selector']").on("change", function(event){    
    var geneID = $(this).val();    

    $.ajax({
      type: 'get',
      url: '/gene_sets/set_gene_set_session',
      dataType: 'JSON',
      data: {        
          gene_set_selector:geneID
      },
      success: function (response) {                
        // This part breaks after a while, unfortunatly at this time for time limitations I'll leave for later
        $("select[name*='gene_set_selector']").each(function(index, el) {      
          $(this).find('option').each(function(index, el) {        
            if($(this).val() !== geneID && $(this).attr('selected')){          
              $(this).removeAttr('selected');
            }
            if($(this).val() === geneID && !($(this).attr('selected'))){     
              $(this).attr('selected', 'selected');               
            }
          });      
        });   
      },
      error: function(){
        alert ("There was a problem with selecting the gene set");
      }
    });    

    var newGeneID = $(this).val();    

    $.ajax({
      type: 'get',
      url: '/',
      dataType: 'JSON',
      data: {        
          gene_set_selector:newGeneID
      },
      success: function (response) {    
        $('#example1').html(response.value[0].name);
        $('#example2').html(response.value[1].name);      
      },
      error: function(){
        alert ("There was a problem with selecting the gene set");
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

  $(".ui-dialog-titlebar-close").html('X');

   $( "#cite_button" ).click(function() {
      $( "#about" ).dialog( "open" );
  });
     
   // Select all studies
  $('.select_all').click(function(event) {

    event.preventDefault();
    $("input[name*='studies[]']").each(function(index, el) {          
      $(this).prop('checked', true);                  
    });
  });

  // Deselect all studies
  $('.deselect_all').click(function(event) {

    event.preventDefault();
    $("input[name*='studies[]']").each(function(index, el) {          
      $(this).prop('checked', false);                  
    });
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
    $(this).contents().find('#blast').find('.checkbox').find('input').each(function(index, el) {
      $(this).attr('type', 'radio');
      $(this).addClass('gene_set');
      $(this).prop('checked', false);
    });    

    // Saving the gene set selected
    var selectedGeneSet = '';
    $(this).contents().find('#blast').find('.gene_set').click(function(event) {
      selectedGeneSet = $(this).parent().text();    
    });

    $($(this).contents()).click(function(event) {
      all_downloads = parent.find(".mutation_link");
      all_downloads.attr('target','_top');
    });

    // Removing the form after the BLAST button has been clicked
    search_btn = $(this).contents().find('#method');    
    search_btn.click(function(){     
      search_right.width('100%')
      self.width('100%');
      self.height('950px');
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
          $('#sequenceserver').contents().find('#blast').find('.databases-container').find('input').each(function(index, el) {
            if($(this).parent().text() != selectedGeneSet){
              $(this).prop('checked', false);
            } else {
              geneSet = selectedGeneSet;
              geneSet = $.trim(geneSet).replace(/\s+/g, '');
            }            
          });
          
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

    // Select all studies
    $('.select_all').click(function(event) {
      event.preventDefault();
      $("input[name*='studies[]']").each(function(index, el) {          
        $(this).prop('checked', true);                  
        var selectedStudy = $(this).val();              
        studies[selectedStudy] = true;        
        sessionStorage.setItem('bar_expression_viewer_selectedFactors', JSON.stringify(expBarSelectedStudiesObj));
      });
    });

    // Deselect all studies
    $('.deselect_all').click(function(event) {
        event.preventDefault();
      $("input[name*='studies[]']").each(function(index, el) {          
        $(this).prop('checked', false);                  
        var selectedStudy = $(this).val();              
        studies[selectedStudy] = false;        
        sessionStorage.setItem('bar_expression_viewer_selectedFactors', JSON.stringify(expBarSelectedStudiesObj));
      });
    });

    $("input[name='studies[]']").click(function(){   // Store the study in the session if it has been checked        
        var selectedStudy = $(this).val();              
        studies[selectedStudy] = !studies[selectedStudy];        
        sessionStorage.setItem('bar_expression_viewer_selectedFactors', JSON.stringify(expBarSelectedStudiesObj));      
    });    

  } else {

  }
  //*************************************SELECTED STUDIES SESSION STORAGE - END*************************************


  // **********************************Slide Toggle Studies - START**********************************
  $("#select_studies").click(function(){
      $(".glyphicon").toggleClass("glyphicon-chevron-up");
      $(".glyphicon").toggleClass("glyphicon-chevron-down");
      $(".study_title").slideToggle("slow");
      $("input[name='studies[]']").slideToggle("slow");
  });
  // **********************************Slide Toggle Studies - END**********************************


  // Initialsizing of the logos 
  var totalWidth = 0;
  $(".footer img").each(function(){
    totalWidth =  totalWidth + $(this).width();    
  });  
  $(".logo").css("margin-left", ((window.innerWidth - totalWidth)/8)-10 );
  $(".logo").css("margin-right", ((window.innerWidth - totalWidth)/8)-10 );

  // Resizing the logos dynamically 
  var resizeLogoTimer;
  $(window).on('resize', function(e){      
    clearTimeout(resizeLogoTimer);  // Making sure that the reload doesn't happen if the window is resized within 1.5 seconds
    resizeLogoTimer = setTimeout(function(){      
      $(".logo").css("margin-left", ((window.innerWidth - totalWidth)/8)-10 );
      $(".logo").css("margin-right", ((window.innerWidth - totalWidth)/8)-10 );
    }, 1500);
  });  
  

});

$(document).ready(ready);
$(document).on('page:load', ready);
