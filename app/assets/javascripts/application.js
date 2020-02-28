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

function setNavbarInputPlaceholder() {
  
  $('#gene-search-input').attr("placeholder", $('#example1').html());

}

function activateCurrentLink() {
  
  $('a[href="' + this.location.pathname + '"]').parent().addClass('active');

}

function autocompleteGene() {
  

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

}

function updateExample() {
  
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
        $('#gene-search-input').attr("placeholder", response.search.gene);
        $('#example1').html(response.search.gene); //for genes
        $('#example2').html(response.compare.gene ); 
        $('#example3').html(response.search.name);        // for transcripts
        $('#example4').html(response.compare.name );                     
        $("select[name*='gene_set_selector']").val(geneID)
      },
      error: function(){
        alert ("There was a problem with selecting the gene set");
      }
    });    
  });  

}

function hideAlert() {
  
  $(".alert").on("click", function(event) { 
    $(this).hide();
  });

}

function openStudies(){

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

  $( "#studies_button" ).click(function() {
      $( "#about_studies" ).dialog( "open" );
  });

}

function addCrossToCloseButton(){

  $(".ui-dialog-titlebar-close").html('X');

}

function openCitation(){

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

  $( "#cite_button" ).click(function() {
    $( "#about" ).dialog( "open" );
  });

}

function selectAllStudies(){

  $('.select_all').click(function(event) {

    event.preventDefault();
    $("input[name*='studies[]']").each(function(index, el) {          
      $(this).prop('checked', true);                  
    });
  });

}

function deselectAllStudies(){

  $('.deselect_all').click(function(event) {

    event.preventDefault();
    $("input[name*='studies[]']").each(function(index, el) {          
      $(this).prop('checked', false);                  
    });
  });

}

function populateHeatmapExamples(){

  $(`.heatmap_example`).click(function(event) {
    event.preventDefault();
    var heatmapGeneExamples = '';

    // AJAX to get heatmap gene examples
    $.ajax({
      url: '/genes/examples',
      type: 'GET',
      dataType: 'json',
      data: {},
    })
    .done(function(response) {          
      //TODO complete this with the example[:heatmap]
      
      for (var key in response.heatmap) {                  
        var obj = response.heatmap[key];        
        heatmapGeneExamples += `${obj}\n`;           
      }      
      $(`#genes_heatmap`).html(heatmapGeneExamples);
    })
    .fail(function() {
      alert("There was an error while trying to populate the textarea");
    });
    
  });

}

function sequenceserverModification(){

  var search_right = $('#search_right');
  var search_left = $('#search_left');
  var introblurb = $('#introblurb');
   $('#sequenceserver').load(function(){    

    var parent = $(this).contents();
    var node = $(this).contents().find('body').find('.navbar');
    var self = $(this);
    node.html('<h4>BLAST Scaffold</h4>');
    $(this).contents().find('#footer').html('');                  

    // Changing the checkbox input under the textarea to a radio button     
    var gemeSetNames = '';
    var lableName = '';
    $(this).contents().find('#blast').find('.checkbox').find('input').each(function(index, el) {
      // Getting the gene set names
      gemeSetNames = $(this).parent().text();
      lableName = $.trim(gemeSetNames).replace(/\s+/g, '');

      // Adding a class(gene set name) to the list item 
      $(this).parents('li').addClass(lableName);
      
      $(this).attr('type', 'radio');
      $(this).addClass('gene_set');
      $(this).prop('checked', false);
    }); 

    // Reordering the gene set ordering in the blast    
    var xone = $(this).contents().find('#blast').find('[class*="IWGSC2.26"]');
    var yone = $(this).contents().find('#blast').find('[class*="TGACv1"]');
    $(yone).insertAfter(xone);


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

      // AJAX call to save the selected studies in the session       
      var selectedStudies = [];      
      $("input[name*='studies[]']").each(function(index, el) {          
        if($(this).attr('checked')){          
          selectedStudies.push($(this).val());
        }        
      });      
      var selectedStudiesObj = JSON.stringify(selectedStudies);;
      $.ajax({
        url: '/genes/set_studies_session',
        type: 'GET',
        dataType: 'JSON',        
        data: {studies:selectedStudiesObj}
      })
      .done(function() {
        
      })
      .fail(function() {
        console.log("error while storing the selected studies in the backend session");
      });
      

      search_right.width('100%')
      self.width('100%');
      self.height('950px');
      search_left.hide();
      introblurb.hide();             

      // Remove the download links
      setTimeout(function(){
        var dooo = $('#sequenceserver').contents().find('#result').children().children().eq(1).children().hide();        
      }, 20000);
      

      // Adding a new column to the results table (with a time delay to let the content to be generated first and then changed)  
      $(document).ready(function($) {
        setTimeout(function(){
          console.log("inside timeout")
          // Adding the header of the column
          $('#sequenceserver').contents().find('thead').eq(0).find('th').eq(1).after('<th class="text-left">Expression</th><th class="text-left"></th>')
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
            var link = "genes/forward?submit=Search&gene=" + geneName + "&gene_set=" + geneSet + "&search_by=";
            var secondColResTable = $(this).find('td').eq(1);            
            secondColResTable.after("<td> <a href='" + link  + "gene' target=\"_top\">gene</a></td><td>  <a href='" + link  + "transcript' target=\"_top\">transcript</a> </td>");            
          });          
        }, 20000);  //RHRG: This timout is a bit arbitrary. As it is now, it doesn't show the table first. We need to find a betteer trigger.       
      });

    });
  });

}

