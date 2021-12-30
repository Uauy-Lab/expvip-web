//var jQuery = require('jquery');
var science = require('science');
var colorbrewer = require('colorbrewer');
require('string.prototype.startswith');
//  require("./expressionValues")
import ExpressionValues from "./expressionValues"
 class ExpressionData{
	constructor(data, options) {
		for (var attrname in data) {
			if (attrname == 'values'){
				this[attrname] = this._sortGeneOrder(attrname, data[attrname]);
			} else {
				this[attrname] = data[attrname];
			}
		}	
	
		this.opt = options;
		this.sortOrder = [];
	}

	getExpressionValueTypes(){
		var keys = Object.keys(this.values);
		if(keys.length == 0){
			return [];
		}
		var firstVals = this.values[keys[0]];
		return Object.keys(firstVals);
	}

	mean(data){
		
		var values = Object.keys(data).map(function(val) {
			return data[val].value;
		});

		values = values.sort();
		var toRemove = values.length * 0.1;
		values.splice(0, toRemove);
		values.splice(-1 * toRemove);
		return science.stats.mean(values);
	}

	log2(val){
		var newVal = val;
		if(newVal < 1){
			newVal = 0;
		}else{
			newVal = Math.log2(newVal); 
		}
		return newVal;
	};

	calculateLog2(){
		
		for(let g in this.renderedData){
			for(let v in this.renderedData[g]){
				var toTransform = this.renderedData[g][v];
				toTransform.stdev = this.log2(toTransform.stdev );
				toTransform.value = this.log2(toTransform.value );
				for(let d in toTransform.data){
					toTransform.data[d] = this.log2(toTransform.data[d]);
				}
			}
		}
	};

	setAvailableFactors(){
		var groups = this.factorOrder;
		var fo = this.factorOrder;
		var sf = this.selectedFactors;
		var optFO = this.opt.renderedOrder;
		var optSF = this.opt.selectedFactors;

		if( typeof optFO !== 'undefined'){
			fo = this.opt.renderedOrder;
		}

		if(typeof optSF !== 'undefined' ){
			sf = this.opt.selectedFactors;
		}

		var numberOfElements = 0;
		if(typeof this.renderedOrder !== 'undefined' ){
			numberOfElements = Object.keys(this.renderedOrder).length;
		}

		if(numberOfElements === 0){
			this.renderedOrder = jQuery.extend(true, {}, fo);
		}

		this.selectedFactors = jQuery.extend(true, {},  sf);
		var factorOrder = this.defaultFactorOrder;

		this.factors = new Map();
		for (var f in factorOrder) {
			var g = factorOrder[f];
			for(var k in groups[g]){
				if(! this.factors.has(g)){
					this.factors.set(g, new Set());
				}
				var currentSet = this.factors.get(g);
				currentSet.add(k);
			}  
		}
	};



	prepareColorsForFactors(){//TODO: this should go somewher in the rendering, not in the data. 
	//this.factorColors = Map.new();
	this.totalColors = 8;
	var self = this;
	var colors = [
	colorbrewer.Pastel2[this.totalColors],
	colorbrewer.Accent[this.totalColors],
	colorbrewer.Dark2[this.totalColors],
	colorbrewer.Set1[this.totalColors],
	colorbrewer.Set2[this.totalColors],
	colorbrewer.Paired[this.totalColors],
	colorbrewer.Pastel1[this.totalColors], 
	colorbrewer.Set3[this.totalColors]
	];
	this.factorColors= new Map();  
	var i = 0;  
	this.factors.forEach(function(value, key, map){
		var color = new Map();
		var index =  i % self.totalColors ;
		var currentColorSet = colors[index];
		var j = 0;   
		value.forEach(function(name){
			color[name] = currentColorSet[j++ % self.totalColors ];
		});
		i ++ ; 
		self.factorColors[key] = color;
	});
	return self.factorColors;
	};


	isFiltered(group){
		var ret = true;
		for(var f in group.factors){
			if(this.selectedFactors[f]){
				ret &= this.selectedFactors[f][group.factors[f]];   
			}else{
				throw new Error('The factor ' + f + ' is not available (' + this.selectedFactors.keys + ')');
			}

		}
		return !ret;
	};

	getSortedKeys(factor) {
		var i = this.defaultFactorOrder[factor];
		var obj = this.renderedOrder[i];
		var keys = []; 
		for(var key in obj) {
			keys.push(key);
		}
		return keys.sort(function(a,b){return obj[a] - obj[b];});
	};


	/*
	The only parameter, sortOrder, is an array of the factors that will be used to sort. 
	*/
	sortRenderedGroups(){
		var i;
		if(this.renderedData.length == 0){
			return;
		}
		var sortable = this.renderedData[0].slice();
		var sortOrder =  this.sortOrder;
		var factorOrder= this.renderedOrder; 
		var sorted = sortable.sort(function(a, b){
			for(i in sortOrder){
				var o = sortOrder[i];
				if(factorOrder[o][a.factors[o]] > factorOrder[o][b.factors[o]]) {
					return 1;
				}
				if (factorOrder[o][a.factors[o]] < factorOrder[o][b.factors[o]]) {
					return -1;
				}
			}
			return a.id > b.id  ? 1 : -1;
		});

		for ( i = 0; i < sorted.length; i++) {
			sorted[i].renderIndex = i;
		}

		for(i = 0; i < this.renderedData.length; i++){
			for (var j = 0; j < sorted.length; j++) { 
				var obj = this.renderedData[i][sorted[j].id];
				obj.renderIndex = sorted[j].renderIndex;
			}
		}
	};


	hasExpressionValue(property){
		for(var gene in this.values){
			if(typeof this.values[gene][property] === 'undefined'){
				return false;
			}else{
				return true;
			}
		}
	}

	getDefaultProperty(){
		for(var gene in this.values){
			var vals = this.values[gene];
			for(var v in vals){
				return v;
			}
		}
	}


	//WARN: This method sets "this.renderedData" to the result of this call. 
	//This means that the function is not stateles, but the object is the container
	//For the data. It could be possible to make it "reentrant"
	getGroupedData(property, groupBy){
		var dataArray = [];
		for(var gene in this.values){
			if(!this.opt.showHomoeologues && 
				( 	
					gene !== this.gene &&  
					gene !==  this.compare 
					) 
				)
			{
				continue;
			}
			var i = 0;
			var innerArray;
			if(groupBy === 'ungrouped'){
				innerArray = []; 
				var data = this.values[gene][property];
				for(var o in data) {  
					var oldObject = data[o];
					var newObject = this._prepareSingleObject(i, oldObject);
					newObject.gene = gene;
					var filtered = this.isFiltered(newObject);
					if (! filtered){
						innerArray.push(newObject);
						i++;
					}

				}
				dataArray.push(innerArray);
			}else if(groupBy === 'groups'){
				innerArray = this._fillGroupByExperiment(i++, gene, property);
				dataArray.push(innerArray);
			}else if(groupBy.constructor === Array){
				//This is grouping by factors.  
				innerArray = this._fillGroupByFactor(i++, gene, property, groupBy);
				dataArray.push(innerArray);
			}else{
				console.log('Not yet implemented');
			}
		}
		this.addMissingFactors(dataArray);
		if(this.renderedData && this.renderedData.length > 0){ 
			this.setRenderIndexes(dataArray,this.renderedData);
		}
		this.renderedData = dataArray;
		if(this.isLog()){
			this.calculateLog2();
		}
		this.calculateMinMax();
		return dataArray;
	};

	calculateStats(newObject){
		var v = science.stats.mean(newObject.data);
		var stdev = Math.sqrt(science.stats.variance(newObject.data));
		newObject.value = v;
		newObject.stdev = stdev;
		

	};

	isLog(){
		return  this.opt.calculateLog;
	};

	calculateMinMax(){
		var max = -Infinity;
		var min = Infinity;
		var isLog = this.isLog();
		
		for(var i in this.renderedData){
			for(var j in this.renderedData[i]){
				var curr =this.renderedData[i][j]
				var val = curr.value ;
				if(!isLog){
					val += curr.stdev;
				} 
				if(val > max) max = val ;
				if(val < min) min = val ;
			}
		}
		//if(isLog){
		min = 0;
		//}
		
		this.max = max;
		this.min = min;
		//this.min = -1;
		//this.max = 1;
	}

	_prepareSingleObject(index, oldObject){
		var newObject = JSON.parse(JSON.stringify(oldObject));

		newObject.renderIndex = index;
		newObject.id = index;
		newObject.name = this.experiments[newObject.experiment].name;
		newObject.data = []; 
		newObject.data.push(oldObject.value); 
		newObject.value = oldObject.value;
		newObject.stdev = 0;
		var group = this.experiments[newObject.experiment].group;
		newObject.factors = this.groups[group].factors;
		return newObject;
	};

	_prepareGroupedByExperiment(index, group){
		var newObject= {};
		newObject.renderIndex = index;
		newObject.id = index;
		newObject.name = this.data.groups[group].description;
		newObject.data = [];
		newObject.factors = this.data.groups[group].factors;
		newObject.value = 0;
		newObject.stdev = 0.0;
		return newObject;
	};

	_prepareGroupedByFactor(index, description){
		var newObject= {};
		newObject.renderIndex = index;
		newObject.id = index;
		newObject.name = description;
		newObject.data = [];
		newObject.factors = {};
		newObject.value = 0;
		newObject.stdev = 0.0;
		return newObject;
	};


	_fillGroupByExperiment(index, gene, property){
		var groups ={};
		var innerArray = [];
		var data = this.values[gene][property];
		var g = this.groups;
		var e = this.experiments;
		var o;
		var filtered;
		var i = index;
		for(o in g){  
			var newObject = this._prepareGroupedByExperiment(i++,o);
			newObject.gene = gene;
			groups[o] = newObject;
		}
		for(o in e){
			groups[e[o].group].data.push(data[o].value);
		}
		i = index;
		for(o in groups){
			var newObject = groups[o];
			newObject.gene = gene;
			this.calculateStats(newObject);
			if(!this.isFiltered(newObject)){
				newObject.renderIndex = i;
				newObject.id = i++;
				innerArray.push(newObject);
			}

		}
		return innerArray;
	};

	_fillGroupByFactor(index, gene, property, groupBy){
		var groups ={};
		var innerArray = [];
		var data = this.values[gene][property];
		var g = this.groups;
		var e = this.experiments;
		var names = [];
		var o;
		var i = index;

		for(o in g){  
			var description = this.getGroupFactorDescription(g[o], groupBy);
			var longDescription = this.getGroupFactorLongDescription(g[o], groupBy);
			if(names.indexOf(description) === -1){
				var newObject = this._prepareGroupedByFactor(i++, description);
				newObject.gene = gene;
				newObject.longDescription = longDescription;
				var factorValues = this.getGroupFactor(g[o], groupBy);
				newObject.factors = factorValues;
				groups[description] = newObject;
				names.push(description);
			}
		}
		i = index;
		for(o in e){
			if(typeof data[o] === 'undefined' ){
				continue; //This is for the cases when the data is set up but not defined
			}

			var group = g[e[data[o].experiment].group];

			if(!this.isFiltered(group)){
				var description = this.getGroupFactorDescription(g[e[o].group], groupBy);
				groups[description].data.push(data[o].value);
			}
		}
		for(o in groups){
			var newObject = groups[o];
			if( newObject.data.length === 0){
				continue;
			}
			this.calculateStats(newObject);
			if(!this.isFiltered(newObject)){
				newObject.renderIndex = i;
				newObject.id = i++;
				innerArray.push(newObject);
			}
		}
		return innerArray;
	};

	addNames(o){
		var factors = o.factors;
		var factorNames = this.longFactorName;
		var numOfFactors = factors.length;
		var groupBy = []; //TODO: change this to something like factors.keys
		for(var i in factors){
			groupBy.push(i);

		}
		o.name = this.getGroupFactorDescription(o, groupBy);
		o.longDescription = this.getGroupFactorLongDescription(o, groupBy);
	};

	getGroupFactorDescription(o,groupBy){
		var factorArray = [];
		var factorNames = this.longFactorName;
		var numOfFactors = groupBy.length;
		var arrOffset = 0;
		for(var i in groupBy) {
			var grpby = groupBy[i];
			var currFact = factorNames[grpby];
			var currShort =  o.factors[groupBy[i]]; 
			if(typeof currShort === 'undefined' ){
				console.error(groupBy[i] + ' is not present in ' + o.factors );
				console.error(o.factors);
			}
			var currLong = currFact[currShort];
			factorArray[i - arrOffset ] = currLong;
			if(numOfFactors > 4 || currLong.length > 20 ){
				factorArray[i - arrOffset ] = currShort;
			}
		};
		return factorArray.join(', ');
	};

	getGroupFactorLongDescription(o,groupBy){
		var factorArray = [];
		var factorNames = this.longFactorName;
		//console.log(factorNames);

		var numOfFactors = groupBy.length;
		for(var i in groupBy) {
			var grpby = groupBy[i];
			var currFact = factorNames[grpby];
			var currShort =  o.factors[groupBy[i]]; 
			var currLong = currFact[currShort];
			factorArray[i] = currLong;

		}
		return factorArray.join(', ');
	};


	getGroupFactor(o,groupBy){
		var factorArray = {};
		for (var i in groupBy) {
			factorArray[groupBy[i]] = o.factors[groupBy[i]];
		}
		return factorArray;
	};


	//To keep the indeces we reiterate and set them
	setRenderIndexes(to, from){
		for(var i in to){
			var gene=from[i];
			for(var j in gene){
				to[i][j].renderIndex = from[0][j].renderIndex; //we only use the first gene
			}
		}
	};

	_equals(factorA, factorB){
		for(let a in factorA){		
			if(factorA[a] != factorB[a]){
				return false
			}
		}
		//We test in both sides, to make sure to compare all the 
		//possible entries in both objects. 
		for(let a in factorB){
			if(factorA[a] != factorB[a]){
				return false
			}
		}
		return true;
	};

	_arrayContains(array, object){
		for(let i in array){
			if(this._equals(array[i], object)){
				return i;
			}
		}
		return -1;
	};

	addMissingFactors(dataArray){
		//console.log(dataArray);
		var allFactors = [];
		for( var i in dataArray){
			var gene = dataArray[i];
			for(var j in gene){
				var factors = dataArray[i][j].factors
				if(this._arrayContains(allFactors, factors) == -1){
					allFactors.push(factors);
				}
			}
		}
		//console.log(allFactors);
		var fullDataArray = []
		for(var i in dataArray){
			var gene = dataArray[i];
			var localFactors = [];
			var tmpDataArray = [];
			var localDataArray = [];
			for(var j in gene){
				localFactors.push(dataArray[i][j].factors);
				tmpDataArray.push(dataArray[i][j]);
			}
			for(var j in allFactors){
				var localObject = this._arrayContains(localFactors, allFactors[j])
				j =   parseInt(j);
				if(localObject >= 0){
					localDataArray.push(tmpDataArray[localObject]);
					//console.log(tmpDataArray[localObject]);
				}else{
					var obj = this._prepareGroupedByFactor(j, "");
					obj.gene = gene[0].gene;
					obj.factors = allFactors[j];
					localDataArray.push( obj);
				}
				//localDataArray[j].id = j;
				//localDataArray[j].renderIndexs = j;
			}
			for(var j in localDataArray){
				j = parseInt(j);
				//console.log(j);
				localDataArray[j].id = j;
				localDataArray[j].renderIndex = j;
				this.addNames(localDataArray[j]);
				

				//console.log(localDataArray[j]);
			}
			//console.log(localDataArray);
			fullDataArray.push(localDataArray);

		}
		for(var j in fullDataArray){
			//console.log(j);
			dataArray[j] = fullDataArray[j];
		}
		//console.log(dataArray);
		//console.log(fullDataArray);
		

	};

	addSortPriority(factor, end){
		end = typeof end !== 'undefined' ? end : true;
		this.removeSortPriority(factor);
		if(end === true){
			this.sortOrder.push(factor);
		}else{
			this.sortOrder.unshift(factor);
		}

	};

	removeSortPriority(factor){
		if(typeof this.sortOrder === 'undefined' || this.sortOrder === null){
			this.sortOrder = [];
		}
		var index = this.sortOrder.indexOf(factor);
		if (index > -1) {
			this.sortOrder.splice(index, 1);
		}
	};

	_sortGeneOrder (key, value){ //TODO: This method shouldn't be needed. 
		var geneOrder = {};
		var gene;
		if(typeof this.tern !== 'undefined' && !$.isEmptyObject(this.tern)){
			for (var i = 0; i < Object.keys(this.tooltip_order).length; i++){
				gene = this.tern[this.tooltip_order[i]];
				if(typeof value[gene] !== 'undefined'){
					geneOrder[gene] = value[gene];
				}
			}
			return geneOrder;
		} else {
			return value;	
		}
	}

	get hasTern(){
		return "tern" in this && Object.keys(this.tern).length === 3;
	}

	get hasHomologues(){
		return "homologues" in this && this.homologues.length > 0
	}

	// get values(){
	// 	if(this.#values != null){
	// 		return this.#values;
	// 	}
	// 	console.log("We will load them")
	// 	this.#values = new Map();
	// 	Object.keys(this.paths).forEach(k => {
	// 		this.#values.set(k, this.#expressionValues.values();
	// 	})
	// 	console.log("Loaded");
	// 	console.log(this.#values);
	// 	return this.#values;
	// 	//TODO: This is an eager load. it may be better to find a way to make this lazy, but values is very tightly integrated to the object
	// 	// throw("We need to fix this!");
	// }
}


// module.exports.ExpressionData = ExpressionData;
export default ExpressionData;