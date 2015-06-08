# README #


##Loading data ##

To laod data in the database, a set of rake tasks is provded. 
###Experiment Metadata ###

The first step is to load the experiment meta data. Currently, a tab separated file is the input and it must contain the following collumns with the header named exactly as stated:

* **secondary\_study\_accession**
* **run\_accession**
* **scientific\_name**
* **experiment\_title**
* **study\_title**
* **Variety**
* **Tissue**
* **Age**
* **Stress/disease**
* **Manuscript**
* **Group\_for\_averaging**
* **Group\_number\_for\_averaging**

The rake task is :

```sh
rake load_data:metadata[metadata.txt]
```

### Loading the gene sets ###
Before loading the actual expression, it is necesary to load the gene models. Currently, only the fasta file with the cdna from ensembl is supported. The fasta header should contain the following fields, besides the gene name (first string in the header).

* **cdna**
* **chromosome** or **scaffold** are converted to possition
* **gene** 
* **transcript** 
* **description** a free text, in quotes. Any other field with quotes may fail in the load. 

```sh
rake load_data:ensembl_genes[IWGSC2.26,/Triticum_aestivum.IWGSC2.26.cdna.all.fa]
```