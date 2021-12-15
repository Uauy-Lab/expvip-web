var jQuery = require('jquery');
var colorbrewer = require('colorbrewer');
var d3 = require('d3');
var $ = jQuery;
//require('d3-ease');

var exts = require('./d3Extensions.js')
require('string.prototype.startswith');

var HeatMap = function  (parent) {
	this.parent = parent;
	this.data = parent.data;
	this.opt = parent.opt;
}



HeatMap.prototype.calculateBarWidth = function(){  
  var availableWidth = this.opt.width - this.opt.labelWidth;
  var widthPerBar = (availableWidth / this.parent.totalRenderedGenes ); // 10 px of border. maybe dynamic?
  return widthPerBar;
};

HeatMap.prototype.rangeX = function(scaleWidth){

 var x = d3.scaleLinear().range([0, scaleWidth]);
 x.domain([this.parent.data.min,this.parent.data.max]);
 return x;
}

HeatMap.prototype.renderGeneBar = function( i){
  var parent = this.parent;  
  var data = this.parent.data.renderedData;
  var dat = data[i];
  var render_width = this.calculateBarWidth();
  var barHeight = this.opt.barHeight;
  var labelWidth = this.opt.labelWidth;
  //var x = this.rangeX();
  var sc = parent.opt.sc;
  var blockWidth = (parent.opt.width - parent.opt.labelWidth) / parent.totalRenderedGenes;
  var gXOffset = (blockWidth * i) + labelWidth;
  var self = this;

  var bar = parent.barGroup.append('g');
  bar.attr('transform', 'translate(' + gXOffset  + ',' + barHeight + ')');
  var gene = '';

  for(var j in  dat){
    var d = dat[j];
 
    var y = (barHeight * d.renderIndex  ) ;
    var rect = bar.append('rect')
    .attr('y', y)
    .attr('height', barHeight - 2)
    .attr('fill', 'white')
    .attr('width', render_width)
    .on('mouseenter', function(event, da){
      var pos = d3.select(this).position(this);   
      var tooltip =  da.gene + 
      '\n' + parent.opt.renderProperty + ': '+ exts.numberWithCommas(da.value) +
        '\nsem:' + exts.numberWithCommas(da.stdev);      
      parent.showTooltip(tooltip, this, self.parent.tooltip, self.parent.tooltipBox, false);
      parent.showHighlightedFactors(da, this);
    }
    )
    .on('mouseleave', function(){
      parent.hideTooltip();
      parent.hideHighlightedFactors();
    });

      rect.data([d]); //Bind the data to the rect
      
    };
  };

  HeatMap.prototype.domain = function(){
    return [this.parent.data.min, (this.parent.data.max + this.parent.data.min) /2,this.parent.data.max ];
  }

  HeatMap.prototype.rangeColor = function(){
   this.buckets = 9;

   this.colors = colorbrewer.YlGnBu[this.buckets];
   //this.colors = colorbrewer.RdBu[this.buckets];

   this.colors = [this.colors[0],this.colors[4],this.colors[8]]
   var colorScale = d3.scaleLinear()
   .domain( this.domain())
   .range(this.colors);
   return colorScale;

 };

HeatMap.prototype.renderScales = function(i){ 
  return;
}

HeatMap.prototype.setGradient = function(){
  
  var svg = this.parent.svgFootContainer;
  svg.select("#gradient").remove();
  var gradient = svg.append("defs")
  .append("linearGradient")
  .attr("id", "gradient")
  .attr("x1", "0%")
  .attr("y1", "0%")
  .attr("x2", "100%")
  .attr("y2", "0%")
  .attr("spreadMethod", "pad");

  for (var i = 0; i < this.colors.length; i++) {
    var offset = 100 * i/(this.colors.length-1);
    gradient.append('stop')
    .attr('offset',  offset + '%' )
    .attr('stop-color', this.colors[i])
    .attr('stop-opacity', 1);
  };
}

