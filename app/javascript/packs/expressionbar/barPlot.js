var jQuery = require('jquery');
var science = require('science');
var colorbrewer = require('colorbrewer');
var d3 = require('d3');
require('string.prototype.startswith');

require('jquery-ui');
var exts = require('./d3Extensions.js');


class BarPlot {
	constructor(parent) {
		this.parent = parent;
		this.opt = parent.opt;
	}
	renderScales(i) {
		var xAxis;
		var barWidth = this.calculateBarWidth();
		if (((100 * barWidth) / this.opt.width) < 35) {
			xAxis = d3.axisBottom(axisScale).ticks(3);
		} else {
			xAxis = d3.axisBottom(axisScale).ticks(5);
		}

		var axisScale = this.ScaleRangeX();
		//Create the Axis  
		xAxis = d3.axisBottom(axisScale).ticks(5);
		//Create an SVG group Element for the Axis elements and call the xAxis function
		var xAxisGroup = this.parent.svgFootContainer
			.append('g').call(xAxis)
			.attr('class', 'x axis')
			.attr('font-size', (this.parent.opt.fontSize / 1.4));

		var blockWidth = (this.parent.opt.width - this.parent.opt.labelWidth) / this.parent.totalRenderedGenes;
		var gXOffset = (blockWidth * i) + this.parent.opt.labelWidth;

		xAxisGroup.attr('transform', 'translate(' + gXOffset + ',0)');

	}
	renderGlobalScale() {
		this.parent.svgFootContainer.attr('height', 20);
		$(`#${this.parent.chartSVGidFoot}`).css('display', 'block');
		this._responseToScroll();

		return;
	}
	calculateBarWidth() {
		var availableWidth = this.opt.width - this.opt.labelWidth;
		var widthPerBar = (availableWidth / this.parent.totalRenderedGenes) - 10; // 10 px of border. maybe dynamic?
		return widthPerBar;
	}
	rangeX() {
		var barWidth = this.calculateBarWidth();
		// barWidth /= 2;  // This is divided to by 2 to allow the lines to be present in the chart
		var x = d3.scaleLinear().range([0, barWidth]);
		x.domain([this.parent.data.min, this.parent.maxInData()]);
		return x;
	}
	ScaleRangeX() {
		var barWidth = this.calculateBarWidth();
		var x = d3.scaleLinear().range([0, barWidth]);
		x.domain([this.parent.data.min, this.parent.maxInData()]);
		return x;
	}
	renderGeneBar(i) {
		var parent = this.parent;
		var data = this.parent.data.renderedData;
		var dat = data[i];
		var barHeight = this.opt.barHeight;
		var labelWidth = this.opt.labelWidth;
		var x = this.rangeX();
		var sc = parent.opt.sc;
		var blockWidth = (parent.opt.width - parent.opt.labelWidth) / parent.totalRenderedGenes;
		var gXOffset = (blockWidth * i) + labelWidth;
		var self = this;

		var bar = parent.barGroup.append('g');
		bar.attr('transform', 'translate(' + gXOffset + ',' + barHeight + ')');
		var gene = '';

		for (var j in dat) {
			var d = dat[j];
			var y = (barHeight * d.renderIndex);
			var rect = bar.append('rect')
				.attr('y', y)
				.attr('height', barHeight - 2)
				.attr('fill', 'white')
				.attr('width', x(0))
				.on('mouseenter', function (event, da) {
					var pos = d3.select(this).position(this);
					var index = ((pos.top) / parent.opt.barHeight) - 1;
					var tooltip = parent.opt.renderProperty + ': ' +
						exts.numberWithCommas(da.value) + '\nsem: ' + exts.numberWithCommas(da.stdev);
					parent.showTooltip(tooltip, this, self.parent.tooltip, self.parent.tooltipBox, false);
					parent.showHighlightedFactors(da, this);
				}
				)
				.on('mouseleave', function () {
					parent.hideTooltip();
					parent.hideHighlightedFactors();
				});

			rect.data([d]); //Bind the data to the rect
			bar.append('line').attr('x1', 0)
				.attr('y1', y + (barHeight / 2))
				.attr('x2', 0)
				.attr('y2', y + (barHeight / 2))
				.attr('stroke-width', 1)
				.attr('stroke', 'black');
		};

	}
	refreshBar(gene, i) {
		var data = this.parent.data.renderedData;
		var dat = data[i];
		var x = this.rangeX();
		var sc = this.opt.sc;
		var colorFactor = this.opt.colorFactor;
		var self = this;
		var colors = null;
		var barHeight = this.opt.barHeight;
		var headerOffset = 0;

		if (!this.parent.isFactorPresent(colorFactor)) {
			colorFactor = this.parent.getDefaultColour();
		}

		var getY = function (d, j) {
			return (barHeight * dat[j].renderIndex);
		};

		if (colorFactor != 'renderGroup') {
			colors = this.parent.factorColors[colorFactor];
		}

		//Refresh the bar sizes and move them if they where sorted
		var bar = this.parent.barGroup.selectAll('g').filter(function (d, j) { return j == i; });
		rects = bar.selectAll('rect').transition()
			.duration(1000)
			//.ease("cubic-in-out")
			.attr('width', function (d, j) {
				var val = dat[j].value;
				if (isNaN(val)) {
					val = 0;
				}
				return x(val);
			})
			.attr('fill', function (d, j) {
				//var ret = sc(dat[j].id%20);
				var ret = "#222222";
				if (colorFactor != 'renderGroup') {
					// console.log(dat[j]);
					// console.log(dat[j].factors[colorFactor]);
					ret = colors[dat[j].factors[colorFactor]];
				}
				return ret;
			})
			.attr('y', getY)
			.each(function (r, j) {
				var d = dat[j];
				var rect = d3.select(this);
				rect.data([d]);
			});

		var lines = bar.selectAll('line')
			.transition()
			.duration(1000)
			//.ease("cubic-in-out")
			// .attr('x1', gXOffset)
			.attr('y1', function (d, j) { return getY(d, j) + ((barHeight - 2) / 2.0); })
			.attr('y2', function (d, j) { return getY(d, j) + ((barHeight - 2) / 2.0); })
			.attr('x2', function (d, j) {
				var ret = x(dat[j].value + dat[j].stdev);
				if (isNaN(ret)) {
					ret = 0;
				}
				return ret;
			})
			.attr('x1', function (d, j) {
				var left = dat[j].value - dat[j].stdev;
				if (isNaN(left)) {
					left = 0;
				}
				if (left < 0) {
					left = 0;
				}
				return x(left);
			});
	}
	refreshScale() {
		var axisScale = this.parent.x;
		var xAxis;

		var barWidth = this.calculateBarWidth();
		if (((100 * barWidth) / this.opt.width) < 35) {
			xAxis = d3.axisBottom(axisScale).ticks(3);
		} else {
			xAxis = d3.axisBottom(axisScale).ticks(5);
		}

		var toUpdate = this.parent
			.svgFootContainer.selectAll("g.x.axis");

		toUpdate.transition()
			.duration(1000)
			.call(xAxis);
	}
	showHighithRow() {
		var self = this;
		if (typeof self.parent.selectionBox !== 'undefined') {
			self.parent.selectionBox.attr('visibility', 'visible');
		}
	}
	hideHidelightRow() {
		var self = this;
		if (typeof self.parent.selectionBox !== 'undefined') {
			self.parent.selectionBox.attr('visibility', 'hidden');
			self.parent.selectionBoxGene.attr('visibility', 'hidden');
			self.parent.selectionBoxTitles.attr('display', 'none');
		}
	}
	_responseToScroll() {
		var plotContainer = this.parent.plotContainer;
		var sortDiv = this.parent.sortDivId;
		var chartSVGidHead = this.parent.chartSVGidHead;
		var chartSVGidFoot = this.parent.chartSVGidFoot;
		var lastScrollLeft = 0;


		$(`#${plotContainer}`).on("scroll", function () {

			// Amount of Scroll horizontally
			var documentScrollLeft = $(`#${plotContainer}`).scrollLeft();

			// Move elements horizontally in response
			if (lastScrollLeft != documentScrollLeft) {
				lastScrollLeft = documentScrollLeft;
				$(`#${chartSVGidHead}`).css('position', 'relative');
				$(`#${chartSVGidHead}`).css('left', -lastScrollLeft);
				$(`#${chartSVGidFoot}`).css('position', 'relative');
				$(`#${chartSVGidFoot}`).css('left', -lastScrollLeft);
				$(`#${sortDiv}`).css('left', -lastScrollLeft);
			}

		});

	}
}

 module.exports.BarPlot = BarPlot;