function selectedStudiesSession(){

  if(sessionStorage.bar_expression_viewer_selectedFactors){    // If bar_expression_viewer_selectedFactors exists        
    var expBarSelectedStudies = sessionStorage.bar_expression_viewer_selectedFactors;
    var expBarSelectedStudiesObj = JSON.parse(expBarSelectedStudies);
    var studies = expBarSelectedStudiesObj.study;    

    // Ticking the study checkboxes based on their session value
    for (var key in studies) {    
      if (studies.hasOwnProperty(key)) {        
        if(studies[key]){          
          $("[value='" + key + "']").prop('checked', true);
        } else {
          $("[value='" + key + "']").prop('checked', false);
        }
      }
    }

    // Select all studies clicked
    $('.select_all').click(function(event) {
      event.preventDefault();
      $("input[name*='studies[]']").each(function(index, el) {          
        $(this).prop('checked', true);                  
        var selectedStudy = $(this).val();              
        studies[selectedStudy] = true;        
        sessionStorage.setItem('bar_expression_viewer_selectedFactors', JSON.stringify(expBarSelectedStudiesObj));
      });
    });

    // Deselect all studies clicked
    $('.deselect_all').click(function(event) {
        event.preventDefault();
      $("input[name*='studies[]']").each(function(index, el) {          
        $(this).prop('checked', false);                  
        var selectedStudy = $(this).val();              
        studies[selectedStudy] = false;        
        sessionStorage.setItem('bar_expression_viewer_selectedFactors', JSON.stringify(expBarSelectedStudiesObj));
      });
    });

    // Store the study in the session if the checkbox for it has been checked        
    $("input[name='studies[]']").click(function(){   
        var selectedStudy = $(this).val();              
        studies[selectedStudy] = !studies[selectedStudy];        
        sessionStorage.setItem('bar_expression_viewer_selectedFactors', JSON.stringify(expBarSelectedStudiesObj));      
    });    

  }

}

function toggleStudies(){
  $("#select_studies").click(function(){
    $(".glyphicon").toggleClass("glyphicon-chevron-up");
    $(".glyphicon").toggleClass("glyphicon-chevron-down");
    $(".study_title").slideToggle("slow");
    $("input[name='studies[]']").slideToggle("slow");
  });
}

function logoMargin(){
  setTimeout(function(){
    var totalWidth = 0;
    $(".footer img").each(function(){
      totalWidth =  totalWidth + $(this).width();    
    }); 
    $(".logo").css("margin-left", ((window.innerWidth - totalWidth)/8)-10 );
    $(".logo").css("margin-right", ((window.innerWidth - totalWidth)/8)-10 );
  }, 200);  
}

function setDocumentHeight(){

  var windowHeight = $(window).height();  
  var navHeight = $('nav').height();
  var footerHeight = 55;
  var contentHeight = 0;
  
  $('body').height(windowHeight);
  contentHeight = windowHeight - (navHeight + footerHeight) - 35;   // 35 is the sum of margins and paddings form top and bottom 
  $('#content').height(contentHeight);

}

function spaceLogosOnResize(){
  // Resizing the logos dynamically 
  var resizeLogoTimer;
  $(window).on('resize', function(e){      
    clearTimeout(resizeLogoTimer);  // Making sure that the reload doesn't happen if the window is resized within 1.5 seconds
    resizeLogoTimer = setTimeout(function(){      
      setDocumentHeight();
      logoMargin();
    }, 1500);
  });
}


var ready;
ready = (function() {  
  setDocumentHeight();
  autocompleteGene();
  updateExample();
  hideAlert();
  openStudies();    
  openCitation();
  addCrossToCloseButton();
  selectAllStudies();
  deselectAllStudies();  
  populateHeatmapExamples();
  sequenceserverModification();
  selectedStudiesSession();
  toggleStudies();
  logoMargin();
  spaceLogosOnResize()
});

$(document).ready(ready);
$(document).on('page:load', ready);