HeatMap.prototype.renderGlobalScale = function(){
  var svg = this.parent.svgFootContainer;
  svg.attr("height", 60);
  var range = this.rangeColor();
  this.scaleWidth = this.parent.getTitleFactorWidth();

  this.setGradient();
 
  this.rectScale = svg.append("rect")
  .attr("width", this.scaleWidth)
  .attr("height", 20)
  .style("fill", "url(#gradient)");

  var axisScale = this.rangeX(this.scaleWidth);
  //var xAxis = d3.svg.axis()
  //.scale(axisScale).ticks(5);

  var xAxis = d3.axisBottom(axisScale).ticks(5); 

  var xAxisGroup = svg.append("g")
  .call(xAxis).attr("class", "x axis").attr('font-size', (this.parent.opt.fontSize/1.4));
  var offset = this.parent.getTitleSetOffset();


  xAxisGroup.attr('transform', 'translate(' + offset + ',20)');
  this.rectScale.attr('transform', 'translate(' + offset + ',0)');
  var labOffset = offset + (this.scaleWidth/2);
  this.scaleUnits = svg.append('text')
  .attr('y',50)
  .attr('x', labOffset);
  this.setScaleText(this.opt.renderProperty)

  this._responseToScroll();

  return;
};

HeatMap.prototype.setScaleText = function(unit){
  var offset = this.parent.getTitleSetOffset();
  var isLog2 = this.parent.opt.calculateLog;

  
  // Add log2 to the legend
  if(isLog2){
    unit = '\nLog\u2082 (' + unit + ')';
  }
 

  this.scaleUnits.text(unit);

  var renderedTextWidth = this.scaleUnits.node().getBBox().width;
  var labOffset = offset + (this.scaleWidth/2) - (renderedTextWidth/2);
  this.scaleUnits
  .transition().duration(1000)//.easeCubicInOut(1000)//.duration(1000).easeCubicInOut()
  .attr('x', labOffset);

  return;
}



HeatMap.prototype.refreshScale = function(){
    var axisScale = this.rangeX(this.scaleWidth);
    //var xAxis = d3.svg.axis().scale(axisScale).ticks(5);
    var xAxis = d3.axisBottom(axisScale).ticks(5);
    var toUpdate = this.parent.svgFootContainer.selectAll("g.x.axis")
    this.setScaleText(this.opt.renderProperty);
    this.setGradient();
    toUpdate.transition()
     .duration(1000)
    // .easeCubicInOut()
     .call(xAxis);

}

 HeatMap.prototype.refreshBar = function(gene, i){
  var data = this.parent.data.renderedData;
  var dat = data[i];
  var cols = this.rangeColor();
  var barHeight = this.opt.barHeight;
  var headerOffset  = 0;


  var getY = function(d,j){
    return (barHeight * dat[j].renderIndex) + headerOffset;   
  };

  var bar = this.parent.barGroup.selectAll('g').
  filter(function (d, j) { return j == i;});

  var rects = bar.selectAll('rect').transition()
  .duration(1000)//.ease("cubic-in-out")
  .attr('fill', function(d,j){
    var val = dat[j].value;
    if(isNaN(val)){
     val = 0;
   }
   return cols(val);
 })
  .attr('y', getY )
  .each(function(r,j){
    var d = dat[j];
    var rect = d3.select(this);
    rect.data([d]); 
  });


}; 



HeatMap.prototype.showHighithRow = function(){
  var self = this;
  if(typeof self.parent.selectionBox !== 'undefined'){    
    self.parent.selectionBox.attr('visibility', 'visible');    
    self.parent.selectionBoxGene.attr('visibility', 'visible');
    self.parent.selectionBoxTitles.attr('display', 'inline');    
  }  
}

HeatMap.prototype.hideHidelightRow = function(){
  var self = this;
  if(typeof self.parent.selectionBox !== 'undefined'){
    self.parent.selectionBox .attr('visibility', 'hidden');
    self.parent.selectionBoxGene.attr('visibility', 'hidden');
    self.parent.selectionBoxTitles.attr('display', 'none');
  }
}

HeatMap.prototype._responseToScroll = function(){
  var plotContainer = this.parent.plotContainer;  
  var sortDiv = this.parent.sortDivId;
  var chartSVGidHead = this.parent.chartSVGidHead;  
  var lastScrollLeft = 0;  
    

  $(`#${plotContainer}`).scroll(function(){   
    
    // Amount of Scroll horizontally
    var documentScrollLeft = $(`#${plotContainer}`).scrollLeft();

    // Move elements horizontally in response
    if (lastScrollLeft != documentScrollLeft){      
      lastScrollLeft = documentScrollLeft;
      $(`#${chartSVGidHead}`).css(`position`, 'relative');
      $(`#${chartSVGidHead}`).css(`left`, -lastScrollLeft);      
      $(`#${sortDiv}`).css(`left`, -lastScrollLeft);
    }

  });
  
}

module.exports.HeatMap = HeatMap;
