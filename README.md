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