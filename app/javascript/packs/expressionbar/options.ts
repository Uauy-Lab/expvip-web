import d3 from "d3";
import colorbrewer from "colorbrewer";
import ExpressionBar from "./expressionBar";
import FactorGroup from "./factorGroup";
import ExpressionData from "./dataContainer";

export default class Options{
	target : string;
	fontFamily : string;
	fontColor : string;
	backgroundColor : string;
	selectionFontColor : string;
	selectionBackgroundColor: string;
	width: number;
	height:number
	barHeight : number;
	labelWidth : number;
	renderProperty : string;
	renderGroup : string;
	defaultLog2State : boolean;
	restoreDisplayOptions : boolean;
	highlight : string;
	groupBy : string | Array<string>;
	groupBarWidth : number;
	colorFactor: string;
	headerOffset: number
	showHomoeologues: boolean;
	plot: string;
	fontSize: number;
	tpmThreshold: number;
	sc: any; 
	// defaultGroupBy: string | Array<string>;
	defaultRenderProperty: string;
	calculateLog: boolean;
	showTernaryPlot: boolean;
	#eb: ExpressionBar;

	constructor(eb : ExpressionBar){
		this.target = 'bar_expression_viewer';
		this.fontFamily = 'Andale mono, courier, monospace';
		this.fontColor = 'white';
		this.backgroundColor = 'white';
		this.selectionFontColor = 'black';
		this.selectionBackgroundColor = 'yellow';
		this.width = $(window).width();
		this.height = $(window).height();
		this.barHeight = 17;
		this.labelWidth = ($(window).width() * 0.4);
		this.renderProperty = 'tpm';
		this.renderGroup = 'group';
		this.defaultLog2State = false;
		this.restoreDisplayOptions = true;
		this.highlight = null;
		this.groupBy = 'groups';
		this.groupBarWidth = 18;
		this.colorFactor = 'renderGroup';
		this.headerOffset = 0;
		this.showHomoeologues = false;
		this.plot = 'Bar';
		this.fontSize = 14;
		this.tpmThreshold = 1;
		this.sc = colorbrewer.schemeCategory20;
		// this.defaultGroupBy = this.groupBy;
		this.defaultRenderProperty = this.renderProperty;
		this.calculateLog = this.defaultLog2State;
		this.showTernaryPlot = false;
		this.#eb = eb;
	}

	get defaultGroupBy(){
		let ret = new Array<string>();
		let fgs : Map<string, FactorGroup> = this.#eb.data.factors;
		ret = [...fgs.values()].filter(fg => fg.defaultSelected).map(fg => fg.name);
		return ret;
	}

	restoreUserDefaults(){
		this.groupBy = this.defaultGroupBy;
		this.renderProperty = this.defaultRenderProperty;
		// this.selectedFactors = this.#eb.data.selectedFactors;
		this.calculateLog = this.defaultLog2State;
		// this.storeValue('calculateLog', this.calculateLog);
		this.showTernaryPlot = false;
		this.showHomoeologues = false;
		if (this.plot == 'Ternary') {
			this.plot = 'Bar';
		}
	}

	storeValue(key: string, value: any) {
		var val = JSON.stringify(value);
		sessionStorage.setItem(this.target + "_" + key, val);
	}
	
	removeValue(key: string) {
		sessionStorage.removeItem(this.target + "_" + key);
		this[key] = null;
	}

	retrieveValue(key: string) {
		var val = sessionStorage.getItem(this.target + "_" + key);
		var parsed = null;
		try {
			parsed = JSON.parse(val);
		} catch (err) {
		  	parsed = null;
		}
		return parsed;
	}

	restoreDefaults() {
		this.removeValue('groupBy');
		this.removeValue('renderProperty');
		this.removeValue('sortOrder');
		this.removeValue('renderedOrder');
		this.removeValue('selectedFactors');
		this.removeValue('showHomoeologues');
		this.removeValue('calculateLog');
		this.removeValue('showTernaryPlot');
		let factors : Map<string, FactorGroup> = this.#eb.data.factors;
		[...factors.values()].forEach(fg => fg.restoreDefaults());

	}

	restoreOptions() {
		this.restoreProperty('groupBy');
		this.restoreProperty('renderProperty');
		this.restoreProperty('sortOrder');
		this.restoreProperty('renderedOrder');
		this.restoreProperty('selectedFactors');
		this.restoreProperty('showHomoeologues');
		this.restoreProperty('showTernaryPlot');
		this.restoreProperty('colorFactor');
		this.restoreProperty('calculateLog');
	}

	restoreProperty(key) {
		var stored = this.retrieveValue(key);
		if (stored) {
			this[key] = stored;
		}
	}

	set selectedFactors(sf: object){
		let data: ExpressionData = this.#eb.data;
		let fgs : Map<string, FactorGroup> = data.factors;
		fgs.forEach((fg, group) => fg.factors.forEach(f =>
			f.selected = sf === null? f.defaultSelected :  sf[group] ?  sf[group][f.name] : f.selected
			));
	}

	set sortOrder(so: Array<string>){
		if(so === null){
			this.#eb.data.sortOrder = new Array<string>();
		}
		this.#eb.data.sortOrder = so;
	}

	get selectedFactors(): object{
		let data: ExpressionData = this.#eb.data;
		let ret = {};
		let fgs : Map<string, FactorGroup> = data.factors;
		fgs.forEach((fg, key) => ret[key] = fg.selectedFactors);
		// console.log("Returning selected factors");
		// console.log(ret);
		// console.trace();
		return ret;
	}

	setSelectedFactor(group: string, factor: string, value: boolean){
		let data: ExpressionData = this.#eb.data;
		let fgs : Map<string, FactorGroup> = data.factors;
		fgs.get(group).factors.get(factor).selected = value;
	}
}