# BBEdit Codeless Language Module for `R`

## Introduction

This repo contains a [BBEdit codeless language module](https://www.barebones.com/support/bbedit/plugin_library.html) property list (`R.plist`) file for the R programing language. The purpose of this file is to list all the "keywords" and "function" names in a language for proper syntax highlighting in BBEdit.

First, we must find and list all of the keywords and function names we want highlighted. The `R` script (`make_bbedit_clm_with_my_packages.R`) will do this automatically for all the currently installed `R` packages on your system. All function names exported by each R package get included. Both `function_name` and/or `package_name::function_name` syntax will get highlighted when typed in BBEdit.








## Build a *personalized* codeless language module

* Make sure a version of `R` is available (e.g. `module load R/4.0.0`). All packages you have installed for this version will be examined and all corresponding function names will used for syntax highlighting. 

* On the bash command line, run the `R` script:

	```
	Rscript --vanilla make_bbedit_clm_with_my_packages.R
	```
	An output folder is created in your current working directory, called `build_DATE-TIME`. It contains three files:
		
	1. An `R.plist` BBEdit codeless language module file
	2. An `R` `sessionInfo()` output file
	3. A `my_packages.txt` file listing all `R` packages used to generate the module

* Install the `R.plist` file (see below). This plist file is *personalized* for your current collection of packages and functions.


## Installation

To install a codeless language module, copy `R.plist` to the folder below and restart BBEdit. Any file opened in BBEdit with a `.r` or `.R` suffix should use this language module by default. Filename suffix settings can be configured in the Languages panel of the BBEdit’s preferences. 

```
~/Library/Application Support/BBEdit/Language Modules/
```

If you install new `R` packages and want those new function names to be properly highlighted in BBEdit, repeat the build and install steps above. 
