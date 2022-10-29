//var jQuery = require('jquery');
var science = require('science');
var colorbrewer = require('colorbrewer');
require('string.prototype.startswith');
//  require("./expressionValues")
import ExpressionValues from "./expressionValues"
import GroupedValues from "./groupedValues"
import {parseFactors, getGroupFactorDescription, getGroupFactorLongDescription, parseOrthoGroups} from "./factorHelpers"
import FactorGroup from "./factorGroup";
import {getFactorsForGenes, getFactorsForOrthologues, recalculateValues} from "./pangenomeFactorHelper";
import Gene from "./gene"

 export default class ExpressionData{
	/**
	 * @type {Map<string, FactorGroup>}
	 */
	#default_factors;
	/**
	 * @type {Map<string, FactorGroup>}
	 */
	#factors;

	#default_values;

	#values;

	#gene_factors;
	ortholog_groups: Map<string, import("/Users/ramirezr/Documents/public_code/expvip-web/app/javascript/packs/expressionbar/OrthologueGroupSet").default>;
	opt: any;
	sortOrder: any[];
	factorOrder: any;
	selectedFactors: any;
	totalColors: number;
	factorColors: Map<any, any>;
	renderedData: any;
	compare: any;
	gene: any;
	max: number;
	min: number;
	experiments: any;
	groups: any;
	tern: any;
	homologues: any[];

	constructor(data, options) {
		for (var attrname in data) {
			// console.log(attrname);
			if (attrname == 'values'){
				this.#default_values = this._sortGeneOrder(attrname, data[attrname]);
			}else if(attrname == 'factors'){
				this.#default_factors = parseFactors(data[attrname]);
			}else if(attrname == 'ortholog_groups'){
				this.ortholog_groups = parseOrthoGroups(data[attrname]);
			}else {
				this[attrname] = data[attrname];
			}
			// console.log(this[attrname]);
		}
	
		console.log(options);
		this.opt = options;
		this.sortOrder = [];
		this.#gene_factors = new Map();
	}

	get factors(){
		this.#recalculateFactorAndValues( typeof(this.#factors) === "undefined");
		return this.#factors;
	}

	get values(){
		this.#recalculateFactorAndValues(typeof(this.#values) === "undefined");
		return this.#values
	}

	get defaultFactorOrder(){
		let sorted = [...this.factors.values()].sort((a,b) => a.order - b.order)
		console.log(sorted);
		return sorted.map(f => f.name);
	}

	/**
	 * 
	 * @param {boolean} force 
	 * @returns 
	 */
	#recalculateFactorAndValues(force){
		force = false
		if(!force && this.opt.orthologues == this.opt.orthologues_last_status){
		 	return
		}
		console.log("Recalculating factors...");
        console.log(this.opt);
		this.#factors = new Map(this.#default_factors);
		if(this.opt.orthologues ){
			//TODO: We need to fix this to be dynamic. Probably we want to pre-build them
			let orth_group = this.opt.orth_group;
			let og = this.ortholog_groups.get(orth_group);
			let tmp_fact = getFactorsForOrthologues(og)
			tmp_fact.forEach(fg => this.#factors.set(fg.name, fg));
			recalculateValues(this.#default_values, og);
			this.#gene_factors = getFactorsForGenes(og);
			console.log(this.#gene_factors);
		}

		this.#values = this.#default_values;
		
		this.opt.orthologues_last_status = this.opt.orthologues ;
	}

	getExpressionValueTypes(){
		var keys = Object.keys(this.values);
		if(keys.length == 0){
			return [];
		}
		var firstVals = this.values[keys[0]];
		return Object.keys(firstVals);
	}


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

		// if(numberOfElements === 0){
		// 	this.renderedOrder = jQuery.extend(true, {}, fo);
		// }

		this.selectedFactors = jQuery.extend(true, {},  sf);
	};



	prepareColorsForFactors(){//TODO: this should go somewher in the rendering, not in the data. 
	//this.factorColors = Map.new();
	this.totalColors = 9;
	var self = this;
	var sets = 
	[{color: "Pastel2", id: 8}, 
	{color: "Accent",   id: 8}, 
	{color: "Dark2",    id: 8}, 
	{color: "Set1",     id: 9}, 
	{color: "Set2",     id: 8}, 
	{color: "Paired",   id: 12}, 
	{color: "Pastel1",  id: 9},
	{color: "Set3",     id: 12}]
	var colors = sets.map(c => colorbrewer[c.color][c.id])
	console.log(colorbrewer);
	
	this.factorColors= new Map();  
	var i = 0;  
	this.factors.forEach(function(fg, key, map){
		var color = new Map();
		var index =  i % sets.length ;
		var currentColorSet = colors[index];
		let totalColors = currentColorSet.length - 1;
		var j = 0;  
		fg.factors.forEach((factor, name) => {
			color[name] = currentColorSet[j++ % totalColors ]; //We will eventually need to remove this line. 
			factor.color = color[name];
		}) 
		i ++ ; 
		self.factorColors[key] = color;
	});
	return self.factorColors;
	};


	isFiltered(group){
		var ret : boolean = true;
		let selectedFactors = this.opt.selectedFactors;
		for(var f in group.factors){
			if(selectedFactors[f]){
				ret &&= selectedFactors[f][group.factors[f]];   
			}
		}
		return !ret;
	};

	/**
	 * 
	 * @param {string} fact 
	 * @returns {Array<FactorGroup>}
	 */
	getSortedFactors(fact) {
		/**
		 * @type{FactorGroup}
		 */
		let factors = [...this.factors.get(fact)];
		return factors.sort((a,b)=> a.order - b.order);

	};

	/**
	 * @return {Array<FactorGroup>}
	 */
	get sortedFactorGroups(){
		return [...this.factors.values()].sort((a,b) => a.order - b.order);
	}

	get renderedOrder(){
		let ret = {}
		this.sortedFactorGroups.forEach(fg => {
			ret[fg.name] = fg.sortedFactors.map(f => f.name);
		})
		return ret;
	}

	/*
	The only parameter, sortOrder, is an array of the factors that will be used to sort. 
	*/
	sortRenderedGroups(){
		// console.log("Re-sorting");
		var i;
		// console.log(this.renderedData);
		if(this.renderedData.length == 0){
			return;
		}
		// console.log("We enter to the method properlu");
		var sortable = this.renderedData[0].slice();
		// console.log(sortable);
		var sortOrder =  this.sortOrder;
		// console.log(sortOrder);
		var sorted = sortable.sort((a, b) => {
			for(let o of sortOrder){
				let fg = this.factors.get(o);
				let fa = fg.factors.get(a.factors[o]);
				let fb = fg.factors.get(b.factors[o]);
				if(typeof fa === 'undefined' || typeof fb === 'undefined'){
					continue;
				}
				if(fa.order > fb.order) {
					return 1;
				}
				if (fa.order < fb.order) {
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
				// console.log(sorted[j]);
				var obj = this.renderedData[i][sorted[j].id];
				if(!obj){
					continue;
				}
				// console.log(obj);
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

	get displayed_genes(){
		if(this.opt.orthologues){
			/**
			 * @type {OrtholgueGroupSet}
			 */
			return this.ortholog_groups.get(this.opt.orth_group).genes.map(g => g.full_name);
		}
		if(this.compare){
			return [this.gene, this.compare];
		}
		if(this.opt.showHomoeologues){
			return Object.keys(this.values);
		}
		return [this.gene];
	}


	//WARN: This method sets "this.renderedData" to the result of this call. 
	//This means that the function is not stateles, but the object is the container
	//For the data. It could be possible to make it "reentrant"
	getGroupedData(property, groupBy){
		// console.log(groupBy);
		var dataArray = [];
		console.log("Genes to display:");
		console.log(this.displayed_genes);
		for(var gene of this.displayed_genes){
			// console.log(gene);
			// if(!this.opt.showHomoeologues && 
			// 	( 	
			// 		gene !== this.gene &&  
			// 		gene !==  this.compare 
			// 		) 
			// 	)
			// {
			// 	continue;
			// }
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
				innerArray = this.#fillGroupByFactor(i++, gene, property, groupBy);
				if(innerArray.length > 0){
					dataArray.push(innerArray);
				}
			}else{
				console.log('Not yet implemented');
			}
		}
		if(groupBy.includes("Gene")){
			dataArray = [dataArray.flat(2)]
		}

		this.addMissingFactors(dataArray);
		if(this.renderedData && this.renderedData.length > 0){ 
			this.setRenderIndexes(dataArray,this.renderedData);
		}
		this.renderedData = dataArray;
		// this.renderedData.forEach(gene_arr => gene_arr.forEach(group => group.log = this.isLog));
		// if(this.isLog()){

		// 	this.calculateLog2();
		// }
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
		min = 0;
		
		this.max = max;
		this.min = min;
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
			// var newObject = this._prepareGroupedByExperiment(i++,o);
			/** @type {GroupedValues}} */
			var newObject = new GroupedValues(i++, g[o].description);
			newObject.gene = gene;
			newObject.description = newObject.name;
			newObject.longDescription = g[o].description;
			newObject.factors = g[o].factors;
			groups[g[o].name] = newObject;
		}
		for(o in e){
			var values = data[o];
			groups[e[o].name].addValueObject(values);
		}
		i = index;
		for(o in groups){
			var newObject = groups[o];
			newObject.gene = gene;
			newObject.calculateStats();
			if(!this.isFiltered(newObject)){
				newObject.renderIndex = i;
				newObject.id = i++;
				innerArray.push(newObject);
			}

		}
		return innerArray;
	};

	#fillGroupByFactor(index, gene, property, groupBy){
		var groups ={};
		/** @type {[GroupedValues]} */
		var innerArray = [];
		var data = this.values[gene][property];
		var g = this.groups;

		var g_f = this.#gene_factors.get(gene);
		var e = this.experiments;
		var names = [];
		var o;
		var i = index;
		// console.log(g);
		for(o in g){  
			let sample = g[o];
			if(g_f){
				//If we have factors for the gene, we add them here. 
				//TODO: This pis overwriting the original object. May have secondary effects. 
				Object.keys(g_f).forEach(k => sample.factors[k] = g_f[k]);
			}
			var description = this.getGroupFactorDescription(sample, groupBy);
			var longDescription = this.getGroupFactorLongDescription(sample, groupBy);
			if(names.indexOf(description) === -1){
				var newObject = new GroupedValues(i++, description);
				// console.log(`Adding: ${description}`);
				newObject.gene = gene;
				newObject.longDescription = longDescription;
				var factorValues = this.getGroupFactor(sample, groupBy);
				newObject.factors = factorValues;
				groups[description] = newObject;
				names.push(description);
			}
		}
		// console.log(groups);
		i = index;
		for(o in e){
			if( !data  || typeof data[o] === 'undefined' ){
				continue; //This is for the cases when the data is set up but not defined
			}
			var group = g[e[data[o].experiment].group];

			if(!this.isFiltered(group)){
				var description = this.getGroupFactorDescription(g[e[o].group], groupBy);
				groups[description].addValueObject(data[o]);
			}
		}
		for(o in groups){
			var newObject = groups[o];
			if(newObject.isEmpty){
				continue;
			}
			newObject.log = this.isLog();
			innerArray.push(newObject);
		}
		return innerArray;
	};

	addNames(o){
		var factors = o.factors;
		var groupBy = []; //TODO: change this to something like factors.keys
		for(var i in factors){
			groupBy.push(i);

		}
		o.name = this.getGroupFactorDescription(o, groupBy);
		o.longDescription = this.getGroupFactorLongDescription(o, groupBy);
	};

	getGroupFactorDescription(o,groupBy){
		return getGroupFactorDescription(o, groupBy, this.factors)
	};

	getGroupFactorLongDescription(o,groupBy){
		return getGroupFactorLongDescription(o, groupBy, this.factors);
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
		var fullDataArray = []
		for(var i in dataArray){
			var gene = dataArray[i];
			if(gene.length == 0){
				continue;
			}
			var localFactors = [];
			var tmpDataArray = [];
			var localDataArray = [];
			for(var j in gene){
				localFactors.push(dataArray[i][j].factors);
				tmpDataArray.push(dataArray[i][j]);
			}
			for(var j in allFactors){
				var localObject = this._arrayContains(localFactors, allFactors[j])
				var j_int: number =   parseInt(j);
				if(localObject >= 0){
					localDataArray.push(tmpDataArray[localObject]);
				}else{
					var obj = new GroupedValues(j_int, "");
					obj.gene = gene[0].gene;
					obj.factors = allFactors[j];
					localDataArray.push( obj);
				}
			}
			for(var j in localDataArray){
				var j_int: number = parseInt(j);
				localDataArray[j_int].id = j;
				localDataArray[j_int].renderIndex = j_int;
				this.addNames(localDataArray[j]);
			}
			fullDataArray.push(localDataArray);
		}
		for(var j in fullDataArray){
			dataArray[j] = fullDataArray[j];
		}		
	};

	addSortPriority(factor, end){
		console.log("Adding sort priority");
		console.log(factor);
		console.log(this.sortOrder);
		end = typeof end !== 'undefined' ? end : true;
		this.removeSortPriority(factor);
		if(end === true){
			this.sortOrder.push(factor);
		}else{
			this.sortOrder.unshift(factor);
		}
		console.log(this.sortOrder);

	};

	removeSortPriority(factor){
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
	 tooltip_order(tooltip_order: any) {
		 throw new Error("Method not implemented.");
	 }

	get hasTern(){
		return "tern" in this && Object.keys(this.tern).length === 3;
	}

	get hasHomologues(){
		return "homologues" in this && this.homologues.length > 0
	}

	get longFactorName(){
		let ret = {}
		this.factors.forEach((fg, group) => fg.factors.forEach(f => ret[group][f.name] = f.description));
		return ret;
	}

}
