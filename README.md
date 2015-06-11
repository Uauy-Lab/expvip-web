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

###Loading values ###

The values are stored in a single long table. This allows to get new values, should we want to.  In order to load the data, the task ```load_data:values``` is provided. The table must contain a column ```target_id``` that has the gene name, as the first field in the fasta file used for the mapping. The rest of the columns most contain a header with the accession of the experiment. Each row represents a value. All the values in the table must be from the same time. For exaple, to load the FPKMs, the following command is used. 

```sh
rake "load_data:values[First run,IWGSC2.26,fpkm,edited_final_output_fpkm.txt]"
```



